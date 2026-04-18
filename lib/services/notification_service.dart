import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:isar/isar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import '../repositories/app_config_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/tracker_repository.dart';

enum AppActionType { openHome, openBatch, openEntrySheet }

class PendingAppAction {
  const PendingAppAction({
    required this.type,
    this.trackerUid,
    this.effectiveDate,
  });

  final AppActionType type;
  final String? trackerUid;
  final DateTime? effectiveDate;

  factory PendingAppAction.fromPayload(String payload) {
    final decoded = Map<String, dynamic>.from(jsonDecode(payload) as Map);
    return PendingAppAction(
      type: AppActionType.values.firstWhere(
        (item) => item.name == decoded['type'],
      ),
      trackerUid: decoded['trackerUid'] as String?,
      effectiveDate: decoded['effectiveDate'] == null
          ? null
          : DateTime.parse(decoded['effectiveDate'] as String),
    );
  }

  String toPayload() {
    return jsonEncode(<String, dynamic>{
      'type': type.name,
      'trackerUid': trackerUid,
      'effectiveDate': effectiveDate?.toIso8601String(),
    });
  }
}

@visibleForTesting
class NotificationPlan {
  const NotificationPlan({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.action,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final PendingAppAction action;
}

@visibleForTesting
List<NotificationPlan> buildNotificationPlans({
  required DateTime now,
  required List<Tracker> trackers,
  required List<Event> events,
  required TimeOfDay middayTime,
  required TimeOfDay dayEndTime,
}) {
  final today = normalizeDate(now);
  final completionTrackers = trackers.where((tracker) {
    return tracker.countsForCompletion;
  }).toList();

  final middayPending = completionTrackers.where((tracker) {
    final promptTimes = tracker.promptTimes;
    if (promptTimes.isEmpty) {
      return false;
    }
    final expectedByMidday = promptTimes.any(
      (item) => _isOnOrBefore(parseHhMm(item), middayTime),
    );
    final isLogged = events.any((event) => event.trackerUid == tracker.uid);
    return expectedByMidday && !isLogged;
  }).toList();

  final dayEndPending = completionTrackers.where((tracker) {
    return !events.any((event) => event.trackerUid == tracker.uid);
  }).toList();

  final plans = <NotificationPlan>[];
  final middayAt = _timeOnDate(today, middayTime);
  if (middayPending.isNotEmpty && middayAt.isAfter(now)) {
    plans.add(
      NotificationPlan(
        id: NotificationService.middayNotificationId,
        title: "How's today going?",
        body: '${middayPending.length} to log',
        scheduledAt: middayAt,
        action: const PendingAppAction(type: AppActionType.openHome),
      ),
    );
  }

  final dayEndAt = _timeOnDate(today, dayEndTime);
  if (dayEndPending.isNotEmpty && dayEndAt.isAfter(now)) {
    plans.add(
      NotificationPlan(
        id: NotificationService.dayEndNotificationId,
        title: 'Wrap up your day',
        body: '${dayEndPending.length} to log',
        scheduledAt: dayEndAt,
        action: dayEndPending.length == 1
            ? PendingAppAction(
                type: AppActionType.openEntrySheet,
                trackerUid: dayEndPending.single.uid,
                effectiveDate: today,
              )
            : const PendingAppAction(type: AppActionType.openBatch),
      ),
    );
  }

  return plans;
}

class NotificationService {
  NotificationService(Isar isar)
      : _appConfigRepository = AppConfigRepository(isar),
        _trackerRepository = TrackerRepository(isar),
        _eventRepository = EventRepository(isar);

  static const int middayNotificationId = 101;
  static const int dayEndNotificationId = 202;
  static const String _middayChannelId = 'cato_midday_reminders';
  static const String _dayEndSilentChannelId = 'cato_day_end_reflection';
  static const String _dayEndChimeChannelId = 'cato_day_end_reflection_chime';
  static const Map<String, String> _timezoneAliases = <String, String>{
    'Asia/Calcutta': 'Asia/Kolkata',
  };

  final AppConfigRepository _appConfigRepository;
  final TrackerRepository _trackerRepository;
  final EventRepository _eventRepository;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<PendingAppAction> _actionsController =
      StreamController<PendingAppAction>.broadcast();

  Stream<PendingAppAction> get actions => _actionsController.stream;

  Future<PendingAppAction?> initialize() async {
    tz.initializeTimeZones();
    String timezoneName = 'UTC';
    try {
      timezoneName = await FlutterTimezone.getLocalTimezone();
    } catch (_) {
      // Notifications should degrade gracefully if platform timezone lookup fails.
    }
    tz.setLocalLocation(_resolveTimezoneLocation(timezoneName));

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload;
        if (payload == null) {
          return;
        }
        _actionsController.add(PendingAppAction.fromPayload(payload));
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchPayload == null) {
      return null;
    }
    return PendingAppAction.fromPayload(launchPayload);
  }

  tz.Location _resolveTimezoneLocation(String timezoneName) {
    final candidateNames = <String>[
      timezoneName,
      _timezoneAliases[timezoneName] ?? '',
      'UTC',
    ].where((item) => item.isNotEmpty);

    for (final candidate in candidateNames) {
      try {
        return tz.getLocation(candidate);
      } catch (_) {
        continue;
      }
    }

    return tz.UTC;
  }

  Future<void> requestPermissionOnFirstOpen() async {
    final alreadyRequested = await _appConfigRepository.getBool(
      'notification_permission_requested',
      defaultValue: false,
    );
    if (alreadyRequested) {
      return;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    await _appConfigRepository.setValue('notification_permission_requested', 'true');
    if (granted == false) {
      await _appConfigRepository.setValue('notifications_enabled', 'false');
      await cancelAll();
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> syncSchedules() async {
    final enabled = await _appConfigRepository.getBool(
      'notifications_enabled',
      defaultValue: true,
    );
    if (!enabled) {
      await cancelAll();
      return;
    }

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final allowed = await androidPlugin?.areNotificationsEnabled() ?? true;
    if (!allowed) {
      return;
    }

    await cancelAll();

    final trackers = await _trackerRepository.getAllActive();
    final completionTrackers =
        trackers.where((tracker) => tracker.countsForCompletion).toList();
    final today = normalizeDate(DateTime.now());
    final events = await _eventRepository.getEventsForDate(today);

    final middayTime = parseHhMm(
      await _appConfigRepository.getValue('midday_time') ?? '13:30',
    );
    final dayEndTime = parseHhMm(
      await _appConfigRepository.getValue('day_end_time') ?? '21:30',
    );
    final soundEnabled = await _appConfigRepository.getBool(
      'sound_enabled',
      defaultValue: false,
    );

    final plans = buildNotificationPlans(
      now: DateTime.now(),
      trackers: completionTrackers,
      events: events,
      middayTime: middayTime,
      dayEndTime: dayEndTime,
    );

    for (final plan in plans) {
      final isDayEnd = plan.id == dayEndNotificationId;
      await _scheduleNotification(
        id: plan.id,
        title: plan.title,
        body: plan.body,
        scheduledAt: plan.scheduledAt,
        payload: plan.action.toPayload(),
        playSound: isDayEnd && soundEnabled,
      );
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    await _appConfigRepository.setValue('notifications_enabled', '$enabled');
    if (!enabled) {
      await cancelAll();
      return;
    }
    await syncSchedules();
  }

  Future<void> updateMiddayTime(String value) async {
    await _appConfigRepository.setValue('midday_time', value);
    await syncSchedules();
  }

  Future<void> updateDayEndTime(String value) async {
    await _appConfigRepository.setValue('day_end_time', value);
    await syncSchedules();
  }

  Future<void> dispose() async {
    await _actionsController.close();
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required String payload,
    required bool playSound,
  }) async {
    final scheduledTime = tz.TZDateTime.from(scheduledAt, tz.local);
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }
    final isDayEnd = id == dayEndNotificationId;
    final channelId = isDayEnd
        ? (playSound ? _dayEndChimeChannelId : _dayEndSilentChannelId)
        : _middayChannelId;
    final channelName = isDayEnd
        ? (playSound ? 'Cato Day-end Reflection Chime' : 'Cato Day-end Reflection')
        : 'Cato Midday Check-in';
    final channelDescription = isDayEnd
        ? 'Day-end reflection reminders for Cato'
        : 'Midday check-in reminders for Cato';

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          playSound: playSound,
          sound: playSound
              ? const RawResourceAndroidNotificationSound('evening_chime')
              : null,
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

DateTime _timeOnDate(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

bool _isOnOrBefore(TimeOfDay left, TimeOfDay right) {
  if (left.hour < right.hour) {
    return true;
  }
  if (left.hour > right.hour) {
    return false;
  }
  return left.minute <= right.minute;
}
