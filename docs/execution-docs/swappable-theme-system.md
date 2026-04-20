# Swappable Theme System — Full Aesthetic Engine

**Date:** 2026-04-20
**Status:** Complete (sound assets pending)
**Trigger:** Need runtime theme switching with truly distinct palettes; extend to full aesthetic customization (typography, sound, haptics)

---

## Architecture: Four Customization Dimensions

| Dimension | Count | Bundled with theme? | Overridable? |
|---|---|---|---|
| Color themes | 20 (6 archetypes) | — | — |
| Typography | 12 pairings | Yes (default per theme) | Yes |
| Sound packs | 8 packs | Yes (default per theme) | Yes |
| Haptic profiles | 6 profiles | Yes (default per theme) | Yes |

## Theme Archetypes

Each archetype defines not just colors but shape, motion, and defaults:

| Archetype | Corner | Shadow | Motion | Typography | Sound | Haptic |
|---|---|---|---|---|---|---|
| **Cloud** | 16px (soft) | 0.03 (subtle) | 1.2× (slow) | Classic | Water | Gentle |
| **Earth** | 12px (medium) | 0.05 (warm) | 1.0× (steady) | Gentle | Ceramic | Balanced |
| **Water** | 14px (round) | 0.04 (cool) | 1.1× (smooth) | Bookish | Water | Gentle |
| **Ink** | 6px (sharp) | 0.06 (crisp) | 0.8× (quick) | Editorial | Paper | Crisp |
| **Bloom** | 18px (very soft) | 0.03 (diffuse) | 1.3× (gentlest) | Craft | Bell | Gentle |
| **Stone** | 8px (geometric) | 0.02 (minimal) | 0.9× (measured) | Rational | Wood | Firm |

### 20 Themes

**Cloud (3):** Morning Mist, Lavender Haze, Pearl
**Earth (4):** Classic Earth, Desert Sand, Terracotta, Honey
**Water (3):** Ocean Fog, Rain, Arctic
**Ink (4):** Ink Wash, Midnight (dark), Eclipse (dark), Newsprint
**Bloom (3):** Rose Clay, Petal, Chamomile
**Stone (3):** Concrete, Slate, Sandstone

### 12 Typography Pairings

| ID | Name | Serif | Sans |
|---|---|---|---|
| classic | Classic | Source Serif 4 | Inter |
| bookish | Bookish | Literata | Inter |
| editorial | Editorial | DM Serif Display | DM Sans |
| rational | Rational | IBM Plex Serif | IBM Plex Sans |
| gentle | Gentle | Crimson Pro | Karla |
| craft | Craft | Fraunces | Outfit |
| warm | Warm | Lora | Rubik |
| universal | Universal | Noto Serif | Noto Sans |
| elegant | Elegant | Libre Baskerville | Lato |
| dramatic | Dramatic | Playfair Display | Lato |
| mono | Monospace | JetBrains Mono | JetBrains Mono |
| delicate | Delicate | Cormorant Garamond | Quicksand |

### 8 Sound Packs

Ceramic, Paper, Water, Wood, Bell, Glass, Textile, Silence

All sound assets are placeholder (TODO) — see `assets/sounds/SOUND_ASSETS_TODO.md` for exact requirements per sound.

### 6 Haptic Profiles

Gentle, Balanced, Crisp, Firm, Minimal, None

## Data Models

- `CatoThemeData` — colors + cornerRadius + shadowOpacity + motionScale + default IDs
- `CatoTypography` — serif + sans font names
- `CatoSoundPack` — paths for save/complete/milestone/tick/delete + descriptions
- `CatoHapticProfile` — HapticType enum per interaction

## Provider System

- `themeProvider` — StateNotifier managing theme ID, persists to AppConfig
- `typographyOverrideProvider` — null = theme default, non-null = user choice
- `soundPackOverrideProvider` — same pattern
- `hapticProfileOverrideProvider` — same pattern
- `effectiveTypographyIdProvider` / `effectiveSoundPackIdProvider` / `effectiveHapticProfileIdProvider` — derived providers resolving override vs default

Switching themes resets all overrides to theme defaults.

## Settings UI

- **Aesthetic section** — Theme, Typography, Sound Pack, Haptics rows
- **Theme picker** — Bottom sheet with horizontal scroll per archetype group
- **Typography/Sound/Haptic pickers** — Generic option picker bottom sheet with "Reset to theme default" button
- **Haptic picker** — Previews the haptic on selection

## Dynamic Properties

- `AppDurations` — durations scaled by `motionScale` from active theme
- `surfaceShadow()` — opacity from active theme's `shadowOpacity`
- `AppColors.cornerRadius` — exposed for widgets to use (currently informational; widget sweep to follow)

## Files

### Created
- `lib/app/themes/cato_theme_data.dart` — expanded model
- `lib/app/themes/cloud_themes.dart` — 3 themes
- `lib/app/themes/earth_themes.dart` — 4 themes
- `lib/app/themes/water_themes.dart` — 3 themes
- `lib/app/themes/ink_themes.dart` — 4 themes (2 dark)
- `lib/app/themes/bloom_themes.dart` — 3 themes
- `lib/app/themes/stone_themes.dart` — 3 themes
- `lib/app/themes/theme_registry.dart` — registry with archetype grouping
- `lib/app/typography/cato_typography.dart` — model
- `lib/app/typography/typography_registry.dart` — 12 pairings
- `lib/app/sounds/cato_sound_pack.dart` — model
- `lib/app/sounds/sound_registry.dart` — 8 packs with descriptions
- `lib/app/haptics/cato_haptic_profile.dart` — model + play()
- `lib/app/haptics/haptic_registry.dart` — 6 profiles
- `assets/sounds/` — directory structure for 7 packs
- `assets/sounds/SOUND_ASSETS_TODO.md` — sourcing guide

### Modified
- `lib/app/theme.dart` — dynamic durations, shadow, typography, dark mode support
- `lib/providers/theme_provider.dart` — override providers + persistence
- `lib/screens/settings/settings_screen.dart` — full aesthetic settings UI
- `lib/screens/home/home_screen.dart` — watches themeProvider
- `lib/screens/review/review_screen.dart` — watches themeProvider
- `lib/widgets/app_shell.dart` — watches themeProvider

### Deleted
- `lib/app/themes/morning_mist.dart` (consolidated)
- `lib/app/themes/classic_earth.dart` (consolidated)
- `lib/app/themes/ocean_fog.dart` (consolidated)
- `lib/app/themes/rose_clay.dart` (consolidated)
- `lib/app/themes/ink_wash.dart` (consolidated)
- `lib/app/themes/desert_dusk.dart` (consolidated)

## Validation

`flutter analyze` — 0 errors, 0 warnings (6 pre-existing info-level lints)

## TODO

- [ ] Source actual .ogg sound assets for all 7 packs (35 sounds total)
- [ ] Sweep widget files to use `AppColors.cornerRadius` instead of hardcoded radii
- [ ] Wire haptic profiles into actual interaction points (entry save, sliders, etc.)
- [ ] Wire sound packs into the existing SoundService
- [ ] Monetization gate: mark themes as free/premium
