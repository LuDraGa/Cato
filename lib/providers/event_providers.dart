import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import 'core_providers.dart';
import 'tracker_providers.dart';

class CurrentDateController extends StateNotifier<DateTime>
    with WidgetsBindingObserver {
  CurrentDateController() : super(normalizeDate(DateTime.now())) {
    WidgetsBinding.instance.addObserver(this);
    _scheduleRollover();
  }

  Timer? _timer;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  void refresh() {
    state = normalizeDate(DateTime.now());
    _scheduleRollover();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _scheduleRollover() {
    _timer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(nextMidnight.difference(now).inMilliseconds < 1
        ? const Duration(days: 1)
        : nextMidnight.difference(now), refresh);
  }
}

final currentDateProvider =
    StateNotifierProvider<CurrentDateController, DateTime>(
  (ref) => CurrentDateController(),
);

final allEventsProvider = StreamProvider<List<Event>>((ref) {
  return ref.watch(eventRepositoryProvider).watchAll();
});

final todayEventsProvider = StreamProvider<List<Event>>((ref) {
  final date = ref.watch(currentDateProvider);
  return ref.watch(eventRepositoryProvider).watchEventsForDate(date);
});

final trackerEventsForDateProvider =
    FutureProvider.family<List<Event>, ({String trackerUid, DateTime date})>(
  (ref, args) {
    return ref
        .watch(eventRepositoryProvider)
        .getEventsForTrackerAndDate(args.trackerUid, args.date);
  },
);

class TrackerCardState {
  const TrackerCardState({
    required this.tracker,
    required this.events,
    required this.isCompleted,
    required this.scoreLabel,
  });

  final Tracker tracker;
  final List<Event> events;
  final bool isCompleted;
  final String? scoreLabel;

  Event? get primaryEvent => events.isEmpty ? null : events.first;
}

final trackerCardStateProvider = Provider.family<TrackerCardState?, String>(
  (ref, trackerUid) {
    final trackers = ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
    final tracker = trackers.cast<Tracker?>().firstWhere(
          (item) => item?.uid == trackerUid,
          orElse: () => null,
        );
    if (tracker == null) {
      return null;
    }
    final todayEvents = ref.watch(todayEventsProvider).valueOrNull ?? const <Event>[];
    final events = todayEvents
        .where((event) => event.trackerUid == trackerUid)
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
    return TrackerCardState(
      tracker: tracker,
      events: events,
      isCompleted: events.isNotEmpty,
      scoreLabel: _scoreLabelFor(tracker, events),
    );
  },
);

class HomeTrackerItem {
  const HomeTrackerItem({
    required this.tracker,
    required this.events,
    required this.deEmphasized,
    required this.scoreLabel,
  });

  final Tracker tracker;
  final List<Event> events;
  final bool deEmphasized;
  final String? scoreLabel;

  Event? get primaryEvent => events.isEmpty ? null : events.first;
}

class HomeSections {
  const HomeSections({
    required this.pendingActionable,
    required this.pendingSupplemental,
    required this.logged,
  });

  final List<HomeTrackerItem> pendingActionable;
  final List<HomeTrackerItem> pendingSupplemental;
  final List<HomeTrackerItem> logged;
}

final homeSectionsProvider = Provider<HomeSections>((ref) {
  final trackers = ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
  final todayEvents = ref.watch(todayEventsProvider).valueOrNull ?? const <Event>[];
  final domains = ref.watch(domainsByUidProvider);

  final sortedTrackers = [...trackers]
    ..sort((left, right) {
      final leftDomain = domains[left.domainUid]?.sortOrder ?? 0;
      final rightDomain = domains[right.domainUid]?.sortOrder ?? 0;
      final domainCompare = leftDomain.compareTo(rightDomain);
      if (domainCompare != 0) {
        return domainCompare;
      }
      return left.sortOrder.compareTo(right.sortOrder);
    });

  final groupedEvents = <String, List<Event>>{};
  for (final event in todayEvents) {
    groupedEvents.putIfAbsent(event.trackerUid, () => <Event>[]).add(event);
  }
  for (final events in groupedEvents.values) {
    events.sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  final pendingActionable = <HomeTrackerItem>[];
  final pendingSupplemental = <HomeTrackerItem>[];
  final logged = <HomeTrackerItem>[];

  for (final tracker in sortedTrackers) {
    final events = groupedEvents[tracker.uid] ?? const <Event>[];
    final item = HomeTrackerItem(
      tracker: tracker,
      events: events,
      deEmphasized: tracker.heatmapMode == 'excluded',
      scoreLabel: _homeScoreLabelFor(tracker, events),
    );

    if (events.isNotEmpty) {
      logged.add(item);
      continue;
    }

    if (tracker.countsForCompletion) {
      pendingActionable.add(item);
      continue;
    }

    if (tracker.frequency != 'adhoc') {
      pendingSupplemental.add(item);
    }
  }

  return HomeSections(
    pendingActionable: pendingActionable,
    pendingSupplemental: pendingSupplemental,
    logged: logged,
  );
});

String? _scoreLabelFor(Tracker tracker, List<Event> events) {
  if (events.isEmpty || tracker.scoreKey == null) {
    return null;
  }
  final values = events
      .map((event) => event.metrics.firstWhere(
            (metric) => metric.inputKey == tracker.scoreKey,
            orElse: () => event.metrics.first,
          ))
      .map((metric) => metric.intValue)
      .whereType<int>()
      .toList();
  if (values.isEmpty) {
    return null;
  }
  if (values.length == 1) {
    return '${values.first}';
  }
  final average = values.reduce((left, right) => left + right) / values.length;
  return average.toStringAsFixed(1);
}

String? _homeScoreLabelFor(Tracker tracker, List<Event> events) {
  if (events.isEmpty || !tracker.scoreContribution || tracker.scoreKey == null) {
    return null;
  }
  final values = events
      .map((event) => event.metrics.firstWhere(
            (metric) => metric.inputKey == tracker.scoreKey,
            orElse: () => event.metrics.first,
          ))
      .map((metric) => metric.intValue)
      .whereType<int>()
      .toList();
  if (values.isEmpty) {
    return null;
  }
  final average = values.reduce((left, right) => left + right) / values.length;
  return average == average.roundToDouble()
      ? average.round().toString()
      : average.toStringAsFixed(1);
}
