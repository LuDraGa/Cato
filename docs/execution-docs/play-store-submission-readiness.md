# Play Store Submission Readiness

**Date:** 2026-05-01  
**Status:** Draft checklist for first Google Play submission  
**Scope:** Cato Android v0.1.0 first submission

---

## Purpose

This document converts the Play Academy first-submission guidance into a Cato-specific release checklist. It should be reviewed before creating the first production or testing-track Play Console submission.

Primary policy references:

- [Google Play Developer Program Policy Center](https://play.google/developer-content-policy/)
- [Functionality, Content, and User Experience](https://support.google.com/googleplay/android-developer/answer/9898783)
- [Deceptive Behavior](https://support.google.com/googleplay/android-developer/answer/16680223)
- [User Data](https://support.google.com/googleplay/android-developer/answer/10144311)
- [Data safety section](https://support.google.com/googleplay/android-developer/answer/10787469)
- [Login credentials for app access](https://support.google.com/googleplay/android-developer/answer/15748846)
- [Account deletion requirements](https://support.google.com/googleplay/android-developer/answer/13327111)

---

## Cato Submission Facts

| Area | Current v0.1.0 position | Play Console implication |
|---|---|---|
| Platform | Android only | Configure Android release only |
| Account/login | No auth for v0.1.0 | App access can state no credentials are required |
| Core data | Local-first Isar storage on device | Privacy policy must explain local tracker/event/media storage |
| Camera/media | User can attach media through camera/gallery | Data safety and privacy policy must reflect media access and local storage behavior |
| Notifications | Local reminders, max 2/day | Declare notification behavior; no data sharing implied by local notifications |
| Analytics | Firebase initialized, no analytics wired | Verify SDK behavior before Data safety submission |
| Crash reporting | Sentry initialized | Data safety/privacy policy must reflect crash/error telemetry sent to Sentry |
| Backend/API | No production backend required for MVP behavior | Store listing should not imply cloud sync, accounts, or sharing |
| Hidden/dev tools | Dev panel accessible by long-press version 5x | Release gate: remove, disable, or clearly document before production |

---

## Release Gates

### 1. Broken Functionality

Google Play does not allow apps that fail to install, crash, freeze, become unresponsive, or provide little usable value.

- [ ] Build a signed release artifact for Play.
- [ ] Install the release build on at least one physical Android device.
- [ ] Launch from a cold start without crash or repeated error.
- [ ] Complete the core loop: open Home, log each tracker type, edit an entry, backfill from Review, save batch entry.
- [ ] Verify camera capture, gallery selection, compression, and thumbnail display.
- [ ] Verify notification permission flow and local reminder scheduling on Android 13+.
- [ ] Verify the app remains usable if notification permission is denied.
- [ ] Verify empty state, first-day state, and restart persistence.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build apk --release` or the Play release build command.

### 2. Deceptive Behavior

The app, store listing, screenshots, and metadata must accurately represent what Cato does. Avoid implying medical treatment, diagnosis, cure, guaranteed behavior change, official endorsement, or cloud features that are not present in v0.1.0.

- [ ] Store title, short description, full description, screenshots, and icon match actual v0.1.0 functionality.
- [ ] Do not claim Cato diagnoses, treats, cures, prevents, or clinically improves any condition.
- [ ] Do not imply affiliation with Google, Android, Play Academy, healthcare providers, or any public entity.
- [ ] Do not show screens or features that are not in the submitted build.
- [ ] Do not mention future Firebase sync, auth, sharing, subscriptions, or partner features unless they are active in the submitted build.
- [ ] Ensure notification copy is calm and not misleading or coercive.
- [ ] Ensure all permission requests are user-initiated or clearly tied to visible app functionality.
- [ ] Ensure any setting changes are explicit, user-controlled, and reversible.
- [ ] Release gate: remove or production-disable the hidden dev panel, or document why it exists and ensure it cannot expose destructive or review-only behavior.

### 3. Login Credentials and Reviewer Access

For v0.1.0, Cato has no login, no subscription gate, and no restricted role-based functionality.

Play Console App access declaration:

```text
Cato does not require login credentials for this version. All app functionality is available without an account, subscription, payment, OTP, 2-Step Verification, QR code, or location-dependent access.
```

If auth, paid access, or restricted features are added before submission:

- [ ] Provide reusable credentials that do not expire.
- [ ] Provide credentials valid from any reviewer location.
- [ ] Provide English-language access instructions.
- [ ] Provide a demo account for each role or access type.
- [ ] Provide static URLs for any QR/barcode-based access.
- [ ] Provide a non-biometric fallback if biometric auth is introduced.

### 4. Data Safety

The Data safety form must match the app behavior, SDK behavior, and privacy policy. Complete the privacy policy first, then fill out Data safety.

Current audit items to verify before submission:

- [ ] Confirm exactly what Sentry collects in release mode: crash logs, diagnostics, device/app metadata, breadcrumbs, user identifiers, IP handling, attachments, and sampling.
- [ ] Confirm Firebase Core alone does not enable Analytics or other data collection in this build.
- [ ] Confirm no Dio/Retrofit production calls transmit tracker data.
- [ ] Confirm media files stay in app-private storage unless the user explicitly exports/shares.
- [ ] Confirm JSON export behavior and whether it invokes Android share targets only by user action.
- [ ] Confirm no advertising SDKs are present.
- [ ] Confirm no account creation exists in the submitted build.

Likely Data safety areas for v0.1.0:

| Data area | Current expectation | Form/policy note |
|---|---|---|
| Health/fitness or wellness-style tracker entries | Stored locally by the app | Disclose in privacy policy; Data safety depends on whether any data is transmitted off device |
| Photos/media | User-selected, app-private local storage | Disclose camera/gallery access and local storage |
| Crash/error telemetry | Sent to Sentry if enabled | Disclose collection/sharing with service provider and purpose |
| Device/app diagnostics | May be sent by Sentry or SDKs | Verify and disclose accurately |
| Notifications | Local scheduling | Explain local reminders; no remote notification provider currently required |

Do not submit the Data safety form until SDK behavior is verified against the actual release build.

### 5. Privacy Policy

Google Play requires a privacy policy in Play Console and inside the app, even if the app does not collect personal/sensitive data.

Privacy policy requirements:

- [ ] Title the document clearly as `Privacy Policy`.
- [ ] Name the app (`Cato`) and developer or developer entity.
- [ ] Provide a privacy contact email or inquiry mechanism.
- [ ] Host the policy at an active, public, non-geofenced, non-editable URL.
- [ ] Do not use a PDF as the policy URL.
- [ ] Link the same policy in Play Console.
- [ ] Add an in-app privacy policy link, likely under Settings.
- [ ] Describe local tracker data, event history, media attachments, settings, notification preferences, and exports.
- [ ] Describe Sentry and any SDK/service providers that receive diagnostics.
- [ ] Describe secure handling, including app-private local storage and transport encryption for any telemetry.
- [ ] Describe retention and deletion: local data remains until the user deletes entries, resets the app, uninstalls the app, or uses any provided deletion/export controls.
- [ ] Keep the privacy policy consistent with the Data safety form.

### 6. Account Deletion

For v0.1.0, Cato does not allow account creation, so Play's account deletion requirement should not apply.

If account creation is added before submission:

- [ ] Add an in-app path to request/delete the account.
- [ ] Add an outside-the-app web deletion path.
- [ ] Enter the deletion URL in Play Console.
- [ ] Delete associated account data when deletion is requested.
- [ ] Clearly explain any data retained for legal, security, fraud-prevention, or compliance reasons.

---

## Store Listing Guardrails

Use wording that matches the local-first MVP:

- Cato is a daily self-tracking app.
- Cato helps users log daily habits, mood/energy, review history, and set local reminders.
- Data is stored on the device for this release.
- Media attachments are user-selected and stored locally.

Avoid:

- Medical or therapeutic claims.
- Guaranteed outcome claims.
- Official affiliation claims.
- Claims about sync, accounts, sharing, subscriptions, AI coaching, or cloud backup unless implemented in the submitted build.
- Screenshots containing placeholder, debug, seed, or hidden-tool content.

---

## Pre-Submission Checklist

- [ ] Privacy policy drafted, hosted, and linked in-app.
- [ ] Privacy policy URL added in Play Console.
- [ ] Data safety form completed from verified release-build behavior.
- [ ] App access declaration completed.
- [ ] Store listing copy and screenshots reviewed for accuracy.
- [ ] Content rating questionnaire completed.
- [ ] Target audience and content settings completed.
- [ ] App category selected accurately.
- [ ] Release artifact signed and uploaded.
- [ ] Internal testing or closed testing smoke test completed before production rollout.
- [ ] Hidden dev panel removed, disabled, or explicitly handled.
- [ ] Release notes accurately describe current functionality.

