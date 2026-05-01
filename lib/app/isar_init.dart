import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/app_config.dart';
import '../models/domain.dart';
import '../models/event.dart';
import '../models/tracker.dart';

Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(<CollectionSchema<dynamic>>[
    DomainSchema,
    TrackerSchema,
    EventSchema,
    AppConfigSchema,
  ], directory: dir.path);
}
