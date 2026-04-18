import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/date_utils.dart';
import '../../app/theme.dart';
import '../../providers/core_providers.dart';
import '../../widgets/calm_toggle.dart';
import 'dev_panel.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _aboutLongPresses = 0;
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

    return SafeArea(
      child: FutureBuilder<PackageInfo>(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            children: <Widget>[
              Text(
                'Settings',
                style: AppTextStyles.display(AppColors.inkBlack),
              ),
              const SizedBox(height: AppSpacing.xl),
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
              const SizedBox(height: AppSpacing.xl),
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
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Adds quiet tactile feedback to interactions',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textTertiary,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'Data',
                child: _SettingsRow(
                  label: 'Export data (JSON)',
                  onTap: () async {
                    final file = await ref.read(exportServiceProvider).exportJson();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Exported to ${file.path}')),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Section(
                title: 'About',
                child: _SettingsRow(
                  label: 'Version',
                  trailingWidget: GestureDetector(
                    onLongPress: _handleAboutLongPress,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Text(
                        'Cato v${packageInfo?.version ?? '0.1.0'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatHhMm(BuildContext context, String value) {
    return MaterialLocalizations.of(context).formatTimeOfDay(parseHhMm(value));
  }

  Future<void> _pickTime(
    BuildContext context, {
    required TimeOfDay initial,
    required ValueChanged<TimeOfDay> onSaved,
  }) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      onSaved(picked);
    }
  }

  Future<void> _updateSoundEnabled(bool value) async {
    await ref.read(appConfigRepositoryProvider).setValue('sound_enabled', '$value');
    await ref.read(notificationServiceProvider).syncSchedules();
  }

  Future<void> _handleAboutLongPress() async {
    _aboutLongPresses += 1;
    _aboutTimer?.cancel();
    _aboutTimer = Timer(
      const Duration(seconds: 3),
      () => _aboutLongPresses = 0,
    );
    if (_aboutLongPresses >= 5) {
      _aboutLongPresses = 0;
      if (!mounted) {
        return;
      }
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
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: AppTextStyles.headline(AppColors.inkBlack),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(22),
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
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (trailingWidget != null)
              trailingWidget!
            else if (trailing != null)
              Text(
                trailing!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}
