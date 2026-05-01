import 'cato_haptic_profile.dart';

const availableHapticProfiles = <CatoHapticProfile>[
  gentle,
  balanced,
  crisp,
  firm,
  minimal,
  none,
];

const defaultHapticProfileId = 'balanced';

CatoHapticProfile hapticProfileById(String id) {
  return availableHapticProfiles.firstWhere(
    (h) => h.id == id,
    orElse: () => availableHapticProfiles.first,
  );
}

// Convenience single-pattern bindings, used widely below.
const _ceramicTap = PatternBinding([
  PatternStep(pattern: HapticPattern.ceramicTap),
]);
const _glassBeadTick = PatternBinding([
  PatternStep(pattern: HapticPattern.glassBeadTick),
]);
const _glassBeadTickAccent = PatternBinding([
  PatternStep(
    pattern: HapticPattern.glassBeadTick,
    intensity: Intensity.accent,
  ),
]);
const _softPaperPress = PatternBinding([
  PatternStep(pattern: HapticPattern.softPaperPress),
]);
const _softPaperPressSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.softPaperPress, intensity: Intensity.soft),
]);
const _inkSettle = PatternBinding([
  PatternStep(pattern: HapticPattern.inkSettle),
]);
const _dialNotch = PatternBinding([
  PatternStep(pattern: HapticPattern.dialNotch),
]);
const _dialNotchSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.dialNotch, intensity: Intensity.soft),
]);
const _twoStageConfirm = PatternBinding([
  PatternStep(pattern: HapticPattern.twoStageConfirm),
]);
const _twoStageConfirmSoft = PatternBinding([
  PatternStep(
    pattern: HapticPattern.twoStageConfirm,
    intensity: Intensity.soft,
  ),
]);
const _waxSeal = PatternBinding([PatternStep(pattern: HapticPattern.waxSeal)]);
const _waxSealSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.waxSeal, intensity: Intensity.soft),
]);
const _stoneStamp = PatternBinding([
  PatternStep(pattern: HapticPattern.stoneStamp),
]);
const _stoneStampSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.stoneStamp, intensity: Intensity.soft),
]);
const _paperLift = PatternBinding([
  PatternStep(pattern: HapticPattern.paperLift),
]);
const _paperLiftSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.paperLift, intensity: Intensity.soft),
]);
const _blockedThud = PatternBinding([
  PatternStep(pattern: HapticPattern.blockedThud),
]);
const _blockedThudSoft = PatternBinding([
  PatternStep(pattern: HapticPattern.blockedThud, intensity: Intensity.soft),
]);
const _blockedThudAccent = PatternBinding([
  PatternStep(pattern: HapticPattern.blockedThud, intensity: Intensity.accent),
]);

// Sequenced bindings (§7 of haptic_redesign.md).
// gapAfterMs is the delay before the NEXT step; clamped ≥ 30 ms by fire().
const _crispComplete = PatternBinding([
  PatternStep(pattern: HapticPattern.dialNotch, gapAfterMs: 50),
  PatternStep(pattern: HapticPattern.twoStageConfirm),
]);
const _firmMilestone = PatternBinding([
  PatternStep(
    pattern: HapticPattern.stoneStamp,
    intensity: Intensity.accent,
    gapAfterMs: 80,
  ),
  PatternStep(pattern: HapticPattern.waxSeal, intensity: Intensity.accent),
]);

// ── Gentle ──────────────────────────────────────────────────────────────────
// Like touching silk. Soft material throughout; rare ceremonial weight.
// Default for Cloud, Water, Bloom archetypes.
const gentle = CatoHapticProfile(
  id: 'gentle',
  name: 'Gentle',
  description: 'Barely there — like touching silk',
  save: _softPaperPress,
  complete: _twoStageConfirmSoft,
  milestone: _waxSealSoft,
  tick: _ceramicTap,
  delete: _paperLiftSoft,
  error: _blockedThudSoft,
);

// ── Balanced ────────────────────────────────────────────────────────────────
// Graduated feedback: ink-settle saves, two-stage completes, ceremonial milestones.
// Default for Earth archetype. The most intuitive profile.
const balanced = CatoHapticProfile(
  id: 'balanced',
  name: 'Balanced',
  description: 'Graduated — quiet ticks to firm milestones',
  save: _inkSettle,
  complete: _twoStageConfirm,
  milestone: _waxSeal,
  tick: _glassBeadTick,
  delete: _paperLift,
  error: _blockedThud,
);

// ── Crisp ───────────────────────────────────────────────────────────────────
// Dial notches and dry clicks. Like a mechanical instrument.
// Default for Ink archetype.
const crisp = CatoHapticProfile(
  id: 'crisp',
  name: 'Crisp',
  description: 'Sharp and precise — like a mechanical switch',
  save: _dialNotch,
  complete: _crispComplete,
  milestone: _stoneStamp,
  tick: _glassBeadTickAccent,
  delete: _dialNotchSoft,
  error: _blockedThudAccent,
);

// ── Firm ────────────────────────────────────────────────────────────────────
// Stone stamps and ceremonial weight. You feel every interaction.
// Default for Stone archetype.
const firm = CatoHapticProfile(
  id: 'firm',
  name: 'Firm',
  description: 'Definite presence in every interaction',
  save: _stoneStampSoft,
  complete: _stoneStamp,
  milestone: _firmMilestone,
  tick: _dialNotch,
  delete: _stoneStampSoft,
  error: _blockedThud,
);

// ── Minimal ─────────────────────────────────────────────────────────────────
// Only meaningful moments get feedback. Ticks and deletes silent.
const minimal = CatoHapticProfile(
  id: 'minimal',
  name: 'Minimal',
  description: 'Only save gets feedback',
  save: _inkSettle,
  complete: _softPaperPressSoft,
  milestone: _waxSeal,
  tick: PatternBinding.none,
  delete: PatternBinding.none,
  error: _blockedThudSoft,
);

// ── None ────────────────────────────────────────────────────────────────────
// No haptics at all. Pure visual feedback.
const none = CatoHapticProfile(
  id: 'none',
  name: 'None',
  description: 'No haptics — visual feedback only',
  save: PatternBinding.none,
  complete: PatternBinding.none,
  milestone: PatternBinding.none,
  tick: PatternBinding.none,
  delete: PatternBinding.none,
  error: PatternBinding.none,
);
