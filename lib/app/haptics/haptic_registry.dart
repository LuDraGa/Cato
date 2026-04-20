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

// ── Gentle ──────────────────────────────────────────────────────────────────
// Like touching silk. Everything is light, barely there.
// Default for Cloud, Water, Bloom archetypes.
const gentle = CatoHapticProfile(
  id: 'gentle',
  name: 'Gentle',
  description: 'Barely there — like touching silk',
  save: HapticType.light,
  complete: HapticType.light,
  milestone: HapticType.medium,
  tick: HapticType.selection,
  delete: HapticType.selection,
);

// ── Balanced ────────────────────────────────────────────────────────────────
// Graduated feedback: quiet ticks, definite save, heavy milestones.
// Default for Earth archetype. The most intuitive profile.
const balanced = CatoHapticProfile(
  id: 'balanced',
  name: 'Balanced',
  description: 'Graduated — quiet ticks to firm milestones',
  save: HapticType.medium,
  complete: HapticType.medium,
  milestone: HapticType.heavy,
  tick: HapticType.selection,
  delete: HapticType.light,
);

// ── Crisp ───────────────────────────────────────────────────────────────────
// Sharp, precise, clicky. Like a mechanical keyboard.
// Default for Ink archetype.
const crisp = CatoHapticProfile(
  id: 'crisp',
  name: 'Crisp',
  description: 'Sharp and precise — like a mechanical switch',
  save: HapticType.medium,
  complete: HapticType.heavy,
  milestone: HapticType.heavy,
  tick: HapticType.light,
  delete: HapticType.medium,
);

// ── Firm ────────────────────────────────────────────────────────────────────
// Authoritative, definite. You feel every interaction.
// Default for Stone archetype.
const firm = CatoHapticProfile(
  id: 'firm',
  name: 'Firm',
  description: 'Definite presence in every interaction',
  save: HapticType.heavy,
  complete: HapticType.heavy,
  milestone: HapticType.heavy,
  tick: HapticType.medium,
  delete: HapticType.medium,
);

// ── Minimal ─────────────────────────────────────────────────────────────────
// Only the save moment matters. Everything else is silent.
// For people who want focus without distraction.
const minimal = CatoHapticProfile(
  id: 'minimal',
  name: 'Minimal',
  description: 'Only save gets feedback',
  save: HapticType.medium,
  complete: HapticType.light,
  milestone: HapticType.medium,
  tick: HapticType.none,
  delete: HapticType.none,
);

// ── None ────────────────────────────────────────────────────────────────────
// No haptics at all. Pure visual feedback.
const none = CatoHapticProfile(
  id: 'none',
  name: 'None',
  description: 'No haptics — visual feedback only',
  save: HapticType.none,
  complete: HapticType.none,
  milestone: HapticType.none,
  tick: HapticType.none,
  delete: HapticType.none,
);
