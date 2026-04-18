import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app/date_utils.dart';
import '../app/theme.dart';
import '../models/input_field_schema.dart';
import '../providers/core_providers.dart';
import '../providers/entry_form_provider.dart';
import '../screens/entry/widgets/chip_selector.dart';
import '../screens/entry/widgets/count_stepper.dart';
import '../screens/entry/widgets/duration_picker.dart';
import '../screens/entry/widgets/media_capture.dart';
import '../screens/entry/widgets/score_slider.dart';
import '../screens/entry/widgets/time_input.dart';
import '../widgets/calm_toggle.dart';

class DynamicEntryFields extends ConsumerWidget {
  const DynamicEntryFields({
    super.key,
    required this.seed,
    this.showSectionHeaders = true,
  });

  final EntryFormSeed seed;
  final bool showSectionHeaders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(entryFormProvider(seed));

    final fields = seed.tracker.sortedInputSchema.where((field) {
      return !(field.key == 'time' && field.type == 'time');
    }).toList();
    final required = fields.where((field) => field.isRequired).toList();
    final optional = fields.where((field) => !field.isRequired).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showSectionHeaders && required.isNotEmpty)
          const _SectionLabel(label: 'Required'),
        ...required.map(
          (field) => _EntryField(
            key: ValueKey(field.key),
            field: field,
            seed: seed,
            showValidation: state.showValidation,
          ),
        ),
        if (showSectionHeaders && required.isNotEmpty && optional.isNotEmpty)
          const SizedBox(height: AppSpacing.lg),
        if (showSectionHeaders && optional.isNotEmpty)
          const _SectionLabel(label: 'Optional'),
        ...optional.map(
          (field) => _EntryField(
            key: ValueKey(field.key),
            field: field,
            seed: seed,
            showValidation: false,
          ),
        ),
      ],
    );
  }
}

class _EntryField extends ConsumerWidget {
  const _EntryField({
    super.key,
    required this.field,
    required this.seed,
    required this.showValidation,
  });

  final InputFieldSchema field;
  final EntryFormSeed seed;
  final bool showValidation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(entryFormProvider(seed));
    final controller = ref.read(entryFormProvider(seed).notifier);
    final metric = state.metricFor(field.key);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            field.label,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildField(context, ref, state, controller, metric),
          if (showValidation && (metric?.hasValue != true))
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'This field matters for today’s entry.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    BuildContext context,
    WidgetRef ref,
    EntryFormState state,
    EntryFormController controller,
    dynamic metric,
  ) {
    switch (field.type) {
      case 'score':
        final config = field.config;
        final min = config['min'] as int? ?? 1;
        final max = config['max'] as int? ?? 10;
        final value = metric?.intValue as int? ?? min;
        return Row(
          children: <Widget>[
            Expanded(
              child: ScoreSlider(
                min: min,
                max: max,
                value: value,
                onChanged: (next) => controller.setInt(field.key, next),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 32,
              child: Text(
                '$value',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inkBlack,
                    ),
              ),
            ),
          ],
        );
      case 'count':
        final config = field.config;
        return CountStepper(
          value: metric?.intValue as int? ?? (config['min'] as int? ?? 0),
          min: config['min'] as int? ?? 0,
          max: config['max'] as int? ?? 99,
          onChanged: (next) => controller.setInt(field.key, next),
        );
      case 'duration':
        return DurationPicker(
          minutes: (metric?.doubleValue as double?)?.round() ?? 0,
          onChanged: (minutes) => controller.setDouble(field.key, minutes.toDouble()),
        );
      case 'text':
        final config = field.config;
        return _SyncedTextField(
          value: metric?.stringValue as String?,
          maxLines: config['maxLines'] as int? ?? 1,
          hintText: config['placeholder'] as String?,
          onChanged: (value) => controller.setString(field.key, value),
        );
      case 'boolean':
        return Align(
          alignment: Alignment.centerLeft,
          child: CalmToggle(
            value: metric?.boolValue as bool? ?? false,
            onChanged: (next) => controller.setBool(field.key, next),
          ),
        );
      case 'single_select':
        final options = List<String>.from(field.config['options'] as List? ?? const []);
        final selected = metric?.stringValue == null
            ? <String>{}
            : <String>{metric.stringValue as String};
        return ChipSelector(
          options: options,
          selectedValues: selected,
          multi: false,
          onChanged: (values) => controller.setString(
            field.key,
            values.isEmpty ? null : values.first,
          ),
        );
      case 'multi_select':
        final options = List<String>.from(field.config['options'] as List? ?? const []);
        final selected = (metric?.listValue as List<String>?)?.toSet() ?? <String>{};
        return ChipSelector(
          options: options,
          selectedValues: selected,
          multi: true,
          onChanged: (values) => controller.setList(field.key, values.toList()),
        );
      case 'media':
        return MediaCapture(
          relativePath: metric?.mediaPath as String?,
          onTap: () => _pickMedia(context, ref, controller),
        );
      case 'time':
        final value = metric?.stringValue as String?;
        final parsed = value == null ? null : parseHhMm(value);
        return TimeInput(
          label: field.label,
          time: parsed,
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: parsed ?? TimeOfDay.now(),
            );
            if (picked != null) {
              controller.setString(field.key, hhMm(picked));
            }
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<void> _pickMedia(
    BuildContext context,
    WidgetRef ref,
    EntryFormController controller,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: surfaceShadow(elevated: true),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Add photo',
                  style: AppTextStyles.title(AppColors.inkBlack),
                ),
                const SizedBox(height: AppSpacing.md),
                _mediaOption(context, Icons.photo_camera_outlined, 'Camera', ImageSource.camera),
                const SizedBox(height: AppSpacing.sm),
                _mediaOption(context, Icons.photo_library_outlined, 'Gallery', ImageSource.gallery),
              ],
            ),
          ),
        );
      },
    );
    if (source == null) {
      return;
    }
    final mediaService = ref.read(mediaServiceProvider);
    final result = await mediaService.pickAndStore(
      source: source,
      trackerUid: seed.tracker.uid,
      effectiveDate: seed.effectiveDate,
    );
    if (result == null) {
      return;
    }
    if (result.relativePath != null) {
      controller.setMedia(field.key, result.relativePath);
      return;
    }
    if (result.needsSettings) {
      await openAppSettings();
    }
    if (context.mounted && result.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message!)),
      );
    }
  }

  Widget _mediaOption(
    BuildContext context,
    IconData icon,
    String label,
    ImageSource source,
  ) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(source),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.inkBlack),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
    );
  }
}

class _SyncedTextField extends StatefulWidget {
  const _SyncedTextField({
    required this.value,
    required this.onChanged,
    this.maxLines = 1,
    this.hintText,
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final int maxLines;
  final String? hintText;

  @override
  State<_SyncedTextField> createState() => _SyncedTextFieldState();
}

class _SyncedTextFieldState extends State<_SyncedTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value ?? '');

  @override
  void didUpdateWidget(covariant _SyncedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != _controller.text) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(hintText: widget.hintText),
      onChanged: widget.onChanged,
    );
  }
}
