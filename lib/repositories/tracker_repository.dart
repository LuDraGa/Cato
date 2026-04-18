import 'package:isar/isar.dart';

import '../models/tracker.dart';

class TrackerRepository {
  const TrackerRepository(this._isar);

  final Isar _isar;

  Stream<List<Tracker>> watchAll() {
    return _isar.trackers.where().sortBySortOrder().watch(fireImmediately: true);
  }

  Stream<List<Tracker>> watchActive() {
    return _isar.trackers
        .filter()
        .isActiveEqualTo(true)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Future<List<Tracker>> getAllActive() {
    return _isar.trackers.filter().isActiveEqualTo(true).sortBySortOrder().findAll();
  }

  Future<Tracker?> getByUid(String uid) {
    return _isar.trackers.filter().uidEqualTo(uid).findFirst();
  }

  Future<void> replaceAll(List<Tracker> trackers) async {
    await _isar.writeTxn(() async {
      await _isar.trackers.clear();
      await _isar.trackers.putAll(trackers);
    });
  }
}

