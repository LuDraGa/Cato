import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/date_utils.dart';
import '../../app/theme.dart';
import '../../engines/input_engine.dart';
import '../../models/event.dart';
import '../../models/tracker.dart';
import '../../providers/core_providers.dart';
import '../../providers/entry_form_provider.dart';
import '../../repositories/event_repository.dart';

Future<Event?> showTrackerEntrySheet({
  required BuildContext context,
  required Tracker tracker,
  DateTime? effectiveDate,
  Event? existingEvent,
  bool isBackfill = false,
  List<Event>? carouselEntries,
  VoidCallback? onCarouselNext,
  VoidCallback? onCarouselPrevious,
}) {
  final seed = EntryFormSeed(
    tracker: tracker,
    effectiveDate: effectiveDate ?? normalizeDate(DateTime.now()),
    existingEvent: existingEvent,
    isBackfill: isBackfill,
  );

  return showModalBottomSheet<Event?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.inkBlack.withValues(alpha: 0.15),
    builder: (sheetContext) => _EntrySheet(
      seed: seed,
      hostContext: context,
      carouselEntries: carouselEntries,
      onCarouselNext: onCarouselNext,
      onCarouselPrevious: onCarouselPrevious,
    ),
  );
}

class _EntrySheet extends ConsumerStatefulWidget {
  const _EntrySheet({
    required this.seed,
    required this.hostContext,
    this.carouselEntries,
    this.onCarouselNext,
    this.onCarouselPrevious,
  });

  final EntryFormSeed seed;
  final BuildContext hostContext;
  final List<Event>? carouselEntries;
  final VoidCallback? onCarouselNext;
  final VoidCallback? onCarouselPrevious;

  @override
  ConsumerState<_EntrySheet> createState() => _EntrySheetState();
}

class _EntrySheetState extends ConsumerState<_EntrySheet> {
  late Future<Event?> _previousEventFuture;
  bool _isApplyingPrevious = false;

  @override
  void initState() {
    super.initState();
    _previousEventFuture = ref
        .read(eventRepositoryProvider)
        .getMostRecentEvent(
          widget.seed.tracker.uid,
          excludingEventUid: widget.seed.existingEvent?.uid,
        );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(entryFormProvider(widget.seed));
    final controller = ref.read(entryFormProvider(widget.seed).notifier);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
              ),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: surfaceShadow(elevated: true),
              ),
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dy > 300) {
                    Navigator.of(context).pop();
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.velocity.pixelsPerSecond.dx > 300 && widget.onCarouselPrevious != null) {
                    widget.onCarouselPrevious!();
                  } else if (details.velocity.pixelsPerSecond.dx < -300 && widget.onCarouselNext != null) {
                    widget.onCarouselNext!();
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.bgSurface,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (widget.carouselEntries != null && widget.carouselEntries!.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: widget.onCarouselPrevious,
                            tooltip: 'Previous entry',
                          ),
                          Text(
                            '${widget.seed.tracker.icon}  ${widget.seed.tracker.name}',
                            style: AppTextStyles.title(AppColors.inkBlack),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: widget.onCarouselNext,
                            tooltip: 'Next entry',
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        '${widget.seed.tracker.icon}  ${widget.seed.tracker.name}',
                        style: AppTextStyles.title(AppColors.inkBlack),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: _editDateTime,
                      child: Row(
                        children: <Widget>[
                          Text(
                            '${MaterialLocalizations.of(context).formatMediumDate(formState.effectiveDate)} · ${MaterialLocalizations.of(context).formatTimeOfDay(formState.headerTime)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Text('✎'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DynamicEntryFields(seed: widget.seed),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: formState.isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.sage,
                          foregroundColor: AppColors.bgElevated,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          formState.isSaving ? 'Saving…' : 'Save',
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FutureBuilder<Event?>(
                      future: _previousEventFuture,
                      builder: (context, snapshot) {
                        final previous = snapshot.data;
                        if (previous == null) {
                          return const SizedBox.shrink();
                        }
                        return Center(
                          child: TextButton(
                            onPressed: _isApplyingPrevious
                                ? null
                                : () => _applyPrevious(controller, previous),
                            child: Text(
                              _isApplyingPrevious
                                  ? 'Applying yesterday…'
                                  : 'Same as yesterday',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (widget.seed.existingEvent != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Center(
                        child: TextButton(
                          onPressed: _confirmDelete,
                          child: Text(
                            'Delete entry',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editDateTime() async {
    final controller = ref.read(entryFormProvider(widget.seed).notifier);
    final current = ref.read(entryFormProvider(widget.seed));
    final date = await showDatePicker(
      context: context,
      initialDate: current.effectiveDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (!mounted) {
      return;
    }
    if (date != null && !isSameDay(date, current.effectiveDate)) {
      if (await _hasConflict(date)) {
        _showConflictMessage();
        return;
      }
      controller.setEffectiveDate(date);
    }
    if (!mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: current.headerTime,
      helpText: 'Entry time',
      initialEntryMode: TimePickerEntryMode.dialOnly,
    );
    if (!mounted) {
      return;
    }
    if (time != null) {
      controller.setHeaderTime(time);
    }
  }

  Future<bool> _hasConflict(DateTime targetDate) async {
    final tracker = widget.seed.tracker;
    if (tracker.frequency != 'daily') {
      return false;
    }
    final eventRepository = ref.read(eventRepositoryProvider);
    final existing = await eventRepository.getEventsForTrackerAndDate(
      tracker.uid,
      targetDate,
    );
    final currentEventUid = widget.seed.existingEvent?.uid;
    return existing.any((e) => e.uid != currentEventUid);
  }

  void _showConflictMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(widget.hostContext).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.seed.tracker.name} already has an entry for that date.',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _applyPrevious(
    EntryFormController controller,
    Event previous,
  ) async {
    setState(() {
      _isApplyingPrevious = true;
    });
    try {
      await controller.copyFromPreviousStaggered(previous);
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingPrevious = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final controller = ref.read(entryFormProvider(widget.seed).notifier);
    if (!controller.validate()) {
      return;
    }
    final formState = ref.read(entryFormProvider(widget.seed));
    if (await _hasConflict(formState.effectiveDate)) {
      _showConflictMessage();
      return;
    }
    controller.setSaving(true);
    final homeFeedback = ref.read(homeFeedbackProvider.notifier);
    homeFeedback.beginSave();

    try {
      final formState = ref.read(entryFormProvider(widget.seed));
      final eventRepository = ref.read(eventRepositoryProvider);
      final appConfigRepository = ref.read(appConfigRepositoryProvider);
      final notificationService = ref.read(notificationServiceProvider);
      final soundEnabled = ref.read(soundEnabledProvider).valueOrNull ?? false;

      final draft = EventDraft(
        tracker: widget.seed.tracker,
        effectiveDate: formState.effectiveDate,
        effectiveTime: mergeDateAndTime(formState.effectiveDate, formState.headerTime),
        metrics: controller.buildMetrics(),
        clearedKeys: controller.buildClearedKeys(),
        isBackfill: widget.seed.isBackfill ||
            widget.seed.existingEvent?.isBackfill == true ||
            !isSameDay(formState.effectiveDate, normalizeDate(DateTime.now())),
        existingEvent: widget.seed.existingEvent,
      );

      final savedEvent = await eventRepository.upsertDraft(draft);
      await HapticFeedback.mediumImpact();
      if (soundEnabled) {
        await ref.read(soundServiceProvider).playSaveTap();
      }
      ref.read(pendingSaveEventProvider.notifier).state = savedEvent;
      unawaited(notificationService.syncSchedules());

      if (!mounted) {
        homeFeedback.cancelSave();
        return;
      }
      Navigator.of(context).pop(savedEvent);
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 100),
          homeFeedback.completeSave,
        ),
      );
      await _maybeShowSoundPrompt(appConfigRepository, eventRepository);
    } catch (_) {
      homeFeedback.cancelSave();
      rethrow;
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: AppColors.inkBlack.withValues(alpha: 0.15),
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: BorderRadius.circular(14),
            boxShadow: surfaceShadow(elevated: true),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Delete entry?',
                style: AppTextStyles.title(AppColors.inkBlack),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'This cannot be undone.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.bgElevated,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Delete'),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final eventRepository = ref.read(eventRepositoryProvider);
    await eventRepository.deleteEvent(widget.seed.existingEvent!);
    if (!mounted) return;
    Navigator.of(context).pop(null);
  }

  Future<void> _maybeShowSoundPrompt(
    dynamic appConfigRepository,
    dynamic eventRepository,
  ) async {
    final alreadyShown = await appConfigRepository.getBool(
      'sound_prompt_shown',
      defaultValue: false,
    );
    if (alreadyShown) {
      return;
    }
    final count = await eventRepository.countEvents();
    if (count != 1) {
      return;
    }
    await appConfigRepository.setValue('sound_prompt_shown', 'true');
    if (!widget.hostContext.mounted) {
      return;
    }
    ScaffoldMessenger.of(widget.hostContext).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Row(
          children: <Widget>[
            const Expanded(
              child: Text('Add subtle feedback to your entries?'),
            ),
            TextButton(
              onPressed: () async {
                await appConfigRepository.setValue('sound_enabled', 'true');
                await ref.read(notificationServiceProvider).syncSchedules();
                if (widget.hostContext.mounted) {
                  ScaffoldMessenger.of(widget.hostContext).hideCurrentSnackBar();
                }
              },
              child: const Text('Enable'),
            ),
            TextButton(
              onPressed: () {
                if (widget.hostContext.mounted) {
                  ScaffoldMessenger.of(widget.hostContext).hideCurrentSnackBar();
                }
              },
              child: const Text('Not now'),
            ),
          ],
        ),
      ),
    );
  }
}
