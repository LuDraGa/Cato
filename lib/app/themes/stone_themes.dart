import 'package:flutter/material.dart';

import 'cato_theme_data.dart';

/// ── Stone Archetype ────────────────────────────────────────────────────────
/// Minimal, architectural, geometric. Like a gallery space.
/// Small geometric corners, minimal shadows, measured precise motion.

const concrete = CatoThemeData(
  id: 'concrete',
  name: 'Concrete',
  description: 'Neutral gray, brutalist calm',
  archetypeId: 'stone',
  cornerRadius: 8,
  shadowOpacity: 0.02,
  motionScale: 0.9,
  defaultTypographyId: 'rational',
  defaultSoundPackId: 'wood',
  defaultHapticProfileId: 'firm',

  bgPrimary: Color(0xFFF0F0EE),
  bgSurface: Color(0xFFE2E2E0),
  bgElevated: Color(0xFFF8F8F6),

  inkBlack: Color(0xFF1A1A1A),
  textPrimary: Color(0xFF343434),
  textSecondary: Color(0xFF6C6C6C),
  textTertiary: Color(0xFF9C9C9C),

  accent: Color(0xFF787878),
  accentLight: Color(0xFFA0A0A0),
  accentPale: Color(0xFFC8C8C8),

  nutrition: Color(0xFF6E7E72),
  fitness: Color(0xFF7E7670),
  rest: Color(0xFF6E747E),
  mind: Color(0xFF766E7E),
  vices: Color(0xFF7E6E6E),

  heatNoData: Color(0xFFE2E2E0),
  heatMinimal: Color(0xFFD0D0CE),
  heatLow: Color(0xFFBABAB8),
  heatMid: Color(0xFFA0A0A0),
  heatHigh: Color(0xFF787878),
  heatStrong: Color(0xFF5C5C5C),
  heatPeak: Color(0xFF404040),

  error: Color(0xFF7E6E6E),
  warning: Color(0xFF7E7670),
);

const slate = CatoThemeData(
  id: 'slate',
  name: 'Slate',
  description: 'Blue-gray and cool precision',
  archetypeId: 'stone',
  cornerRadius: 8,
  shadowOpacity: 0.02,
  motionScale: 0.9,
  defaultTypographyId: 'rational',
  defaultSoundPackId: 'wood',
  defaultHapticProfileId: 'firm',

  bgPrimary: Color(0xFFEEEFF2),
  bgSurface: Color(0xFFE0E2E6),
  bgElevated: Color(0xFFF7F8FA),

  inkBlack: Color(0xFF1A1A1A),
  textPrimary: Color(0xFF303640),
  textSecondary: Color(0xFF606A74),
  textTertiary: Color(0xFF909AA4),

  accent: Color(0xFF687888),
  accentLight: Color(0xFF90A0B0),
  accentPale: Color(0xFFBCC8D4),

  nutrition: Color(0xFF688878),
  fitness: Color(0xFF808898),
  rest: Color(0xFF607090),
  mind: Color(0xFF786C90),
  vices: Color(0xFF907C78),

  heatNoData: Color(0xFFE0E2E6),
  heatMinimal: Color(0xFFCED2DA),
  heatLow: Color(0xFFB4BCC8),
  heatMid: Color(0xFF90A0B0),
  heatHigh: Color(0xFF687888),
  heatStrong: Color(0xFF505C6C),
  heatPeak: Color(0xFF3A4452),

  error: Color(0xFF907C78),
  warning: Color(0xFF808898),
);

const sandstone = CatoThemeData(
  id: 'sandstone',
  name: 'Sandstone',
  description: 'Warm gray-beige and quiet geometry',
  archetypeId: 'stone',
  cornerRadius: 8,
  shadowOpacity: 0.02,
  motionScale: 0.9,
  defaultTypographyId: 'rational',
  defaultSoundPackId: 'wood',
  defaultHapticProfileId: 'firm',

  bgPrimary: Color(0xFFF2F0EC),
  bgSurface: Color(0xFFE4E2DC),
  bgElevated: Color(0xFFFAF8F4),

  inkBlack: Color(0xFF1A1A1A),
  textPrimary: Color(0xFF383428),
  textSecondary: Color(0xFF6A6458),
  textTertiary: Color(0xFF9A9488),

  accent: Color(0xFF8A8478),
  accentLight: Color(0xFFAEA898),
  accentPale: Color(0xFFD0CCB8),

  nutrition: Color(0xFF748A76),
  fitness: Color(0xFF8A8270),
  rest: Color(0xFF727A8A),
  mind: Color(0xFF807488),
  vices: Color(0xFF8A7870),

  heatNoData: Color(0xFFE4E2DC),
  heatMinimal: Color(0xFFD4D0C6),
  heatLow: Color(0xFFC0BAA8),
  heatMid: Color(0xFFAEA898),
  heatHigh: Color(0xFF8A8478),
  heatStrong: Color(0xFF6C6860),
  heatPeak: Color(0xFF504E48),

  error: Color(0xFF8A7870),
  warning: Color(0xFF8A8270),
);
