import 'bloom_themes.dart';
import 'cato_theme_data.dart';
import 'cloud_themes.dart';
import 'earth_themes.dart';
import 'ink_themes.dart';
import 'stone_themes.dart';
import 'water_themes.dart';

/// All available themes, grouped by archetype.
/// To add a new theme:
/// 1. Add a const CatoThemeData to the appropriate archetype file
/// 2. Add it to the list below
const availableThemes = <CatoThemeData>[
  // Cloud — airy, ethereal
  morningMist,
  lavenderHaze,
  pearl,
  // Earth — grounded, warm
  classicEarth,
  desertSand,
  terracotta,
  honey,
  // Water — cool, fluid
  oceanFog,
  rain,
  arctic,
  // Ink — editorial, precise
  inkWash,
  midnight,
  eclipse,
  newsprint,
  // Bloom — soft, organic
  roseClay,
  petal,
  chamomile,
  // Stone — minimal, architectural
  concrete,
  slate,
  sandstone,
];

const defaultThemeId = 'morning_mist';

/// Archetype display names for grouping in the picker.
const archetypeNames = <String, String>{
  'cloud': 'Cloud',
  'earth': 'Earth',
  'water': 'Water',
  'ink': 'Ink',
  'bloom': 'Bloom',
  'stone': 'Stone',
};

/// Archetype descriptions for the picker.
const archetypeDescriptions = <String, String>{
  'cloud': 'Airy and ethereal',
  'earth': 'Grounded and warm',
  'water': 'Cool and fluid',
  'ink': 'Editorial and precise',
  'bloom': 'Soft and organic',
  'stone': 'Minimal and architectural',
};

/// Ordered list of archetype IDs for display.
const archetypeOrder = <String>[
  'cloud',
  'earth',
  'water',
  'ink',
  'bloom',
  'stone',
];

CatoThemeData themeById(String id) {
  return availableThemes.firstWhere(
    (t) => t.id == id,
    orElse: () => availableThemes.first,
  );
}

/// Get all themes for a specific archetype.
List<CatoThemeData> themesByArchetype(String archetypeId) {
  return availableThemes.where((t) => t.archetypeId == archetypeId).toList();
}
