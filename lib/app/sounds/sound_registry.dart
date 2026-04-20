import 'cato_sound_pack.dart';

// TODO: Source actual audio assets for each pack.
// Format: .ogg (Android-native, zero decode latency)
// Size: each sound <50KB, full pack <500KB
// Pre-load at app init for sub-50ms response time.
//
// Sources to check:
// - freesound.org (CC-licensed, filter by rating)
// - zapsplat.com (free with attribution, paid for no-attribution)
// - pixabay.com/sound-effects (royalty-free, no attribution)
// - Google Material Sound assets (GitHub: material-design-icons/sound)

const availableSoundPacks = <CatoSoundPack>[
  ceramic,
  paper,
  water,
  wood,
  bell,
  glass,
  textile,
  silence,
];

const defaultSoundPackId = 'ceramic';

CatoSoundPack soundPackById(String id) {
  return availableSoundPacks.firstWhere(
    (s) => s.id == id,
    orElse: () => availableSoundPacks.first,
  );
}

// ── Ceramic ─────────────────────────────────────────────────────────────────
// The tactile default. Clay taps, porcelain clicks, kiln-fired detents.
// Reference: the "ceramic light switch" from the aesthetic lenses doc.
const ceramic = CatoSoundPack(
  id: 'ceramic',
  name: 'Ceramic',
  description: 'Clay taps and porcelain clicks',
  save: SoundAsset(
    path: 'sounds/ceramic/save.ogg',
    description: 'Single ceramic tap — like setting down a cup on a saucer. '
        'Short attack, warm resonance, ~150ms total.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/ceramic/complete.ogg',
    description: 'Deeper ceramic bowl tap — rounder, more resonant than save. '
        'Like tapping a thick pottery bowl. ~300ms with decay.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/ceramic/milestone.ogg',
    description: 'Two ceramic taps in quick succession (low then high), '
        'like stacking two bowls. ~400ms total.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/ceramic/tick.ogg',
    description: 'Tiny porcelain click — like a ceramic bead dropping. '
        'Very short, dry, ~50ms. Must not fatigue on rapid repetition.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/ceramic/delete.ogg',
    description: 'Soft scrape — like sliding a ceramic piece across a surface. '
        'Receding, not punitive. ~200ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Paper ────────────────────────────────────────────────────────────────────
// Stationery and bookbinding. Page turns, pencil marks, paper folds.
// Reference: "paper resting under natural light" from product DNA.
const paper = CatoSoundPack(
  id: 'paper',
  name: 'Paper',
  description: 'Page turns and pencil marks',
  save: SoundAsset(
    path: 'sounds/paper/save.ogg',
    description: 'Single page turn — not a full book flip, just one leaf '
        'of quality paper settling. ~200ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/paper/complete.ogg',
    description: 'Soft book closing — a journal shutting with gentle finality. '
        '~350ms with muffled thud at end.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/paper/milestone.ogg',
    description: 'Paper stamp impression — like a seal pressed into paper. '
        'Brief impact followed by a soft exhale of compressed air. ~300ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/paper/tick.ogg',
    description: 'Pencil mark — single graphite stroke on paper. '
        'Dry, textured, ~40ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/paper/delete.ogg',
    description: 'Paper tear — gentle, not violent. Like tearing a perforated '
        'edge off a notebook page. ~250ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Water ────────────────────────────────────────────────────────────────────
// Calm water: drops, ripples, gentle stream moments.
// The most zen/meditative option.
const water = CatoSoundPack(
  id: 'water',
  name: 'Water',
  description: 'Drops and ripples',
  save: SoundAsset(
    path: 'sounds/water/save.ogg',
    description: 'Single water drop into a still pool — clear, round, '
        'with a brief ripple decay. ~250ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/water/complete.ogg',
    description: 'Two drops in sequence (different pitches) — like the last '
        'two drops from a faucet settling into stillness. ~400ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/water/milestone.ogg',
    description: 'Gentle stream moment — a brief 500ms sample of water '
        'flowing over smooth stones, fading to silence.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/water/tick.ogg',
    description: 'Tiny bubble pop — almost subliminal, very short. '
        '~30ms. Must not fatigue.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/water/delete.ogg',
    description: 'Water draining — gentle, receding, like the last '
        'of bathwater finding the drain. ~300ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Wood ─────────────────────────────────────────────────────────────────────
// Workshop and nature: bamboo, woodblocks, soft knocks.
// Grounding, warm, grounded.
const wood = CatoSoundPack(
  id: 'wood',
  name: 'Wood',
  description: 'Bamboo ticks and soft knocks',
  save: SoundAsset(
    path: 'sounds/wood/save.ogg',
    description: 'Bamboo knock — hollow, warm, like tapping a bamboo tube '
        'with a wooden mallet. ~180ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/wood/complete.ogg',
    description: 'Wooden box closing — the satisfying click of a '
        'well-fitted wooden lid settling. ~250ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/wood/milestone.ogg',
    description: 'Temple woodblock (mokugyo) — single strike, resonant. '
        'Like the start of a meditation. ~500ms with decay.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/wood/tick.ogg',
    description: 'Chopstick tap — two thin wooden sticks clicking together. '
        'Dry, precise, ~40ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/wood/delete.ogg',
    description: 'Drawer sliding — a wooden drawer pushed gently closed. '
        'Receding, soft friction. ~300ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Bell ─────────────────────────────────────────────────────────────────────
// Meditation and mindfulness: singing bowls, temple bells, soft chimes.
// The most overtly spiritual option.
const bell = CatoSoundPack(
  id: 'bell',
  name: 'Bell',
  description: 'Singing bowls and soft chimes',
  save: SoundAsset(
    path: 'sounds/bell/save.ogg',
    description: 'Small singing bowl — single soft strike with a mallet. '
        'Clear fundamental, gentle overtones, ~400ms decay.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/bell/complete.ogg',
    description: 'Medium singing bowl — deeper, richer than save. '
        'Longer resonance, ~600ms total.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/bell/milestone.ogg',
    description: 'Temple bell (bonshō style) — single deep strike, '
        'long warm decay. Feels significant. ~800ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/bell/tick.ogg',
    description: 'Tiny wind chime — single high note from a small '
        'metal tube. Bright but not harsh, ~60ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/bell/delete.ogg',
    description: 'Dampened bell — a chime immediately muted by a palm. '
        'Brief ring cut short. ~150ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Glass ────────────────────────────────────────────────────────────────────
// Crystal and glass: clear, bright, delicate.
// Elegant, slightly cooler than bell.
const glass = CatoSoundPack(
  id: 'glass',
  name: 'Glass',
  description: 'Crystal clinks and wind chimes',
  save: SoundAsset(
    path: 'sounds/glass/save.ogg',
    description: 'Wine glass rim tap — gentle finger tap on crystal. '
        'Clear, bright, ~200ms decay.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/glass/complete.ogg',
    description: 'Two glasses touching — a soft toast clink. '
        'Brief, celebratory without being loud. ~300ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/glass/milestone.ogg',
    description: 'Crystal bowl singing — a wet finger circling a crystal rim. '
        'Brief swell of a pure tone. ~500ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/glass/tick.ogg',
    description: 'Glass marble click — two small glass beads touching. '
        'Tiny, precise, ~30ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/glass/delete.ogg',
    description: 'Glass bead rolling — a small marble rolling across a '
        'surface and stopping. Receding. ~250ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Textile ──────────────────────────────────────────────────────────────────
// Fabric and thread: soft, warm, tactile.
// The coziest option — like wrapping up in a blanket.
const textile = CatoSoundPack(
  id: 'textile',
  name: 'Textile',
  description: 'Soft fabric and thread',
  save: SoundAsset(
    path: 'sounds/textile/save.ogg',
    description: 'Cloth fold — a single fold of quality linen or cotton. '
        'Soft, warm friction. ~200ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  complete: SoundAsset(
    path: 'sounds/textile/complete.ogg',
    description: 'Blanket settling — the sound of a throw blanket landing '
        'softly on a surface. Muffled, warm. ~350ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  milestone: SoundAsset(
    path: 'sounds/textile/milestone.ogg',
    description: 'Ribbon pull — a satin ribbon being pulled through fabric. '
        'Smooth, satisfying, slight rasp. ~400ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  tick: SoundAsset(
    path: 'sounds/textile/tick.ogg',
    description: 'Thread snap — a single thread being plucked or snapped. '
        'Tiny, almost inaudible. ~25ms.',
    isPlaceholder: true, // TODO: source asset
  ),
  delete: SoundAsset(
    path: 'sounds/textile/delete.ogg',
    description: 'Velcro whisper — a very gentle, very short velcro separation. '
        'Not harsh — the softest, briefest version. ~150ms.',
    isPlaceholder: true, // TODO: source asset
  ),
);

// ── Silence ──────────────────────────────────────────────────────────────────
// No sounds at all. Haptics carry the full experience.
// Should always be a free option.
const silence = CatoSoundPack(
  id: 'silence',
  name: 'Silence',
  description: 'No sounds — haptics only',
);
