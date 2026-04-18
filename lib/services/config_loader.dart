import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isar/isar.dart';

import '../models/app_config.dart';
import '../models/domain.dart';
import '../models/event.dart';
import '../models/tracker.dart';
import '../repositories/app_config_repository.dart';
import '../repositories/domain_repository.dart';
import '../repositories/tracker_repository.dart';

class ConfigLoader {
  ConfigLoader(this._isar)
      : _domainRepository = DomainRepository(_isar),
        _trackerRepository = TrackerRepository(_isar),
        _appConfigRepository = AppConfigRepository(_isar);

  final Isar _isar;
  final DomainRepository _domainRepository;
  final TrackerRepository _trackerRepository;
  final AppConfigRepository _appConfigRepository;

  Future<void> seedIfNeeded() async {
    final seeded = await _appConfigRepository.getBool(
      'seeded',
      defaultValue: false,
    );
    if (seeded) {
      return;
    }

    final domainsJson = await rootBundle.loadString(
      'assets/tracker_configs/domains.json',
    );
    final trackersJson = await rootBundle.loadString(
      'assets/tracker_configs/trackers.json',
    );

    final domains = (jsonDecode(domainsJson) as List)
        .map((item) => Domain.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    final trackers = (jsonDecode(trackersJson) as List)
        .map((item) => Tracker.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    await _domainRepository.replaceAll(domains);
    await _trackerRepository.replaceAll(trackers);
    await _appConfigRepository.setValue('seeded', 'true');
    await _appConfigRepository.setValue('notifications_enabled', 'true');
    await _appConfigRepository.setValue('midday_time', '13:30');
    await _appConfigRepository.setValue('day_end_time', '21:30');
    await _appConfigRepository.setValue('sound_enabled', 'false');
    await _appConfigRepository.setValue('sound_prompt_shown', 'false');
    await _appConfigRepository.setValue('notification_permission_requested', 'false');
  }

  Future<void> resetAndReseed() async {
    await _isar.writeTxn(() async {
      await _isar.events.clear();
      await _isar.trackers.clear();
      await _isar.domains.clear();
      await _isar.appConfigs.clear();
    });
    await seedIfNeeded();
  }
}
