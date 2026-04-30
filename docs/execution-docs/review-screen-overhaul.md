# Review Screen Aesthetic Overhaul

**Date:** 2026-04-19
**Status:** In Progress

## Goal

Redesign the Review screen applying the Aesthetic Overhaul Lenses framework. Kill the infinite vertical scroll, add temporal navigation (week/month/year), single-tracker focus, and inline trend comparisons.

## User Pain Points

1. Immense vertical scroll across months and trackers
2. Only month visibility — no week or year views
3. No way to see relative trends across selected trackers

## Lens Failures Identified

- **Lens 1 (Spatial):** Pure vertical stack, additive "show more", no spatial model of time
- **Lens 2 (Physics):** Tap-only interactions, no swipe/paging for temporal data
- **Lens 5 (Hierarchy):** All tracker sections identical weight, no differentiation

## Architecture

- Single-tracker focus with horizontal tracker selector
- Time-scale tabs: Week | Month | Year
- Horizontal swipe (PageView) to navigate through time periods
- Summary stats per period below the grid
- Inline trend sparklines with comparison tracker toggles
- Multi-tracker summary DEMO view (tagged)

## Files

| File | Action |
|------|--------|
| `lib/providers/review_providers.dart` | New — review state, summary, trend data |
| `lib/screens/review/review_screen.dart` | Rewrite — new architecture |
| `lib/screens/review/widgets/heatmap_grid.dart` | Keep — existing grid works well |
| `lib/screens/review/widgets/tracker_selector.dart` | New — horizontal tracker picker |
| `lib/screens/review/widgets/month_review.dart` | New — single-tracker month view |
| `lib/screens/review/widgets/week_review.dart` | New — 7-day detail strip |
| `lib/screens/review/widgets/year_review.dart` | New — GitHub-style annual grid |
| `lib/screens/review/widgets/summary_stats.dart` | New — period stats row |
| `lib/screens/review/widgets/multi_tracker_summary.dart` | New — DEMO compact overview |
| `lib/screens/review/widgets/trend_chart.dart` | New — sparkline overlay |

## Progress

- [x] Review providers (state + computed data)
- [x] Tracker selector widget
- [x] Summary stats widget
- [x] Month review (refactored single-tracker)
- [x] Week review (7-day detail)
- [x] Year review (contribution grid)
- [x] Trend chart (sparklines)
- [x] Multi-tracker summary (DEMO)
- [x] Main review_screen.dart rewrite
- [x] Analyzer passes (0 errors, 0 warnings)
- [ ] On-device visual verification
