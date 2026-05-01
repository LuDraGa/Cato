import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import 'event_providers.dart';

class HeatmapRequest {
  const HeatmapRequest({
    required this.tracker,
    required this.start,
    required this.end,
  });

  final Tracker tracker;
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) {
    return other is HeatmapRequest &&
        other.tracker.uid == tracker.uid &&
        isSameDay(other.start, start) &&
        isSameDay(other.end, end);
  }

  @override
  int get hashCode =>
      Object.hash(tracker.uid, start.year, start.month, end.year, end.month);
}

final reviewMonthCountProvider = StateProvider<int>((ref) => 3);

final heatmapDataProvider =
    Provider.family<Map<DateTime, double?>, HeatmapRequest>((ref, request) {
      final events =
          ref.watch(allEventsProvider).valueOrNull ?? const <Event>[];
      final relevant = events.where((event) {
        if (event.trackerUid != request.tracker.uid) {
          return false;
        }
        final date = normalizeDate(event.effectiveDate);
        return !date.isBefore(normalizeDate(request.start)) &&
            !date.isAfter(normalizeDate(request.end));
      }).toList();

      final byDate = <DateTime, List<Event>>{};
      for (final event in relevant) {
        byDate
            .putIfAbsent(normalizeDate(event.effectiveDate), () => <Event>[])
            .add(event);
      }

      final result = <DateTime, double?>{};
      for (final date in enumerateDays(request.start, request.end)) {
        final dayEvents = byDate[normalizeDate(date)] ?? const <Event>[];
        result[normalizeDate(date)] = _valueFor(request.tracker, dayEvents);
      }
      return result;
    });

double? _valueFor(Tracker tracker, List<Event> events) {
  if (tracker.heatmapMode == 'excluded') {
    return null;
  }
  if (events.isEmpty) {
    return null;
  }
  if (tracker.heatmapMode == 'presence') {
    return 1;
  }
  if (tracker.scoreKey == null) {
    return 0;
  }
  final values = events
      .map(
        (event) => event.metrics.firstWhere(
          (metric) => metric.inputKey == tracker.scoreKey,
          orElse: () => event.metrics.first,
        ),
      )
      .map((metric) => metric.intValue)
      .whereType<int>()
      .toList();
  if (values.isEmpty) {
    return null;
  }
  final average = values.reduce((left, right) => left + right) / values.length;
  final denominator = tracker.scoreMax - tracker.scoreMin;
  if (denominator <= 0) {
    return 0;
  }
  return (average - tracker.scoreMin) / denominator;
}
