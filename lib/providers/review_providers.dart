import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import 'event_providers.dart';
import 'score_providers.dart';
import 'tracker_providers.dart';

// ---------------------------------------------------------------------------
// Time scale
// ---------------------------------------------------------------------------

enum TimeScale { week, month, year }

final reviewTimeScaleProvider =
    StateProvider<TimeScale>((ref) => TimeScale.month);

// ---------------------------------------------------------------------------
// Selected tracker
// ---------------------------------------------------------------------------

final reviewSelectedTrackerUidProvider =
    StateProvider<String?>((ref) => null);

final reviewTrackersProvider = Provider<List<Tracker>>((ref) {
  final trackers =
      ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
  return trackers.where((t) => t.heatmapMode != 'excluded').toList();
});

final reviewEffectiveTrackerProvider = Provider<Tracker?>((ref) {
  final selectedUid = ref.watch(reviewSelectedTrackerUidProvider);
  final trackers = ref.watch(reviewTrackersProvider);
  if (trackers.isEmpty) return null;
  if (selectedUid != null) {
    for (final t in trackers) {
      if (t.uid == selectedUid) return t;
    }
  }
  return trackers.first;
});

// ---------------------------------------------------------------------------
// Comparison trackers (for trends)
// ---------------------------------------------------------------------------

final reviewComparisonUidsProvider =
    StateProvider<Set<String>>((ref) => const <String>{});

// ---------------------------------------------------------------------------
// Period summary
// ---------------------------------------------------------------------------

class PeriodSummary {
  const PeriodSummary({
    required this.longestStreak,
    this.averageScore,
    required this.completedDays,
    required this.totalDays,
    this.scoreMin,
    this.scoreMax,
  });

  final int longestStreak;
  final double? averageScore;
  final int completedDays;
  final int totalDays;
  final int? scoreMin;
  final int? scoreMax;

  double get completionRate => totalDays == 0 ? 0 : completedDays / totalDays;
}

class PeriodSummaryRequest {
  const PeriodSummaryRequest({
    required this.trackerUid,
    required this.start,
    required this.end,
  });

  final String trackerUid;
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      other is PeriodSummaryRequest &&
      other.trackerUid == trackerUid &&
      isSameDay(other.start, start) &&
      isSameDay(other.end, end);

  @override
  int get hashCode => Object.hash(
        trackerUid,
        start.year,
        start.month,
        start.day,
        end.year,
        end.month,
        end.day,
      );
}

final periodSummaryProvider =
    Provider.family<PeriodSummary, PeriodSummaryRequest>((ref, request) {
  final events =
      ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
  final trackers =
      ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];

  Tracker? tracker;
  for (final t in trackers) {
    if (t.uid == request.trackerUid) {
      tracker = t;
      break;
    }
  }

  final relevant = events.where((e) {
    if (e.trackerUid != request.trackerUid) return false;
    final date = normalizeDate(e.effectiveDate);
    return !date.isBefore(normalizeDate(request.start)) &&
        !date.isAfter(normalizeDate(request.end));
  }).toList();

  final datesWithData =
      relevant.map((e) => normalizeDate(e.effectiveDate)).toSet();

  final today = normalizeDate(DateTime.now());
  final effectiveEnd =
      normalizeDate(request.end).isAfter(today) ? today : normalizeDate(request.end);
  final totalDays =
      effectiveEnd.difference(normalizeDate(request.start)).inDays + 1;

  // Longest streak within the period
  int longestStreak = 0;
  int currentStreak = 0;
  for (final date in enumerateDays(request.start, effectiveEnd)) {
    if (datesWithData.contains(normalizeDate(date))) {
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    } else {
      currentStreak = 0;
    }
  }

  double? avgScore;
  if (tracker != null && tracker.scoreKey != null) {
    final scores = <int>[];
    for (final e in relevant) {
      for (final m in e.metrics) {
        if (m.inputKey == tracker.scoreKey && m.intValue != null) {
          scores.add(m.intValue!);
        }
      }
    }
    if (scores.isNotEmpty) {
      avgScore = scores.reduce((a, b) => a + b) / scores.length;
    }
  }

  return PeriodSummary(
    longestStreak: longestStreak,
    averageScore: avgScore,
    completedDays: datesWithData.length,
    totalDays: totalDays > 0 ? totalDays : 0,
    scoreMin: tracker?.scoreMin,
    scoreMax: tracker?.scoreMax,
  );
});

// ---------------------------------------------------------------------------
// Trend data
// ---------------------------------------------------------------------------

class TrendRequest {
  const TrendRequest({
    required this.trackerUids,
    required this.start,
    required this.end,
  });

  final List<String> trackerUids;
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) {
    if (other is! TrendRequest) return false;
    if (other.trackerUids.length != trackerUids.length) return false;
    for (var i = 0; i < trackerUids.length; i++) {
      if (other.trackerUids[i] != trackerUids[i]) return false;
    }
    return isSameDay(other.start, start) && isSameDay(other.end, end);
  }

  @override
  int get hashCode =>
      Object.hash(trackerUids.length, start.year, start.month, end.year, end.month);
}

class TrendLine {
  const TrendLine({
    required this.trackerUid,
    required this.trackerName,
    required this.points,
  });

  final String trackerUid;
  final String trackerName;
  final List<TrendPoint> points;
}

class TrendPoint {
  const TrendPoint({required this.date, this.value});

  final DateTime date;
  final double? value;
}

final trendDataProvider =
    Provider.family<List<TrendLine>, TrendRequest>((ref, request) {
  final events =
      ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
  final trackers =
      ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];

  final trackerMap = <String, Tracker>{};
  for (final t in trackers) {
    trackerMap[t.uid] = t;
  }

  final lines = <TrendLine>[];
  for (final uid in request.trackerUids) {
    final tracker = trackerMap[uid];
    if (tracker == null) continue;

    final byDate = <DateTime, List<Event>>{};
    for (final e in events) {
      if (e.trackerUid != uid) continue;
      final date = normalizeDate(e.effectiveDate);
      if (date.isBefore(normalizeDate(request.start)) ||
          date.isAfter(normalizeDate(request.end))) continue;
      byDate.putIfAbsent(date, () => <Event>[]).add(e);
    }

    final points = <TrendPoint>[];
    for (final date in enumerateDays(request.start, request.end)) {
      final d = normalizeDate(date);
      final dayEvents = byDate[d] ?? const <Event>[];
      double? value;

      if (dayEvents.isNotEmpty && tracker.scoreKey != null) {
        final scores = <int>[];
        for (final e in dayEvents) {
          for (final m in e.metrics) {
            if (m.inputKey == tracker.scoreKey && m.intValue != null) {
              scores.add(m.intValue!);
            }
          }
        }
        if (scores.isNotEmpty) {
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          final denom = tracker.scoreMax - tracker.scoreMin;
          value = denom > 0 ? (avg - tracker.scoreMin) / denom : 0;
        }
      } else if (dayEvents.isNotEmpty &&
          tracker.heatmapMode == 'presence') {
        value = 1.0;
      }
      points.add(TrendPoint(date: d, value: value));
    }

    lines.add(TrendLine(
      trackerUid: uid,
      trackerName: tracker.name,
      points: points,
    ));
  }

  return lines;
});

// ---------------------------------------------------------------------------
// Multi-tracker summary (for DEMO view)
// ---------------------------------------------------------------------------

class TrackerSummaryItem {
  const TrackerSummaryItem({
    required this.tracker,
    required this.streak,
    required this.completionRate30d,
    required this.last30Values,
  });

  final Tracker tracker;
  final int streak;
  final double completionRate30d;
  final List<double?> last30Values;
}

final multiTrackerSummaryProvider =
    Provider<List<TrackerSummaryItem>>((ref) {
  final reviewTrackers = ref.watch(reviewTrackersProvider);
  final events =
      ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
  final currentDate = ref.watch(currentDateProvider);
  final start = currentDate.subtract(const Duration(days: 29));

  return reviewTrackers.map((tracker) {
    final byDate = <DateTime, List<Event>>{};
    for (final e in events) {
      if (e.trackerUid != tracker.uid) continue;
      final date = normalizeDate(e.effectiveDate);
      if (date.isBefore(normalizeDate(start)) ||
          date.isAfter(currentDate)) continue;
      byDate.putIfAbsent(date, () => <Event>[]).add(e);
    }

    final values = <double?>[];
    int completedDays = 0;
    for (final date in enumerateDays(start, currentDate)) {
      final d = normalizeDate(date);
      final dayEvents = byDate[d] ?? const <Event>[];
      if (dayEvents.isNotEmpty) completedDays++;

      double? value;
      if (dayEvents.isNotEmpty && tracker.scoreKey != null) {
        final scores = <int>[];
        for (final e in dayEvents) {
          for (final m in e.metrics) {
            if (m.inputKey == tracker.scoreKey && m.intValue != null) {
              scores.add(m.intValue!);
            }
          }
        }
        if (scores.isNotEmpty) {
          final avg = scores.reduce((a, b) => a + b) / scores.length;
          final denom = tracker.scoreMax - tracker.scoreMin;
          value = denom > 0 ? (avg - tracker.scoreMin) / denom : 0;
        }
      } else if (dayEvents.isNotEmpty) {
        value = 1.0;
      }
      values.add(value);
    }

    return TrackerSummaryItem(
      tracker: tracker,
      streak: ref.watch(streakProvider(tracker.uid)),
      completionRate30d: completedDays / 30,
      last30Values: values,
    );
  }).toList();
});
