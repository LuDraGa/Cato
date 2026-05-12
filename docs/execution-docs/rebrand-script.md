# Rebrand Script

**Date:** 2026-05-12
**Status:** ✅ Shipped — pre-launch tool for renaming the Android package id and display name in one command.

## Why

Android `applicationId` (= Play app identity) is **permanent** once the first AAB is published to Play. Pre-launch, the package can be renamed freely, but the package id is referenced across `build.gradle.kts`, Kotlin folder paths, `package` declarations, and the manifest — manual rename is error-prone. This script centralises that rename to one command and gates it on a Play-publication flag so post-launch renames can't happen by accident.

## Usage

```bash
make rebrand PACKAGE=dev.ludraga.cato
make rebrand PACKAGE=dev.ludraga.cato NAME="Cato"
# or:
bash tools/rebrand.sh --package dev.ludraga.cato --name "Cato"
```

Flags:

| Flag | Required | Purpose |
|---|---|---|
| `--package` | Yes | New reverse-DNS package id (`^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$`) |
| `--name` | No | New `android:label` for the manifest (display name on the home screen) |
| `--yes` | No | Skip the interactive prompts (CI use only — bypasses the published-yet check) |

## What it touches

| File | Change |
|---|---|
| `android/app/build.gradle.kts` | `namespace` + `applicationId` |
| `android/app/src/main/kotlin/<old>/` → `<new>/` | Folder move via `git mv` (history preserved); old empty dirs pruned |
| Every `*.kt` under the new path | Rewrites the `package` declaration |
| `android/app/src/main/AndroidManifest.xml` | `android:label` (only with `--name`) |
| `android/play_status.yaml` | Bumps `last_checked` |
| `flutter clean` | Run at end so stale R-classes don't bite |

## Lock semantics — `android/play_status.yaml`

```yaml
published: false
last_checked: 2026-05-12
```

| State | Behaviour |
|---|---|
| `published: false` | Script prompts: "Has Cato been published to Play yet? (y/N)". `N` → rebrand proceeds. `y` → flips file to `true` and aborts (package now locked). |
| `published: true` | Rebrand refused with exit code 1. Manual edit of `play_status.yaml` is the escape hatch. |

The Play API isn't checked — this is dev-intelligence-plus-tracked-flag, which is enough for a solo project.

## Safety rails

1. Refuses if the working tree is dirty (forces a clean commit before mutating).
2. Refuses if the new package fails the reverse-DNS regex.
3. Refuses if `play_status.yaml` says `published: true`.
4. No-ops gracefully if `PACKAGE` already matches the current `applicationId` (still updates display name if `--name` given).
5. Prints any stray references to the old package across the repo (excluding `build/` and `docs/`) so leftovers can be reviewed.

## Override (post-launch)

If you genuinely need to rebrand after a Play upload (e.g. fresh listing on a new track, not a rename of the live app):

1. Open `android/play_status.yaml`, set `published: false`.
2. Leave a one-line git note explaining why (new listing, sunset of old id, etc.).
3. Run the script.
4. Treat the new package as a **brand-new Play app**: new keystore, new listing, new Data safety form. The old listing remains under the old package.

## Out of scope

- iOS bundle id — no iOS in this repo.
- Flutter Dart package name (`pubspec.yaml` `name:`) — internal Dart only, never user-facing.
- App icon swap — handled by `make brand-assets`.
- Keystore rotation — separate flow; package rename pre-launch keeps the same debug keystore.
