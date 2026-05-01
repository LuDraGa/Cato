import 'dart:async';

import 'package:sentry_flutter/sentry_flutter.dart';

class SentryMonitor {
  const SentryMonitor._();

  static const _redacted = '[redacted]';
  static const _sensitiveKeyFragments = <String>[
    'metric',
    'note',
    'text',
    'value',
    'path',
    'file',
    'media',
    'photo',
    'image',
    'token',
    'secret',
    'password',
    'dsn',
    'email',
    'user',
  ];

  static SentryEvent? beforeSend(SentryEvent event, Hint hint) {
    event.user = null;
    event.request = null;
    event.serverName = null;

    // ignore: deprecated_member_use
    final extra = event.extra;
    if (extra != null) {
      // ignore: deprecated_member_use
      event.extra = _scrubMap(extra);
    }

    final breadcrumbs = event.breadcrumbs;
    if (breadcrumbs != null) {
      for (final breadcrumb in breadcrumbs) {
        final data = breadcrumb.data;
        if (data != null) {
          breadcrumb.data = _scrubMap(data);
        }
      }
    }

    return event;
  }

  static Future<void> breadcrumb(
    String message, {
    String category = 'cato',
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) {
    return Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data == null ? null : _scrubMap(data),
        level: level,
      ),
    );
  }

  static Future<void> captureException(
    Object error,
    StackTrace stackTrace, {
    required String area,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.error,
  }) {
    return Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: (scope) async {
        scope.level = level;
        await scope.setTag('area', area);
        if (data != null && data.isNotEmpty) {
          await scope.setContexts('cato', _scrubMap(data));
        }
      },
    );
  }

  static Map<String, dynamic> _scrubMap(Map<dynamic, dynamic> input) {
    return <String, dynamic>{
      for (final entry in input.entries)
        entry.key.toString(): _scrubValue(entry.key.toString(), entry.value),
    };
  }

  static dynamic _scrubValue(String key, dynamic value) {
    final normalizedKey = key.toLowerCase();
    if (_sensitiveKeyFragments.any(normalizedKey.contains)) {
      return _redacted;
    }
    if (value is Map) {
      return _scrubMap(value);
    }
    if (value is Iterable) {
      return value.map((item) => _scrubValue(key, item)).toList();
    }
    if (value is String && _looksLikePath(value)) {
      return _redacted;
    }
    return value;
  }

  static bool _looksLikePath(String value) {
    return value.contains('/data/') ||
        value.contains('/storage/') ||
        value.contains('/Users/') ||
        value.contains('\\');
  }
}
