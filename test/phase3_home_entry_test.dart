import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cato/models/domain.dart';
import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/providers/entry_form_provider.dart';
import 'package:cato/providers/event_providers.dart';
import 'package:cato/providers/tracker_providers.dart';

void main() {
  test('entry form pre-fills header time from tracker prompt time', () {
    final controller = EntryFormController(
      EntryFormSeed(
        tracker: _tracker(
          uid: 'tracker-lunch',
          domainUid: 'domain-nutrition',
          name: 'Lunch',
          frequency: 'multi_daily',
          promptTimes: <String>['13:30'],
          countsForCompletion: true,
          scoreContribution: true,
          heatmapMode: 'score_average',
        ),
        effectiveDate: DateTime(2026, 4, 18),
      ),
    );

    expect(controller.state.headerTime.hour, 13);
    expect(controller.state.headerTime.minute, 30);
    expect(controller.state.metricFor('time')?.stringValue, '13:30');
  });

  test('home sections hide unlogged adhoc trackers and keep excluded trackers loggable',
      () async {
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      domainUid: 'domain-nutrition',
      name: 'Breakfast',
      frequency: 'daily',
      promptTimes: <String>['08:30'],
      countsForCompletion: true,
      scoreContribution: true,
      heatmapMode: 'score_average',
      sortOrder: 0,
    );
    final snack = _tracker(
      uid: 'tracker-snack',
      domainUid: 'domain-nutrition',
      name: 'Snack',
      frequency: 'adhoc',
      promptTimes: const <String>[],
      countsForCompletion: false,
      scoreContribution: false,
      heatmapMode: 'presence',
      sortOrder: 1,
    );
    final vices = _tracker(
      uid: 'tracker-vices',
      domainUid: 'domain-vices',
      name: 'Vices',
      frequency: 'multi_daily',
      promptTimes: const <String>[],
      countsForCompletion: false,
      scoreContribution: false,
      heatmapMode: 'excluded',
      sortOrder: 0,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allDomainsProvider.overrideWith(
          (ref) => Stream.value(
            <Domain>[
              _domain('domain-nutrition', 0),
              _domain('domain-vices', 1),
            ],
          ),
        ),
        allTrackersProvider.overrideWith(
          (ref) => Stream.value(<Tracker>[breakfast, snack, vices]),
        ),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(
            <Event>[
              _event('tracker-breakfast', 'score', 8),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allDomainsProvider.future);
    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);

    final sections = container.read(homeSectionsProvider);
    expect(
      sections.pendingActionable.map((item) => item.tracker.uid),
      isEmpty,
    );
    expect(
      sections.pendingSupplemental.map((item) => item.tracker.uid),
      <String>['tracker-vices'],
    );
    expect(
      sections.logged.map((item) => item.tracker.uid),
      <String>['tracker-breakfast'],
    );
  });

  test('home sections show adhoc trackers only after they are logged', () async {
    final breakfast = _tracker(
      uid: 'tracker-breakfast',
      domainUid: 'domain-nutrition',
      name: 'Breakfast',
      frequency: 'daily',
      promptTimes: <String>['08:30'],
      countsForCompletion: true,
      scoreContribution: true,
      heatmapMode: 'score_average',
      sortOrder: 0,
    );
    final snack = _tracker(
      uid: 'tracker-snack',
      domainUid: 'domain-nutrition',
      name: 'Snack',
      frequency: 'adhoc',
      promptTimes: const <String>[],
      countsForCompletion: false,
      scoreContribution: false,
      heatmapMode: 'presence',
      sortOrder: 1,
    );

    final container = ProviderContainer(
      overrides: <Override>[
        allDomainsProvider.overrideWith(
          (ref) => Stream.value(<Domain>[_domain('domain-nutrition', 0)]),
        ),
        allTrackersProvider.overrideWith(
          (ref) => Stream.value(<Tracker>[breakfast, snack]),
        ),
        todayEventsProvider.overrideWith(
          (ref) => Stream.value(
            <Event>[
              _event('tracker-breakfast', 'score', 8),
              _event('tracker-snack', 'score', 6),
            ],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(allDomainsProvider.future);
    await container.read(allTrackersProvider.future);
    await container.read(todayEventsProvider.future);

    final sections = container.read(homeSectionsProvider);
    expect(
      sections.logged.map((item) => item.tracker.uid),
      <String>['tracker-breakfast', 'tracker-snack'],
    );
  });
}

Tracker _tracker({
  required String uid,
  required String domainUid,
  required String name,
  required String frequency,
  required List<String> promptTimes,
  required bool countsForCompletion,
  required bool scoreContribution,
  required String heatmapMode,
  int sortOrder = 0,
}) {
  return Tracker()
    ..uid = uid
    ..domainUid = domainUid
    ..name = name
    ..icon = '•'
    ..frequency = frequency
    ..promptTimes = promptTimes
    ..inputSchema = <InputFieldSchema>[
      InputFieldSchema()
        ..key = 'time'
        ..label = 'Time'
        ..type = 'time'
        ..configJson = null
        ..isRequired = false
        ..sortOrder = 0,
    ]
    ..allowedVisualizations = <String>['heatmap', 'streak']
    ..scoreContribution = scoreContribution
    ..scoreKey = scoreContribution ? 'score' : null
    ..scoreMin = 1
    ..scoreMax = 10
    ..countsForCompletion = countsForCompletion
    ..heatmapMode = heatmapMode
    ..sortOrder = sortOrder
    ..isActive = true
    ..version = 1
    ..createdAt = DateTime(2026);
}

Domain _domain(String uid, int sortOrder) {
  return Domain()
    ..uid = uid
    ..name = uid
    ..icon = '•'
    ..color = '#8BA88B'
    ..sortOrder = sortOrder
    ..isActive = true;
}

Event _event(String trackerUid, String key, int value) {
  return Event()
    ..uid = '$trackerUid-$key-$value'
    ..trackerUid = trackerUid
    ..effectiveDate = DateTime(2026, 4, 18)
    ..effectiveTime = DateTime(2026, 4, 18, 12)
    ..createdAt = DateTime(2026, 4, 18, 12)
    ..updatedAt = DateTime(2026, 4, 18, 12)
    ..isBackfill = false
    ..trackerVersion = 1
    ..metrics = <MetricValue>[
      MetricValue()
        ..inputKey = key
        ..intValue = value,
    ];
}
