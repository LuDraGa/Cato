import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../app/themes/theme_registry.dart';
import '../app/typography/typography_registry.dart';
import 'core_providers.dart';

// ── Aesthetic revision counter ──────────────────────────────────────────────
// Incremented whenever any aesthetic dimension changes.
// Screens watch this to know when to rebuild.
final aestheticRevisionProvider = StateProvider<int>((ref) => 0);

void _bumpRevision(dynamic ref) {
  if (ref is WidgetRef) {
    ref.read(aestheticRevisionProvider.notifier).state++;
  } else if (ref is Ref) {
    ref.read(aestheticRevisionProvider.notifier).state++;
  }
}

// ── Theme ───────────────────────────────────────────────────────────────────

final themeProvider = StateNotifierProvider<ThemeController, String>(
  (ref) => ThemeController(ref),
);

class ThemeController extends StateNotifier<String> {
  ThemeController(this._ref) : super(defaultThemeId) {
    _loadSaved();
  }

  final Ref _ref;

  Future<void> _loadSaved() async {
    final repo = _ref.read(appConfigRepositoryProvider);
    final saved = await repo.getValue('theme_id');
    if (saved != null) {
      _applyTheme(saved);
    }
    // Load overrides
    final typoOverride = await repo.getValue('typography_override');
    if (typoOverride != null && typoOverride.isNotEmpty) {
      _ref.read(typographyOverrideProvider.notifier).state = typoOverride;
      AppColors.setTypography(typographyById(typoOverride));
    }
    final soundOverride = await repo.getValue('sound_pack_override');
    if (soundOverride != null && soundOverride.isNotEmpty) {
      _ref.read(soundPackOverrideProvider.notifier).state = soundOverride;
    }
    final hapticOverride = await repo.getValue('haptic_profile_override');
    if (hapticOverride != null && hapticOverride.isNotEmpty) {
      _ref.read(hapticProfileOverrideProvider.notifier).state = hapticOverride;
    }
    _ref.read(aestheticRevisionProvider.notifier).state++;
  }

  /// Called when user explicitly picks a new theme from the picker.
  /// Resets all overrides to the new theme's defaults.
  void setTheme(String themeId) {
    _applyTheme(themeId);
    _ref.read(appConfigRepositoryProvider).setValue('theme_id', themeId);

    // Reset overrides to new theme's defaults
    final theme = themeById(themeId);
    _ref.read(typographyOverrideProvider.notifier).state = null;
    _ref.read(soundPackOverrideProvider.notifier).state = null;
    _ref.read(hapticProfileOverrideProvider.notifier).state = null;
    AppColors.setTypography(typographyById(theme.defaultTypographyId));

    final repo = _ref.read(appConfigRepositoryProvider);
    repo.setValue('typography_override', '');
    repo.setValue('sound_pack_override', '');
    repo.setValue('haptic_profile_override', '');

    _ref.read(aestheticRevisionProvider.notifier).state++;
  }

  void _applyTheme(String themeId) {
    final theme = themeById(themeId);
    AppColors.setTheme(theme);
    // Set typography: override takes priority, else theme default
    final typoOverride = _ref.read(typographyOverrideProvider);
    AppColors.setTypography(
      typographyById(typoOverride ?? theme.defaultTypographyId),
    );
    state = theme.id;
  }
}

// ── Typography override ─────────────────────────────────────────────────────

final typographyOverrideProvider = StateProvider<String?>((ref) => null);

final effectiveTypographyIdProvider = Provider<String>((ref) {
  final override = ref.watch(typographyOverrideProvider);
  if (override != null) return override;
  final themeId = ref.watch(themeProvider);
  return themeById(themeId).defaultTypographyId;
});

// ── Sound pack override ─────────────────────────────────────────────────────

final soundPackOverrideProvider = StateProvider<String?>((ref) => null);

final effectiveSoundPackIdProvider = Provider<String>((ref) {
  final override = ref.watch(soundPackOverrideProvider);
  if (override != null) return override;
  final themeId = ref.watch(themeProvider);
  return themeById(themeId).defaultSoundPackId;
});

// ── Haptic profile override ─────────────────────────────────────────────────

final hapticProfileOverrideProvider = StateProvider<String?>((ref) => null);

final effectiveHapticProfileIdProvider = Provider<String>((ref) {
  final override = ref.watch(hapticProfileOverrideProvider);
  if (override != null) return override;
  final themeId = ref.watch(themeProvider);
  return themeById(themeId).defaultHapticProfileId;
});

// ── Override setters (with persistence + rebuild trigger) ────────────────────

void setTypographyOverride(WidgetRef ref, String? id) {
  ref.read(typographyOverrideProvider.notifier).state = id;
  if (id != null) {
    AppColors.setTypography(typographyById(id));
    ref.read(appConfigRepositoryProvider).setValue('typography_override', id);
  } else {
    final themeId = ref.read(themeProvider);
    AppColors.setTypography(
      typographyById(themeById(themeId).defaultTypographyId),
    );
    ref.read(appConfigRepositoryProvider).setValue('typography_override', '');
  }
  _bumpRevision(ref);
}

void setSoundPackOverride(WidgetRef ref, String? id) {
  ref.read(soundPackOverrideProvider.notifier).state = id;
  ref
      .read(appConfigRepositoryProvider)
      .setValue('sound_pack_override', id ?? '');
  _bumpRevision(ref);
}

void setHapticProfileOverride(WidgetRef ref, String? id) {
  ref.read(hapticProfileOverrideProvider.notifier).state = id;
  ref
      .read(appConfigRepositoryProvider)
      .setValue('haptic_profile_override', id ?? '');
  _bumpRevision(ref);
}
