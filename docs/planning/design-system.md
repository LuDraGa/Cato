# Design System

**Status:** Planning
**Dependencies:** product-dna.md (Theme #8: Aesthetic Craft, Theme #9: Ritual Design)
**Feeds into:** user-flows.md, Figma designs, all UI implementation

---

*Concrete specifications for the design language described in the DNA. Hex values, font names, spacing scales, motion curves, haptic patterns, sound specs.*

---

## Defined

### Color Palette — "Morning Mist"

Philosophy: Calm neutrals over earthy pigments. Warmth comes from light quality, not pigment saturation. The palette feels like cloud, stone, and water — soothing, never asserting.

**Backgrounds (warm cloud family):**
| Token | Hex | RGB | Role |
|---|---|---|---|
| bgPrimary | `#F4F3F0` | 244, 243, 240 | Canvas / scaffold background |
| bgSurface | `#E9E8E4` | 233, 232, 228 | Receded surfaces, inputs, tracks |
| bgElevated | `#FBFAF8` | 251, 250, 248 | Cards, sheets, active surfaces |

**Text (warm-neutral cascade):**
| Token | Hex | Role |
|---|---|---|
| inkBlack | `#1A1A1A` | Focal data only (1-2 per screen) |
| textPrimary | `#353330` | Main readable content |
| textSecondary | `#6D6B66` | Secondary info, subtitles |
| textTertiary | `#9C9A95` | Hints, disabled, captions |

**Accent — "mist sage" (between sage and teal):**
| Token | Hex | Role |
|---|---|---|
| sage | `#7C9A92` | Primary interactive: buttons, ring, active states |
| sageLight | `#A6C4BB` | Selected chips, light fills |
| sagePale | `#D2E3DD` | Wash / tint backgrounds |

**Domain colors (harmonized watercolor set):**
| Token | Hex | Character |
|---|---|---|
| nutrition | `#88A698` | Soft green, aligned with accent |
| fitness | `#AE9A86` | Warm stone |
| rest | `#8C93B0` | Soft twilight |
| mind | `#9B8DA6` | Quiet lavender |
| vices | `#AE8F8A` | Faded rose |

**Heatmap gradient (accent wash → saturated):**
| Token | Hex |
|---|---|
| heatNoData | `#E9E8E4` (bgSurface) |
| heatMinimal | `#DBE6E2` |
| heatLow | `#C8DAD4` |
| heatMid | `#A6C4BB` |
| heatHigh | `#7C9A92` |
| heatStrong | `#5C7A72` |
| heatPeak | `#3E5C55` |

**Semantic:**
| Token | Hex | Note |
|---|---|---|
| error | `#AE8F8A` | Faded rose — never punitive |
| warning | `#AE9A86` | Warm stone |

### Typography

- **Display:** Source Serif 4, 26px, w600
- **Headline:** Source Serif 4, 20px, w600
- **Title:** Source Serif 4, 17px, w500
- **Metric:** Inter, 28px, w600
- **Body Large:** Inter, 14px, w400
- **Body Medium:** Inter, 14px, w400
- **Body Small:** Inter, 11px, w400
- **Label Large:** Inter, 13px, w500
- **Label Medium:** Inter, 13px, w500

### Spacing System

Base unit: 4px. Scale: xs(4), sm(8), md(12), lg(16), xl(24), xxl(32), xxxl(48).

### Elevation & Depth

- Normal shadow: offset(0,1), blur 4, inkBlack @ 0.04 alpha
- Elevated shadow: offset(0,2), blur 8, inkBlack @ 0.06 alpha
- Material layering: bgSurface (receded) → bgPrimary (resting) → bgElevated (elevated)

### Motion System

- Micro: 120ms
- Short: 220ms (most interactive elements, easeOutCubic)
- Medium: 340ms (page transitions)
- Long: 560ms (score count-up, milestone moments)
- Spring: mass 1, stiffness 220, damping 32 (completion ring)

## To Define

- [ ] Haptic patterns (entry save, streak milestone, error, navigation)
- [ ] Sound design (entry save, completion, milestone, notification tone)
- [ ] Component library (entry card, heatmap cell, score slider, completion ring, streak badge, nav bar)
- [ ] Data visualization style (bezier curves, gauge styles, heatmap gradient, chart typography)
- [ ] Dark mode treatment (if applicable)
- [ ] Iconography style
