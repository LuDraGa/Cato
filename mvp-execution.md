# DailyTracker — MVP Execution Document

**Date:** 2026-04-16 | **Revised:** 2026-04-18
**Status:** Execution-ready spec (v2.1 — surgical correction pass)
**Purpose:** Single source of truth for building the MVP. A new session executes from this. Post-execution, this tracks completed vs pending.

**References:** `product-dna.md` (9 core themes), `planning/technical-manifest.md` (confirmed stack)

---

## Table of Contents

1. [MVP Scope](#1-mvp-scope)
2. [Product Rules](#2-product-rules)
3. [Design Contract](#3-design-contract)
4. [UI/UX Design](#4-uiux-design)
5. [Data Layer](#5-data-layer)
6. [Execution Plan](#6-execution-plan)
7. [Scaffolding Steps](#7-scaffolding-steps)

---

# 1. MVP Scope

## 1.1 Trackers in MVP

5 domains, 8 tracker instances. Each tracker defines its scoring, completion, and heatmap behavior in config.

| Domain | Tracker | Frequency | Core Inputs | Score Key | Completion | Heatmap |
|---|---|---|---|---|---|---|
| Nutrition | Breakfast | multi_daily | score (1-10), dishes, photo, time | score | counts | score_avg |
| Nutrition | Lunch | multi_daily | score (1-10), dishes, photo, time | score | counts | score_avg |
| Nutrition | Dinner | multi_daily | score (1-10), dishes, photo, time | score | counts | score_avg |
| Nutrition | Snack | adhoc | score (1-10), what, time | — | excluded | presence |
| Fitness | Workout | daily | type, score (1-10), duration, exercises, photo | score | counts | score_avg |
| Rest | Sleep | daily | quality (1-10), duration, sleep_time, wake_time, notes | quality | counts | score_avg |
| Mind | Mood | daily | feeling (select), energy (1-5), notes | energy | counts | score_avg |
| Vices | Vices | multi_daily | type, count, time, notes | — | excluded | excluded |

**Key decisions:**
- **Snack** (adhoc): does not count toward completion ring or daily score. Heatmap shows binary presence only.
- **Vices**: does not count toward completion ring, daily score, or heatmap. Logged as activity tracking only — no judgment encoding.
- **Mood energy** (1-5 scale): normalized to 0-1 like all other scores for daily score computation.

## 1.2 User Flows — In vs Out

**IN (MVP):**
- [ ] F1: First launch — seed config loaded, straight to home
- [ ] F2: Home screen — calm surface with completion ring, score, and today's cards
- [ ] F3: Single entry from home — tap card → entry sheet → save
- [ ] F4: Single entry from notification — tap → entry sheet directly
- [ ] F5: Batch day-end entry — reflect on your day, log all pending, save all
- [ ] F6: Backfill past date — tap empty heatmap cell → entry for that date
- [ ] F7: Review — per-tracker calendar grid, scroll through months
- [ ] F8: Settings — notification prefs, dev panel access

**OUT (Post-MVP):** Partner sharing, admin UI, multi-metric overlays, compare weeks, weekly pulse, correlation insights, PDF export, auth, cloud sync, iOS, web.

## 1.3 Features — In vs Out

**IN (MVP):**

| Feature | Must-have | Deferrable |
|---|---|---|
| Dynamic form rendering from JSON config | Yes | — |
| Calendar heatmap (per-tracker) | Yes | — |
| Streak counter (per-tracker + global) | Yes | — |
| Completion ring (today's progress) | Yes | — |
| Daily composite score | Yes | — |
| Local push notifications (max 2/day) | Yes | — |
| Batch entry mode | Yes | — |
| Backfill with isBackfill flag | Yes | — |
| Entry sheet spring animation + blur | — | Can ship with basic transition first |
| "Same as yesterday" quick-repeat | — | Can ship without, add in polish |
| Dev panel (Isar browser, seed data) | — | Can ship without, add in Phase 7 |
| Haptic feedback on interactions | — | Can add in polish pass |
| Optional sound layer (off by default) | — | Can add in polish pass |

## 1.4 Definition of Done

MVP is done when:
1. App runs on physical Android device
2. All 8 trackers render correct entry forms from JSON config
3. Entries persist across app restarts (Isar)
4. Home screen is calm: ring, score, cards with proper hierarchy
5. Review screen shows calendar grid per tracker with correct shading
6. Tapping empty cell opens backfill entry
7. Max 2 notifications/day fire correctly
8. Batch entry mode works for day-end catchup
9. Visual language follows Design Contract (colors, type, spacing, surfaces)

## 1.5 DNA Theme Coverage

**MVP fully satisfies:** Frictionless Capture, Instant Reward, Progressive Disclosure, Config Over Code, Data Sovereignty, Aesthetic Craft, Ritual Design.

**Partial:** Compounding Temporal Narrative — heatmap shows accumulation over time, but advanced narrative (weekly pulse, trend overlays, correlation insights) is deferred.

**Deferred:** Social Accountability — partner sharing is post-MVP (architecturally accounted for).

---

# 2. Product Rules

These rules are non-negotiable. They derive from the Product DNA and override any implementation convenience.

| Rule | Enforcement |
|---|---|
| **Max 2 notifications/day** | Hard cap. 1 contextual midday prompt + 1 day-end catchup. No per-tracker notification stack. |
| **Calm surface** | Home screen above-the-fold shows ONE primary object (ring+score) and max 3 actionable cards. Completed cards collapse aggressively. No wall of cards. |
| **Anti-gamification** | No badges, no leaderboards, no "You're falling behind!" copy. Streak is a quiet counter, not a screaming banner. Missed days are neutral (white), never punitive (red). |
| **Local-first data** | All data in Isar on device. No network required to use any MVP feature. Sentry + Shorebird are outbound-only and failure-tolerant. |
| **Visual language** | Earth tones, muted surfaces, serif+sans type pairing, aggressive whitespace. No bright synthetic accents, no flat soulless vectors, no default Material widgets unstyled. See Design Contract. |
| **Scoring is config-driven** | Which trackers contribute to daily score is defined in tracker config (`scoreContribution`), not hardcoded. Normalization to 0-1 is computed, not assumed. |
| **Completion is config-driven** | Which trackers count toward completion ring is defined in tracker config (`countsForCompletion`). Adhoc and vices are excluded by default. |
| **No punishment** | The app never makes you feel bad. Empty heatmap cells are white. Missed entries are neutral. Notifications are invitations, not demands. |

---

# 3. Design Contract

Concrete implementation rules for the Aesthetic Craft and Ritual Design themes. Every UI decision must pass through this contract.

## 3.1 Color Palette

```
BACKGROUND & SURFACES
  bg-primary:     #FAF7F2   warm off-white (app background)
  bg-surface:     #F0EBE3   warm sand (card backgrounds at rest)
  bg-elevated:    #FFFFFF   white (elevated cards, sheets — distinguished by shadow)

TEXT
  ink-black:      #1A1A1A   focal data only — scores, primary labels, headers
  text-primary:   #3D3833   primary readable text
  text-secondary: #6B6560   secondary labels, timestamps, helper text
  text-tertiary:  #9B9590   disabled, placeholder

ACCENT
  sage:           #7C9A7C   primary positive accent (completion, heatmap peak)
  sage-light:     #A8C5A8   lighter variant
  sage-pale:      #D4E6D4   very light (heatmap low-score cells)

DOMAIN COLORS (softened, harmonized with base)
  nutrition:      #8BA88B   muted sage
  fitness:        #C4956A   warm terracotta
  rest:           #8B8DB5   muted lavender
  mind:           #A88BA5   dusty mauve
  vices:          #B58B8B   muted coral

HEATMAP GRADIENT (6 steps — warmer low end to reduce on/off perception)
  no-data:        #F0EBE3   (surface color — blends with background)
  minimal (1):    #E2EBDA   warm sage-tint (nearly continuous with no-data)
  low (2-3):      #D4E6D4   pale sage
  mid (4-5):      #A8C5A8   light sage
  high (6-7):     #7C9A7C   sage
  strong (8-9):   #5A7A5A   deep sage
  peak (10):      #3D5C3D   dark sage

SEMANTIC
  error:          #B58B8B   muted (not alarming red)
  warning:        #C4956A   warm terracotta
```

**Rules:**
- Ink-black (#1A1A1A) is reserved for scores, primary data, and headers. Never used for secondary text or decoration.
- No bright saturated colors anywhere in the UI. Domain colors are muted variants.
- Heatmap gradient is continuous and soft, not hard-stepped.

## 3.2 Typography

```
HEADERS:    "Source Serif 4" (Google Fonts — architectural serif)
BODY:       "Inter" (Google Fonts — clean legible sans-serif)

SCALE (using Inter unless noted):
  display:    Source Serif 4, 32px, SemiBold (600)    — screen titles only
  headline:   Source Serif 4, 24px, SemiBold (600)    — section headers
  title:      Source Serif 4, 20px, Medium (500)      — card titles, tracker names
  body:       Inter, 16px, Regular (400)              — primary content
  label:      Inter, 14px, Medium (500)               — input labels, button text
  caption:    Inter, 12px, Regular (400)              — timestamps, helper text
  metric:     Inter, 32px, SemiBold (600)             — daily score number, streak count
```

**Rules:**
- Serif (Source Serif 4) for headers and titles ONLY. Never for body, labels, or dense content.
- Sans (Inter) for everything interactive, metric, or dense.
- Metric numbers are the largest non-header text — they are focal data.

## 3.3 Surfaces & Material

| Surface | Background | Shadow | Usage |
|---|---|---|---|
| App background | bg-primary #FAF7F2 | none | Screen background |
| Card at rest | bg-surface #F0EBE3 | offset(0,1) blur(4) #1A1A1A @ 4% | Completed tracker cards |
| Card elevated (tappable) | bg-elevated #FFFFFF | offset(0,2) blur(8) #1A1A1A @ 6% | Pending tracker cards |
| Card pressed | bg-elevated #FFFFFF | offset(0,1) blur(4) #1A1A1A @ 4% | Active press state — shadow recedes |
| Bottom sheet | bg-elevated #FFFFFF | top shadow offset(0,-2) blur(12) @ 8% | Entry sheet |
| Bottom sheet scrim | — | BackdropFilter blur sigma 8, color #1A1A1A @ 15% | Behind entry sheet |
| Bottom nav | bg-primary #FAF7F2 | top border 1px #F0EBE3 | Navigation bar (no blur for MVP — keep simple) |

**Rules:**
- Surfaces feel matte, like paper or frosted glass. No glossy reflections.
- Shadow direction is always top-down (light source from above). Subtle, never dramatic.
- Elevation changes convey interactivity: elevated = tappable, receded = at rest or completed.

## 3.4 Spacing

```
BASE UNIT: 4px

SCALE:
  xs:     4px     micro-gaps (icon-to-text inline)
  sm:     8px     tight spacing (within card sections)
  md:     12px    between related elements (between input fields)
  lg:     16px    card internal padding, between cards
  xl:     24px    screen horizontal margins, section gaps
  2xl:    32px    major section separators
  3xl:    48px    above-the-fold breathing room (around ring)

SCREEN MARGINS:
  horizontal:  24px (xl) — both sides
  top:         16px below app bar
  bottom:      16px above nav bar

TOUCH TARGETS:
  minimum:     48px height (Material guideline)
  cards:       minimum 56px collapsed, variable expanded
```

**Rules:**
- Whitespace around the completion ring must be at least 48px (3xl) on all sides. The ring breathes.
- Cards have 16px (lg) internal padding. Between cards: 12px (md).
- Never cram more than 3 actionable cards above the fold on a compact (5") screen.

## 3.5 Motion

```
SPRING CONFIGS:
  standard:   damping 0.8, stiffness 300     — sheet open/close, card transitions
  snappy:     damping 0.7, stiffness 400     — score counter, streak bounce
  gentle:     damping 0.9, stiffness 200     — background fades, scrim

DURATIONS:
  micro:      100-150ms    — haptic-paired taps, switch toggles
  short:      200-250ms    — card collapse, tab crossfade, color fill
  medium:     300-400ms    — sheet slide, ring fill animation
  long:       500-600ms    — score count-up, stagger sequences

EASING:
  reveals:    Curves.easeOutCubic
  dismissals: Curves.easeInCubic
  interactive: SpringSimulation (use spring configs above)
```

**Rules:**
- Motion must feel weighted and deliberate, not snappy-for-the-sake-of-snappy.
- Stagger animations (e.g., "same as yesterday" field fill) at 50-80ms intervals — creates a sense of flow, not instantaneous.
- No bouncy overshoots on data elements (scores, ring). Overshoot only on decorative elements (streak badge).
- Sheet dismiss: if user swipes less than 30% of sheet height, spring back. Over 30%, complete dismiss.
- **Temporal inertia cascade:** After an entry save, data elements on Home don't update simultaneously. They settle in a staggered sequence that feels like the system is processing, not just rendering:
  1. Sheet dismisses (immediate)
  2. Card collapses to "Logged" row (~100ms after dismiss)
  3. Ring sweeps to new position (~50ms after card collapse, gauge-needle motion)
  4. Score counts up to new value (~100ms after ring starts)
  5. Streak updates last (~150ms after score, if changed)
  Total cascade: ~400-500ms from save to fully settled. The effect is subtle but gives weight to each entry — the system absorbs the data, not just displays it.

## 3.6 Haptics

| Action | Haptic | Rationale |
|---|---|---|
| Score slider step | `HapticFeedback.selectionClick` | Dial-like tactile feedback per step — functional, not decorative |
| Save entry | `HapticFeedback.mediumImpact` | Clear tactile anchor for the commit moment — the one haptic that matters most |
| Streak milestone (7, 30, 100) | `HapticFeedback.heavyImpact` (single) | Restrained, rare acknowledgment |
| Entry sheet opens | None | Removed — surface transitions don't need haptic noise |
| Card tap | None | Removed — too much micro-feedback |
| Error / validation fail | None | Errors are visual only. No punishment. |
| Tab switch | None | Navigation is silent. |

**Rules:**
- Haptics simulate physical resistance, not digital reward sounds translated to vibration.
- Never repeat haptics rapidly (no buzz patterns, no vibration sequences).
- Errors produce zero haptic response. The system does not punish.

## 3.7 Sound

**MVP: Optional sound layer — off by default.** Sound adds analog texture to the ritual. It ships in MVP but is disabled until the user opts in via Settings ("Sound: On/Off").

| Trigger | Sound | Character |
|---|---|---|
| Save entry | Ceramic tap | Short, matte, like setting down a stone. ~100ms. |
| Day-end notification | Muted analog chime | Custom asset, not OS default. Warm, not bright. |

**Rules:**
- Max 1 sound per interaction. Never layer or overlap.
- Volume: low by default, respects system media volume.
- No synthetic UI sounds. No success jingles. No whooshes.
- Sound assets: `.wav` or `.ogg`, kept in `assets/sounds/`. Must feel handmade — ceramic, paper, wood tones.
- Entry sheet open: no sound (visual spring is sufficient).
- If sound is off (default), zero audio output. Haptics carry the feedback alone.

**Discoverability (so sound isn't a hidden feature):**
- **First save prompt:** After the user's very first entry save, show a subtle inline toast/snackbar: *"Add subtle feedback to your entries?"* with [Enable] / [Not now]. One-time only — stored in AppConfig (`sound_prompt_shown`). If dismissed, never shown again. Note: the prompt sells tactility/feedback, not "sound" as a feature — this aligns with the ritual philosophy.
- **Settings micro-copy:** Below the Sound toggle, add caption text: *"Adds quiet tactile feedback to interactions"* (text-tertiary, caption size).

**Post-MVP additions (for reference, not implementation):**
- Completion ring full: heavy page turn
- Streak milestone: muted acoustic tone
- All synthetic/gamified sounds explicitly rejected

## 3.8 Data Visualization Language

| Element | Style | Anti-pattern |
|---|---|---|
| Heatmap cells | Rounded corners (radius 6px), **8px cell gap** (tighter than typical grids — reduces segmentation feel). Soft gradient between steps. Empty cells and low-score cells are near-continuous: empty (#F0EBE3) → low (#E2EBDA, shifted warmer) → mid-low (#D4E6D4). Filled cells carry a very subtle inner shadow (offset(0,0.5) blur(1) #1A1A1A @ 3%) giving slight depth without color contrast. Optional organic touch: slight corner radius variation (6px ±0.5px random per cell, seeded by date) to break mechanical repetition. | Sharp squares, hard color steps, GitHub contribution-chart aesthetic, grid-like harsh segmentation, high-contrast empty vs filled, uniform mechanical grid |
| Completion ring | Custom `CustomPainter` with anti-aliased stroke (width 10px), rounded cap, ring background is bg-surface. **Fill animation:** on entry save, ring sweeps to new position after ~50ms lag post-sheet-dismiss. The motion uses `gentle` spring (damping 0.9, stiffness 200) but must feel like a **gauge needle catching up** — it accelerates into the new position and decelerates with slight overshoot-free settling (easeOutCubic envelope on the spring). The ring doesn't "jump then ease" — it "lags, then sweeps fluidly to rest." Think analog instrument, not progress bar. | Default `CircularProgressIndicator` — too thin, too mechanical. Instant snapping to new value. Delayed-then-instant jump. |
| Score display | Large metric text (32px), count-up animation with easing | Static text dump, small numbers buried in UI |
| Streak counter | Quiet text with warm accent, no flame emoji in production (use subtle icon or just the number) | Gamified badges, achievement unlock animations |
| Calendar month label | Source Serif 4, caption size, text-secondary color | Bold screaming month headers |

**Rules:**
- Data viz must feel like an instrument panel, not a fitness dashboard.
- Soft edges everywhere. No jagged lines, no aggressive angular styling.
- The heatmap is a **temporal field** — a soft memory surface, not a filled grid. It should read as a continuous warm surface with gentle color variation, where patterns emerge naturally over time. The goal is to feel like looking at a textile or mosaic, not counting boxes.
- Cell gaps are **8px** (not 12px) to reduce segmentation. Rounded corners (6px ±0.5px organic variation) break mechanical repetition. The gradient from no-data → minimal → low is nearly imperceptible — both live in the warm palette and the transition feels continuous, not binary.
- Filled cells use a subtle inner shadow for depth, not just color difference. This gives a "pressed into the surface" quality rather than "colored in."
- **Heatmap container:** The entire month grid sits inside a subtle container with bg-surface background, 16px inset padding, and rounded corners (12px). This embeds the cells into a surface rather than floating them on the screen background. The container's bg-surface (#F0EBE3) and the no-data cell color (#F0EBE3) are identical — empty cells disappear into the container, and filled cells emerge from it. The grid reads as a field first, cells second.
- **Noise texture overlay:** Apply a very faint noise texture over the entire heatmap container (not per cell). Implementation: a semi-transparent PNG noise asset (~2% opacity) tiled across the container via `ImageRepeat.repeat`, or generated at paint time with a seeded `Random` drawing single-pixel dots at ~1-2% density. This breaks the last bit of digital flatness and gives the surface a paper/textile grain. The texture must be subtle enough that you notice its absence, not its presence.
- **Future direction (not MVP):** Replace grid with flowing trend curves / river visualization. The grid is the MVP compromise — these rules exist to make it feel as un-grid-like as possible.

---

# 4. UI/UX Design

## 4.1 Screen Map & Navigation

Bottom tab navigation (3 tabs). Entry sheet is a modal overlay, not a navigation destination.

```
[Home]          [Review]         [Settings]
  │                │                │
  └─ Today view    └─ Calendar      └─ Notification prefs
     (calm)           grid             Data export
     Entry sheet      Backfill         Dev panel
     (modal over)     (via cell tap)
     Batch mode
     (full screen)
```

**Routing (GoRouter):**

| Route | Screen | Type |
|---|---|---|
| `/` | Home | Tab (persistent) |
| `/review` | Review | Tab (persistent) |
| `/settings` | Settings | Tab (persistent) |
| `/batch` | Batch entry | Full screen (push) |

Entry sheet is NOT a route. It is presented via `showModalBottomSheet` triggered programmatically. This keeps navigation clean and avoids back-stack complexity.

## 4.2 Entry Sheet Behavior (Exact Spec)

The entry sheet is the most critical interaction surface. Exact behavior for every scenario:

| Scenario | Behavior |
|---|---|
| **Tap card on Home** | `showModalBottomSheet` presents sheet over Home tab. Home visible behind scrim (blurred). |
| **Back press while sheet open** | Sheet dismisses. No entry saved. Returns to Home. |
| **Swipe down on sheet** | If swipe < 30% of sheet height: spring back. If > 30%: dismiss. |
| **Save button** | Event written to Isar. Sheet dismisses. Home state refreshes (card collapses, ring fills). |
| **Notification tap (app in background)** | App foregrounds to Home tab. Sheet auto-presents for the target tracker. |
| **Notification tap (app killed / cold start)** | App initializes normally. After init, auto-presents sheet for the target tracker. Pending tracker ID stored in launch intent. |
| **Notification tap (already in Review tab)** | Sheet presents over Review tab. On dismiss, user is still on Review. |
| **Edit existing entry** | Tap completed card → sheet opens pre-filled with existing event data. Save overwrites the event (same uid, updated `updatedAt`). **Edit-safety:** on save, merge form values with the original event's MetricValues — any keys not present in the current form (removed/renamed fields from older schema versions) are preserved as-is. The form only renders current-schema fields, but the save never drops unknown keys. |
| **Backfill from heatmap** | Tap empty cell → sheet opens with `effectiveDate` pre-set to that cell's date. On save, `isBackfill: true`. |
| **Backfill edit** | Tap filled heatmap cell → sheet opens pre-filled. Same as edit. |

**Sheet state management:** `entryFormProvider(trackerUid)` holds in-progress form values. Disposed on sheet dismiss. If user dismisses without saving, state is lost (intentional — no drafts in MVP).

## 4.3 Home Screen (Calm Surface)

```
┌──────────────────────────────────┐
│                                  │
│  Wednesday, April 16             │  ← Date (Source Serif 4, headline)
│                                  │
│         ┌──────────┐             │
│         │          │             │  ← Completion ring
│         │    72    │             │     (custom painter, sage accent)
│         │          │             │     Score centered (metric, 32px)
│         └──────────┘             │
│       4 of 6 logged              │  ← Fraction (caption, text-secondary)
│                                  │     If 0 logged: "Today · not yet logged"
│                                  │     (text-tertiary, non-punitive hint)
│                                  │
│                      Day 14      │  ← Global streak (right-aligned,
│                                  │     quiet, text-secondary)
│──────────────────────────────────│
│                                  │  ← BELOW THE FOLD on compact screens
│  ┌────────────────────────────┐  │
│  │  🥗 Lunch                  │  │  ← Pending card (elevated white)
│  │  Tap to log                │  │     Only pending/overdue cards
│  └────────────────────────────┘  │     are full-height
│                                  │
│  ┌────────────────────────────┐  │
│  │  🏋 Workout                │  │
│  │  Tap to log                │  │
│  └────────────────────────────┘  │
│                                  │
│  ── Logged ──────────────────    │  ← Divider label (caption, tertiary)
│                                  │
│  Breakfast · 7    Sleep · 6      │  ← Completed: single-line, paired
│  Mood · 4         Dinner · 8     │     (compact, muted, no card border)
│                                  │
│──────────────────────────────────│
│  [● Home]    [Review]    [Set]   │
└──────────────────────────────────┘
```

**Calm surface rules:**
- **Above the fold (top ~350px on compact screen):** Date + ring + score + fraction + streak. Nothing else. The ring breathes in whitespace.
- **Below the fold:** Pending cards first (elevated, actionable). Max 3-4 visible before scroll.
- **Completed cards collapse** to single-line text items grouped in a "Logged" section. No card border, no elevation — they recede into the surface. Format: `{icon} {name} · {score}` inline, 2 per row.
- **Adhoc trackers (Snack):** Only appear in the card list if the user has logged one today. Otherwise hidden. No empty "Snack" card sitting there.
- **Excluded trackers (Vices):** Appear in the card list (user should be able to log them), but visually separated and do NOT affect ring or score. Marked with text-tertiary styling.
- **"Log the rest" action:** If >1 tracker pending, a subtle text link below the pending cards: "Log the rest →". Not a prominent button. No urgency framing.
- **No overdue state in MVP.** Cards are either pending or completed. Overdue adds visual noise for no user value when you're the only user.

**Home screen data requirements:**
- Active trackers where `countsForCompletion: true` → ring denominator
- Today's events for those trackers → ring numerator
- All active trackers (including excluded) → card list
- Daily score from scoring-eligible trackers → ring center number
- Global streak → top-right quiet counter

## 4.4 Entry Screen (Bottom Sheet)

```
┌──────────────────────────────────┐
│  ░░░░░░░ (blurred, sigma 8) ░░░ │
│──────────────────────────────────│
│  ┌──────────────────────────────┐│
│  │  ── handle ──                ││  ← 40px wide, 4px tall, rounded,
│  │                              ││     bg-surface color
│  │  🥗 Lunch                    ││  ← Title (Source Serif 4, title)
│  │  Wed, Apr 16 · 1:30 PM  ✎   ││  ← Editable date/time (caption)
│  │                              ││
│  │  ─── Required ───            ││  ← Section label if mixed req/opt
│  │                              ││
│  │  Score                       ││  ← Label (Inter, label, text-secondary)
│  │  ○○○○○○●○○○  7              ││  ← Score slider + value
│  │                              ││     (haptic on each step)
│  │  ─── Optional ───            ││
│  │                              ││
│  │  Dishes                      ││
│  │  ┌──────────────────────┐    ││  ← Text input (Inter, body)
│  │  │ dal rice + salad     │    ││
│  │  └──────────────────────┘    ││
│  │                              ││
│  │  📷  Add photo               ││  ← Collapsed media capture
│  │                              ││
│  │                              ││
│  │  ┌──────────────────────────┐││
│  │  │         Save             │││  ← Primary button (sage bg, white text)
│  │  └──────────────────────────┘││
│  │  ┌──────────────────────────┐││
│  │  │    Same as yesterday     │││  ← Secondary (text button, tertiary)
│  │  └──────────────────────────┘││
│  └──────────────────────────────┘│
└──────────────────────────────────┘
```

**Dynamic Input Engine** reads `inputSchema` and renders per field:

| InputField.type | Widget | Behavior |
|---|---|---|
| `score` | Discrete slider (custom, not default Material) | Steps with haptic tick. Value displayed right of slider. |
| `count` | Stepper (+/- buttons flanking number) | Tap to increment/decrement. Long-press to type. |
| `duration` | Hour:minute scroll wheels | Two side-by-side scroll pickers. |
| `text` | TextField (Inter, body) | maxLines from config. Placeholder from config. |
| `boolean` | Custom toggle (sage accent when on) | Not default Material Switch. |
| `single_select` | Wrapped chip group | Chips use bg-surface, selected chip uses sage-light bg + sage border. |
| `multi_select` | Wrapped chip group | Same as single_select, multiple selectable. |
| `media` | Tap to capture (camera/gallery choice) | Shows thumbnail after capture. See Media Handling. |
| `time` | Time display, tappable → picker | Pre-filled from tracker promptTime. |

**Field ordering:** `sortOrder` ascending. Required fields above optional divider.

**"Same as yesterday":** Copies MetricValues from most recent Event for this tracker. Fields fill in with stagger animation (50ms per field). User adjusts and saves.

## 4.5 Batch Entry Screen

Full-screen page (pushed via GoRouter `/batch`). Shows inline forms for all pending trackers.

```
┌──────────────────────────────────┐
│  ← Back     Reflect on your day  │  ← App bar with back button
│──────────────────────────────────│
│  3 not yet logged                │  ← Count (caption, text-secondary)
│                                  │
│  ┌────────────────────────────┐  │
│  │ 🥗 Lunch                   │  │  ← Inline expanded form
│  │ Score: ○○○○○○●○○○  7       │  │     (same widgets as entry sheet,
│  │ Dishes: [            ]     │  │      rendered from inputSchema)
│  │ 📷 Add photo                │  │
│  └────────────────────────────┘  │
│        12px gap                  │
│  ┌────────────────────────────┐  │
│  │ 🏋 Workout                 │  │
│  │ Type: [Cardio] [Strength]  │  │
│  │ Score: ○○○○○○○○○○          │  │
│  │ Duration: [  :  ]          │  │
│  └────────────────────────────┘  │
│        12px gap                  │
│  ┌────────────────────────────┐  │
│  │ 😊 Mood                    │  │
│  │ Feeling: [chips...]        │  │
│  │ Energy: ○○○○○              │  │
│  └────────────────────────────┘  │
│                                  │
│  ┌──────────────────────────┐    │
│  │       Save all (3)       │    │  ← Primary button (sage)
│  └──────────────────────────┘    │
│                                  │
└──────────────────────────────────┘
```

"Save all" writes one Event per tracker in a single Isar write batch.

## 4.6 Review Screen

```
┌──────────────────────────────────┐
│  Review                          │  ← Title (Source Serif 4, display)
│──────────────────────────────────│
│                                  │
│  [All] [Nutrition] [Fitness]     │  ← Filter chips (horizontal scroll)
│  [Rest] [Mind] [Vices]           │     bg-surface, selected = sage-light
│                                  │
│──────────────────────────────────│
│                                  │
│  Lunch                    12 🔥  │  ← Tracker name (title) + streak
│                                  │
│  April 2026                      │  ← Month label (caption, text-secondary)
│  Mo Tu We Th Fr Sa Su            │
│  ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐  │  ← Calendar grid cells
│  │  ││▓▓││▓▓││  ││██││▓▓││  │  │     Rounded corners (6px ±0.5px)
│  └──┘└──┘└──┘└──┘└──┘└──┘└──┘  │     Soft gradient coloring
│  ┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐┌──┐  │     8px gap between cells (tight)
│  │██││██││▓▓││██││██││  ││  │  │     Tap empty = backfill
│  └──┘└──┘└──┘└──┘└──┘└──┘└──┘  │     Tap filled = view/edit
│                                  │
│  March 2026                      │  ← Vertical scroll through months
│  ...                             │     (lazy loaded, 3 months at a time)
│                                  │
│──────────────────────────────────│
│  Workout                   8     │  ← Next tracker section
│  ...                             │
│──────────────────────────────────│
│  [Home]    [● Review]    [Set]   │
└──────────────────────────────────┘
```

**Heatmap rendering rules:**

| Tracker heatmapMode | Cell value computation | Color mapping |
|---|---|---|
| `score_average` | Average of all event scores for that date, normalized to 0-1: `(avg_score - min) / (max - min)` | 0-1 maps to 6-step gradient (see Design Contract 3.1) |
| `presence` | Binary: has event = 1, no event = 0 | 0 = no-data color, 1 = sage (#7C9A7C) |
| `excluded` | Not rendered | Tracker has no heatmap section in Review |

**Multi-entry aggregation (multi_daily trackers like meals):** Average of all events' score values for that date. E.g., Lunch scored 7, Dinner scored 9 → cell value = (7+9)/2 = 8 → normalized → color.

**Empty cell:** bg-surface color (#F0EBE3). Blends with background. Not white-on-white.

**Cell tap:** Empty → `showModalBottomSheet` entry for that tracker + date (backfill). Filled → same sheet, pre-filled (edit).

## 4.7 Settings Screen

```
┌──────────────────────────────────┐
│  Settings                        │
│──────────────────────────────────│
│                                  │
│  Reminders                       │  ← Section header (headline)
│  ┌────────────────────────────┐  │
│  │ Midday check-in    1:30 PM│  │  ← Tappable → time picker
│  │ Day-end catchup    9:30 PM│  │  ← Tappable → time picker
│  │ Notifications      [  ON ]│  │  ← Toggle to disable all
│  └────────────────────────────┘  │
│                                  │
│  Experience                      │  ← Section header (headline)
│  ┌────────────────────────────┐  │
│  │ Sound               [ OFF ]│  │  ← Off by default
│  │ Quiet tactile feedback      │  │     (caption, text-tertiary)
│  └────────────────────────────┘  │
│                                  │
│  Data                            │
│  ┌────────────────────────────┐  │
│  │ Export data (JSON)         │  │
│  └────────────────────────────┘  │
│                                  │
│  About                           │
│  ┌────────────────────────────┐  │
│  │ DailyTracker v0.1.0       │  │  ← Long-press 5x → Dev Panel
│  └────────────────────────────┘  │
│                                  │
│──────────────────────────────────│
│  [Home]    [Review]    [● Set]   │
└──────────────────────────────────┘
```

**Notification settings expose 2 times only** (midday + day-end), not per-tracker. This enforces the max-2/day product rule. **Toggle-off behavior:** Disabling the master toggle immediately cancels all scheduled notifications (`cancelAll()`). No stale notifications may fire after toggle-off.

**Dev Panel (hidden, strictly non-production):**
- Isar data browser (list collections, browse entries)
- Seed 30 days of fake data
- Clear all events (keep configs)
- Reset app (clear everything, re-seed from JSON)
- View loaded tracker configs as raw JSON

**Dev Panel isolation rule:** The dev panel is a debug-only surface. Zero visual bleed into the main UX — no shared widgets, no shared state providers, no dev-panel styles leaking into user-facing screens. It uses default Material styling (unstyled is fine here). It lives in `dev_panel.dart` only and is gated behind the long-press gesture. In release builds, the gesture handler can remain (low risk) but consider a `kDebugMode` gate.

## 4.8 Notification Design

**Max 2 notifications per day. No exceptions.**

| Notification | Default Time | Content | Tap Action |
|---|---|---|---|
| Midday check-in | 1:30 PM | "How's today going? {N} to log" where N = unlogged trackers from morning/midday prompt times | Opens Home (user picks which card to tap) |
| Day-end reflection | 9:30 PM | "Wrap up your day — {N} to log" | Opens `/batch` if N > 1, opens entry sheet for the single tracker if N = 1 |

**Scheduling logic:**
- Tracker `promptTimes` are used internally to determine which trackers are "expected" by midday vs day-end
- Trackers with promptTime before midday notification time → counted in midday notification
- All remaining unlogged trackers → counted in day-end notification
- If all trackers are logged before notification time → notification is suppressed (not sent)

**Android notification lifecycle:**
- **Permission:** Request `POST_NOTIFICATIONS` permission (Android 13+) on first app open. If denied, notifications silently disabled. No nagging.
- **Reboot:** `flutter_local_notifications` uses `AndroidAlarmManager`. Notifications re-registered via a `BootReceiver` (configured in AndroidManifest).
- **Timezone change:** Re-schedule on next app open.
- **App update:** Re-register on next app open (check in `main.dart` init).
- **Missed notifications:** Dropped, not replayed. No backlog.
- **Preference change:** Cancel all existing, reschedule with new times.
- **Toggle disabled:** When user turns off the master notification toggle in Settings, ALL scheduled notifications are cancelled immediately via `flutterLocalNotificationsPlugin.cancelAll()`. No stale or delayed notifications may fire after toggle-off. On toggle-on, reschedule both from current time preferences.

## 4.9 Media Handling

| Concern | Approach |
|---|---|
| **Permission request** | Request camera permission on first media capture tap, not on app launch. Use `permission_handler` package. |
| **Storage location** | `getApplicationDocumentsDirectory()/media/` — app-private, survives app updates, no external storage permission needed. |
| **File naming** | `{trackerUid}_{effectiveDate_YYYYMMDD}_{timestamp}.jpg` |
| **Path storage** | `MetricValue.mediaPath` stores relative path from app docs dir (e.g., `media/tracker-lunch_20260416_1730.jpg`). Relative paths are stable across app updates. |
| **Missing file** | If file at path doesn't exist (deleted externally), show placeholder icon. No crash. Log warning to Sentry. |
| **Compression on capture** | Before saving, resize image to max 1280px on longest edge and compress to JPEG quality 85. Use `image` package or `flutter_image_compress`. This happens synchronously before writing to disk — no full-resolution images are ever stored. |
| **Thumbnail** | MVP: no separate thumbnail generation. Use `Image.file` with `fit: BoxFit.cover` and fixed widget size (80x80). Flutter handles the already-compressed image fine at this size. |
| **Gallery picker** | Offer both camera and gallery as options. Gallery doesn't require camera permission. |
| **Permission denied** | Show inline "Camera permission required — tap to open settings" message. Gallery option still available if photos permission granted. |
| **Storage limits** | Not enforced in MVP. Log media directory size in dev panel for monitoring. |

## 4.10 Component Library

| Component | Description | Design Contract Notes |
|---|---|---|
| **TrackerCard** | Home entry card | Elevated white when pending, bg-surface when completed (collapsed). Domain-colored icon. |
| **EntrySheet** | Modal bottom sheet | bg-elevated, top shadow, drag handle in bg-surface color. |
| **ScoreSlider** | Custom discrete slider | Track in bg-surface, thumb in sage, haptic per step. NOT default Material Slider. |
| **CountStepper** | +/- with number | Buttons in bg-surface circles, number in ink-black metric style. |
| **DurationPicker** | Scroll wheels | Two side-by-side wheel pickers. bg-surface background. |
| **ChipSelector** | Wrapped chips | Unselected: bg-surface. Selected: sage-light bg + sage border. |
| **MediaCapture** | Camera/gallery + thumb | Dashed border placeholder. Thumbnail after capture (rounded 8px). |
| **HeatmapGrid** | Monthly calendar | Wrapped in bg-surface container (16px inset, 12px corner radius). Rounded cells (6px ±0.5px organic), 6-step soft gradient, 8px gap, subtle inner shadow on filled. Empty cells = same as container bg → invisible. CustomPainter. |
| **CompletionRing** | Circular progress | CustomPainter, 10px stroke, rounded cap, sage fill, bg-surface track. |
| **StreakBadge** | Counter text | Quiet number + subtle icon. text-secondary. No flame emoji. |
| **DailyScoreDisplay** | Animated number | metric style (32px, SemiBold), count-up with easeOutCubic. |

## 4.11 Responsive Considerations

| Concern | Approach |
|---|---|
| Screen sizes | Test on 5" (compact) and 6.7" (large). `MediaQuery` for padding. |
| Text scaling | Respect system font size. Use `TextTheme`. |
| Orientation | Lock to portrait for MVP. |
| Safe areas | `SafeArea` wrapping all screens. Sheet respects system nav. |
| Keyboard | Entry sheet content scrolls when keyboard opens. `SingleChildScrollView` inside sheet. |
| Notch/punch-hole | `SafeArea` handles it. |

---

# 5. Data Layer

## 5.1 Isar Collections

### Domain

```dart
@Collection()
class Domain {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true)
  late String uid;
  late String name;
  late String icon;
  late String color;        // hex, from Design Contract domain palette
  late int sortOrder;
  late bool isActive;
}
```

### Tracker

```dart
@Collection()
class Tracker {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true)
  late String uid;
  late String domainUid;
  late String name;
  late String icon;
  late String frequency;    // "daily" | "multi_daily" | "weekly" | "adhoc"
  late List<String> promptTimes; // HH:mm format

  // Input schema
  late List<InputFieldSchema> inputSchema;
  late List<String> allowedVisualizations;

  // Scoring config
  late bool scoreContribution;  // does this tracker count toward daily score?
  late String? scoreKey;        // which inputField.key provides the score (null = no score)
  late int scoreMin;            // min value of the score field (for normalization)
  late int scoreMax;            // max value of the score field (for normalization)

  // Completion config
  late bool countsForCompletion; // does this count against the completion ring?

  // Heatmap config
  late String heatmapMode;      // "score_average" | "presence" | "excluded"

  // Meta
  late int sortOrder;
  late bool isActive;
  late int version;
  late DateTime createdAt;
}
```

### InputFieldSchema (Embedded)

```dart
@Embedded()
class InputFieldSchema {
  late String key;
  late String label;
  late String type;         // "score"|"count"|"duration"|"text"|"boolean"
                            // |"single_select"|"multi_select"|"media"|"time"
  late String? configJson;  // type-specific config (JSON string)
  late bool isRequired;
  late int sortOrder;
}
```

### Event

```dart
@Collection()
class Event {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true)
  late String uid;

  @Index()
  late String trackerUid;
  @Index()
  late DateTime effectiveDate;  // normalized to midnight
  late DateTime? effectiveTime;
  late DateTime createdAt;      // immutable
  late DateTime updatedAt;
  late bool isBackfill;
  late int trackerVersion;      // snapshot of Tracker.version at creation time

  late List<MetricValue> metrics;
}
```

**Composite index:**
```dart
@Index(composite: [CompositeIndex('effectiveDate')])
late String trackerUid;
```

### MetricValue (Embedded)

```dart
@Embedded()
class MetricValue {
  late String inputKey;
  int? intValue;            // score, count
  double? doubleValue;      // duration (minutes)
  String? stringValue;      // text, single_select, time
  List<String>? listValue;  // multi_select
  bool? boolValue;          // boolean
  String? mediaPath;        // relative path from app docs dir
}
```

### AppConfig

```dart
@Collection()
class AppConfig {
  Id isarId = Isar.autoIncrement;
  @Index(unique: true)
  late String key;
  late String value;
}
```

## 5.2 Schema Evolution Policy (MVP)

| Scenario | Handling |
|---|---|
| **Field added to tracker config** | New events include it. Old events don't have it — display engine shows "—" or hides the field. |
| **Field removed from tracker config** | Old events retain the value. New entry form doesn't render it. Old data visible in edit view as read-only. |
| **Field renamed** | Treated as remove + add. Old events keep old key. New events use new key. |
| **Field type changed** | NOT SUPPORTED in MVP. Add a new field instead. |
| **Tracker version** | Every Event stores `trackerVersion` at creation time. Display engine uses the tracker's current schema for the form, but tolerates missing/extra metric keys in old events. |
| **Migration** | No migration of old events. Events are immutable once written (except `updatedAt` on user edit). Lazy interpretation: display handles gracefully. |
| **Edit safety** | When a user edits an old event, the write-back must preserve all existing MetricValue entries — including keys that no longer exist in the current tracker schema. The entry form only renders fields from the current schema, but on save, untouched MetricValues from the original event are merged back. Unknown fields are never silently dropped. |

**Rule:** Events are append-only historical records. The system never rewrites history. Edits preserve the full original payload — the form may show a subset, but the save merges, not replaces.

## 5.3 Scoring, Completion, and Heatmap Rules

### Daily Score

```
dailyScore = (sum of normalized scores for ALL eligible trackers)
             / (total count of eligible trackers)
             * 100

For each eligible tracker:
  if has event(s) today → normalized_score = (raw_score - scoreMin) / (scoreMax - scoreMin)
  if missing (no event) → contributes 0 to numerator, still counted in denominator
```

| Rule | Definition |
|---|---|
| Eligible trackers | `scoreContribution == true` |
| Score source | `event.metrics` where `inputKey == tracker.scoreKey`, read `intValue` |
| Normalization | `(value - scoreMin) / (scoreMax - scoreMin)` → 0.0 to 1.0 |
| Multi-entry (meals) | Average of all events' normalized scores for that tracker today |
| **Missing entry** | **Contributes 0 to the numerator. Denominator is always total eligible trackers (6 in MVP). This reflects true day quality — skipping trackers lowers your score.** |
| No entries at all | Score shows "—", not 0. The "—" state triggers only when zero events exist for any eligible tracker today. |
| Partial data | Score computes normally with 0 for missing. UI shows score alongside coverage: "{score}" + "N of M logged" (already visible in fraction line). |

**MVP scoring eligibility:** Breakfast, Lunch, Dinner, Workout, Sleep, Mood (6 trackers). Snack and Vices excluded.

**Example:** User logs Breakfast (7/10 → 0.667), Sleep (8/10 → 0.778), Mood (4/5 → 0.75). Three missing trackers contribute 0. Score = (0.667 + 0 + 0 + 0.778 + 0.75 + 0) / 6 * 100 = **37**. The "4 of 6 logged" fraction already communicates coverage.

### Completion Ring

```
completion = (count of completion-eligible trackers with ≥1 event today)
             / (count of completion-eligible trackers)
```

| Frequency | Completion rule |
|---|---|
| `daily` | Complete when ≥1 event exists for today |
| `multi_daily` (with `countsForCompletion: true`) | Complete when ≥1 event exists for today (not per-prompt) |
| `adhoc` | Excluded from ring. Does not count as incomplete if not logged. |
| Any tracker with `countsForCompletion: false` | Excluded from ring entirely |

**MVP:** Ring denominator = 6 (Breakfast, Lunch, Dinner, Workout, Sleep, Mood). Snack and Vices excluded.

### Heatmap

| heatmapMode | Cell computation |
|---|---|
| `score_average` | Average normalized score of all events for that tracker on that date. If no events: empty cell (bg-surface). |
| `presence` | Binary: ≥1 event = sage fill, no event = bg-surface. |
| `excluded` | No heatmap section rendered for this tracker. |

**Multi-daily score_average:** All events for that tracker on that date are averaged. E.g., Breakfast 7 + Lunch 5 → avg 6 → normalized → color.

**Backfill cells:** Rendered the same as normal cells. No visual distinction for backfilled data in the heatmap. (`isBackfill` is metadata for future analytics, not display.)

## 5.4 Seed Config JSON

`assets/tracker_configs/domains.json`:
```json
[
  {"uid": "domain-nutrition", "name": "Nutrition", "icon": "🍽", "color": "#8BA88B", "sortOrder": 0, "isActive": true},
  {"uid": "domain-fitness", "name": "Fitness", "icon": "💪", "color": "#C4956A", "sortOrder": 1, "isActive": true},
  {"uid": "domain-rest", "name": "Rest", "icon": "😴", "color": "#8B8DB5", "sortOrder": 2, "isActive": true},
  {"uid": "domain-mind", "name": "Mind", "icon": "🧠", "color": "#A88BA5", "sortOrder": 3, "isActive": true},
  {"uid": "domain-vices", "name": "Vices", "icon": "🚬", "color": "#B58B8B", "sortOrder": 4, "isActive": true}
]
```

`assets/tracker_configs/trackers.json`:
```json
[
  {
    "uid": "tracker-breakfast",
    "domainUid": "domain-nutrition",
    "name": "Breakfast",
    "icon": "🍳",
    "frequency": "multi_daily",
    "promptTimes": ["08:30"],
    "inputSchema": [
      {"key": "score", "label": "Score", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 0},
      {"key": "dishes", "label": "Dishes", "type": "text", "configJson": "{\"maxLines\":2,\"placeholder\":\"What did you eat?\"}", "isRequired": false, "sortOrder": 1},
      {"key": "photo", "label": "Photo", "type": "media", "configJson": null, "isRequired": false, "sortOrder": 2},
      {"key": "time", "label": "Time", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 3}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "score",
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 0,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-lunch",
    "domainUid": "domain-nutrition",
    "name": "Lunch",
    "icon": "🥗",
    "frequency": "multi_daily",
    "promptTimes": ["13:30"],
    "inputSchema": [
      {"key": "score", "label": "Score", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 0},
      {"key": "dishes", "label": "Dishes", "type": "text", "configJson": "{\"maxLines\":2,\"placeholder\":\"What did you eat?\"}", "isRequired": false, "sortOrder": 1},
      {"key": "photo", "label": "Photo", "type": "media", "configJson": null, "isRequired": false, "sortOrder": 2},
      {"key": "time", "label": "Time", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 3}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "score",
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 1,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-dinner",
    "domainUid": "domain-nutrition",
    "name": "Dinner",
    "icon": "🍛",
    "frequency": "multi_daily",
    "promptTimes": ["20:00"],
    "inputSchema": [
      {"key": "score", "label": "Score", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 0},
      {"key": "dishes", "label": "Dishes", "type": "text", "configJson": "{\"maxLines\":2,\"placeholder\":\"What did you eat?\"}", "isRequired": false, "sortOrder": 1},
      {"key": "photo", "label": "Photo", "type": "media", "configJson": null, "isRequired": false, "sortOrder": 2},
      {"key": "time", "label": "Time", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 3}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "score",
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 2,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-snack",
    "domainUid": "domain-nutrition",
    "name": "Snack",
    "icon": "🍪",
    "frequency": "adhoc",
    "promptTimes": [],
    "inputSchema": [
      {"key": "score", "label": "Score", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 0},
      {"key": "what", "label": "What", "type": "text", "configJson": "{\"maxLines\":1,\"placeholder\":\"What'd you snack on?\"}", "isRequired": false, "sortOrder": 1},
      {"key": "time", "label": "Time", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 2}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": false,
    "scoreKey": null,
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": false,
    "heatmapMode": "presence",
    "sortOrder": 3,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-workout",
    "domainUid": "domain-fitness",
    "name": "Workout",
    "icon": "🏋",
    "frequency": "daily",
    "promptTimes": ["18:00"],
    "inputSchema": [
      {"key": "type", "label": "Type", "type": "single_select", "configJson": "{\"options\":[\"Cardio\",\"Strength\",\"Mixed\"]}", "isRequired": true, "sortOrder": 0},
      {"key": "score", "label": "Score", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 1},
      {"key": "duration", "label": "Duration", "type": "duration", "configJson": "{\"format\":\"HH:mm\"}", "isRequired": false, "sortOrder": 2},
      {"key": "exercises", "label": "Exercises", "type": "text", "configJson": "{\"maxLines\":3,\"placeholder\":\"Pushups 50, Pullups 12...\"}", "isRequired": false, "sortOrder": 3},
      {"key": "photo", "label": "Photo", "type": "media", "configJson": null, "isRequired": false, "sortOrder": 4}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "score",
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 0,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-sleep",
    "domainUid": "domain-rest",
    "name": "Sleep",
    "icon": "😴",
    "frequency": "daily",
    "promptTimes": ["07:30"],
    "inputSchema": [
      {"key": "quality", "label": "Quality", "type": "score", "configJson": "{\"min\":1,\"max\":10,\"step\":1}", "isRequired": true, "sortOrder": 0},
      {"key": "duration", "label": "Duration", "type": "duration", "configJson": "{\"format\":\"HH:mm\"}", "isRequired": true, "sortOrder": 1},
      {"key": "sleep_time", "label": "Slept at", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 2},
      {"key": "wake_time", "label": "Woke at", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 3},
      {"key": "notes", "label": "Notes", "type": "text", "configJson": "{\"maxLines\":2,\"placeholder\":\"How'd you sleep?\"}", "isRequired": false, "sortOrder": 4}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "quality",
    "scoreMin": 1,
    "scoreMax": 10,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 0,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-mood",
    "domainUid": "domain-mind",
    "name": "Mood",
    "icon": "😊",
    "frequency": "daily",
    "promptTimes": ["15:00"],
    "inputSchema": [
      {"key": "feeling", "label": "Right now I feel like...", "type": "single_select", "configJson": "{\"options\":[\"Starting something new\",\"Finishing a chore\",\"Scrolling mindlessly\",\"Going outside\",\"Working out\",\"Talking to someone\",\"Being alone\",\"Creating something\"]}", "isRequired": true, "sortOrder": 0},
      {"key": "energy", "label": "Energy", "type": "score", "configJson": "{\"min\":1,\"max\":5,\"step\":1}", "isRequired": true, "sortOrder": 1},
      {"key": "notes", "label": "Notes", "type": "text", "configJson": "{\"maxLines\":3,\"placeholder\":\"Anything on your mind?\"}", "isRequired": false, "sortOrder": 2}
    ],
    "allowedVisualizations": ["heatmap", "streak"],
    "scoreContribution": true,
    "scoreKey": "energy",
    "scoreMin": 1,
    "scoreMax": 5,
    "countsForCompletion": true,
    "heatmapMode": "score_average",
    "sortOrder": 0,
    "isActive": true,
    "version": 1
  },
  {
    "uid": "tracker-vices",
    "domainUid": "domain-vices",
    "name": "Vices",
    "icon": "🚬",
    "frequency": "multi_daily",
    "promptTimes": [],
    "inputSchema": [
      {"key": "type", "label": "Type", "type": "single_select", "configJson": "{\"options\":[\"Smoke\",\"Drink\",\"Masturbate\"]}", "isRequired": true, "sortOrder": 0},
      {"key": "count", "label": "Count", "type": "count", "configJson": "{\"min\":0,\"max\":50}", "isRequired": true, "sortOrder": 1},
      {"key": "time", "label": "Time", "type": "time", "configJson": null, "isRequired": false, "sortOrder": 2},
      {"key": "notes", "label": "Notes", "type": "text", "configJson": "{\"maxLines\":2,\"placeholder\":\"Context...\"}", "isRequired": false, "sortOrder": 3}
    ],
    "allowedVisualizations": ["streak"],
    "scoreContribution": false,
    "scoreKey": null,
    "scoreMin": 0,
    "scoreMax": 0,
    "countsForCompletion": false,
    "heatmapMode": "excluded",
    "sortOrder": 0,
    "isActive": true,
    "version": 1
  }
]
```

## 5.5 Key Queries

| Query | Used by | Approach |
|---|---|---|
| Active trackers | Home, Review, Batch | `where().isActiveEqualTo(true).sortBySortOrder()` |
| Today's events for tracker | Card state | Composite index: `trackerUid + effectiveDate` |
| Events for tracker in range | Heatmap | `trackerUidEqualTo(uid).effectiveDateBetween(start, end)` |
| All events today | Daily score, ring | `effectiveDateEqualTo(today)` |
| Streak (tracker) | Home, Review | Walk backwards from today counting consecutive days with events. Cache in provider. |
| Most recent event (tracker) | "Same as yesterday" | `trackerUidEqualTo(uid).sortByEffectiveDateDesc().findFirst()` |

## 5.6 Riverpod Providers

```
isarProvider                          → Isar instance
allDomainsProvider                    → Stream<List<Domain>>
allTrackersProvider                   → Stream<List<Tracker>>
completionEligibleTrackersProvider    → filtered: countsForCompletion == true
scoreEligibleTrackersProvider         → filtered: scoreContribution == true
todayEventsProvider                   → Stream<List<Event>> for today
trackerCardStateProvider(uid)         → computed: pending | completed
completionProvider                    → computed: {completed: int, total: int}
dailyScoreProvider                    → computed: int (0-100) or null if zero events exist. Denominator is always total eligible trackers (not just logged). Missing trackers contribute 0.
streakProvider(trackerUid)            → computed: int (consecutive days)
globalStreakProvider                  → computed: int (days where all eligible logged)
heatmapDataProvider(uid, DateRange)   → computed: Map<DateTime, double?> 
entryFormProvider(trackerUid)         → StateNotifier for in-progress form
```

---

# 6. Execution Plan

Each phase builds a vertical slice. Every phase ends with acceptance criteria that must pass on a physical device before moving on.

## Phase 1: Scaffold [MUST-HAVE]
> Full stack installed. App runs on device with bottom nav and 3 empty tab screens.

- [ ] **E1.1** Create Flutter project → [Section 7.1](#71-project-creation)
- [ ] **E1.2** Install all dependencies → [Section 7.2](#72-dependencies)
- [ ] **E1.3** Set up code generation → [Section 7.3](#73-code-generation)
- [ ] **E1.4** Initialize Isar → [Section 7.4](#74-isar-initialization)
- [ ] **E1.5** Set up Riverpod ProviderScope → [Section 7.5](#75-riverpod-setup)
- [ ] **E1.6** Set up GoRouter with 3 tab routes → [Section 7.6](#76-gorouter-setup)
- [ ] **E1.7** Create `theme.dart` with Design Contract colors, type, spacing → [Section 3](#3-design-contract)
- [ ] **E1.8** Create project directory structure → [Section 7.11](#711-project-structure)
- [ ] **E1.9** Initialize Sentry → [Section 7.7](#77-sentry-initialization)
- [ ] **E1.10** Initialize Shorebird → [Section 7.8](#78-shorebird-initialization)
- [ ] **E1.11** Set up Firebase SDK (init only) → [Section 7.9](#79-firebase-initialization)
- [ ] **E1.12** Set up Dio base (configured, no endpoints) → [Section 7.10](#710-dio--retrofit-setup)

**Acceptance criteria:**
- [ ] App launches on physical Android device (USB debug)
- [ ] 3 tabs visible with correct labels, tab switching works
- [ ] Theme uses Design Contract colors and fonts (visible on placeholder text)
- [ ] No crashes, no red error screens
- [ ] `flutter analyze` passes with no errors

## Phase 2: Data Layer + Seed Config [MUST-HAVE]
> Models exist. JSON configs load on first launch. Data persists.

- [ ] **E2.1** Create Isar collections: Domain, Tracker, Event, AppConfig → [Section 5.1](#51-isar-collections)
- [ ] **E2.2** Create embedded classes: InputFieldSchema, MetricValue → [Section 5.1](#51-isar-collections)
- [ ] **E2.3** Add JSON seed files to `assets/tracker_configs/` → [Section 5.4](#54-seed-config-json)
- [ ] **E2.4** Build `ConfigLoader`: reads JSON, writes to Isar on first launch (checks AppConfig `seeded` flag)
- [ ] **E2.5** Create providers: isarProvider, allDomainsProvider, allTrackersProvider, completionEligibleTrackersProvider, scoreEligibleTrackersProvider → [Section 5.6](#56-riverpod-providers)
- [ ] **E2.6** Create repository classes: DomainRepository, TrackerRepository, EventRepository

**Acceptance criteria:**
- [ ] All 5 domains and 8 trackers visible in debug console on first launch
- [ ] Kill app and relaunch: same data present (not re-seeded)
- [ ] Tracker objects include scoreContribution, countsForCompletion, heatmapMode fields
- [ ] `build_runner build` completes without errors

## Phase 3: Home Screen + Single Entry [MUST-HAVE]
> Core interaction loop. User sees today's trackers and can log an entry.

- [ ] **E3.1** Build Home screen layout following calm surface rules → [Section 4.3](#43-home-screen-calm-surface)
- [ ] **E3.2** Build TrackerCard (pending/completed states) → [Section 4.10](#410-component-library)
- [ ] **E3.3** Build todayEventsProvider and trackerCardStateProvider
- [ ] **E3.4** Build Dynamic Input Engine: InputFieldSchema → Widget → [Section 4.4](#44-entry-screen-bottom-sheet)
- [ ] **E3.5** Build input widgets: ScoreSlider (custom, not Material), CountStepper, DurationPicker, ChipSelector, MediaCapture, TextField, TimePicker → [Section 4.10](#410-component-library)
- [ ] **E3.6** Build EntrySheet (modal bottom sheet) with exact behavior spec → [Section 4.2](#42-entry-sheet-behavior-exact-spec)
- [ ] **E3.7** Wire save: form → MetricValue list → Event (with trackerVersion) → Isar → provider refresh
- [ ] **E3.8** Implement media capture with permission handling → [Section 4.9](#49-media-handling)
- [ ] **E3.9** Entry sheet spring animation + blur scrim → [Section 3.5](#35-motion)

**Acceptance criteria:**
- [ ] Home shows date + ring placeholder + pending cards. Calm surface: no card wall.
- [ ] Completed cards collapse to single-line text items in "Logged" section
- [ ] Tap pending card → entry sheet slides up with spring animation
- [ ] All 8 trackers render correct form fields from config (score sliders, chips, text, duration, media, time)
- [ ] Save entry → sheet dismisses → card collapses → data in Isar
- [ ] Camera capture works (permission requested on first tap, photo compressed to max 1280px before save, thumbnail visible)
- [ ] Edit existing entry → sheet opens pre-filled → save overwrites
- [ ] Back press / swipe down dismisses sheet without saving
- [ ] Adhoc trackers (Snack) hidden from cards when not logged today
- [ ] Vices card appears but styled as text-tertiary / de-emphasized

## Phase 4: Completion Ring + Daily Score + Streaks [MUST-HAVE]
> Dopamine features. Visual reward on every interaction.

- [ ] **E4.1** Build CompletionRing (CustomPainter, 10px stroke, sage fill) → [Section 4.10](#410-component-library)
- [ ] **E4.2** Build completionProvider (only countsForCompletion trackers)
- [ ] **E4.3** Build DailyScoreDisplay with count-up animation
- [ ] **E4.4** Build dailyScoreProvider with normalization logic → [Section 5.3](#53-scoring-completion-and-heatmap-rules)
- [ ] **E4.5** Build StreakBadge (quiet counter, text-secondary)
- [ ] **E4.6** Build streakProvider and globalStreakProvider
- [ ] **E4.7** Wire into Home screen with correct hierarchy: ring above fold, streaks subtle
- [ ] **E4.8** Haptic feedback: save → mediumImpact, slider → selectionClick per step. No haptic on card tap or sheet open. → [Section 3.6](#36-haptics)

**Acceptance criteria:**
- [ ] Ring shows correct fraction (e.g., 4/6, not 4/8 — excludes Snack and Vices)
- [ ] Score computes correctly: denominator = all 6 eligible trackers (not just logged), missing = 0 contribution, "—" only when zero events exist
- [ ] Mood energy (1-5) is correctly normalized against Mood's scoreMin/scoreMax in the daily score
- [ ] Ring animates clockwise on entry save
- [ ] Score counts up on entry save
- [ ] Streak shows correct consecutive-day count
- [ ] Global streak shows days where all 6 eligible trackers were logged
- [ ] Haptics fire on slider steps (selectionClick) and save (mediumImpact). No haptic on card tap or sheet open.
- [ ] Home screen above-the-fold: date + ring + score + streak + whitespace. No cards above fold on compact screen.

## Phase 5: Review Screen + Heatmap [MUST-HAVE]
> Historical view. Backfill works.

- [ ] **E5.1** Build Review screen with filter chips → [Section 4.6](#46-review-screen)
- [ ] **E5.2** Build HeatmapGrid (CustomPainter): rounded cells (6px ±0.5px organic), soft 6-step gradient, 8px gap, subtle inner shadow on filled cells → [Section 3.8](#38-data-visualization-language)
- [ ] **E5.3** Build heatmapDataProvider with correct aggregation per heatmapMode → [Section 5.3](#53-scoring-completion-and-heatmap-rules)
- [ ] **E5.4** Tap empty cell → entry sheet with date pre-set, isBackfill: true
- [ ] **E5.5** Tap filled cell → entry sheet pre-filled (edit mode)
- [ ] **E5.6** Filter chips: "All" vs domain-specific
- [ ] **E5.7** Streak per tracker section
- [ ] **E5.8** Lazy loading: 3 months at a time, load more on scroll

**Acceptance criteria:**
- [ ] Heatmap cells have rounded corners (6px ±0.5px organic), 8px gaps, soft 6-step gradient, and subtle inner shadow on filled cells — reads as a soft memory surface, not a filled grid
- [ ] score_average trackers show correct 5-step color gradient
- [ ] presence trackers (Snack) show binary sage/empty
- [ ] excluded trackers (Vices) have no heatmap section
- [ ] Multi-daily trackers (meals) average correctly across same-day events
- [ ] Empty cells are bg-surface (#F0EBE3), not white-on-white
- [ ] Backfill: tap empty cell → fill entry → cell fills with color → isBackfill: true in Isar
- [ ] Seed 30 days of data (manually or dev panel) → heatmap renders correctly for past month
- [ ] Filter chips work: "All" shows all, domain chip shows only that domain's trackers

## Phase 6: Batch Entry + Notifications [MUST-HAVE]
> Day-end catchup and max-2/day reminders.

- [ ] **E6.1** Build Batch entry screen → [Section 4.5](#45-batch-entry-screen)
- [ ] **E6.2** "Save All" writes events in single Isar batch
- [ ] **E6.3** "Log the rest →" text link on Home (visible when >1 pending)
- [ ] **E6.4** Set up `flutter_local_notifications`
- [ ] **E6.5** Build notification scheduler: 2 notifications/day only → [Section 4.8](#48-notification-design)
- [ ] **E6.6** Midday notification tap → opens Home
- [ ] **E6.7** Day-end notification tap → opens `/batch` (or entry sheet if only 1 remaining)
- [ ] **E6.8** Build Settings notification section (2 times + toggle) → [Section 4.7](#47-settings-screen)
- [ ] **E6.9** Android 13+ POST_NOTIFICATIONS permission request → [Section 4.8](#48-notification-design)
- [ ] **E6.10** Notification re-registration on reboot and app update

**Acceptance criteria:**
- [ ] Exactly 2 notifications/day maximum, never more
- [ ] Midday notification suppressed if all morning trackers are logged
- [ ] Day-end notification suppressed if everything is logged
- [ ] Notification tap opens correct screen (Home for midday, batch/entry for day-end)
- [ ] Settings shows 2 time pickers + master toggle, NOT per-tracker reminders
- [ ] Disable notifications toggle → all scheduled notifications cancelled immediately → zero delivered after toggle-off
- [ ] Re-enable toggle → both notifications rescheduled from stored time preferences
- [ ] Batch mode: fill 3 trackers, save all → 3 events created → ring updates → return to Home
- [ ] Notification copy is calm: "How's today going?" (midday), "Wrap up your day" (day-end) — no urgency framing

## Phase 7: Dev Panel + Polish [DEFERRABLE — but completes MVP]
> Developer tools, edge cases, fit and finish.

- [ ] **E7.1** Build Dev Panel (long-press version 5x) → [Section 4.7](#47-settings-screen)
- [ ] **E7.2** Isar browser: list collections, browse entries
- [ ] **E7.3** "Seed 30 days" button
- [ ] **E7.4** "Clear events" and "Reset app" buttons
- [ ] **E7.5** Raw JSON config viewer
- [ ] **E7.6** "Same as yesterday" in entry sheet → [Section 4.4](#44-entry-screen-bottom-sheet)
- [ ] **E7.7** Data export: JSON dump to downloads
- [ ] **E7.8** Edge cases: empty state, first-day streak, midnight rollover
- [ ] **E7.9** Keyboard handling: sheet scrolls with keyboard
- [ ] **E7.10** Sentry captures crashes correctly
- [ ] **E7.11** Optional sound layer: ceramic tap on save, analog chime on day-end notification. Off by default. Settings toggle. → [Section 3.7](#37-sound)
- [ ] **E7.12** Ring fill animation: gentle spring (~50ms lag after sheet dismiss) → [Section 3.8](#38-data-visualization-language)
- [ ] **E7.13** Final visual audit: all screens match Design Contract
- [ ] **E7.14** Build release APK: `flutter build apk --release`

**Acceptance criteria:**
- [ ] Dev panel accessible and all functions work
- [ ] Seed 30 days → heatmap fully populated → scores/ring/streaks all correct
- [ ] Empty state (fresh install): Home shows ring at 0, "—" score, no completed section, clean
- [ ] App survives midnight rollover (effective date changes to next day correctly)
- [ ] Release APK installs and runs on device without debug tools
- [ ] Sound toggle works: off by default, ceramic tap on save when on, no sound when off
- [ ] Ring fill animation uses gentle spring with ~50ms lag — never instant
- [ ] All 9 DNA themes are visibly honored: calm surface, earth tones, serif headers, muted accents, whitespace, quiet streaks, no punishment, no gamification, ritual-weight motion (see Section 1.5 for coverage map)

---

# 7. Scaffolding Steps

## 7.1 Project Creation

```bash
cd /Users/abhiroopprasad/code/personal/startup/dailytracker
flutter create --org com.dailytracker --project-name dailytracker_app .
```

Creates Flutter project alongside existing `planning/`, `product-dna.md`, etc.

## 7.2 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  isar: ^3.1.0+1
  isar_flutter_libs: ^3.1.0+1
  path_provider: ^2.1.3
  go_router: ^14.2.0
  dio: ^5.4.3+1
  retrofit: ^4.1.0
  firebase_core: ^2.31.0
  sentry_flutter: ^8.2.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.9.0
  flutter_local_notifications: ^17.1.2
  uuid: ^4.4.0
  intl: ^0.19.0
  flutter_animate: ^4.5.0
  permission_handler: ^11.3.1
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
  retrofit_generator: ^8.1.0
  isar_generator: ^3.1.0+1
  mocktail: ^1.0.3
  flutter_lints: ^3.0.2
```

```bash
flutter pub get
```

## 7.3 Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
# Or watch mode:
dart run build_runner watch --delete-conflicting-outputs
```

Convention: `part 'filename.g.dart';` and `part 'filename.freezed.dart';`

## 7.4 Isar Initialization

`lib/app/isar_init.dart`:
```dart
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return await Isar.open(
    [DomainSchema, TrackerSchema, EventSchema, AppConfigSchema],
    directory: dir.path,
  );
}
```

## 7.5 Riverpod Setup

`lib/providers/core_providers.dart`:
```dart
final isarProvider = Provider<Isar>((ref) => throw UnimplementedError());
```

`main.dart` wraps app in `ProviderScope` with `isarProvider.overrideWithValue(isar)`.

## 7.6 GoRouter Setup

`lib/app/router.dart`: `StatefulShellRoute.indexedStack` with 3 branches (Home `/`, Review `/review`, Settings `/settings`). Separate route for `/batch`. Entry sheet is NOT a route.

## 7.7 Sentry Initialization

```dart
await SentryFlutter.init((options) {
  options.dsn = 'YOUR_SENTRY_DSN';
  options.tracesSampleRate = 1.0;
  options.environment = 'development';
}, appRunner: () async { /* init isar, run app */ });
```

Setup: Create project at sentry.io, get DSN.

## 7.8 Shorebird Initialization

```bash
curl --proto '=https' --tlsv1.2 https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh -sSf | bash
shorebird init
```

## 7.9 Firebase Initialization

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_FIREBASE_PROJECT
```

In `main.dart`: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`

## 7.10 Dio + Retrofit Setup

`lib/services/api_client.dart`: Create `Dio` instance with base options. No endpoints for MVP. Provider: `final dioProvider = Provider<Dio>((ref) => createDioClient());`

## 7.11 Project Structure

```
dailytracker/
├── product-dna.md
├── mvp-execution.md
├── planning/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart            ← MaterialApp + theme
│   │   ├── router.dart         ← GoRouter
│   │   ├── theme.dart          ← Design Contract implementation
│   │   └── isar_init.dart
│   ├── models/
│   │   ├── domain.dart
│   │   ├── tracker.dart
│   │   ├── event.dart
│   │   ├── metric_value.dart
│   │   ├── input_field_schema.dart
│   │   └── app_config.dart
│   ├── repositories/
│   │   ├── domain_repository.dart
│   │   ├── tracker_repository.dart
│   │   └── event_repository.dart
│   ├── providers/
│   │   ├── core_providers.dart
│   │   ├── tracker_providers.dart
│   │   ├── event_providers.dart
│   │   ├── score_providers.dart
│   │   ├── heatmap_providers.dart
│   │   └── entry_form_provider.dart
│   ├── engines/
│   │   └── input_engine.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── tracker_card.dart
│   │   │       ├── completion_ring.dart
│   │   │       ├── daily_score_display.dart
│   │   │       └── streak_badge.dart
│   │   ├── entry/
│   │   │   ├── entry_sheet.dart
│   │   │   ├── batch_entry_screen.dart
│   │   │   └── widgets/
│   │   │       ├── score_slider.dart
│   │   │       ├── count_stepper.dart
│   │   │       ├── duration_picker.dart
│   │   │       ├── chip_selector.dart
│   │   │       ├── media_capture.dart
│   │   │       └── time_input.dart
│   │   ├── review/
│   │   │   ├── review_screen.dart
│   │   │   └── widgets/
│   │   │       └── heatmap_grid.dart
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── dev_panel.dart
│   ├── services/
│   │   ├── api_client.dart
│   │   ├── config_loader.dart
│   │   └── notification_service.dart
│   └── widgets/
│       └── app_shell.dart
├── assets/
│   ├── tracker_configs/
│   │   ├── domains.json
│   │   └── trackers.json
│   └── sounds/
│       ├── save_tap.wav
│       └── evening_chime.wav
├── test/
├── pubspec.yaml
├── shorebird.yaml
└── firebase_options.dart
```

Assets in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/tracker_configs/
    - assets/sounds/
  fonts:
    # Google Fonts loaded via google_fonts package — no manual font files needed
```

---

# Completion Tracker

**Updated:** 2026-05-01 | **Status:** All phases complete, RC1 ready for release

| Phase | Description | Priority | Status | Date Completed |
|---|---|---|---|---|
| Phase 1 | Scaffold | MUST-HAVE | ✅ COMPLETE | 2026-04-18 |
| Phase 2 | Data layer + seed | MUST-HAVE | ✅ COMPLETE | 2026-04-18 |
| Phase 3 | Home + entry | MUST-HAVE | ✅ COMPLETE | 2026-04-19 |
| Phase 4 | Ring + score + streaks | MUST-HAVE | ✅ COMPLETE | 2026-04-30 |
| Phase 5 | Review + heatmap | MUST-HAVE | ✅ COMPLETE | 2026-04-29 |
| Phase 6 | Batch + notifications | MUST-HAVE | ✅ COMPLETE | 2026-04-26 |
| Phase 7 | Dev panel + polish | DEFERRABLE | ✅ COMPLETE | 2026-04-25 |

**Acceptance Criteria:** ✅ All 9 MVP DoD items met (app runs on device, all trackers render, entries persist, calm home, review grid, backfill, max 2 notifs, batch mode, Design Contract visual language)

**Release readiness:** See `/execution_docs/mvp-completion-and-release-readiness.md` for full audit
