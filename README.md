# Cato

Android-first Flutter app for local-first daily self-tracking.

## Requirements

- Flutter SDK
- Android SDK
- Android device or emulator running Android 8.0+ (API 26+)

## Development

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Release Build

Build the Play Store app bundle:

```bash
flutter build appbundle --release \
  --dart-define=PRIVACY_POLICY_URL="https://gist.github.com/abhiroopprasad/TODO" \
  --dart-define=SENTRY_DSN="TODO" \
  --dart-define=SENTRY_ENVIRONMENT="production" \
  --dart-define=SENTRY_RELEASE="cato@0.1.0+1"
```

If Sentry is not ready for a release, omit `SENTRY_DSN`.

The generated app bundle is written to:

```text
build/app/outputs/bundle/release/app-release.aab
```

## Branding Assets

The placeholder brand source lives in:

```text
assets/brand/brand_master.svg
```

Regenerate derived PNG assets:

```bash
bash tools/export_brand_assets.sh
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Replace the placeholder SVGs before final Play Store branding.

## Release Docs

- `docs/privacy-policy.md`
- `docs/execution-docs/play-store-submission-readiness.md`
- `docs/execution-docs/play-store-data-safety-answers.md`
- `docs/execution-docs/play-store-listing-copy.md`
- `docs/execution-docs/release-operations.md`

