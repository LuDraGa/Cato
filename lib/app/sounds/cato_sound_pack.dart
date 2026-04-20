/// Defines a set of interaction sounds for a specific aesthetic.
///
/// Each sound path points to an asset in assets/sounds/<packId>/.
/// Null paths mean the interaction is silent for this pack.
class CatoSoundPack {
  const CatoSoundPack({
    required this.id,
    required this.name,
    required this.description,
    this.save,
    this.complete,
    this.milestone,
    this.tick,
    this.delete,
  });

  final String id;
  final String name;
  final String description;

  /// Entry saved — the signature moment
  final SoundAsset? save;

  /// All trackers done for the day
  final SoundAsset? complete;

  /// Streak milestone reached
  final SoundAsset? milestone;

  /// Slider/stepper increment
  final SoundAsset? tick;

  /// Entry deleted
  final SoundAsset? delete;
}

class SoundAsset {
  const SoundAsset({
    required this.path,
    required this.description,
    this.isPlaceholder = false,
  });

  /// Asset path relative to assets/ (e.g., 'sounds/ceramic/save.ogg')
  final String path;

  /// Description of the intended sound (for sourcing replacements)
  final String description;

  /// True if this is a placeholder that needs a real asset
  final bool isPlaceholder;
}
