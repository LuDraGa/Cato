import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app/app.dart';
import 'app/isar_init.dart';
import 'firebase_options.dart';
import 'providers/core_providers.dart';
import 'services/api_client.dart';
import 'services/config_loader.dart';
import 'services/notification_service.dart';
import 'services/sentry_monitor.dart';
import 'services/sound_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  const sentryEnvironment = String.fromEnvironment(
    'SENTRY_ENVIRONMENT',
    defaultValue: kReleaseMode ? 'production' : 'development',
  );
  const sentryRelease = String.fromEnvironment('SENTRY_RELEASE');

  if (sentryDsn.isEmpty) {
    await _bootstrapAndRunApp();
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = sentryDsn;
    options.environment = sentryEnvironment;
    if (sentryRelease.isNotEmpty) {
      options.release = sentryRelease;
    }
    options.sendDefaultPii = false;
    options.tracesSampleRate = 0.0;
    options.attachScreenshot = false;
    options.attachViewHierarchy = false;
    options.reportViewHierarchyIdentifiers = false;
    options.enableUserInteractionTracing = false;
    options.beforeSend = SentryMonitor.beforeSend;
  }, appRunner: _bootstrapAndRunApp);
}

Future<void> _bootstrapAndRunApp() async {
  await SentryMonitor.breadcrumb('app bootstrap started', category: 'startup');

  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  if (firebaseOptions != null) {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      await SentryMonitor.breadcrumb(
        'firebase initialized',
        category: 'startup',
      );
    } catch (error, stackTrace) {
      await SentryMonitor.captureException(
        error,
        stackTrace,
        area: 'startup.firebase',
        level: SentryLevel.warning,
      );
      // Firebase is optional for core app behavior.
    }
  }

  await SentryMonitor.breadcrumb(
    'isar initialization started',
    category: 'startup',
  );
  final isar = await initIsar();
  await SentryMonitor.breadcrumb('isar initialized', category: 'startup');

  final configLoader = ConfigLoader(isar);
  await configLoader.seedIfNeeded();

  final notificationService = NotificationService(isar);
  final initialAction = await notificationService.initialize();
  await notificationService.requestPermissionOnFirstOpen();
  await notificationService.syncSchedules();

  final soundService = SoundService();
  await soundService.warmUp();

  final app = ProviderScope(
    overrides: <Override>[
      isarProvider.overrideWithValue(isar),
      dioProvider.overrideWithValue(createDioClient()),
      notificationServiceProvider.overrideWithValue(notificationService),
      soundServiceProvider.overrideWithValue(soundService),
      initialAppActionProvider.overrideWithValue(initialAction),
    ],
    child: const CatoApp(),
  );

  await SentryMonitor.breadcrumb('app bootstrap complete', category: 'startup');
  runApp(app);
}
