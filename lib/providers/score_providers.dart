import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import 'event_providers.dart';
import 'tracker_providers.dart';

class CompletionStats {
  const CompletionStats({required this.completed, required this.total});

  final int completed;
  final int total;

  double get progress => total == 0 ? 0 : completed / total;
}

final completionProvider = Provider<CompletionStats>((ref) {
  final trackers = ref.watch(completionEligibleTrackersProvider);
  final events = ref.watch(todayEventsProvider).valueOrNull ?? const <Event>[];
  final completed = trackers
      .where(
        (tracker) => events.any((event) => event.trackerUid == tracker.uid),
      )
      .length;
  return CompletionStats(completed: completed, total: trackers.length);
});

final dailyScoreProvider = Provider<int?>((ref) {
  final trackers = ref.watch(scoreEligibleTrackersProvider);
  final events = ref.watch(todayEventsProvider).valueOrNull ?? const <Event>[];
  if (trackers.isEmpty) {
    return null;
  }

  final grouped = <String, List<Event>>{};
  for (final event in events) {
    grouped.putIfAbsent(event.trackerUid, () => <Event>[]).add(event);
  }

  final anyEligibleEvent = trackers.any((tracker) {
    return (grouped[tracker.uid] ?? const <Event>[]).isNotEmpty;
  });
  if (!anyEligibleEvent) {
    return null;
  }

  double sum = 0;
  for (final tracker in trackers) {
    final trackerEvents = grouped[tracker.uid] ?? const <Event>[];
    if (trackerEvents.isEmpty || tracker.scoreKey == null) {
      continue;
    }
    final scores = trackerEvents
        .map((event) => _extractScore(event, tracker.scoreKey!))
        .whereType<int>()
        .map((value) => _normalizeScore(value, tracker))
        .toList();
    if (scores.isEmpty) {
      continue;
    }
    sum += scores.reduce((left, right) => left + right) / scores.length;
  }
  return ((sum / trackers.length) * 100).round();
});

final streakProvider = Provider.family<int, String>((ref, trackerUid) {
  final currentDate = ref.watch(currentDateProvider);
  final allEvents = ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
  final dates = allEvents
      .where((event) => event.trackerUid == trackerUid)
      .map((event) => normalizeDate(event.effectiveDate))
      .toSet();
  var streak = 0;
  var cursor = currentDate;
  while (dates.contains(cursor)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

final globalStreakProvider = Provider<int>((ref) {
  final currentDate = ref.watch(currentDateProvider);
  final allEvents = ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
  final completionTrackers = ref.watch(completionEligibleTrackersProvider);
  if (completionTrackers.isEmpty) {
    return 0;
  }

  final byDate = <DateTime, Set<String>>{};
  for (final event in allEvents) {
    final date = normalizeDate(event.effectiveDate);
    byDate.putIfAbsent(date, () => <String>{}).add(event.trackerUid);
  }

  final required = completionTrackers.map((tracker) => tracker.uid).toSet();
  var streak = 0;
  var cursor = currentDate;
  while ((byDate[cursor] ?? const <String>{}).containsAll(required)) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
});

int? _extractScore(Event event, String scoreKey) {
  for (final metric in event.metrics) {
    if (metric.inputKey == scoreKey) {
      return metric.intValue;
    }
  }
  return null;
}

double _normalizeScore(int value, Tracker tracker) {
  final denominator = tracker.scoreMax - tracker.scoreMin;
  if (denominator <= 0) {
    return 0;
  }
  return (value - tracker.scoreMin) / denominator;
}
