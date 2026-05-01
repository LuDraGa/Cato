import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/metric_value.dart';
import '../models/tracker.dart';

class EventDraft {
  EventDraft({
    required this.tracker,
    required this.effectiveDate,
    this.effectiveTime,
    required this.metrics,
    required this.isBackfill,
    this.existingEvent,
    this.clearedKeys = const <String>{},
  });

  final Tracker tracker;
  final DateTime effectiveDate;
  final DateTime? effectiveTime;
  final List<MetricValue> metrics;
  final bool isBackfill;
  final Event? existingEvent;
  final Set<String> clearedKeys;
}

class EventRepository {
  EventRepository(this._isar, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Isar _isar;
  final Uuid _uuid;

  Stream<List<Event>> watchEventsForDate(DateTime date) {
    final normalized = normalizeDate(date);
    return _isar.events
        .filter()
        .effectiveDateEqualTo(normalized)
        .watch(fireImmediately: true);
  }

  Stream<List<Event>> watchAll() {
    return _isar.events.where().watch(fireImmediately: true);
  }

  Future<List<Event>> getEventsForDate(DateTime date) {
    final normalized = normalizeDate(date);
    return _isar.events.filter().effectiveDateEqualTo(normalized).findAll();
  }

  Future<List<Event>> getEventsForTrackerAndDate(
    String trackerUid,
    DateTime date,
  ) {
    final normalized = normalizeDate(date);
    return _isar.events
        .filter()
        .trackerUidEqualTo(trackerUid)
        .and()
        .effectiveDateEqualTo(normalized)
        .sortByCreatedAtDesc()
        .findAll();
  }

  Stream<List<Event>> watchEventsForTrackerRange(
    String trackerUid,
    DateTime start,
    DateTime end,
  ) {
    return _isar.events
        .filter()
        .trackerUidEqualTo(trackerUid)
        .and()
        .effectiveDateBetween(normalizeDate(start), normalizeDate(end))
        .watch(fireImmediately: true);
  }

  Future<List<Event>> getEventsForTrackerRange(
    String trackerUid,
    DateTime start,
    DateTime end,
  ) {
    return _isar.events
        .filter()
        .trackerUidEqualTo(trackerUid)
        .and()
        .effectiveDateBetween(normalizeDate(start), normalizeDate(end))
        .findAll();
  }

  Future<Event?> getMostRecentEvent(
    String trackerUid, {
    String? excludingEventUid,
  }) async {
    final events = await _isar.events
        .filter()
        .trackerUidEqualTo(trackerUid)
        .sortByEffectiveDateDesc()
        .thenByCreatedAtDesc()
        .findAll();
    for (final event in events) {
      if (excludingEventUid == null || event.uid != excludingEventUid) {
        return event;
      }
    }
    return null;
  }

  Future<void> deleteEvent(Event event) async {
    await _isar.writeTxn(() async {
      await _isar.events.delete(event.isarId);
    });
  }

  Future<void> clearEvents() async {
    await _isar.writeTxn(() async {
      await _isar.events.clear();
    });
  }

  Future<int> countEvents() {
    return _isar.events.count();
  }

  Future<Event> upsertDraft(EventDraft draft) async {
    final normalizedDate = normalizeDate(draft.effectiveDate);
    final now = DateTime.now();
    final existing = draft.existingEvent;
    final mergedMetrics = _mergeMetrics(
      original: existing?.metrics ?? const <MetricValue>[],
      updates: draft.metrics,
      clearedKeys: draft.clearedKeys,
    );

    final event = existing ?? Event();
    event.uid = existing?.uid ?? _uuid.v4();
    event.trackerUid = draft.tracker.uid;
    event.effectiveDate = normalizedDate;
    event.effectiveTime = draft.effectiveTime;
    event.createdAt = existing?.createdAt ?? now;
    event.updatedAt = now;
    event.isBackfill = draft.isBackfill;
    event.trackerVersion = draft.tracker.version;
    event.metrics = mergedMetrics;

    await _isar.writeTxn(() async {
      await _isar.events.put(event);
    });
    return event;
  }

  Future<void> saveBatch(List<EventDraft> drafts) async {
    await _isar.writeTxn(() async {
      for (final draft in drafts) {
        final normalizedDate = normalizeDate(draft.effectiveDate);
        final now = DateTime.now();
        final existing = draft.existingEvent;
        final event = existing ?? Event();
        event.uid = existing?.uid ?? _uuid.v4();
        event.trackerUid = draft.tracker.uid;
        event.effectiveDate = normalizedDate;
        event.effectiveTime = draft.effectiveTime;
        event.createdAt = existing?.createdAt ?? now;
        event.updatedAt = now;
        event.isBackfill = draft.isBackfill;
        event.trackerVersion = draft.tracker.version;
        event.metrics = _mergeMetrics(
          original: existing?.metrics ?? const <MetricValue>[],
          updates: draft.metrics,
          clearedKeys: draft.clearedKeys,
        );
        await _isar.events.put(event);
      }
    });
  }

  Future<String> exportJson() async {
    final events = await _isar.events.where().findAll();
    final payload = events.map((event) => event.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  List<MetricValue> _mergeMetrics({
    required List<MetricValue> original,
    required List<MetricValue> updates,
    required Set<String> clearedKeys,
  }) {
    final merged = <String, MetricValue>{
      for (final metric in original)
        metric.inputKey: MetricValue.copyOf(metric),
    };
    for (final key in clearedKeys) {
      merged.remove(key);
    }
    for (final metric in updates) {
      merged[metric.inputKey] = MetricValue.copyOf(metric);
    }
    return merged.values.toList();
  }
}
