import 'dart:ffi';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:cato/models/event.dart';
import 'package:cato/models/input_field_schema.dart';
import 'package:cato/models/metric_value.dart';
import 'package:cato/models/tracker.dart';
import 'package:cato/providers/entry_form_provider.dart';
import 'package:cato/repositories/event_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Isar.initializeIsarCore(
      libraries: <Abi, String>{
        Abi.macosArm64: _isarCoreLibraryPath(),
        Abi.macosX64: _isarCoreLibraryPath(),
      },
    );
  });

  group('Phase 7 polish', () {
    test(
      'same as yesterday fills current-schema fields in staggered order',
      () async {
        final controller = EntryFormController(
          EntryFormSeed(
            tracker: _trackerWithFields(),
            effectiveDate: DateTime(2026, 4, 18),
          ),
        );
        final previous = _event(
          uid: 'previous',
          effectiveDate: DateTime(2026, 4, 17),
          metrics: <MetricValue>[
            _intMetric('score', 8),
            _stringMetric('notes', 'Steady day'),
          ],
        );

        final future = controller.copyFromPreviousStaggered(
          previous,
          stepDelay: const Duration(milliseconds: 2),
        );

        expect(controller.state.metricFor('score')?.intValue, 8);
        expect(controller.state.metricFor('notes'), isNull);

        await Future<void>.delayed(const Duration(milliseconds: 3));
        expect(controller.state.metricFor('notes')?.stringValue, 'Steady day');

        await future;
      },
    );

    test(
      'most recent lookup can skip the event currently being edited',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'cato_phase7_polish_',
        );
        final isar = await Isar.open(
          <CollectionSchema<dynamic>>[EventSchema],
          directory: directory.path,
          name: 'phase7_polish_test',
          inspector: false,
        );
        addTearDown(() async {
          await isar.close(deleteFromDisk: true);
          if (directory.existsSync()) {
            await directory.delete(recursive: true);
          }
        });

        final repository = EventRepository(isar);
        final latest = _event(
          uid: 'event-latest',
          effectiveDate: DateTime(2026, 4, 18),
          metrics: <MetricValue>[_intMetric('score', 9)],
        );
        final previous = _event(
          uid: 'event-previous',
          effectiveDate: DateTime(2026, 4, 17),
          metrics: <MetricValue>[_intMetric('score', 7)],
        );

        await isar.writeTxn(() async {
          await isar.events.putAll(<Event>[latest, previous]);
        });

        final result = await repository.getMostRecentEvent(
          'tracker-mood',
          excludingEventUid: 'event-latest',
        );

        expect(result?.uid, 'event-previous');
      },
    );
  });
}

String _isarCoreLibraryPath() {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw StateError('HOME is missing for Isar test initialization.');
  }
  return '$home/.pub-cache/hosted/pub.dev/isar_flutter_libs-3.1.0+1/macos/libisar.dylib';
}

Tracker _trackerWithFields() {
  return Tracker()
    ..uid = 'tracker-mood'
    ..domainUid = 'domain-mind'
    ..name = 'Mood'
    ..icon = '😊'
    ..frequency = 'daily'
    ..promptTimes = <String>['15:00']
    ..inputSchema = <InputFieldSchema>[
      _field(
        key: 'score',
        label: 'Score',
        type: 'score',
        isRequired: true,
        sortOrder: 0,
      ),
      _field(
        key: 'notes',
        label: 'Notes',
        type: 'text',
        isRequired: false,
        sortOrder: 1,
      ),
    ]
    ..allowedVisualizations = <String>['heatmap', 'streak']
    ..scoreContribution = true
    ..scoreKey = 'score'
    ..scoreMin = 1
    ..scoreMax = 10
    ..countsForCompletion = true
    ..heatmapMode = 'score_average'
    ..sortOrder = 0
    ..isActive = true
    ..version = 2
    ..createdAt = DateTime(2026, 4, 18);
}

InputFieldSchema _field({
  required String key,
  required String label,
  required String type,
  required bool isRequired,
  required int sortOrder,
}) {
  return InputFieldSchema()
    ..key = key
    ..label = label
    ..type = type
    ..configJson = null
    ..isRequired = isRequired
    ..sortOrder = sortOrder;
}

Event _event({
  required String uid,
  required DateTime effectiveDate,
  required List<MetricValue> metrics,
}) {
  return Event()
    ..uid = uid
    ..trackerUid = 'tracker-mood'
    ..effectiveDate = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
    )
    ..effectiveTime = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
      18,
    )
    ..createdAt = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
      18,
    )
    ..updatedAt = DateTime(
      effectiveDate.year,
      effectiveDate.month,
      effectiveDate.day,
      18,
    )
    ..isBackfill = false
    ..trackerVersion = 1
    ..metrics = metrics;
}

MetricValue _intMetric(String key, int value) {
  return MetricValue()
    ..inputKey = key
    ..intValue = value;
}

MetricValue _stringMetric(String key, String value) {
  return MetricValue()
    ..inputKey = key
    ..stringValue = value;
}
