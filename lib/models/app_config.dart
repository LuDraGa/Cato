import 'package:isar/isar.dart';

part 'app_config.g.dart';

@Collection()
class AppConfig {
  AppConfig();

  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String key;
  late String value;
}

