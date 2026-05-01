import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'midday notification is suppressed when relevant trackers are already logged',
    () {
      final breakfast = _tracker(
        uid: 'tracker-breakfast',
        promptTimes: <String>['08:30'],
      );
      final lunch = _tracker(
        uid: 'tracker-lunch',
        promptTimes: <String>['13:00'],
      );
      final dinner = _tracker(
        uid: 'tracker-dinner',
        promptTimes: <String>['19:00'],
      );

      final plans = buildNotificationPlans(
        now: DateTime(2026, 4, 18, 10),
        trackers: <Tracker>[breakfast, lunch, dinner],
        events: <Event>[
          _event('tracker-breakfast', date: DateTime(2026, 4, 18)),
          _event('tracker-lunch', date: DateTime(2026, 4, 18)),
        ],
        middayTime: const TimeOfDay(hour: 13, minute: 30),
        dayEndTime: const TimeOfDay(hour: 21, minute: 30),
      );

      expect(plans, hasLength(1));
      expect(plans.single.id, NotificationService.dayEndNotificationId);
      expect(plans.single.action.type, AppActionType.openEntrySheet);
      expect(plans.single.action.trackerUid, 'tracker-dinner');
    },
  );

  test(
    'day-end notification opens batch when more than one tracker remains',
    () {
      final workout = _tracker(
        uid: 'tracker-workout',
        promptTimes: <String>['18:00'],
      );
      final mood = _tracker(
        uid: 'tracker-mood',
        promptTimes: <String>['20:00'],
      );

      final plans = buildNotificationPlans(
        now: DateTime(2026, 4, 18, 12),
        trackers: <Tracker>[workout, mood],
        events: const <Event>[],
        middayTime: const TimeOfDay(hour: 13, minute: 30),
        dayEndTime: const TimeOfDay(hour: 21, minute: 30),
      );

      expect(plans, hasLength(1));
      expect(plans.single.id, NotificationService.dayEndNotificationId);
      expect(plans.single.action.type, AppActionType.openBatch);
    },
  );

  test(
    'missed midday notifications are dropped instead of queued for tomorrow',
    () {
      final breakfast = _tracker(
        uid: 'tracker-breakfast',
        promptTimes: <String>['08:30'],
      );
      final dinner = _tracker(
        uid: 'tracker-dinner',
        promptTimes: <String>['19:00'],
      );

      final plans = buildNotificationPlans(
        now: DateTime(2026, 4, 18, 15),
        trackers: <Tracker>[breakfast, dinner],
        events: const <Event>[],
        middayTime: const TimeOfDay(hour: 13, minute: 30),
        dayEndTime: const TimeOfDay(hour: 21, minute: 30),
      );

      expect(plans, hasLength(1));
      expect(plans.single.id, NotificationService.dayEndNotificationId);
      expect(plans.single.scheduledAt, DateTime(2026, 4, 18, 21, 30));
    },
  );

  test(
    'notification planner never emits more than the midday and day-end pair',
    () {
      final breakfast = _tracker(
        uid: 'tracker-breakfast',
        promptTimes: <String>['08:30'],
      );
      final dinner = _tracker(
        uid: 'tracker-dinner',
        promptTimes: <String>['19:00'],
      );

      final plans = buildNotificationPlans(
        now: DateTime(2026, 4, 18, 9),
        trackers: <Tracker>[breakfast, dinner],
        events: const <Event>[],
        middayTime: const TimeOfDay(hour: 13, minute: 30),
        dayEndTime: const TimeOfDay(hour: 21, minute: 30),
      );

      expect(plans, hasLength(2));
      expect(plans.map((plan) => plan.id), <int>[
        NotificationService.middayNotificationId,
        NotificationService.dayEndNotificationId,
      ]);
    },
  );
}

Tracker _tracker({required String uid, required List<String> promptTimes}) {
  return Tracker()
    ..uid = uid
    ..domainUid = 'domain'
    ..name = uid
    ..icon = '•'
    ..frequency = 'daily'
    ..promptTimes = promptTimes
    ..inputSchema = <InputFieldSchema>[]
    ..allowedVisualizations = <String>['heatmap', 'streak']
    ..scoreContribution = true
    ..scoreKey = 'score'
    ..scoreMin = 1
    ..scoreMax = 10
    ..countsForCompletion = true
    ..heatmapMode = 'score_average'
    ..sortOrder = 0
    ..isActive = true
    ..version = 1
    ..createdAt = DateTime(2026);
}

Event _event(String trackerUid, {required DateTime date}) {
  final stamp =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return Event()
    ..uid = '$trackerUid-$stamp'
    ..trackerUid = trackerUid
    ..effectiveDate = DateTime(date.year, date.month, date.day)
    ..effectiveTime = DateTime(date.year, date.month, date.day, 12)
    ..createdAt = DateTime(date.year, date.month, date.day, 12)
    ..updatedAt = DateTime(date.year, date.month, date.day, 12)
    ..isBackfill = false
    ..trackerVersion = 1
    ..metrics = <MetricValue>[
      MetricValue()
        ..inputKey = 'score'
        ..intValue = 7,
    ];
}
