import 'package:flutter/material.dart';

import 'cato_theme_data.dart';

/// ── Ink Archetype ──────────────────────────────────────────────────────────
/// Editorial, precise, high contrast. Like a well-set newspaper.
/// Sharp corners, crisp shadows, quick decisive motion.
/// Includes both light and dark expressions.

const inkWash = CatoThemeData(
  id: 'ink_wash',
  name: 'Ink Wash',
  description: 'Monochrome clarity, graphite on paper',
  archetypeId: 'ink',
  cornerRadius: 6,
  shadowOpacity: 0.06,
  motionScale: 0.8,
  defaultTypographyId: 'editorial',
  defaultSoundPackId: 'paper',
  defaultHapticProfileId: 'crisp',

  bgPrimary: Color(0xFFF3F2F0),
  bgSurface: Color(0xFFE5E4E2),
  bgElevated: Color(0xFFFAF9F8),

  inkBlack: Color(0xFF1A1A1A),
  textPrimary: Color(0xFF333333),
  textSecondary: Color(0xFF6B6B6B),
  textTertiary: Color(0xFF999999),

  accent: Color(0xFF5C5C5C),
  accentLight: Color(0xFF8C8C8C),
  accentPale: Color(0xFFC4C4C4),

  nutrition: Color(0xFF6A7A6E),
  fitness: Color(0xFF7A7068),
  rest: Color(0xFF68707A),
  mind: Color(0xFF746A7A),
  vices: Color(0xFF7A6A68),

  heatNoData: Color(0xFFE5E4E2),
  heatMinimal: Color(0xFFD2D2D0),
  heatLow: Color(0xFFBABAB8),
  heatMid: Color(0xFF8C8C8C),
  heatHigh: Color(0xFF5C5C5C),
  heatStrong: Color(0xFF424242),
  heatPeak: Color(0xFF2A2A2A),

  error: Color(0xFF7A6A68),
  warning: Color(0xFF7A7068),
);

const midnight = CatoThemeData(
  id: 'midnight',
  name: 'Midnight',
  description: 'Warm dark, candlelit calm',
  archetypeId: 'ink',
  isDark: true,
  cornerRadius: 6,
  shadowOpacity: 0.12,
  motionScale: 0.85,
  defaultTypographyId: 'editorial',
  defaultSoundPackId: 'paper',
  defaultHapticProfileId: 'crisp',

  bgPrimary: Color(0xFF1C1B1A),
  bgSurface: Color(0xFF262524),
  bgElevated: Color(0xFF2E2D2A),

  inkBlack: Color(0xFFEAE8E4),
  textPrimary: Color(0xFFC8C5C0),
  textSecondary: Color(0xFF8E8B86),
  textTertiary: Color(0xFF5E5B56),

  accent: Color(0xFF7C9A92),
  accentLight: Color(0xFF5A7A72),
  accentPale: Color(0xFF384E48),

  nutrition: Color(0xFF6A8A78),
  fitness: Color(0xFF9A8A6E),
  rest: Color(0xFF707A96),
  mind: Color(0xFF867690),
  vices: Color(0xFF967A74),

  heatNoData: Color(0xFF262524),
  heatMinimal: Color(0xFF2E3A36),
  heatLow: Color(0xFF3A4E48),
  heatMid: Color(0xFF4E6A62),
  heatHigh: Color(0xFF5A7A72),
  heatStrong: Color(0xFF7C9A92),
  heatPeak: Color(0xFFA6C4BB),

  error: Color(0xFF967A74),
  warning: Color(0xFF9A8A6E),
);

const eclipse = CatoThemeData(
  id: 'eclipse',
  name: 'Eclipse',
  description: 'Cool dark, deep space quiet',
  archetypeId: 'ink',
  isDark: true,
  cornerRadius: 6,
  shadowOpacity: 0.12,
  motionScale: 0.85,
  defaultTypographyId: 'editorial',
  defaultSoundPackId: 'glass',
  defaultHapticProfileId: 'crisp',

  bgPrimary: Color(0xFF1A1C20),
  bgSurface: Color(0xFF24262C),
  bgElevated: Color(0xFF2C2E34),

  inkBlack: Color(0xFFE8EAEE),
  textPrimary: Color(0xFFC4C8CE),
  textSecondary: Color(0xFF8A8E98),
  textTertiary: Color(0xFF5A5E68),

  accent: Color(0xFF6A8AA0),
  accentLight: Color(0xFF506C84),
  accentPale: Color(0xFF364A5C),

  nutrition: Color(0xFF5E8878),
  fitness: Color(0xFF8890A8),
  rest: Color(0xFF6678A0),
  mind: Color(0xFF7A6E98),
  vices: Color(0xFF988078),

  heatNoData: Color(0xFF24262C),
  heatMinimal: Color(0xFF2C3640),
  heatLow: Color(0xFF384858),
  heatMid: Color(0xFF486070),
  heatHigh: Color(0xFF506C84),
  heatStrong: Color(0xFF6A8AA0),
  heatPeak: Color(0xFF8EB0C8),

  error: Color(0xFF988078),
  warning: Color(0xFF8890A8),
);

const newsprint = CatoThemeData(
  id: 'newsprint',
  name: 'Newsprint',
  description: 'High contrast, editorial red accent',
  archetypeId: 'ink',
  cornerRadius: 6,
  shadowOpacity: 0.07,
  motionScale: 0.8,
  defaultTypographyId: 'dramatic',
  defaultSoundPackId: 'paper',
  defaultHapticProfileId: 'crisp',

  bgPrimary: Color(0xFFF4F2EE),
  bgSurface: Color(0xFFE6E4E0),
  bgElevated: Color(0xFFFAFAF8),

  inkBlack: Color(0xFF1A1A1A),
  textPrimary: Color(0xFF2E2E2E),
  textSecondary: Color(0xFF606060),
  textTertiary: Color(0xFF909090),

  accent: Color(0xFFB85040),
  accentLight: Color(0xFFD07868),
  accentPale: Color(0xFFE8B0A4),

  nutrition: Color(0xFF608878),
  fitness: Color(0xFFB06050),
  rest: Color(0xFF607088),
  mind: Color(0xFF806880),
  vices: Color(0xFFAA5848),

  heatNoData: Color(0xFFE6E4E0),
  heatMinimal: Color(0xFFE0CAC4),
  heatLow: Color(0xFFD8AEA4),
  heatMid: Color(0xFFD07868),
  heatHigh: Color(0xFFB85040),
  heatStrong: Color(0xFF983830),
  heatPeak: Color(0xFF782820),

  error: Color(0xFFAA5848),
  warning: Color(0xFFB06050),
);
