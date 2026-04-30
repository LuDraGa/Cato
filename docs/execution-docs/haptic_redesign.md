# Haptic Redesign — Execution Doc

**Started:** 2026-04-30
**Last refined:** 2026-04-30 (integrated 4-level haptic framework cheat sheet)
**Owner:** Abhiroop
**Status:** ✅ Complete 2026-05-01 — all 10 phases shipped. Phase 9 deferred refinement is intentional: revisit jointly with sound + animation work.

---

## Status checklist

| # | Phase | Status | Notes |
|---|---|---|---|
| 1 | Architecture lock | ✅ Approved 2026-04-30 | Pattern-library + profile-as-composition; HapticType to be removed |
| 2 | Research guardrails (compact) | ✅ In §4 | Pulled from palmScape, ASMR-VR, Vibrotactile Grids; expanded with 4-level framework in §4a, derived rules in §4b |
| 3 | Pattern recipes (paper) | ✅ Approved 2026-04-30 | 10 core patterns in §6; `soft_paper_press` and `stone_stamp` refined per soft-start / no-squeeze rules |
| 4 | Profile mapping | ✅ Approved 2026-04-30 | Drafted in §7 |
| 5 | Sound role contract | ✅ Approved 2026-04-30 | Drafted in §8 |
| 6 | Engine implementation (Kotlin) | ✅ Done 2026-04-30 | `HapticEngine.kt` rewritten with three-tier dispatch + capability probe; legacy `fire(type)` handler retained until phase 10 |
| 7 | Dart wiring (HapticPattern, firePattern) | ✅ Done 2026-04-30 | `cato_haptic_profile.dart` ships `HapticPattern`, `Intensity`, `PatternBinding`, `firePattern`, `cancelHaptic`; new `HapticInteraction.error` slot |
| 8 | Profile rewiring (replace HapticType) | ✅ Done 2026-04-30 | All 6 profiles re-authored as `PatternBinding` compositions in `haptic_registry.dart`; settings demo updated for `error` interaction |
| 9 | On-device tuning pass | 🟡 Deferred | User validated 6 × 6 matrix in settings — feel is "pretty good, not wow." Refinement intentionally deferred to land jointly with sound + animation polish |
| 10 | Cleanup (delete HapticType, legacy paths) | ✅ Done 2026-05-01 | Dart: removed `HapticType` enum and `fireHaptic()`. Kotlin: removed `TYPE_*` constants, `"fire"` channel case, and `fireLegacy()`. New API is the only path |

---

## 1. Locked architecture

```
Interaction intent  →  Pattern  →  Runtime tier  →  Native effect
                       (recipe)    (cap-based)    (composition / waveform / oneshot)

Profile = (intent → pattern) + intensity bias
```

**Decisions locked:**
- Approved: pattern-library + profile-as-composition.
- HapticType removed from the public API. May survive briefly as an internal alias during migration, then deleted.
- Composition-first. Waveform fallback. OneShot last resort.
- Per-call intensity scalar — **kept, quantized** (3 levels). See §3.
- Long-press buildup deferred to V2.
- Three-stage reveal-quote → Dart-side staging via sequenced `firePattern` calls.
- Per-device calibration deferred to V2.
- Sound pairings defined now (role contract); sound engine itself untouched.
- Research integrated as compact guardrails only.
- Universal overdrive removed. Only sharp patterns (`dial_notch`, `stone_stamp`) may use overdrive — and even there it's localized to the attack segment, not every effect.

**Naming convention:**
- Code identifiers: `snake_case` stable strings (`ink_settle`, `wax_seal`).
- Design docs / poetic names: free form ("ink settling," "wax seal stamp").
- Public Dart enum: stable IDs only.

**Product stance (locked):**
> Soft material + precise ceramic + rare ceremonial weight.
> Not buzz, not game reward, not notification vibration, not keyboard click everywhere.

---

## 2. Capability tiers

The engine probes capabilities once at init and selects the highest-fidelity tier each pattern supports.

| Tier | API gate | Hardware gate | Native call |
|---|---|---|---|
| 1 — Composition | `Build.VERSION.SDK_INT ≥ 30` | `vibrator.areAllPrimitivesSupported(usedPrimitives)` | `VibrationEffect.startComposition().addPrimitive(...).compose()` |
| 2 — Waveform | `SDK_INT ≥ 26` | `vibrator.hasAmplitudeControl() == true` | `VibrationEffect.createWaveform(timings, amplitudes, -1)` |
| 3 — OneShot | `SDK_INT ≥ 26` | always | `VibrationEffect.createOneShot(durationMs, amplitude)` |
| 4 — Legacy | `SDK_INT < 26` | always | `vibrator.vibrate(durationMs)` (binary) |

**Per-pattern tier resolution at boot:**
- Compute set of primitives a pattern uses (e.g. `wax_seal` uses `SLOW_RISE, THUD, LOW_TICK`).
- If all supported → Tier 1.
- Else → Tier 2 if amplitude control.
- Else → Tier 3.
- Else → Tier 4 (binary).

Cache the resolved tier per pattern in a map at init. No runtime branching on the hot path.

---

## 3. Per-call intensity (quantized)

Three levels only:

| Level | Factor | When to use |
|---|---|---|
| `soft`   | 0.7  | Gentle profiles, secondary actions (e.g. delete-of-single in Gentle) |
| `base`   | 1.0  | Default. `firePattern(id)` with no arg. |
| `accent` | 1.3  | Profiles that lean firm (Crisp/Firm), or context-amplified moments (delete-of-streak) |

**Application across tiers:**
- Tier 1 (Composition): multiply each primitive's `scale` by factor, clamp to `[0.0, 1.0]`. Recipes are authored at base scales that leave headroom for accent (most peak ≤ 0.75 at base, so accent ≤ 0.975).
- Tier 2 (Waveform): multiply each amplitude by factor, clamp to `[1, 255]`. (0 stays 0 — gaps remain gaps.)
- Tier 3 (OneShot): factor ignored — duration fixed, amplitude fixed.
- Tier 4 (Legacy): factor ignored — binary.

**Why quantized:** prevents call-site drift toward arbitrary tweakability. Forces a semantic choice (soft / base / accent) at the callsite. Three levels are enough for context modulation; more becomes bikeshedding.

---

## 4. Research guardrails (compact)

Synthesized from: *palmScape* (calm/pleasant vibrotactile signals), *Vibrotactile Triggers in ASMR-VR*, *Vibrotactile Grids for Pleasant Touch Interactions*, plus Android Haptics Principles.

**Pleasant zones** (LRA, ~150–235 Hz hardware resonance):

| Dimension | Pleasant range | Becomes unpleasant when |
|---|---|---|
| Single beat duration | 5–40 ms tap, 40–80 ms intentional | >120 ms continuous → buzzing fatigue |
| Inter-beat spacing (double pulse) | 60–110 ms reads as "settled" | <40 ms reads as buzz; >180 ms reads as two events |
| Amplitude (pleasantness peak) | 0.4–0.7 normalized | Sustained >0.85 → unpleasant / startling |
| Decay shape | Slow decay after sharp attack = "warmth" | Slow attack + abrupt cutoff = "muted / flat" |
| Chained micro-tick spacing | 50–80 ms between ticks reads as "rhythm/breath" | <25 ms reads as buzz; >150 ms loses cohesion |

**These are bounds, not targets.** Every recipe in §6 must stay inside them. If the on-device tuning pass nudges a value outside, that's a flag to redesign, not to widen the bounds.

**Two non-obvious findings worth pinning:**
1. **Decay matters more than attack** for pleasantness. A sharp attack with slow decay reads as "warm click that lingers"; a slow attack with sharp cut reads as "anticlimactic." Recipes prioritize decay shape.
2. **Two-pulse rhythms in 60–110 ms range read as "object settling"** — far more pleasant than single longer pulses of equal energy. This is why `two_stage_confirm`, `ink_settle`, and `wax_seal` are all two-pulse.

---

## 4a. The four-level haptic framework

Mapped onto Cato's pattern intent. Cato lives mostly in **Levels 1, 2, and 4**; Level 3 (spatial intimacy) is unreachable on a single-LRA Android phone and is partially substituted via temporal patterns (deferred to V2).

| Level | Goal | Physics target | Cato patterns at this level | Forbidden |
|---|---|---|---|---|
| 1 — Functional Floor | Confirm | 10–30 ms high-freq pulses | `dial_notch`, `glass_bead_tick`, `ceramic_tap`, `blocked_thud` | Haptic ghosting (overlapping pulses blurring distinct actions) |
| 2 — Sensorial Shift | Delight / calm | Low-freq feel, soft-start envelope (start ≤30% peak, ramp ≥15 ms) | `soft_paper_press`, `ink_settle`, `paper_lift` | Sharp 100% amplitude square waves (industrial feel) |
| 3 — Emotional / Intimacy | Relaxed | "Finger touch" via spatial sequencing | (deferred V2: `cloth_glide`, `breath_pulse`) | Squeeze-shaped sustains (read as arousal/stress) |
| 4 — Transcendental / ASMR | Tingles, comfort | 100–200 Hz triggers, real-time vis–haptic sync | `wax_seal`, `stone_stamp`, `two_stage_confirm` (the trailing pulse + visual settle) | Temporal dissonance — visual lag between UI commit and haptic |

**Lucky platform alignment:** Android LRAs resonate at ~150–235 Hz natively, which sits inside the Level 4 ASMR comfort window. The hardware does part of the work for us; our job is shape, not frequency.

**Frequency control we don't have:** True 25 Hz (Level 2 "calm social touch") cannot be produced by a phone LRA — it's well below resonance and would be near-silent. We approximate via low-amplitude `PRIMITIVE_THUD` / `LOW_TICK` plus slow attack envelopes. This is good enough; keep it in mind when judging gentle profiles.

**Spatial techniques we don't have:** No actuator grid on commodity Android. Level 3 patterns (`cloth_glide`, `breath_pulse`) substitute spatial movement with chained temporal micro-ticks. Effect is genuinely weaker — flagged as V2 because they need visual timing maturity to compensate.

---

## 4b. Design rules derived from the framework

These are **hard rules** every pattern in §6 must respect. Violations should fail review, not get tuned later.

1. **No haptic ghosting.** When patterns are sequenced (e.g. Crisp.complete = `dial_notch + two_stage_confirm`), the Dart-side scheduler must enforce a minimum gap of **30 ms** between end-of-pattern-A and start-of-pattern-B. Below that, distinct actions blur.

2. **Soft-start envelope for Level 2 patterns.** Any pattern targeting calm/gentle profiles (`soft_paper_press`, `ink_settle`, `paper_lift`, `ceramic_tap`) must:
   - Open at ≤ 30% of its peak amplitude (≤ 76 / 255 in waveform terms).
   - Reach peak via at least one intermediate amplitude step over ≥ 15 ms (ticks under 5 ms are exempt — they're shorter than the minimum ramp window anyway).
   - Sharp/Level-1 patterns (`dial_notch`, `stone_stamp`, `glass_bead_tick`) are exempt; sharpness is their aesthetic.

3. **No squeeze-shaped sustains.** Flat-top amplitude segments at >70% peak (>178 / 255) longer than 10 ms read as "squeeze" → arousal/stress. Rule: every segment >10 ms at >70% must have a continuous or stepped decay throughout. Sustained ceremonial weight (`stone_stamp`) is achieved by chained mini-decays, not a flat plateau.

4. **Frequency-by-primitive mapping.** We can't set Hz, but primitive choice is our proxy:
   - Calm / relaxed intent → `THUD`, `LOW_TICK` (low-frequency feel).
   - Alert / confirm intent → `TICK`, `CLICK` (higher-frequency feel).
   - Mismatch (e.g. using `CLICK` in a Gentle save) breaks profile coherence and should fail review.

5. **Temporal dissonance is unacceptable.** Pre-fire haptic *before* `setState` — already locked in §5 / existing memory, restated here as a Level 4 hard rule. For sequenced or paired-with-animation patterns, the second pulse must be tied to `AnimationStatus.completed` callbacks, not `Future.delayed` timers (timers drift relative to vsync).

---

## 5. Removed / collapsed concepts

- **`HapticType { selection, light, medium, heavy }`** — removed. Each was a 1-knob-fits-all intensity that erased shape. No replacement; patterns cover the space semantically.
- **Universal overdrive (5 ms @ 200–255 prefix on every effect)** — removed. Its job was ERM motor spin-up, but most modern Android phones have LRAs (which spin up <5 ms naturally) and the prefix imposes a hard click attack hostile to soft patterns. Overdrive survives only as a localized device inside `dial_notch` and `stone_stamp` where sharpness is the aesthetic.
- **Pre-fire is preserved.** The latency principle (fire haptic before setState) is unchanged — that memory is still load-bearing. What changes is *what* fires, not *when*.

---

## 6. Pattern library — 10 core recipes

**Recipe changelog (2026-04-30 refinement pass):**
- `soft_paper_press` Tier 2 — opened entry from 70→50 amplitude, extended rise from 9 ms to 15 ms (compliance with §4b rule 2: soft-start envelope).
- `stone_stamp` Tier 2 — replaced the 25 ms flat sustain at 200 amplitude with a stepped mini-decay (220 → 210 → 200 → 185), each step < 10 ms (compliance with §4b rule 3: no squeeze-shaped sustains). Total duration unchanged within ± 5 ms.

Each pattern below specifies:
- **Stable id** (snake_case) and **poetic intent**.
- **Level** (1/2/4) it targets per the framework in §4a.
- **Tier 1 (Composition):** primitive sequence with base scales and delays.
- **Tier 2 (Waveform):** `timings[]` and `amplitudes[]` arrays for `createWaveform`. Total duration noted.
- **Tier 3 (OneShot):** single `(duration, amplitude)` — *or "skip" if pattern is shape-dependent (see §11 Q5)*.
- **Notes** — design rationale and tuning targets.

Composition primitive shorthand:
`P(LOW_TICK, 0.4, 0)` = `addPrimitive(PRIMITIVE_LOW_TICK, scale=0.4, delayMs=0)`.

---

### 1. `ceramic_tap` — *ceramic tap*
**Intent:** softest tick. Gentle profile selection / scroll feedback. **Level 1.**

- **Tier 1:** `P(LOW_TICK, 0.4, 0)`
- **Tier 2:** `timings=[4]`, `amplitudes=[80]` — 4 ms total
- **Tier 3:** `(6 ms, 60)`
- **Notes:** Single tiny event. No decay needed at this size; the LRA's natural ringdown supplies it. Exempt from soft-start rule (segment < 5 ms).

### 2. `glass_bead_tick` — *glass bead tick*
**Intent:** firmer tick for balanced/crisp profiles. **Level 1.**

- **Tier 1:** `P(TICK, 0.5, 0)`
- **Tier 2:** `timings=[4]`, `amplitudes=[110]` — 4 ms total
- **Tier 3:** `(8 ms, 100)`
- **Notes:** Differs from `ceramic_tap` in attack sharpness, not duration. `TICK` primitive vs `LOW_TICK`. Exempt from soft-start rule (segment < 5 ms).

### 3. `soft_paper_press` — *soft paper press*
**Intent:** gentle save. Subtle attack–sustain–decay shape — the "press into paper" feel. **Level 2 (soft-start envelope mandatory).**

- **Tier 1:** `P(QUICK_FALL, 0.5, 0)`
- **Tier 2:** `timings=[5, 5, 5, 8, 5, 5, 5]`, `amplitudes=[50, 90, 130, 130, 100, 70, 30]` — 38 ms total
- **Tier 3:** *skip* (see §11 Q5 — pattern is shape-dependent; rectangular oneshot betrays the aesthetic)
- **Notes:** Tier 2 envelope: rise (50→130 over 15 ms — opens at 20% peak per §4b rule 2), hold (8 ms @ 130), decay (100→30 over 15 ms). No overdrive. Decay tail is the part that sells "paper." Earlier draft opened at 70 (27%) over 9 ms; refined to honor the ≥ 15 ms ramp rule.

### 4. `ink_settle` — *ink settling*
**Intent:** balanced save. Initial press + brief settle pulse. **Level 2 + 4 (two-pulse rhythm in settled zone).**

- **Tier 1:** `P(TICK, 0.3, 0) + P(LOW_TICK, 0.2, 50)`
- **Tier 2:** `timings=[3, 50, 2]`, `amplitudes=[90, 0, 40]` — 55 ms total
- **Tier 3:** *skip* (see §11 Q5 — the second pulse is the point; one beat alone reads as a regular tick)
- **Notes:** Two-pulse rhythm in the 50 ms "settled" zone. The 2 ms @ 40 tail is the "ink touching paper after the pen lifts." Both segments < 5 ms — soft-start rule N/A.

### 5. `dial_notch` — *mechanical dial notch*
**Intent:** crisp save. Dry, clicky, intentionally sharp. **Level 1 (overdrive permitted).**

- **Tier 1:** `P(CLICK, 0.6, 0)`
- **Tier 2:** `timings=[5]`, `amplitudes=[180]` — 5 ms total, hard cutoff
- **Tier 3:** `(12 ms, 180)`
- **Notes:** **One of two patterns where overdrive is permitted** — the click-snap is the aesthetic. Single tier 2 segment with no decay tail; the abrupt end is the point. Soft-start exempt (Level 1, sharp by design).

### 6. `two_stage_confirm` — *two-stage settle*
**Intent:** complete. Primary tap + delayed warm thud landing when UI animation settles. **Level 4 (visual-haptic sync is the value).**

- **Tier 1:** `P(TICK, 0.3, 0) + P(THUD, 0.6, 70)`
- **Tier 2:** `timings=[3, 70, 3, 4, 4, 4, 4]`, `amplitudes=[90, 0, 130, 180, 140, 90, 50]` — 92 ms total
- **Tier 3:** *split* — fire `(8 ms, 90)` immediately, then schedule `(20 ms, 150)` from Dart at +70 ms (single beat collapse loses the "settle" meaning)
- **Notes:** 70 ms gap is a starting target. Phase 9 should measure actual save-completion animation duration on device and adjust. The trailing thud has a real decay tail (180→50 over 12 ms) — this is where the warmth lives. Per §4b rule 5: when paired with an animation, the trailing thud must hook `AnimationStatus.completed`, not a `Future.delayed`.

### 7. `wax_seal` — *wax seal stamp*
**Intent:** milestone (warm, ceremonial). Slow rise + decaying body + tail + soft echo. **Level 4.**

- **Tier 1:** `P(SLOW_RISE, 0.7, 0) + P(THUD, 0.9, 0) + P(LOW_TICK, 0.25, 90)`
- **Tier 2:** `timings=[5, 5, 5, 5, 10, 5, 5, 5, 5, 80, 3]`, `amplitudes=[60, 100, 140, 180, 200, 160, 120, 80, 40, 0, 50]` — 133 ms total
- **Tier 3:** *split* — fire `(60 ms, 180)` immediately, then schedule `(3 ms, 50)` echo from Dart at +90 ms
- **Notes:** Longest pattern in the library. **Reserved for milestones** — appears rarely; total length acceptable per §11 Q6 because energy is multi-segment with continuous decay, not flat sustain. Rise is 20 ms (60→200) which honors soft-start; decay tail (160→40 over 20 ms) carries the warmth. Echo at 90 ms gap is the "wax cooling."

### 8. `stone_stamp` — *stone stamp*
**Intent:** firm milestone — authoritative, single ceremonial moment. **Level 4 (overdrive permitted on attack only).**

- **Tier 1:** `P(THUD, 0.95, 0)`
- **Tier 2:** `timings=[3, 3, 6, 6, 6, 6, 5, 5, 5]`, `amplitudes=[180, 220, 210, 200, 185, 160, 120, 80, 40]` — 45 ms total
- **Tier 3:** `(50 ms, 220)`
- **Notes:** Refined 2026-04-30: prior draft had a 25 ms flat sustain at amplitude 200, which violated §4b rule 3 (squeeze-shaped). Replaced with stepped mini-decay (220 → 210 → 200 → 185) — same perceived weight, no flat plateau, each segment under 10 ms. **Other pattern where overdrive is permitted** (3 ms @ 220 attack). No echo — single ceremonial impact, unlike `wax_seal` which is two-stage.

### 9. `paper_lift` — *dry paper lift*
**Intent:** delete. Small low-amp build, abrupt cut, brief tail. Receding, not punitive. **Level 2.**

- **Tier 1:** `P(QUICK_FALL, 0.35, 0)`
- **Tier 2:** `timings=[2, 2, 4, 6]`, `amplitudes=[40, 70, 30, 20]` — 14 ms total
- **Tier 3:** `(10 ms, 70)`
- **Notes:** Quietest pattern after the ticks. The two-step build (40→70) and decay tail (30→20) read as "lifting" rather than "snapping." All segments < 5 ms — soft-start rule N/A; entry amplitude 40/255 ≈ 16% peak is well inside Level 2 zone.

### 10. `blocked_thud` — *blocked thud*
**Intent:** error / blocked action. Short damped thud. **No harsh buzz, no echo. Level 1 (functional clarity, damped).**

- **Tier 1:** `P(THUD, 0.5, 0)`
- **Tier 2:** `timings=[4, 8, 5, 5]`, `amplitudes=[140, 110, 70, 40]` — 22 ms total
- **Tier 3:** `(15 ms, 130)`
- **Notes:** Damped — error should feel "stopped," not "alarmed." No double-pulse (would read as confirmation). No overdrive. The 8 ms segment at 110 (43% peak) is the only segment > 5 ms — well below the 70% squeeze threshold, compliant.

---

## 7. Profile mapping

| Profile | save | complete | milestone | tick | delete | error |
|---|---|---|---|---|---|---|
| Gentle   | `soft_paper_press` (base) | `two_stage_confirm` (soft) | `wax_seal` (soft) | `ceramic_tap` (base) | `paper_lift` (soft) | `blocked_thud` (soft) |
| Balanced | `ink_settle` (base) | `two_stage_confirm` (base) | `wax_seal` (base) | `glass_bead_tick` (base) | `paper_lift` (base) | `blocked_thud` (base) |
| Crisp    | `dial_notch` (base) | `dial_notch + two_stage_confirm` (sequenced) | `stone_stamp` (base) | `glass_bead_tick` (accent) | `dial_notch` (soft) | `blocked_thud` (accent) |
| Firm     | `stone_stamp` (soft) | `stone_stamp` (base) | `stone_stamp + wax_seal` (sequenced, accent) | `dial_notch` (base) | `stone_stamp` (soft) | `blocked_thud` (base) |
| Minimal  | `ink_settle` (base) | `soft_paper_press` (soft) | `wax_seal` (base) | none | none | `blocked_thud` (soft) |
| None     | none | none | none | none | none | none |

**"Sequenced" entries** (Crisp.complete, Firm.milestone) fire two patterns in order from the Dart side, not at the native layer. This keeps the engine stateless and the orchestration testable in Dart.

**`error` is a new interaction role** that the current `HapticInteraction` enum doesn't cover. Phase 7 will add it.

---

## 8. Sound role contract

Sound packs are aesthetic skins (ceramic / paper / water / wood / bell / glass / textile / silence) and are **orthogonal to haptic profile**. A user can pick {Crisp haptics + Bell sounds} or {Gentle haptics + Wood sounds}.

The contract for this redesign:

1. **Haptic patterns fire alongside the sound for the matching interaction role.** No pattern→specific-asset coupling.
2. **Roles align 1:1** between haptic and sound: `save`, `complete`, `milestone`, `tick`, `delete`. (+ new `error`.)
3. **Trigger order:** haptic fires *before* `setState`, sound fires *with* `setState` (audio decode latency means sound naturally lags slightly even when triggered together). This was already the established pattern; preserved.
4. **Sound engine is not rebuilt.** Existing `SoundAsset` system is untouched. The only additive request:
   - Add an `error` `SoundAsset` to each pack — or, until assets exist, fall back to the pack's `delete` asset. (Phase 8 task.)

**Principle:** haptic shape and sound shape should agree (both gentle, both crisp, both ceremonial), but the *coupling is at the role level, not the asset level*. This keeps the matrix at 6 packs × 1 role mapping = 6, not 6 packs × 10 patterns = 60.

---

## 9. Migration / kill plan for `HapticType`

Current callers of the haptic API use `HapticType.{selection, light, medium, heavy}` indirectly via `CatoHapticProfile.{save, complete, milestone, tick, delete}` and `play(HapticInteraction)`.

Migration steps (deferred until phases 6–8):

1. Introduce `HapticPattern` (string id enum) and `firePattern(String, {Intensity})` alongside the existing API. Both work.
2. Rewire each profile to use pattern ids instead of `HapticType` values.
3. Replace `play(HapticInteraction)` body to dispatch via pattern lookup.
4. Confirm no other callers of `fireHaptic(HapticType)` remain.
5. Delete `HapticType` enum and `fireHaptic` function. Delete legacy native handler `"fire"` once the new `"firePattern"` handler is live.
6. Delete the universal-overdrive code paths in Kotlin.

No backwards-compat shim. The redesign is internal; no public API consumers.

---

## 10. Deferred to V2 / later

These are out of scope for this pass — listed so they don't get lost:

- **Continuous / gesture haptics** — `cloth_glide`, `breath_pulse`, `latch_click`, `latch_return`. Need visual timing maturity (swipe completion, toggle animation duration) before authoring.
- **Long-press buildup** — different API shape (continuous ramp + release), not a single recipe.
- **Per-device calibration screen** — let users tune amplitude range if their phone's LRA feels off.
- **Reveal-quote three-stage haptic** — Dart-side sequenced `firePattern` calls; recipe TBD when the reveal animation is finalized.
- **Sound engine rebuild** — out of scope. May revisit when assets are sourced and pack→pattern coupling proves insufficient.
- **`error` sound assets** — additive, deferred to phase 8.

---

## 11. Open review questions

Before greenlighting phases 6+, please confirm. Items marked **🟢 proposed** are answered by the 4-level cheat-sheet integration; confirm or override.

1. **Intensity factors `{0.7, 1.0, 1.3}`** — ✅ **Locked.** ~30% perceptual delta is the noticeable threshold; tighter is undifferentiated, wider clamps too many composition primitives whose base scale is already high (`stone_stamp` THUD @ 0.95, `wax_seal` THUD @ 0.9).

2. **`two_stage_confirm` 70 ms gap** — 🟢 *proposed:* keep 70 ms as the authored default (sits inside both the 60–110 ms "settled" research bound and the cheat sheet's <100 ms "movement" delay window). Phase 9 measures actual save-animation duration on device; if it lands at, say, 90 ms, retune the recipe rather than insert a `Future.delayed`. **Confirm?**

3. **Sequenced patterns** (Crisp.complete = `dial_notch + two_stage_confirm`, Firm.milestone = `stone_stamp + wax_seal`) — 🟢 *proposed:* orchestrate from Dart, with §4b rule 1 enforcement (≥30 ms gap between patterns to prevent ghosting). Native side stays stateless. **Confirm?**

4. **`error` interaction role** — ✅ **Locked: add now.** Recipe is already authored (`blocked_thud`), profile mappings already specify the role, splitting it into a follow-up PR adds friction with zero migration benefit. Non-breaking either way; complete design ships together.

5. **Tier 3 (OneShot) for shape-dependent patterns** — 🟢 *proposed:* The cheat sheet's Level 2 "never sharp 100% square waves" rules out lossy oneshot fallbacks for shape-dependent patterns. Updated stance:
   - **Skip Tier 3 entirely** for `soft_paper_press`, `ink_settle` — devices that can't render shape get no haptic for these (visual feedback only). Loud bad oneshot is worse than silence here.
   - **Split Tier 3** for `two_stage_confirm`, `wax_seal` — Dart schedules two oneshots to preserve the two-pulse rhythm.
   - **Keep simple Tier 3** for the rest (`dial_notch`, `stone_stamp`, `glass_bead_tick`, `ceramic_tap`, `paper_lift`, `blocked_thud`) where a single beat is acceptable degradation. **Confirm?**

6. **`wax_seal` length (133 ms Tier 2)** — 🟢 *proposed:* Acceptable. Exceeds the 120 ms "buzzing fatigue" research bound *only* in total duration; the energy is multi-segment with continuous decay (no flat sustain), which the bound is really about. Reserved for rare milestone moments. **Confirm?**

All six questions resolved (2026-04-30). Phase 6 (Kotlin engine) underway.
