import 'package:flutter/material.dart';

class CatoThemeData {
  const CatoThemeData({
    required this.id,
    required this.name,
    required this.description,
    required this.archetypeId,
    this.isDark = false,
    // Backgrounds
    required this.bgPrimary,
    required this.bgSurface,
    required this.bgElevated,
    // Text
    required this.inkBlack,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    // Accent
    required this.accent,
    required this.accentLight,
    required this.accentPale,
    // Domain
    required this.nutrition,
    required this.fitness,
    required this.rest,
    required this.mind,
    required this.vices,
    // Heatmap
    required this.heatNoData,
    required this.heatMinimal,
    required this.heatLow,
    required this.heatMid,
    required this.heatHigh,
    required this.heatStrong,
    required this.heatPeak,
    // Semantic
    required this.error,
    required this.warning,
    // Shape & surface
    required this.cornerRadius,
    required this.shadowOpacity,
    // Motion
    required this.motionScale,
    // Bundle defaults (overridable by user)
    required this.defaultTypographyId,
    required this.defaultSoundPackId,
    required this.defaultHapticProfileId,
  });

  // Identity
  final String id;
  final String name;
  final String description;
  final String archetypeId;
  final bool isDark;

  // Backgrounds
  final Color bgPrimary;
  final Color bgSurface;
  final Color bgElevated;

  // Text
  final Color inkBlack;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  // Accent
  final Color accent;
  final Color accentLight;
  final Color accentPale;

  // Domain colors
  final Color nutrition;
  final Color fitness;
  final Color rest;
  final Color mind;
  final Color vices;

  // Heatmap gradient
  final Color heatNoData;
  final Color heatMinimal;
  final Color heatLow;
  final Color heatMid;
  final Color heatHigh;
  final Color heatStrong;
  final Color heatPeak;

  // Semantic
  final Color error;
  final Color warning;

  // Shape: base corner radius (widgets scale proportionally)
  final double cornerRadius;

  // Surface: base shadow opacity (0.0–1.0)
  final double shadowOpacity;

  // Motion: duration multiplier (>1 = slower, <1 = faster)
  final double motionScale;

  // Bundle defaults
  final String defaultTypographyId;
  final String defaultSoundPackId;
  final String defaultHapticProfileId;

  /// Preview colors for the theme picker UI
  List<Color> get previewColors => [bgPrimary, accent, accentLight, bgElevated];
}
