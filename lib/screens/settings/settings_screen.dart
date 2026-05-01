import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/date_utils.dart';
import '../../app/haptics/cato_haptic_profile.dart';
import '../../app/haptics/haptic_registry.dart';
import '../../app/release_links.dart';
import '../../app/sounds/sound_registry.dart';
import '../../app/theme.dart';
import '../../services/sound_service.dart';
import '../../app/themes/cato_theme_data.dart';
import '../../app/themes/theme_registry.dart';
import '../../app/typography/cato_typography.dart';
import '../../app/typography/typography_registry.dart';
import '../../providers/core_providers.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/calm_toggle.dart';
import 'dev_panel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const int _devPanelUnlockTapCount = 5;
  static const Duration _devPanelMaxTapGap = Duration(milliseconds: 800);

  int _aboutTaps = 0;
  DateTime? _lastAboutTapAt;
  Timer? _aboutTimer;

  @override
  void dispose() {
    _aboutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final midday = ref.watch(middayTimeProvider).valueOrNull ?? '13:30';
    final dayEnd = ref.watch(dayEndTimeProvider).valueOrNull ?? '21:30';
    final notificationsEnabled =
        ref.watch(notificationsEnabledProvider).valueOrNull ?? true;
    final soundEnabled = ref.watch(soundEnabledProvider).valueOrNull ?? false;
    final effectiveTypoId = ref.watch(effectiveTypographyIdProvider);
    final effectiveSoundId = ref.watch(effectiveSoundPackIdProvider);
    final effectiveHapticId = ref.watch(effectiveHapticProfileIdProvider);

    return SafeArea(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            children: <Widget>[
              Text(
                'Settings',
                style: AppTextStyles.display(AppColors.inkBlack),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Aesthetic ──
              _Section(
                title: 'Aesthetic',
                child: Column(
                  children: <Widget>[
                    // Theme
                    _SettingsRow(
                      label: 'Theme',
                      trailingWidget: _PreviewDots(
                        colors: AppColors.active.previewColors,
                        label: AppColors.active.name,
                      ),
                      onTap: () => _showThemePicker(context, ref),
                    ),
                    // Typography
                    _SettingsRow(
                      label: 'Typography',
                      trailing: typographyById(effectiveTypoId).name,
                      onTap: () => _showTypographyPicker(context, ref),
                    ),
                    // Sound pack
                    _SettingsRow(
                      label: 'Sound pack',
                      trailing: soundPackById(effectiveSoundId).name,
                      onTap: () => _showSoundPackPicker(context, ref),
                    ),
                    // Haptic profile
                    _SettingsRow(
                      label: 'Haptics',
                      trailing: hapticProfileById(effectiveHapticId).name,
                      onTap: () => _showHapticPicker(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Reminders ──
              _Section(
                title: 'Reminders',
                child: Column(
                  children: <Widget>[
                    _SettingsRow(
                      label: 'Midday check-in',
                      trailing: _formatHhMm(context, midday),
                      onTap: () => _pickTime(
                        context,
                        initial: parseHhMm(midday),
                        onSaved: (value) => ref
                            .read(notificationServiceProvider)
                            .updateMiddayTime(hhMm(value)),
                      ),
                    ),
                    _SettingsRow(
                      label: 'Day-end catchup',
                      trailing: _formatHhMm(context, dayEnd),
                      onTap: () => _pickTime(
                        context,
                        initial: parseHhMm(dayEnd),
                        onSaved: (value) => ref
                            .read(notificationServiceProvider)
                            .updateDayEndTime(hhMm(value)),
                      ),
                    ),
                    _SettingsRow(
                      label: 'Notifications',
                      trailingWidget: CalmToggle(
                        value: notificationsEnabled,
                        onChanged: (value) => ref
                            .read(notificationServiceProvider)
                            .updateNotificationsEnabled(value),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Experience ──
              _Section(
                title: 'Experience',
                child: Column(
                  children: <Widget>[
                    _SettingsRow(
                      label: 'Sound',
                      trailingWidget: CalmToggle(
                        value: soundEnabled,
                        onChanged: (value) => _updateSoundEnabled(value),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Adds quiet tactile feedback to interactions',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Data ──
              _Section(
                title: 'Data',
                child: _SettingsRow(
                  label: 'Export data (JSON)',
                  onTap: () async {
                    final file = await ref
                        .read(exportServiceProvider)
                        .exportJson();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exported to ${file.path}')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── About ──
              _Section(
                title: 'About',
                child: Column(
                  children: <Widget>[
                    _SettingsRow(
                      label: 'Privacy Policy',
                      onTap: _openPrivacyPolicy,
                    ),
                    _DevPanelVersionRow(
                      version: packageInfo?.version ?? '0.1.0',
                      activeTaps: _aboutTaps,
                      requiredTaps: _devPanelUnlockTapCount,
                      onTap: kReleaseMode ? null : _handleAboutTap,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  String _formatHhMm(BuildContext context, String value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(parseHhMm(value));
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onSaved,
  }) async {
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      onSaved(picked);
    }
  }

  Future<void> _updateSoundEnabled(bool value) async {
    await ref
        .read(appConfigRepositoryProvider)
        .setValue('sound_enabled', '$value');
    await ref.read(notificationServiceProvider).syncSchedules();
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse(privacyPolicyUrl);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open privacy policy')),
      );
    }
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ThemePickerSheet(
        currentId: ref.watch(themeProvider),
        onSelected: (id) {
          ref.read(themeProvider.notifier).setTheme(id);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showTypographyPicker(BuildContext context, WidgetRef ref) {
    _showOptionSheet<CatoTypography>(
      context: context,
      title: 'Typography',
      items: availableTypographies,
      currentId: ref.watch(effectiveTypographyIdProvider),
      getId: (t) => t.id,
      getName: (t) => t.name,
      getDescription: (t) => '${t.serifFont} + ${t.sansFont}',
      onSelected: (id) => setTypographyOverride(ref, id),
      onReset: () => setTypographyOverride(ref, null),
      hasOverride: ref.watch(typographyOverrideProvider) != null,
    );
  }

  void _showSoundPackPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SoundPackPickerSheet(
        currentId: ref.watch(effectiveSoundPackIdProvider),
        hasOverride: ref.watch(soundPackOverrideProvider) != null,
        soundService: ref.read(soundServiceProvider),
        onSelected: (id) {
          setSoundPackOverride(ref, id);
          Navigator.of(context).pop();
        },
        onReset: () {
          setSoundPackOverride(ref, null);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showHapticPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HapticPickerSheet(
        currentId: ref.watch(effectiveHapticProfileIdProvider),
        hasOverride: ref.watch(hapticProfileOverrideProvider) != null,
        onSelected: (id) {
          setHapticProfileOverride(ref, id);
          Navigator.of(context).pop();
        },
        onReset: () {
          setHapticProfileOverride(ref, null);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String currentId,
    required String Function(T) getId,
    required String Function(T) getName,
    required String Function(T) getDescription,
    required ValueChanged<String> onSelected,
    required VoidCallback onReset,
    required bool hasOverride,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionPickerSheet(
        title: title,
        hasOverride: hasOverride,
        onReset: () {
          onReset();
          Navigator.of(context).pop();
        },
        children: items.map((item) {
          final id = getId(item);
          return _OptionTile(
            name: getName(item),
            description: getDescription(item),
            selected: id == currentId,
            onTap: () {
              onSelected(id);
              Navigator.of(context).pop();
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleAboutTap() async {
    final now = DateTime.now();
    final lastTapAt = _lastAboutTapAt;
    final continuesSequence =
        lastTapAt != null && now.difference(lastTapAt) <= _devPanelMaxTapGap;
    final nextTapCount = continuesSequence ? _aboutTaps + 1 : 1;

    _lastAboutTapAt = now;
    _aboutTimer?.cancel();

    if (nextTapCount >= _devPanelUnlockTapCount) {
      unawaited(HapticFeedback.mediumImpact());
      setState(() {
        _aboutTaps = 0;
        _lastAboutTapAt = null;
      });
      _showDevPanelProgressSnackBar('Dev Panel unlocked');
      await Future<void>.delayed(AppDurations.micro);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => Theme(
            data: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
            ),
            child: const DevPanelScreen(),
          ),
        ),
      );
      return;
    }

    unawaited(HapticFeedback.selectionClick());
    setState(() => _aboutTaps = nextTapCount);
    final remaining = _devPanelUnlockTapCount - nextTapCount;
    _showDevPanelProgressSnackBar(
      '$remaining ${remaining == 1 ? 'tap' : 'taps'} away from Dev Panel',
    );
    _aboutTimer = Timer(_devPanelMaxTapGap, () {
      if (!mounted) {
        _aboutTaps = 0;
        _lastAboutTapAt = null;
        return;
      }
      setState(() {
        _aboutTaps = 0;
        _lastAboutTapAt = null;
      });
    });
  }

  void _showDevPanelProgressSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: AppColors.bgElevated,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.inkBlack.withValues(alpha: 0.92),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.cornerRadius),
          ),
        ),
      );
  }
}

// ── Shared widgets ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTextStyles.headline(AppColors.inkBlack)),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(14),
            boxShadow: surfaceShadow(elevated: true),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.label,
    this.trailing,
    this.trailingWidget,
    this.onTap,
  });

  final String label;
  final String? trailing;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailing != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    trailing!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _DevPanelVersionRow extends StatelessWidget {
  const _DevPanelVersionRow({
    required this.version,
    required this.activeTaps,
    required this.requiredTaps,
    required this.onTap,
  });

  final String version;
  final int activeTaps;
  final int requiredTaps;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = activeTaps > 0;
    final progress = active ? activeTaps / requiredTaps : 0.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppDurations.micro,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: active
              ? AppColors.sagePale.withValues(alpha: 0.72)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Version',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppDurations.micro,
                  child: Text(
                    active
                        ? '${requiredTaps - activeTaps} taps away'
                        : 'Cato v$version',
                    key: ValueKey<int>(activeTaps),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: active ? AppColors.sage : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            AnimatedContainer(
              duration: AppDurations.micro,
              curve: Curves.easeOutCubic,
              height: active ? AppSpacing.xs : 0,
              margin: EdgeInsets.only(top: active ? AppSpacing.sm : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: AppSpacing.xs,
                  backgroundColor: AppColors.bgSurface,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.sage),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewDots extends StatelessWidget {
  const _PreviewDots({required this.colors, required this.label});

  final List<Color> colors;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(width: 6),
        ...colors.map(
          (c) => Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(left: 2),
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textTertiary.withValues(alpha: 0.2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          size: 16,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }
}

// ── Theme picker sheet (grouped by archetype) ───────────────────────────────

class _ThemePickerSheet extends StatelessWidget {
  const _ThemePickerSheet({required this.currentId, required this.onSelected});

  final String currentId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose theme',
                style: AppTextStyles.headline(AppColors.inkBlack),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              itemCount: archetypeOrder.length,
              itemBuilder: (context, index) {
                final archetypeId = archetypeOrder[index];
                final themes = themesByArchetype(archetypeId);
                return _ArchetypeGroup(
                  name: archetypeNames[archetypeId]!,
                  description: archetypeDescriptions[archetypeId]!,
                  themes: themes,
                  currentId: currentId,
                  onSelected: onSelected,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchetypeGroup extends StatelessWidget {
  const _ArchetypeGroup({
    required this.name,
    required this.description,
    required this.themes,
    required this.currentId,
    required this.onSelected,
  });

  final String name;
  final String description;
  final List<CatoThemeData> themes;
  final String currentId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: AppTextStyles.title(AppColors.inkBlack)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: themes.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final theme = themes[index];
                final selected = theme.id == currentId;
                return _ThemeChip(
                  theme: theme,
                  selected: selected,
                  onTap: () => onSelected(theme.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  const _ThemeChip({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final CatoThemeData theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 120,
        decoration: BoxDecoration(
          color: theme.bgPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? theme.accent : theme.bgSurface,
            width: selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color swatches
            Row(
              children: [
                _dot(theme.accent, 14),
                const SizedBox(width: 3),
                _dot(theme.accentLight, 12),
                const SizedBox(width: 3),
                _dot(theme.accentPale, 10),
                const Spacer(),
                if (selected)
                  Icon(Icons.check_rounded, size: 14, color: theme.accent),
              ],
            ),
            const Spacer(),
            // Simulated lines
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: theme.textPrimary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 2,
              width: 56,
              decoration: BoxDecoration(
                color: theme.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              theme.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: theme.textTertiary.withValues(alpha: 0.15)),
      ),
    );
  }
}

// ── Generic option picker sheet ─────────────────────────────────────────────

class _OptionPickerSheet extends StatelessWidget {
  const _OptionPickerSheet({
    required this.title,
    required this.children,
    required this.hasOverride,
    required this.onReset,
  });

  final String title;
  final List<Widget> children;
  final bool hasOverride;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.65,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headline(AppColors.inkBlack),
                  ),
                ),
                if (hasOverride)
                  GestureDetector(
                    onTap: onReset,
                    child: Text(
                      'Reset to theme default',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.sage,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xs,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.name,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.sagePale : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.sage : Colors.transparent,
            width: selected ? 1.5 : 0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: AppColors.sage),
          ],
        ),
      ),
    );
  }
}

// ── Sound Pack Picker Sheet ─────────────────────────────────────────────────

class _SoundPackPickerSheet extends StatefulWidget {
  const _SoundPackPickerSheet({
    required this.currentId,
    required this.hasOverride,
    required this.soundService,
    required this.onSelected,
    required this.onReset,
  });

  final String currentId;
  final bool hasOverride;
  final SoundService soundService;
  final ValueChanged<String> onSelected;
  final VoidCallback onReset;

  @override
  State<_SoundPackPickerSheet> createState() => _SoundPackPickerSheetState();
}

class _SoundPackPickerSheetState extends State<_SoundPackPickerSheet> {
  late String _previewId;
  SoundInteraction _lastDemoInteraction = SoundInteraction.save;

  @override
  void initState() {
    super.initState();
    _previewId = widget.currentId;
  }

  void _playDemo(SoundInteraction interaction) {
    // Pre-fire: sound BEFORE setState for perceptual sync
    widget.soundService.playPackSound(_previewId, interaction);
    setState(() => _lastDemoInteraction = interaction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.cornerRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            'Sound Pack',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Demo interaction dots
          _DemoRow(
            interactions: SoundInteraction.values,
            activeInteraction: _lastDemoInteraction,
            labelFor: _soundInteractionLabel,
            onTap: _playDemo,
          ),
          const SizedBox(height: AppSpacing.md),

          // Option list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableSoundPacks.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final pack = availableSoundPacks[index];
                final selected = pack.id == _previewId;
                return GestureDetector(
                  onTap: () {
                    // Pre-fire: sound BEFORE setState for perceptual sync
                    widget.soundService.playPackSound(
                      pack.id,
                      SoundInteraction.save,
                    );
                    setState(() => _previewId = pack.id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _PickerTile(
                    name: pack.name,
                    description: pack.description,
                    selected: selected,
                    confirmed: pack.id == widget.currentId,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              if (widget.hasOverride)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onReset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.bgSurface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Reset to theme default',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.hasOverride) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onSelected(_previewId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inkBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.bgElevated,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _soundInteractionLabel(SoundInteraction interaction) {
    return switch (interaction) {
      SoundInteraction.save => 'Save',
      SoundInteraction.complete => 'Done',
      SoundInteraction.milestone => 'Mile',
      SoundInteraction.tick => 'Tick',
      SoundInteraction.delete => 'Del',
    };
  }
}

// ── Haptic Picker Sheet ─────────────────────────────────────────────────────

class _HapticPickerSheet extends StatefulWidget {
  const _HapticPickerSheet({
    required this.currentId,
    required this.hasOverride,
    required this.onSelected,
    required this.onReset,
  });

  final String currentId;
  final bool hasOverride;
  final ValueChanged<String> onSelected;
  final VoidCallback onReset;

  @override
  State<_HapticPickerSheet> createState() => _HapticPickerSheetState();
}

class _HapticPickerSheetState extends State<_HapticPickerSheet> {
  late String _previewId;
  HapticInteraction _lastDemoInteraction = HapticInteraction.save;

  @override
  void initState() {
    super.initState();
    _previewId = widget.currentId;
  }

  void _playDemo(HapticInteraction interaction) {
    // Pre-fire: haptic BEFORE setState for perceptual sync
    hapticProfileById(_previewId).play(interaction);
    setState(() => _lastDemoInteraction = interaction);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppColors.cornerRadius),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Title
          Text(
            'Haptics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.inkBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Demo interaction dots
          _DemoRow(
            interactions: HapticInteraction.values,
            activeInteraction: _lastDemoInteraction,
            labelFor: _hapticInteractionLabel,
            onTap: _playDemo,
          ),
          const SizedBox(height: AppSpacing.md),

          // Option list
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: availableHapticProfiles.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final profile = availableHapticProfiles[index];
                final selected = profile.id == _previewId;
                return GestureDetector(
                  onTap: () {
                    // Pre-fire: haptic BEFORE setState for perceptual sync
                    hapticProfileById(profile.id).play(HapticInteraction.save);
                    setState(() => _previewId = profile.id);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: _PickerTile(
                    name: profile.name,
                    description: profile.description,
                    selected: selected,
                    confirmed: profile.id == widget.currentId,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              if (widget.hasOverride)
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onReset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.bgSurface),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Reset to theme default',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              if (widget.hasOverride) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onSelected(_previewId),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inkBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.bgElevated,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hapticInteractionLabel(HapticInteraction interaction) {
    return switch (interaction) {
      HapticInteraction.save => 'Save',
      HapticInteraction.complete => 'Done',
      HapticInteraction.milestone => 'Mile',
      HapticInteraction.tick => 'Tick',
      HapticInteraction.delete => 'Del',
      HapticInteraction.error => 'Err',
    };
  }
}

// ── Shared Demo Row ─────────────────────────────────────────────────────────

class _DemoRow<T> extends StatelessWidget {
  const _DemoRow({
    required this.interactions,
    required this.activeInteraction,
    required this.labelFor,
    required this.onTap,
  });

  final List<T> interactions;
  final T activeInteraction;
  final String Function(T) labelFor;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: interactions.map((interaction) {
          final active = interaction == activeInteraction;
          return GestureDetector(
            onTap: () => onTap(interaction),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: AppDurations.short,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: active ? AppColors.inkBlack : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                labelFor(interaction),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: active
                      ? AppColors.bgElevated
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Shared Picker Tile ──────────────────────────────────────────────────────

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.name,
    required this.description,
    required this.selected,
    required this.confirmed,
  });

  final String name;
  final String description;
  final bool selected;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.short,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.bgSurface : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? AppColors.inkBlack.withValues(alpha: 0.15)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (confirmed)
            Icon(Icons.check_rounded, size: 18, color: AppColors.sage),
        ],
      ),
    );
  }
}
