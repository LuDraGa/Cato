import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'themes/cato_theme_data.dart';
import 'themes/cloud_themes.dart';
import 'typography/cato_typography.dart';
import 'typography/typography_registry.dart';

class AppColors {
  static CatoThemeData _active = morningMist;
  static CatoTypography _typography = typographyById(morningMist.defaultTypographyId);

  static void setTheme(CatoThemeData theme) => _active = theme;
  static CatoThemeData get active => _active;

  static void setTypography(CatoTypography typo) => _typography = typo;
  static CatoTypography get typography => _typography;

  // ── Backgrounds ──
  static Color get bgPrimary => _active.bgPrimary;
  static Color get bgSurface => _active.bgSurface;
  static Color get bgElevated => _active.bgElevated;

  // ── Text ──
  static Color get inkBlack => _active.inkBlack;
  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;
  static Color get textTertiary => _active.textTertiary;

  // ── Accent ──
  static Color get sage => _active.accent;
  static Color get sageLight => _active.accentLight;
  static Color get sagePale => _active.accentPale;

  // ── Domain colors ──
  static Color get nutrition => _active.nutrition;
  static Color get fitness => _active.fitness;
  static Color get rest => _active.rest;
  static Color get mind => _active.mind;
  static Color get vices => _active.vices;

  // ── Heatmap ──
  static Color get heatNoData => _active.heatNoData;
  static Color get heatMinimal => _active.heatMinimal;
  static Color get heatLow => _active.heatLow;
  static Color get heatMid => _active.heatMid;
  static Color get heatHigh => _active.heatHigh;
  static Color get heatStrong => _active.heatStrong;
  static Color get heatPeak => _active.heatPeak;

  // ── Semantic ──
  static Color get error => _active.error;
  static Color get warning => _active.warning;

  // ── Shape ──
  static bool get isDark => _active.isDark;
  static double get cornerRadius => _active.cornerRadius;
  static double get motionScale => _active.motionScale;
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

class AppDurations {
  static Duration get micro => Duration(
        milliseconds: (120 * AppColors.motionScale).round(),
      );
  static Duration get short => Duration(
        milliseconds: (220 * AppColors.motionScale).round(),
      );
  static Duration get medium => Duration(
        milliseconds: (340 * AppColors.motionScale).round(),
      );
  static Duration get long => Duration(
        milliseconds: (560 * AppColors.motionScale).round(),
      );
}

class AppTextStyles {
  static String get _serif => AppColors._typography.serifFont;
  static String get _sans => AppColors._typography.sansFont;

  static TextStyle display(Color color) => GoogleFonts.getFont(
        _serif,
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.1,
      );

  static TextStyle headline(Color color) => GoogleFonts.getFont(
        _serif,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
      );

  static TextStyle title(Color color) => GoogleFonts.getFont(
        _serif,
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle metric(Color color) => GoogleFonts.getFont(
        _sans,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.0,
      );
}

ThemeData buildAppTheme() {
  final sans = AppColors._typography.sansFont;
  final isDark = AppColors.isDark;

  return ThemeData(
    useMaterial3: false,
    brightness: isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
      primary: AppColors.sage,
      onPrimary: AppColors.bgElevated,
      secondary: AppColors.sageLight,
      onSecondary: AppColors.inkBlack,
      error: AppColors.error,
      onError: AppColors.bgElevated,
      surface: AppColors.bgPrimary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.getFont(
        sans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.getFont(
        sans,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.getFont(
        sans,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.35,
      ),
      labelLarge: GoogleFonts.getFont(
        sans,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.getFont(
        sans,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      titleMedium: AppTextStyles.title(AppColors.inkBlack),
      headlineSmall: AppTextStyles.headline(AppColors.inkBlack),
      displaySmall: AppTextStyles.display(AppColors.inkBlack),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headline(AppColors.inkBlack),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    dividerColor: AppColors.bgSurface,
    cardColor: AppColors.bgElevated,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      hintStyle: GoogleFonts.getFont(
        sans,
        color: AppColors.textTertiary,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.getFont(
        sans,
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.inkBlack.withValues(alpha: 0.13)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.sage, width: 1.2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inkBlack.withValues(alpha: 0.92),
      contentTextStyle: GoogleFonts.getFont(
        sans,
        color: AppColors.bgPrimary,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

List<BoxShadow> surfaceShadow({bool elevated = false}) {
  final opacity = AppColors._active.shadowOpacity;
  return <BoxShadow>[
    BoxShadow(
      color: AppColors.inkBlack.withValues(alpha: elevated ? opacity * 1.5 : opacity),
      offset: Offset(0, elevated ? 2 : 1),
      blurRadius: elevated ? 8 : 4,
    ),
  ];
}
