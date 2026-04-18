import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/providers/event_providers.dart';
import 'package:cato/providers/score_providers.dart';
import 'package:cato/providers/tracker_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('daily score normalizes mood energy against scoreMin and scoreMax', () async {
    final mood = _tracker(
      uid: 'tracker-mood',
      scoreKey: 'energy',
      scoreMin: 1,
      scoreMax: 5,
      countsForCompletion: true,
      scoreContribution: true,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allTrackersProvider.overrideWith((ref) => Stream.value(<Tracker>[mood])),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[
            _event('tracker-mood', 'energy', 3),
          ]),
        ),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);
    expect(container.read(dailyScoreProvider), 50);
  });

  test('daily score averages same-day entries before applying denominator', () async {
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final lunch = _tracker(
      uid: 'tracker-lunch',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allTrackersProvider.overrideWith(
          (ref) => Stream.value(<Tracker>[breakfast, lunch]),
        ),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[
            _event('tracker-breakfast', 'score', 7),
            _event('tracker-breakfast', 'score', 9),
          ]),
        ),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);
    expect(container.read(dailyScoreProvider), 39);
  });

  test('daily score uses all eligible trackers as denominator', () async {
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final lunch = _tracker(
      uid: 'tracker-lunch',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final dinner = _tracker(
      uid: 'tracker-dinner',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final workout = _tracker(
      uid: 'tracker-workout',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final sleep = _tracker(
      uid: 'tracker-sleep',
      scoreKey: 'quality',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final mood = _tracker(
      uid: 'tracker-mood',
      scoreKey: 'energy',
      scoreMin: 1,
      scoreMax: 5,
      countsForCompletion: true,
      scoreContribution: true,
    );

    final events = <Event>[
      _event('tracker-breakfast', 'score', 7),
      _event('tracker-sleep', 'quality', 8),
      _event('tracker-mood', 'energy', 4),
    ];

    final container = ProviderContainer(
      overrides: <Override>[
        allTrackersProvider.overrideWith((ref) => Stream.value(
              <Tracker>[
                breakfast,
                lunch,
                dinner,
                workout,
                sleep,
                mood,
              ],
            )),
        todayEventsProvider.overrideWith((ref) => Stream.value(events)),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);
    expect(container.read(dailyScoreProvider), 37);
  });

  test('daily score stays null when no eligible tracker has events', () async {
    final snack = _tracker(
      uid: 'tracker-snack',
      scoreKey: null,
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: false,
      scoreContribution: false,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allTrackersProvider.overrideWith((ref) => Stream.value(<Tracker>[snack])),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[_event('tracker-snack', 'score', 6)]),
        ),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);
    expect(container.read(dailyScoreProvider), isNull);
  });

  test('tracker streak counts consecutive logged days for one tracker', () async {
    final currentDate = DateTime(2026, 4, 18);
    final container = ProviderContainer(
      overrides: <Override>[
        currentDateProvider.overrideWith(
          (ref) => _FixedDateController(currentDate),
        ),
        allEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[
            _event('tracker-breakfast', 'score', 7, date: currentDate),
            _event(
              'tracker-breakfast',
              'score',
              8,
              date: currentDate.subtract(const Duration(days: 1)),
            ),
            _event(
              'tracker-breakfast',
              'score',
              6,
              date: currentDate.subtract(const Duration(days: 2)),
            ),
          ]),
        ),
      ],
    );

    await container.read(allEventsProvider.future);
    expect(container.read(streakProvider('tracker-breakfast')), 3);
  });

  test('global streak only counts days where every eligible tracker was logged', () async {
    final currentDate = DateTime(2026, 4, 18);
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final sleep = _tracker(
      uid: 'tracker-sleep',
      scoreKey: 'quality',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        currentDateProvider.overrideWith(
          (ref) => _FixedDateController(currentDate),
        ),
        allTrackersProvider.overrideWith(
          (ref) => Stream.value(<Tracker>[breakfast, sleep]),
        ),
        allEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[
            _event('tracker-breakfast', 'score', 7, date: currentDate),
            _event('tracker-sleep', 'quality', 8, date: currentDate),
            _event(
              'tracker-breakfast',
              'score',
              6,
              date: currentDate.subtract(const Duration(days: 1)),
            ),
            _event(
              'tracker-sleep',
              'quality',
              9,
              date: currentDate.subtract(const Duration(days: 1)),
            ),
            _event(
              'tracker-breakfast',
              'score',
              8,
              date: currentDate.subtract(const Duration(days: 2)),
            ),
          ]),
        ),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(allEventsProvider.future);
    expect(container.read(globalStreakProvider), 2);
  });

  test('completion excludes snack and vices', () async {
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      scoreKey: 'score',
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: true,
      scoreContribution: true,
    );
    final snack = _tracker(
      uid: 'tracker-snack',
      scoreKey: null,
      scoreMin: 1,
      scoreMax: 10,
      countsForCompletion: false,
      scoreContribution: false,
    );
    final vices = _tracker(
      uid: 'tracker-vices',
      scoreKey: null,
      scoreMin: 0,
      scoreMax: 0,
      countsForCompletion: false,
      scoreContribution: false,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allTrackersProvider.overrideWith(
          (ref) => Stream.value(<Tracker>[breakfast, snack, vices]),
        ),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(
            <Event>[
              _event('tracker-breakfast', 'score', 8),
              _event('tracker-snack', 'score', 6),
              _event('tracker-vices', 'count', 1),
            ],
          ),
        ),
      ],
    );

    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);
    final completion = container.read(completionProvider);
    expect(completion.completed, 1);
    expect(completion.total, 1);
  });
}

Tracker _tracker({
  required String uid,
  required String? scoreKey,
  required int scoreMin,
  required int scoreMax,
  required bool countsForCompletion,
  required bool scoreContribution,
}) {
  return Tracker()
    ..uid = uid
    ..domainUid = 'domain'
    ..name = uid
    ..icon = '•'
    ..frequency = 'daily'
    ..promptTimes = <String>[]
    ..inputSchema = <InputFieldSchema>[]
    ..allowedVisualizations = <String>[]
    ..scoreContribution = scoreContribution
    ..scoreKey = scoreKey
    ..scoreMin = scoreMin
    ..scoreMax = scoreMax
    ..countsForCompletion = countsForCompletion
    ..heatmapMode = scoreContribution ? 'score_average' : 'presence'
    ..sortOrder = 0
    ..isActive = true
    ..version = 1
    ..createdAt = DateTime(2026);
}

Event _event(
  String trackerUid,
  String key,
  int value, {
  DateTime? date,
}) {
  return _eventAtDate(
    trackerUid,
    key,
    value,
    date ?? DateTime(2026, 4, 18),
  );
}

Event _eventAtDate(
  String trackerUid,
  String key,
  int value,
  DateTime date,
) {
  final dayStamp =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return Event()
    ..uid = '$trackerUid-$key-$value-$dayStamp'
    ..trackerUid = trackerUid
    ..effectiveDate = DateTime(date.year, date.month, date.day)
    ..effectiveTime = DateTime(date.year, date.month, date.day, 12)
    ..createdAt = DateTime(date.year, date.month, date.day, 12)
    ..updatedAt = DateTime(date.year, date.month, date.day, 12)
    ..isBackfill = false
    ..trackerVersion = 1
    ..metrics = <MetricValue>[
      MetricValue()
        ..inputKey = key
        ..intValue = value,
    ];
}

class _FixedDateController extends CurrentDateController {
  _FixedDateController(this._date) : super() {
    state = _date;
  }

  final DateTime _date;

  @override
  void refresh() {
    state = _date;
  }
}
