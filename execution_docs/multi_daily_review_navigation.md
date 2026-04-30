# Multi-Daily Entry Review & Carousel Navigation

**Date:** 2026-05-01
**Status:** In Progress

## Context

Following completion of frequency enforcement and vices split, this work extends the review experience for multi_daily trackers. Users can now log multiple entries per day (Workout, Sleep, Mood, Smoke, Drink, Masturbate), but the review page only shows the most recent entry when clicking a day. This creates a poor experience for viewing and editing multiple entries on the same date.

## Goal

Build a layered UX for reviewing multi_daily entries:
1. Day Summary view showing all entries for a date, sorted by time
2. Entry carousel navigation (swipe left/right between entries)
3. Coordinated animations (summary slides in left→right, entry sheet slides in right→left)
4. Gesture support (swipe down to close, swipe left/right to navigate)

## Design Spec

### Summary View (Day Entry Summary)
- Shows all entries for the selected date, sorted by entry time (earliest first)
- Displays entry metadata (time, key metrics)
- "Add New Entry" button at bottom
- Flows in from left-to-right when opened

### Entry Sheet Navigation
- Clicking an entry in summary opens that entry for editing
- Clicking "Add New Entry" opens blank entry sheet
- Flows in from right-to-left, pushing summary left
- Swipe down closes entry sheet → returns to summary
- Swipe left/right navigates to next/previous entry in carousel

### Animations & Gestures
- Summary: SlideTransition (left→right), duration 300ms, curve: easeOutCubic
- Entry sheet: SlideTransition (right→left), duration 300ms, curve: easeOutCubic
- Swipe gestures: GestureDetector with threshold ~50px
- Swipe down closes; swipe left/right navigates carousel

## Implementation Steps

### Step 1: Build Day Summary View ✏️ IN PROGRESS
- [ ] Create `DayEntrySummary` widget (lib/screens/review/widgets/day_entry_summary.dart)
- [ ] Query entries for selected date, sorted by time
- [ ] Display entry list with time + key metrics
- [ ] Add "New Entry" button at bottom
- [ ] Wire up onTap callbacks (item → edit, button → new)
- [ ] Test: clicking day in week_review opens summary for multi_daily trackers

### Step 2: Entry Sheet Carousel Navigation
- [ ] Create `EntryCarouselController` to manage current entry index
- [ ] Modify entry_sheet.dart to accept list of entries + current index
- [ ] Add nav controls (prev/next buttons) in entry sheet header
- [ ] Implement swipe left/right detection for carousel
- [ ] Test: swipe between entries in summary for same date

### Step 3: Animation & Transition Orchestration
- [ ] Add SlideTransition animation to summary (left→right entry)
- [ ] Add SlideTransition animation to entry sheet (right→left entry)
- [ ] Coordinate timing so entry sheet pushes summary off-screen
- [ ] Test: smooth coordinated animations on open/close

### Step 4: Gesture Handling (Swipe Down, Left/Right)
- [ ] Add swipe down detection in entry sheet → close + return to summary
- [ ] Verify swipe left/right works with carousel nav
- [ ] Add swipe down detection in summary → close entire view
- [ ] Test: all gesture directions work as expected

## Files to Create/Modify
- **Create:** lib/screens/review/widgets/day_entry_summary.dart
- **Modify:** lib/screens/review/widgets/week_review.dart (open summary for multi_daily)
- **Modify:** lib/screens/entry/entry_sheet.dart (carousel support)
- **Create:** lib/models/entry_carousel_controller.dart (optional, if needed)

## Related Prior Work

### Frequency Enforcement & Vices Split (Completed 2026-05-01)
- Daily trackers (Breakfast, Lunch, Dinner) enforce one entry per date
- Vices split into three independent multi_daily trackers (Smoke, Drink, Masturbate)
- Expanded Workout, Sleep, Mood to multi_daily for flexibility
- Home screen shows separate pills for each multi_daily entry
- Entry sheet allows date changes for multi_daily entries

### Haptic Redesign (Ongoing)
- Shape-first pattern API with intensity scaling
- Per-call granularity for haptic feedback

## Notes

- Multi_daily on review should aggregate for display (later iteration)
- Review page month/year views need same multi_daily handling
- Sound + animation coordination still pending per haptic design notes
