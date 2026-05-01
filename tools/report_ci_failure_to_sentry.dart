import 'dart:convert';
import 'dart:io';
import 'dart:math';

const _clientName = 'cato-ci/0.1.0';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final env = Platform.environment;
  final dsn = env['SENTRY_DSN'];

  if (dsn == null || dsn.isEmpty) {
    stdout.writeln('SENTRY_DSN is not set; skipping Sentry CI report.');
    return;
  }

  final dsnParts = _SentryDsn.parse(dsn);
  final eventId = _eventId();
  final sentAt = DateTime.now().toUtc().toIso8601String();
  final payload = jsonEncode(_buildEvent(env, eventId, sentAt));
  final envelope = [
    jsonEncode(<String, Object>{
      'event_id': eventId,
      'dsn': dsn,
      'sent_at': sentAt,
      'sdk': <String, String>{'name': 'cato.ci', 'version': '0.1.0'},
    }),
    jsonEncode(<String, Object>{
      'type': 'event',
      'length': utf8.encode(payload).length,
    }),
    payload,
  ].join('\n');

  if (dryRun) {
    stdout.writeln('Prepared Sentry CI event for ${dsnParts.envelopeUri}.');
    stdout.writeln(payload);
    return;
  }

  final client = HttpClient();
  try {
    final request = await client.postUrl(dsnParts.envelopeUri);
    request.headers.contentType = ContentType(
      'application',
      'x-sentry-envelope',
      charset: 'utf-8',
    );
    request.headers.set(
      'X-Sentry-Auth',
      'Sentry sentry_version=7, sentry_key=${dsnParts.publicKey}, sentry_client=$_clientName',
    );
    request.write(envelope);

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      stderr.writeln(
        'Sentry CI report failed with HTTP ${response.statusCode}: $responseBody',
      );
      exitCode = 1;
      return;
    }

    stdout.writeln('Reported CI failure to Sentry event_id=$eventId.');
  } finally {
    client.close(force: true);
  }
}

Map<String, Object> _buildEvent(
  Map<String, String> env,
  String eventId,
  String timestamp,
) {
  final workflow = _value(env, 'GITHUB_WORKFLOW', fallback: 'unknown-workflow');
  final job = _value(env, 'GITHUB_JOB', fallback: 'unknown-job');
  final repository = _value(env, 'GITHUB_REPOSITORY', fallback: 'unknown-repo');
  final runId = _value(env, 'GITHUB_RUN_ID', fallback: 'unknown-run');
  final runAttempt = _value(env, 'GITHUB_RUN_ATTEMPT', fallback: '1');
  final ref = _value(env, 'GITHUB_REF', fallback: 'unknown-ref');
  final sha = _value(env, 'GITHUB_SHA', fallback: 'unknown-sha');
  final serverUrl = _value(
    env,
    'GITHUB_SERVER_URL',
    fallback: 'https://github.com',
  );
  final runUrl = '$serverUrl/$repository/actions/runs/$runId';
  final shortSha = sha.length >= 12 ? sha.substring(0, 12) : sha;
  final message = 'GitHub Actions job failed: $workflow / $job';

  return <String, Object>{
    'event_id': eventId,
    'timestamp': timestamp,
    'platform': 'other',
    'level': 'error',
    'logger': 'github_actions',
    'server_name': 'github-actions',
    'environment': _value(env, 'SENTRY_CI_ENVIRONMENT', fallback: 'ci'),
    if (_value(env, 'SENTRY_CI_RELEASE').isNotEmpty)
      'release': _value(env, 'SENTRY_CI_RELEASE'),
    'message': message,
    'fingerprint': <String>['ci-pipeline', workflow, job],
    'tags': <String, String>{
      'telemetry.source': 'ci',
      'platform': 'ci',
      'pipeline': 'github_actions',
      'workflow': _tag(workflow),
      'job': _tag(job),
      'repository': _tag(repository),
      'event_name': _tag(_value(env, 'GITHUB_EVENT_NAME')),
      'ref': _tag(ref),
      'sha': _tag(shortSha),
      'run_attempt': _tag(runAttempt),
      'runner_os': _tag(_value(env, 'RUNNER_OS')),
    },
    'contexts': <String, Object>{
      'ci': <String, String>{
        'provider': 'github_actions',
        'workflow': workflow,
        'job': job,
        'repository': repository,
        'run_id': runId,
        'run_attempt': runAttempt,
        'run_url': runUrl,
        'ref': ref,
        'sha': sha,
      },
    },
    'extra': <String, String>{
      'run_url': runUrl,
      'commit_url': '$serverUrl/$repository/commit/$sha',
    },
  };
}

String _value(Map<String, String> env, String key, {String fallback = ''}) {
  final value = env[key];
  if (value == null || value.isEmpty) {
    return fallback;
  }
  return value;
}

String _tag(String value) {
  const maxTagLength = 200;
  if (value.length <= maxTagLength) {
    return value;
  }
  return value.substring(0, maxTagLength);
}

String _eventId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

class _SentryDsn {
  const _SentryDsn({required this.publicKey, required this.envelopeUri});

  final String publicKey;
  final Uri envelopeUri;

  static _SentryDsn parse(String dsn) {
    final uri = Uri.parse(dsn);
    if (uri.scheme.isEmpty || uri.host.isEmpty || uri.pathSegments.isEmpty) {
      throw FormatException('Invalid Sentry DSN.', dsn);
    }

    final projectId = uri.pathSegments.last;
    final publicKey = uri.userInfo.split(':').first;
    if (projectId.isEmpty || publicKey.isEmpty) {
      throw FormatException('Invalid Sentry DSN.', dsn);
    }

    final pathPrefix = uri.pathSegments.take(uri.pathSegments.length - 1);
    return _SentryDsn(
      publicKey: publicKey,
      envelopeUri: uri.replace(
        userInfo: '',
        pathSegments: <String>[...pathPrefix, 'api', projectId, 'envelope'],
        query: null,
        fragment: null,
      ),
    );
  }
}
