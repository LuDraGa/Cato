# Multi-Daily Entry Review & Carousel Navigation

**Date:** 2026-05-01
**Status:** In Progress (Step 2/4 Complete)

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

### Step 1: Build Day Summary View ✅ COMPLETE
- [x] Create `DayEntrySummary` widget (lib/screens/review/widgets/day_entry_summary.dart)
- [x] Query entries for selected date, sorted by time
- [x] Display entry list with time + key metrics
- [x] Add "New Entry" button at bottom
- [x] Wire up onTap callbacks (item → edit, button → new)
- [x] Modify week_review.dart and month_review.dart to open summary for multi_daily trackers
- [x] Exclude year_review.dart — heatmap cells too small for reliable selection
- [x] Test on device: verified working in week & month views

### Step 2: Entry Sheet Carousel Navigation ✅ COMPLETE
- [x] Create `EntryCarouselController` model to manage current entry index
- [x] Modify entry_sheet.dart to accept carousel callbacks + entries list
- [x] Add nav controls (prev/next buttons) in entry sheet header
- [x] Implement swipe left/right detection for carousel nav
- [x] Implement swipe down detection to close entry sheet
- [x] Wire up carousel callbacks in week_review.dart and month_review.dart
- [x] Test on device: carousel nav via buttons and swipes verified working

### Step 3: Animation & Transition Orchestration ⏳ DEFERRED
Swipe gestures are functional. Slide animations (left-to-right summary, right-to-left entry sheet) are deferred to polish pass after testing base functionality.

### Step 4: Gesture Handling (Swipe Down, Left/Right) ✅ COMPLETE (Functional)
- [x] Add swipe down detection in entry sheet → close
- [x] Add swipe left/right detection for carousel nav
- [x] Swipe threshold tuned (~300 px/s)
- [ ] Test on device: all swipes work as expected

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

## Completion Summary

**Shipped (2026-05-01):**
- Day summary view for reviewing multiple multi_daily entries on a single date (week & month views)
- Entry carousel navigation via prev/next buttons
- Swipe gestures: left/right for carousel, down to close
- Works for all multi_daily trackers (Smoke, Drink, Masturbate, Workout, Sleep, Mood)

**Scope Decisions:**
- Year review excluded: heatmap cells too small for reliable date selection
- Slide animations deferred to polish pass (functional swipe nav sufficient for MVP)

## Future Iterations

- Multi_daily aggregation on review page (show counts/summaries)
- Slide animations (left→right for summary, right→left for entry sheet)
- Sound + animation coordination per haptic design notes
- Review page month/year views may need additional multi_daily UX refinement
