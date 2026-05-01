import 'package:isar/isar.dart';

import '../models/app_config.dart';

class AppConfigRepository {
  const AppConfigRepository(this._isar);

  final Isar _isar;

  Stream<List<AppConfig>> watchAll() {
    return _isar.appConfigs.where().watch(fireImmediately: true);
  }

  Future<String?> getValue(String key) async {
    final item = await _isar.appConfigs.filter().keyEqualTo(key).findFirst();
    return item?.value;
  }

  Future<bool> getBool(String key, {required bool defaultValue}) async {
    final value = await getValue(key);
    if (value == null) {
      return defaultValue;
    }
    return value.toLowerCase() == 'true';
  }

  Future<void> setValue(String key, String value) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.appConfigs
          .filter()
          .keyEqualTo(key)
          .findFirst();
      final item = existing ?? AppConfig()
        ..key = key;
      item.value = value;
      await _isar.appConfigs.put(item);
    });
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.appConfigs.clear();
    });
  }
}
