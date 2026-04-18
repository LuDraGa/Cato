import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/domain.dart';
import '../models/tracker.dart';
import 'core_providers.dart';

final allDomainsProvider = StreamProvider<List<Domain>>((ref) {
  return ref.watch(domainRepositoryProvider).watchAll();
});

final allTrackersProvider = StreamProvider<List<Tracker>>((ref) {
  return ref.watch(trackerRepositoryProvider).watchActive();
});

final completionEligibleTrackersProvider = Provider<List<Tracker>>((ref) {
  final trackers = ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
  return trackers.where((tracker) => tracker.countsForCompletion).toList();
});

final scoreEligibleTrackersProvider = Provider<List<Tracker>>((ref) {
  final trackers = ref.watch(allTrackersProvider).valueOrNull ?? const <Tracker>[];
  return trackers.where((tracker) => tracker.scoreContribution).toList();
});

final domainsByUidProvider = Provider<Map<String, Domain>>((ref) {
  final domains = ref.watch(allDomainsProvider).valueOrNull ?? const <Domain>[];
  return <String, Domain>{
    for (final domain in domains) domain.uid: domain,
  };
});

