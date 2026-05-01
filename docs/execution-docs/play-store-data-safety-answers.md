# Play Store Data Safety Answers

**Date:** 2026-05-01  
**Release:** Cato v0.1.0  
**Status:** Draft answers for Play Console

Use this after the release build is configured with the final Sentry DSN and privacy policy URL.

## Important Rule

Google Play's Data safety form is about data collected or shared by the app. Google's guidance says user data processed only locally on the user's device and not sent off device does not need to be disclosed as collected in the Data safety form.

Cato still discloses local tracker data in the Privacy Policy because users should understand what the app stores locally.

## Recommended Form Answers

### Data Collection

Answer **Yes** if the release build includes `SENTRY_DSN`.

Declare:

| Data type | Collected? | Shared? | Required? | Purpose |
|---|---:|---:|---:|---|
| App info and performance: Crash logs | Yes | No, if Sentry is acting as a service provider | Required if Sentry is enabled | App functionality, analytics |
| App info and performance: Diagnostics | Yes | No, if Sentry is acting as a service provider | Required if Sentry is enabled | App functionality, analytics |
| Device or other IDs | Verify in Sentry project settings and event payloads | No, if service provider | Required if present | App functionality, analytics |

If `SENTRY_DSN` is empty for the Play release, answer **No data collected** only after confirming no other SDK sends data off device.

### Local-Only Data

Do not mark the following as collected in Data safety if they remain only on device:

- Tracker entries, scores, counts, notes, selections, dates, and timestamps.
- Mood/energy or routine logs.
- Media attachments stored in app-private storage.
- Notification preferences and reminder times.
- Local theme, sound, haptic, and app settings.

Keep these described in the Privacy Policy.

### User-Initiated Export

If users export JSON and choose a destination, treat it as a user-initiated action. Do not mark it as app sharing unless the app automatically transfers exported data to a third party.

### Security Practices

Answer:

- Data is encrypted in transit: **Yes** for Sentry diagnostic uploads.
- Users can request data deletion: **Not applicable for accounts**, because v0.1.0 has no account creation. Local deletion happens through app reset/uninstall and local file deletion.
- Data is collected temporarily/ephemerally: **No** for Sentry crash diagnostics if retained in Sentry.

## Firebase

Firebase Core is initialized only when build-time Firebase values are supplied. For v0.1.0, do not enable Firebase Analytics, Authentication, Firestore, Cloud Messaging, or Crashlytics. If any Firebase product is enabled before release, revisit this document and Data safety answers.

## Shorebird

If Shorebird is initialized before release, review Shorebird's current privacy/FAQ documentation and confirm whether its updater telemetry affects your Data safety answer. Shorebird currently documents that its code push requests do not send personally identifiable information, but include updater metadata such as app id, release version, patch number, architecture, platform, and an anonymous aggregated client id.

## Release Verification

Before submitting:

- Build with final `SENTRY_DSN`, `SENTRY_ENVIRONMENT=production`, `SENTRY_RELEASE`, and `PRIVACY_POLICY_URL`.
- Trigger a test crash or captured exception in a non-production Sentry environment first.
- Inspect the Sentry event payload for user identifiers, IP behavior, breadcrumbs, screenshots, attachments, and view hierarchy.
- Confirm `sendDefaultPii=false`, `attachScreenshot=false`, and `attachViewHierarchy=false`.
- Confirm Firebase Analytics is not in `pubspec.yaml` and no Firebase backend product is used in app flows.

## Official References

- [Google Play Data safety form guidance](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Google Play User Data policy](https://support.google.com/googleplay/android-developer/answer/10144311)
