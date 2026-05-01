import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/event.dart';
import '../repositories/app_config_repository.dart';
import '../repositories/domain_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/tracker_repository.dart';
import '../services/api_client.dart';
import '../services/config_loader.dart';
import '../services/export_service.dart';
import '../services/media_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';

final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());

final dioProvider = Provider<Dio>((ref) => createDioClient());

final appConfigRepositoryProvider = Provider<AppConfigRepository>(
  (ref) => AppConfigRepository(ref.watch(isarProvider)),
);

final domainRepositoryProvider = Provider<DomainRepository>(
  (ref) => DomainRepository(ref.watch(isarProvider)),
);

final trackerRepositoryProvider = Provider<TrackerRepository>(
  (ref) => TrackerRepository(ref.watch(isarProvider)),
);

final eventRepositoryProvider = Provider<EventRepository>(
  (ref) => EventRepository(ref.watch(isarProvider)),
);

final configLoaderProvider = Provider<ConfigLoader>(
  (ref) => ConfigLoader(ref.watch(isarProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => throw UnimplementedError(),
);

final soundServiceProvider = Provider<SoundService>(
  (ref) => throw UnimplementedError(),
);

final mediaServiceProvider = Provider<MediaService>((ref) => MediaService());

final exportServiceProvider = Provider<ExportService>(
  (ref) => ExportService(ref.watch(isarProvider)),
);

final pendingAppActionProvider = StateProvider<PendingAppAction?>(
  (ref) => null,
);

final initialAppActionProvider = Provider<PendingAppAction?>((ref) => null);

final pendingSaveEventProvider = StateProvider<Event?>((ref) => null);

class HomeFeedbackState {
  const HomeFeedbackState({required this.pending, required this.epoch});

  final bool pending;
  final int epoch;

  HomeFeedbackState copyWith({bool? pending, int? epoch}) {
    return HomeFeedbackState(
      pending: pending ?? this.pending,
      epoch: epoch ?? this.epoch,
    );
  }
}

class HomeFeedbackController extends StateNotifier<HomeFeedbackState> {
  HomeFeedbackController()
    : super(const HomeFeedbackState(pending: false, epoch: 0));

  void beginSave() {
    state = state.copyWith(pending: true);
  }

  void completeSave() {
    state = HomeFeedbackState(pending: false, epoch: state.epoch + 1);
  }

  void cancelSave() {
    state = state.copyWith(pending: false);
  }
}

final homeFeedbackProvider =
    StateNotifierProvider<HomeFeedbackController, HomeFeedbackState>(
      (ref) => HomeFeedbackController(),
    );

final middayTimeProvider = StreamProvider<String>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return repository.watchAll().map((items) {
    return items
        .firstWhere(
          (item) => item.key == 'midday_time',
          orElse: () => throw StateError('midday_time missing'),
        )
        .value;
  });
});

final dayEndTimeProvider = StreamProvider<String>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return repository.watchAll().map((items) {
    return items
        .firstWhere(
          (item) => item.key == 'day_end_time',
          orElse: () => throw StateError('day_end_time missing'),
        )
        .value;
  });
});

final notificationsEnabledProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return repository.watchAll().map((items) {
    final value = items
        .firstWhere(
          (item) => item.key == 'notifications_enabled',
          orElse: () => throw StateError('notifications_enabled missing'),
        )
        .value;
    return value.toLowerCase() == 'true';
  });
});

final soundEnabledProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(appConfigRepositoryProvider);
  return repository.watchAll().map((items) {
    final value = items
        .firstWhere(
          (item) => item.key == 'sound_enabled',
          orElse: () => throw StateError('sound_enabled missing'),
        )
        .value;
    return value.toLowerCase() == 'true';
  });
});
