import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/app_config.dart';
import '../models/domain.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import 'sentry_monitor.dart';

class ExportService {
  const ExportService(this._isar);

  final Isar _isar;

  Future<File> exportJson() async {
    await SentryMonitor.breadcrumb('data export started', category: 'export');
    try {
      final domains = await _isar.domains.where().findAll();
      final trackers = await _isar.trackers.where().findAll();
      final events = await _isar.events.where().findAll();
      final appConfig = await _isar.appConfigs.where().findAll();

      final payload = <String, dynamic>{
        'domains': domains.map((item) => item.toJson()).toList(),
        'trackers': trackers.map((item) => item.toJson()).toList(),
        'events': events.map((item) => item.toJson()).toList(),
        'appConfig': appConfig
            .map(
              (item) => <String, dynamic>{'key': item.key, 'value': item.value},
            )
            .toList(),
      };

      final downloadsDirectory =
          await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File(
        path.join(
          downloadsDirectory.path,
          'cato-export-${DateTime.now().millisecondsSinceEpoch}.json',
        ),
      );
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
      await SentryMonitor.breadcrumb(
        'data export completed',
        category: 'export',
        data: <String, dynamic>{
          'domains_count': domains.length,
          'trackers_count': trackers.length,
          'events_count': events.length,
          'app_config_count': appConfig.length,
        },
      );
      return file;
    } catch (error, stackTrace) {
      await SentryMonitor.captureException(
        error,
        stackTrace,
        area: 'export.json',
      );
      rethrow;
    }
  }
}
