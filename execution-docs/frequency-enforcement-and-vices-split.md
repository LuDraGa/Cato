# Frequency Enforcement & Vices Domain Split

**Date:** 2026-04-19
**Status:** In Progress

## Problem

1. Users can freely edit dates on entries, even moving them to dates that already have data — creating silent duplicates for trackers that should be once-per-day.
2. Breakfast, Lunch, Dinner are marked `multi_daily` but are realistically once-per-day trackers.
3. Vices is a single tracker with a `type` dropdown (Smoke/Drink/Masturbate) — but Vices is a *domain*, and each vice should be its own tracker allowing independent multi-daily logging.

## Changes

### 1. Split Vices into separate trackers
- [x] Remove single `tracker-vices` from `trackers.json`
- [x] Add `tracker-smoke`, `tracker-drink`, `tracker-masturbate` — each `multi_daily` under `domain-vices`
- [x] Each gets its own count, time, notes fields (no more `type` single_select)

### 2. Update meal frequencies
- [x] Breakfast: `multi_daily` -> `daily`
- [x] Lunch: `multi_daily` -> `daily`
- [x] Dinner: `multi_daily` -> `daily`

### 3. Frequency enforcement
- [x] In `_save()` (entry_sheet.dart): before saving a `daily` tracker, query if an entry already exists for that tracker+date (excluding the current event if editing). If conflict found, block save and show message.
- [x] In `_editDateTime()`: after picking a new date for a `daily` tracker, check for conflict before applying. If conflict, show message and don't change the date.

## Files Modified
- `assets/tracker_configs/trackers.json`
- `lib/screens/entry/entry_sheet.dart`
