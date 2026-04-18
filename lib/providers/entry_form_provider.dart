import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/date_utils.dart';
import '../models/event.dart';
import '../models/metric_value.dart';
import '../models/tracker.dart';

class EntryFormSeed {
  const EntryFormSeed({
    required this.tracker,
    required this.effectiveDate,
    this.existingEvent,
    this.isBackfill = false,
  });

  final Tracker tracker;
  final DateTime effectiveDate;
  final Event? existingEvent;
  final bool isBackfill;

  @override
  bool operator ==(Object other) {
    return other is EntryFormSeed &&
        other.tracker.uid == tracker.uid &&
        isSameDay(other.effectiveDate, effectiveDate) &&
        other.existingEvent?.uid == existingEvent?.uid &&
        other.isBackfill == isBackfill;
  }

  @override
  int get hashCode => Object.hash(
        tracker.uid,
        effectiveDate.year,
        effectiveDate.month,
        effectiveDate.day,
        existingEvent?.uid,
        isBackfill,
      );
}

class EntryFormState {
  const EntryFormState({
    required this.effectiveDate,
    required this.headerTime,
    required this.values,
    this.showValidation = false,
    this.isSaving = false,
  });

  final DateTime effectiveDate;
  final TimeOfDay headerTime;
  final Map<String, MetricValue> values;
  final bool showValidation;
  final bool isSaving;

  MetricValue? metricFor(String key) => values[key];

  EntryFormState copyWith({
    DateTime? effectiveDate,
    TimeOfDay? headerTime,
    Map<String, MetricValue>? values,
    bool? showValidation,
    bool? isSaving,
  }) {
    return EntryFormState(
      effectiveDate: effectiveDate ?? this.effectiveDate,
      headerTime: headerTime ?? this.headerTime,
      values: values ?? this.values,
      showValidation: showValidation ?? this.showValidation,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class EntryFormController extends StateNotifier<EntryFormState> {
  EntryFormController(this.seed)
      : super(
          EntryFormState(
            effectiveDate: normalizeDate(seed.effectiveDate),
            headerTime: _initialHeaderTime(seed),
            values: _initialValues(seed),
          ),
        );

  final EntryFormSeed seed;

  void setEffectiveDate(DateTime value) {
    state = state.copyWith(effectiveDate: normalizeDate(value));
  }

  void setHeaderTime(TimeOfDay value) {
    final nextValues = Map<String, MetricValue>.from(state.values);
    if (_hasHeaderTimeField(seed.tracker)) {
      nextValues['time'] = MetricValue()
        ..inputKey = 'time'
        ..stringValue = hhMm(value);
    }
    state = state.copyWith(headerTime: value, values: nextValues);
  }

  void setInt(String key, int? value) {
    _setMetric(
      key,
      (metric) => metric..intValue = value,
    );
  }

  void setDouble(String key, double? value) {
    _setMetric(
      key,
      (metric) => metric..doubleValue = value,
    );
  }

  void setString(String key, String? value) {
    _setMetric(
      key,
      (metric) => metric..stringValue = value,
    );
  }

  void setBool(String key, bool? value) {
    _setMetric(
      key,
      (metric) => metric..boolValue = value,
    );
  }

  void setList(String key, List<String> values) {
    _setMetric(
      key,
      (metric) => metric..listValue = values,
    );
  }

  void setMedia(String key, String? path) {
    _setMetric(
      key,
      (metric) => metric..mediaPath = path,
    );
  }

  void copyFromPrevious(Event event) {
    final nextValues = Map<String, MetricValue>.from(state.values);
    for (final metric in event.metrics) {
      nextValues[metric.inputKey] = MetricValue.copyOf(metric);
    }
    final headerMetric = nextValues['time']?.stringValue;
    final nextHeaderTime = headerMetric == null
        ? state.headerTime
        : parseHhMm(headerMetric);
    state = state.copyWith(values: nextValues, headerTime: nextHeaderTime);
  }

  Future<void> copyFromPreviousStaggered(
    Event event, {
    Duration stepDelay = const Duration(milliseconds: 50),
  }) async {
    for (final field in seed.tracker.sortedInputSchema) {
      if (!mounted) {
        return;
      }
      final nextValues = Map<String, MetricValue>.from(state.values);
      final previousMetric = event.metrics
          .cast<MetricValue?>()
          .firstWhere(
            (item) => item?.inputKey == field.key,
            orElse: () => null,
          );

      TimeOfDay nextHeaderTime = state.headerTime;
      if (field.key == 'time' && field.type == 'time') {
        final previousTime = previousMetric?.stringValue ??
            (event.effectiveTime == null
                ? null
                : hhMm(TimeOfDay.fromDateTime(event.effectiveTime!)));
        if (previousTime == null || previousTime.isEmpty) {
          nextValues.remove(field.key);
        } else {
          nextValues[field.key] = MetricValue()
            ..inputKey = field.key
            ..stringValue = previousTime;
          nextHeaderTime = parseHhMm(previousTime);
        }
      } else if (previousMetric?.hasValue == true) {
        nextValues[field.key] = MetricValue.copyOf(previousMetric!);
      } else {
        nextValues.remove(field.key);
      }

      state = state.copyWith(
        values: nextValues,
        headerTime: nextHeaderTime,
      );

      if (field != seed.tracker.sortedInputSchema.last) {
        await Future<void>.delayed(stepDelay);
      }
    }
  }

  bool validate() {
    final isValid = _requiredFields(seed.tracker).every((field) {
      final metric = state.values[field.key];
      return metric?.hasValue == true;
    });
    state = state.copyWith(showValidation: !isValid);
    return isValid;
  }

  List<MetricValue> buildMetrics() {
    final result = <MetricValue>[];
    for (final entry in state.values.entries) {
      if (entry.value.hasValue) {
        result.add(MetricValue.copyOf(entry.value));
      }
    }
    return result;
  }

  Set<String> buildClearedKeys() {
    return {
      for (final field in seed.tracker.sortedInputSchema)
        if (state.values[field.key]?.hasValue != true) field.key,
    };
  }

  void setSaving(bool saving) {
    state = state.copyWith(isSaving: saving);
  }

  void _setMetric(String key, MetricValue Function(MetricValue) update) {
    final nextValues = Map<String, MetricValue>.from(state.values);
    final current = MetricValue.copyOf(
      nextValues[key] ??
          (MetricValue()
            ..inputKey = key),
    );
    nextValues[key] = update(current);
    state = state.copyWith(values: nextValues);
  }
}

final entryFormProvider = StateNotifierProvider.autoDispose
    .family<EntryFormController, EntryFormState, EntryFormSeed>(
  (ref, seed) => EntryFormController(seed),
);

Map<String, MetricValue> _initialValues(EntryFormSeed seed) {
  final values = <String, MetricValue>{
    for (final metric in seed.existingEvent?.metrics ?? const <MetricValue>[])
      metric.inputKey: MetricValue.copyOf(metric),
  };
  if (_hasHeaderTimeField(seed.tracker) && !values.containsKey('time')) {
    values['time'] = MetricValue()
      ..inputKey = 'time'
      ..stringValue = hhMm(_initialHeaderTime(seed));
  }
  return values;
}

TimeOfDay _initialHeaderTime(EntryFormSeed seed) {
  final metricTime = seed.existingEvent?.metrics
      .cast<MetricValue?>()
      .firstWhere(
        (item) => item?.inputKey == 'time',
        orElse: () => null,
      )
      ?.stringValue;
  if (metricTime != null && metricTime.isNotEmpty) {
    return parseHhMm(metricTime);
  }
  final existingTime = seed.existingEvent?.effectiveTime;
  if (existingTime != null) {
    return TimeOfDay.fromDateTime(existingTime);
  }
  final promptTime = _promptTime(seed.tracker);
  if (promptTime != null) {
    return promptTime;
  }
  return TimeOfDay.fromDateTime(DateTime.now());
}

bool _hasHeaderTimeField(Tracker tracker) {
  return tracker.sortedInputSchema.any(
    (field) => field.key == 'time' && field.type == 'time',
  );
}

List<dynamic> _requiredFields(Tracker tracker) {
  return tracker.sortedInputSchema.where((field) {
    if (field.key == 'time' && field.type == 'time') {
      return false;
    }
    return field.isRequired;
  }).toList();
}

TimeOfDay? _promptTime(Tracker tracker) {
  if (tracker.promptTimes.isEmpty) {
    return null;
  }
  return parseHhMm(tracker.promptTimes.first);
}
