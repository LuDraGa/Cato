import 'dart:convert';
import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/app_config.dart';
import '../models/domain.dart';
import '../models/event.dart';
import '../models/tracker.dart';

class ExportService {
  const ExportService(this._isar);

  final Isar _isar;

  Future<File> exportJson() async {
    final payload = <String, dynamic>{
      'domains': (await _isar.domains.where().findAll())
          .map((item) => item.toJson())
          .toList(),
      'trackers': (await _isar.trackers.where().findAll())
          .map((item) => item.toJson())
          .toList(),
      'events': (await _isar.events.where().findAll())
          .map((item) => item.toJson())
          .toList(),
      'appConfig': (await _isar.appConfigs.where().findAll())
          .map((item) => <String, dynamic>{'key': item.key, 'value': item.value})
          .toList(),
    };

    final downloadsDirectory =
        await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File(
      path.join(
        downloadsDirectory.path,
        'cato-export-${DateTime.now().millisecondsSinceEpoch}.json',
      ),
    );
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
    return file;
  }
}
