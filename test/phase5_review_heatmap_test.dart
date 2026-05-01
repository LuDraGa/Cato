import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cato/app/theme.dart';
import 'package:cato/models/domain.dart';
import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/providers/event_providers.dart';
import 'package:cato/providers/heatmap_providers.dart';
import 'package:cato/providers/tracker_providers.dart';
import 'package:cato/screens/review/review_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'heatmap data averages normalized scores for score_average trackers',
    () async {
      final tracker = _tracker(
        uid: 'tracker-lunch',
        domainUid: 'domain-nutrition',
        name: 'Lunch',
        heatmapMode: 'score_average',
        scoreContribution: true,
        scoreKey: 'score',
      );
      final request = HeatmapRequest(
        tracker: tracker,
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 3),
      );

      final container = ProviderContainer(
        overrides: <Override>[
          allEventsProvider.overrideWith(
            (ref) => Stream.value(<Event>[
              _event('tracker-lunch', 'score', 7, date: DateTime(2026, 4, 2)),
              _event('tracker-lunch', 'score', 9, date: DateTime(2026, 4, 2)),
            ]),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(allEventsProvider.future);
      final data = container.read(heatmapDataProvider(request));
      expect(data[DateTime(2026, 4, 1)], isNull);
      expect(data[DateTime(2026, 4, 2)], closeTo(0.7777, 0.0001));
      expect(data[DateTime(2026, 4, 3)], isNull);
    },
  );

  test('heatmap data uses binary presence mode', () async {
    final tracker = _tracker(
      uid: 'tracker-snack',
      domainUid: 'domain-nutrition',
      name: 'Snack',
      heatmapMode: 'presence',
      scoreContribution: false,
      scoreKey: null,
    );
    final request = HeatmapRequest(
      tracker: tracker,
      start: DateTime(2026, 4, 1),
      end: DateTime(2026, 4, 2),
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allEventsProvider.overrideWith(
          (ref) => Stream.value(<Event>[
            _event('tracker-snack', 'count', 1, date: DateTime(2026, 4, 1)),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allEventsProvider.future);
    final data = container.read(heatmapDataProvider(request));
    expect(data[DateTime(2026, 4, 1)], 1);
    expect(data[DateTime(2026, 4, 2)], isNull);
  });

  testWidgets(
    'review screen hides excluded trackers, removes dead-end domains, and keeps review shallower by default',
    (tester) async {
      final breakfast = _tracker(
        uid: 'tracker-breakfast',
        domainUid: 'domain-nutrition',
        name: 'Breakfast',
        heatmapMode: 'score_average',
        scoreContribution: true,
        scoreKey: 'score',
        sortOrder: 0,
      );
      final sleep = _tracker(
        uid: 'tracker-sleep',
        domainUid: 'domain-rest',
        name: 'Sleep',
        heatmapMode: 'score_average',
        scoreContribution: true,
        scoreKey: 'quality',
        sortOrder: 1,
      );
      final viceLog = _tracker(
        uid: 'tracker-vices',
        domainUid: 'domain-vices',
        name: 'Vice Log',
        heatmapMode: 'excluded',
        scoreContribution: false,
        scoreKey: null,
        sortOrder: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: <Override>[
            currentDateProvider.overrideWith(
              (ref) => _FixedDateController(DateTime(2026, 4, 18)),
            ),
            allDomainsProvider.overrideWith(
              (ref) => Stream.value(<Domain>[
                _domain('domain-nutrition', 'Nutrition', 0),
                _domain('domain-rest', 'Rest', 1),
                _domain('domain-vices', 'Vices', 2),
              ]),
            ),
            allTrackersProvider.overrideWith(
              (ref) => Stream.value(<Tracker>[breakfast, sleep, viceLog]),
            ),
            allEventsProvider.overrideWith(
              (ref) => Stream.value(<Event>[
                _event(
                  'tracker-breakfast',
                  'score',
                  8,
                  date: DateTime(2026, 4, 18),
                ),
                _event(
                  'tracker-sleep',
                  'quality',
                  7,
                  date: DateTime(2026, 4, 18),
                ),
              ]),
            ),
          ],
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: ReviewScreen()),
          ),
        ),
      );
      await tester.pump();

      // Verify excluded trackers (heatmapMode: 'excluded') are hidden from review
      expect(find.text('Vice Log'), findsNothing);
      expect(find.text('Vices'), findsNothing);

      // Verify eligible trackers are present in selector
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Sleep'), findsOneWidget);

      // Verify month navigation is rendered (current month visible)
      expect(find.text('April 2026'), findsWidgets);

      // Verify past months are not eagerly loaded (lazy-loading via PageView)
      expect(find.text('March 2026'), findsNothing);
    },
  );
}

Tracker _tracker({
  required String uid,
  required String domainUid,
  required String name,
  required String heatmapMode,
  required bool scoreContribution,
  required String? scoreKey,
  int sortOrder = 0,
}) {
  return Tracker()
    ..uid = uid
    ..domainUid = domainUid
    ..name = name
    ..icon = '•'
    ..frequency = 'daily'
    ..promptTimes = <String>['12:00']
    ..inputSchema = <InputFieldSchema>[]
    ..allowedVisualizations = <String>['heatmap', 'streak']
    ..scoreContribution = scoreContribution
    ..scoreKey = scoreKey
    ..scoreMin = 1
    ..scoreMax = 10
    ..countsForCompletion = scoreContribution
    ..heatmapMode = heatmapMode
    ..sortOrder = sortOrder
    ..isActive = true
    ..version = 1
    ..createdAt = DateTime(2026);
}

Domain _domain(String uid, String name, int sortOrder) {
  return Domain()
    ..uid = uid
    ..name = name
    ..icon = '•'
    ..color = '#8BA88B'
    ..sortOrder = sortOrder
    ..isActive = true;
}

Event _event(
  String trackerUid,
  String key,
  int value, {
  required DateTime date,
}) {
  final stamp =
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  return Event()
    ..uid = '$trackerUid-$key-$value-$stamp'
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
