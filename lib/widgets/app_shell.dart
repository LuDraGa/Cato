import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../models/tracker.dart';
import '../providers/core_providers.dart';
import '../providers/theme_provider.dart';
import '../providers/tracker_providers.dart';
import '../screens/entry/entry_sheet.dart';
import '../services/notification_service.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  StreamSubscription<PendingAppAction>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = ref.read(initialAppActionProvider);
      if (initial != null) {
        ref.read(pendingAppActionProvider.notifier).state = initial;
      }
      _subscription = ref.read(notificationServiceProvider).actions.listen((action) {
        ref.read(pendingAppActionProvider.notifier).state = action;
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(ref.read(notificationServiceProvider).syncSchedules());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PendingAppAction?>(
      pendingAppActionProvider,
      (previous, next) async {
        if (next == null) {
          return;
        }
        if (next.type == AppActionType.openHome) {
          widget.navigationShell.goBranch(0);
        } else if (next.type == AppActionType.openBatch) {
          if (context.mounted) {
            await context.push('/batch');
          }
        } else if (next.type == AppActionType.openEntrySheet) {
          final trackerUid = next.trackerUid;
          Tracker? tracker;
          if (trackerUid != null) {
            final trackers = ref.read(allTrackersProvider).valueOrNull ?? const <Tracker>[];
            tracker = trackers.cast<Tracker?>().firstWhere(
                  (item) => item?.uid == trackerUid,
                  orElse: () => null,
                );
            tracker ??= await ref.read(trackerRepositoryProvider).getByUid(trackerUid);
          }
          if (tracker != null && context.mounted) {
            await showTrackerEntrySheet(
              context: context,
              tracker: tracker,
              effectiveDate: next.effectiveDate,
              isBackfill: false,
            );
          }
        }
        ref.read(pendingAppActionProvider.notifier).state = null;
      },
    );

    // Force rebuild when any aesthetic dimension changes
    ref.watch(aestheticRevisionProvider);

    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgPrimary,
            border: Border(top: BorderSide(color: AppColors.bgSurface)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Row(
            children: <Widget>[
              _NavItem(
                label: 'Home',
                selected: widget.navigationShell.currentIndex == 0,
                onTap: () => widget.navigationShell.goBranch(0),
              ),
              _NavItem(
                label: 'Review',
                selected: widget.navigationShell.currentIndex == 1,
                onTap: () => widget.navigationShell.goBranch(1),
              ),
              _NavItem(
                label: 'Settings',
                selected: widget.navigationShell.currentIndex == 2,
                onTap: () => widget.navigationShell.goBranch(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppDurations.short,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.bgSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color:
                      selected ? AppColors.inkBlack : AppColors.textSecondary,
                ),
          ),
        ),
      ),
    );
  }
}
