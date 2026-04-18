import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bgPrimary = Color(0xFFFAF7F2);
  static const bgSurface = Color(0xFFF0EBE3);
  static const bgElevated = Color(0xFFFFFFFF);

  static const inkBlack = Color(0xFF1A1A1A);
  static const textPrimary = Color(0xFF3D3833);
  static const textSecondary = Color(0xFF6B6560);
  static const textTertiary = Color(0xFF9B9590);

  static const sage = Color(0xFF7C9A7C);
  static const sageLight = Color(0xFFA8C5A8);
  static const sagePale = Color(0xFFD4E6D4);

  static const nutrition = Color(0xFF8BA88B);
  static const fitness = Color(0xFFC4956A);
  static const rest = Color(0xFF8B8DB5);
  static const mind = Color(0xFFA88BA5);
  static const vices = Color(0xFFB58B8B);

  static const heatNoData = Color(0xFFF0EBE3);
  static const heatMinimal = Color(0xFFE2EBDA);
  static const heatLow = Color(0xFFD4E6D4);
  static const heatMid = Color(0xFFA8C5A8);
  static const heatHigh = Color(0xFF7C9A7C);
  static const heatStrong = Color(0xFF5A7A5A);
  static const heatPeak = Color(0xFF3D5C3D);

  static const error = Color(0xFFB58B8B);
  static const warning = Color(0xFFC4956A);
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
  static const micro = Duration(milliseconds: 120);
  static const short = Duration(milliseconds: 220);
  static const medium = Duration(milliseconds: 340);
  static const long = Duration(milliseconds: 560);
}

class AppTextStyles {
  static TextStyle display(Color color) => GoogleFonts.sourceSerif4(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.1,
      );

  static TextStyle headline(Color color) => GoogleFonts.sourceSerif4(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.15,
      );

  static TextStyle title(Color color) => GoogleFonts.sourceSerif4(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: color,
        height: 1.2,
      );

  static TextStyle metric(Color color) => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.0,
      );
}

ThemeData buildAppTheme() {
  final inter = GoogleFonts.interTextTheme();

  return ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: AppColors.bgPrimary,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: AppColors.sage,
      onPrimary: AppColors.bgElevated,
      secondary: AppColors.sageLight,
      onSecondary: AppColors.inkBlack,
      error: AppColors.error,
      onError: AppColors.bgElevated,
      surface: AppColors.bgPrimary,
      onSurface: AppColors.textPrimary,
    ),
    textTheme: inter.copyWith(
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.45,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.35,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 14,
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
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
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
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textTertiary,
        fontSize: 16,
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x221A1A1A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.sage, width: 1.2),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.inkBlack.withValues(alpha: 0.92),
      contentTextStyle: GoogleFonts.inter(
        color: AppColors.bgPrimary,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

List<BoxShadow> surfaceShadow({bool elevated = false}) {
  return <BoxShadow>[
    BoxShadow(
      color: AppColors.inkBlack.withValues(alpha: elevated ? 0.06 : 0.04),
      offset: Offset(0, elevated ? 2 : 1),
      blurRadius: elevated ? 8 : 4,
    ),
  ];
}
