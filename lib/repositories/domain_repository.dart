import 'package:isar/isar.dart';

import '../models/domain.dart';

class DomainRepository {
  const DomainRepository(this._isar);

  final Isar _isar;

  Stream<List<Domain>> watchAll() {
    return _isar.domains.where().sortBySortOrder().watch(fireImmediately: true);
  }

  Future<List<Domain>> getAll() {
    return _isar.domains.where().sortBySortOrder().findAll();
  }

  Future<void> replaceAll(List<Domain> domains) async {
    await _isar.writeTxn(() async {
      await _isar.domains.clear();
      await _isar.domains.putAll(domains);
    });
  }
}

