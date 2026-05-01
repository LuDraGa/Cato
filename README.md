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

Create a local `.env` from `.env.example`, then fill in the production values.
The local `.env` is ignored by git.

Build the Play Store app bundle:

```bash
make build-production
```

The generated app bundle is written to:

```text
build/app/outputs/bundle/release/app-release.aab
```

## GitHub Actions

CI runs on pull requests and `main` pushes. Pushes to `main` also build a
release AAB artifact and upload Sentry debug files when secrets are configured.

Required repository secrets:

```text
SENTRY_DSN
SENTRY_AUTH_TOKEN
PRIVACY_POLICY_URL
GIST_TOKEN
```

`GIST_TOKEN` needs permission to write Gists so the privacy policy workflow can
sync `docs/privacy-policy.md` to the public Privacy Policy Gist.

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
