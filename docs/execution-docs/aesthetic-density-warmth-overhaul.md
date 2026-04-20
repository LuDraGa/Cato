# Aesthetic Overhaul: Density + Warmth

**Date:** 2026-04-20
**Status:** Complete
**Trigger:** User feedback: "the app is not soothing and calm; it's jagged and cold"

---

## Problem Statement

Three interrelated issues:
1. **Ring dominance** — 228x228px fixed-size ring consumed ~half the viewport, forcing scrolling to reach tracker cards
2. **White harshness** — `bgElevated: #FFFFFF` (pure white) cards against warm beige `#FAF7F2` background created stark, cold contrast. The whites broke the warm material family.
3. **Oversized elements** — Cards, buttons, icons, typography, and spacing were all sized for "spacious feel" but resulted in low information density that felt bloated on real devices

## Design Philosophy (from Product DNA)

> "like paper resting under natural light" — paper under warm light is never pure white
> "The product does less, more clearly" — density serves clarity when done right
> "Nothing is ornamental. Nothing is loud." — oversized elements are ornamental

## Changes Made

### 1. Color: Full Palette Redesign — "Morning Mist"

Complete palette replaced. Direction shift: "earthy workshop" → "quiet morning." Warmth from light quality, not pigment. See `docs/planning/design-system.md` for full spec.

Key shifts:
- Backgrounds: warm beige → warm cloud (less yellow, more neutral)
- Accent: pure sage `#7C9A7C` → mist sage `#7C9A92` (blue undertone = calm)
- Domain colors: random earthy tones → harmonized watercolor set
- Text: warm-brown cascade → warm-neutral gray cascade
- Heatmap: green gradient → teal-sage gradient aligned with accent

### 2. Typography: Tighter Scale

| Style | Before | After |
|---|---|---|
| display | 32px | 26px |
| headline | 24px | 20px |
| title | 20px | 17px |
| metric | 32px | 28px |
| bodyLarge | 16px | 14px |
| bodyMedium | 16px | 14px |
| bodySmall | 12px | 11px |
| labelLarge | 14px | 13px |
| labelMedium | 14px | 13px |

### 3. Completion Ring: Responsive Sizing

- **Before:** Fixed 228x228px, strokeWidth 10
- **After:** `screenWidth * 0.40`, clamped to 140-200px, strokeWidth proportional (6-8px)
- Ring scales with device — smaller on compact phones, larger on tablets

### 4. Home Screen: Restructured Layout

- Moved streak badge into header row (right-aligned, baseline-aligned with date)
- Removed ConstrainedBox hero section — content flows naturally
- Reduced all section spacing (xl->lg, lg->sm gaps)
- Reduced page padding from 24px to 16px horizontal

### 5. Tracker Cards: Densified

| Property | Before | After |
|---|---|---|
| Padding | 16px all | 12px h, 10px v |
| Icon badge | 44x44, r14 | 36x36, r10 |
| Icon font | 20px | 16px |
| Border radius | 22px | 14px |
| Title style | title @ 18px | title (17px default) |
| Subtitle style | bodyMedium | bodySmall |
| Spacing between cards | 12px | 8px |

Logged tracker pills:
- Padding: 12h/8v -> 10h/6v
- Icon: 14px -> 12px

### 6. Navigation Bar: Compacted

| Property | Before | After |
|---|---|---|
| Bar padding | 16h/8v | 12h/4v |
| Item padding | 12px v | 8px v |
| Selected radius | 14px | 10px |

### 7. Entry Sheet: Compacted

| Property | Before | After |
|---|---|---|
| Top radius | 28px | 20px |
| Content padding | 24h/16t/24b | 16h/12t/16b |
| Drag handle | 40x4 | 36x4 |
| Save button padding | 16px v | 12px v |
| Save button radius | 18px | 12px |

### 8. Input Widgets: Compacted

- **Count stepper:** buttons 52->40px, display 56->44px h, radius 18->12, font 24->20
- **Chip selector:** padding 12h/8v -> 10h/6v
- **Score slider:** height 36->32, track 8->6px, dots 6.5/4.5->5.5/3.5
- **Duration picker:** height 108->96, radius 18->12
- **Input fields:** padding 16h/12v -> 12h/8v, radius 14->10

### 9. Review Screen: Compacted

- Header padding reduced
- Time scale tabs: 36->32px height, r10->r8
- Tracker selector: 40->34px height, pill padding reduced
- All sub-view horizontal padding: 24->16px
- Heatmap grid padding: 16->12px, r12->r10
- Summary stats padding: 16->12, stat font 20->17px

### 10. Settings Screen: Compacted

- Page padding: 24->16px
- Section spacing: 24->16px
- Section card radius: 22->14px
- Row padding: 16h/12v -> 12h/8v
- Calm toggle: 54x32 -> 46x28, thumb 24->20px

## Files Modified

- `lib/app/theme.dart` — colors, typography, input decoration, snackbar
- `lib/screens/home/home_screen.dart` — layout restructure
- `lib/screens/home/widgets/completion_ring.dart` — responsive sizing
- `lib/screens/home/widgets/tracker_card.dart` — density reduction
- `lib/widgets/app_shell.dart` — nav bar compaction
- `lib/screens/entry/entry_sheet.dart` — sheet + dialog compaction
- `lib/screens/entry/widgets/count_stepper.dart` — size reduction
- `lib/screens/entry/widgets/chip_selector.dart` — padding reduction
- `lib/screens/entry/widgets/score_slider.dart` — track + dot reduction
- `lib/screens/entry/widgets/duration_picker.dart` — height + radius
- `lib/screens/entry/batch_entry_screen.dart` — padding + button
- `lib/screens/review/review_screen.dart` — header + tabs + spacing
- `lib/screens/review/widgets/tracker_selector.dart` — height + padding
- `lib/screens/review/widgets/heatmap_grid.dart` — padding + radius
- `lib/screens/review/widgets/summary_stats.dart` — padding + font
- `lib/screens/review/widgets/week_review.dart` — padding
- `lib/screens/review/widgets/month_review.dart` — padding
- `lib/screens/review/widgets/year_review.dart` — padding
- `lib/screens/review/widgets/multi_tracker_summary.dart` — padding
- `lib/screens/review/widgets/trend_chart.dart` — padding
- `lib/screens/settings/settings_screen.dart` — full compaction
- `lib/widgets/calm_toggle.dart` — size reduction

## Validation

`flutter analyze` — 0 errors, 0 warnings (27 pre-existing info-level lints unchanged)
