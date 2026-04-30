import 'package:flutter/services.dart';

/// Native haptic channel — bypasses Flutter's HapticFeedback bridge.
/// Calls go directly to our Kotlin HapticEngine via MethodChannel.
const _channel = MethodChannel('com.cato.cato/haptics');

// ── Public pattern API ──────────────────────────────────────────────────────

/// The 10 patterns shipped with the native engine.
/// Stable ids MUST match `Patterns` object in HapticEngine.kt.
/// See docs/execution-docs/haptic_redesign.md §6 for recipes.
enum HapticPattern {
  ceramicTap('ceramic_tap'),
  glassBeadTick('glass_bead_tick'),
  softPaperPress('soft_paper_press'),
  inkSettle('ink_settle'),
  dialNotch('dial_notch'),
  twoStageConfirm('two_stage_confirm'),
  waxSeal('wax_seal'),
  stoneStamp('stone_stamp'),
  paperLift('paper_lift'),
  blockedThud('blocked_thud');

  const HapticPattern(this.id);
  final String id;
}

/// Per-call intensity, quantized (§3 of haptic_redesign.md).
/// soft = 0.7×, base = 1.0×, accent = 1.3× — applied as scale/amplitude
/// multipliers natively, with appropriate clamping per tier.
enum Intensity {
  soft('soft'),
  base('base'),
  accent('accent');

  const Intensity(this.key);
  final String key;
}

/// Fire a single pattern. Pre-fire BEFORE setState (§4b rule 5 — temporal
/// dissonance kills the effect).
void firePattern(
  HapticPattern pattern, {
  Intensity intensity = Intensity.base,
}) {
  _channel.invokeMethod('firePattern', {
    'id': pattern.id,
    'intensity': intensity.key,
  });
}

/// Cancel any in-flight vibration or scheduled split-tier-3 continuation.
void cancelHaptic() {
  _channel.invokeMethod('cancel');
}

// ── Pattern bindings (single or sequenced) ──────────────────────────────────

/// Binds an interaction to one or more patterns.
///
/// Single binding: one step in the list, fires immediately.
/// Sequenced binding: multiple steps; the gapAfterMs on step N defines the
/// delay before step N+1, clamped to ≥ 30 ms (§4b rule 1: no haptic ghosting).
class PatternBinding {
  const PatternBinding(this.steps);

  /// Empty binding — no haptic. Use for `Intensity.none` profiles.
  static const PatternBinding none = PatternBinding(<PatternStep>[]);

  final List<PatternStep> steps;

  bool get isEmpty => steps.isEmpty;

  /// Play the binding. `intensityOverride` replaces every step's intensity if
  /// provided — useful for context modulation (e.g. delete-of-streak).
  void fire({Intensity? intensityOverride}) {
    if (steps.isEmpty) return;

    var elapsedMs = 0;
    for (var i = 0; i < steps.length; i++) {
      final step = steps[i];
      final intensity = intensityOverride ?? step.intensity;

      if (elapsedMs == 0) {
        firePattern(step.pattern, intensity: intensity);
      } else {
        Future.delayed(Duration(milliseconds: elapsedMs), () {
          firePattern(step.pattern, intensity: intensity);
        });
      }

      // §4b rule 1: minimum 30 ms gap between sequenced patterns.
      if (i < steps.length - 1) {
        elapsedMs += step.gapAfterMs.clamp(30, 1000);
      }
    }
  }
}

/// One step inside a PatternBinding.
class PatternStep {
  const PatternStep({
    required this.pattern,
    this.intensity = Intensity.base,
    this.gapAfterMs = 30,
  });

  final HapticPattern pattern;
  final Intensity intensity;

  /// Delay before the NEXT step in a sequence. Ignored for the last step.
  /// Clamped to ≥ 30 ms by `PatternBinding.fire()`.
  final int gapAfterMs;
}

// ── Profile ─────────────────────────────────────────────────────────────────

/// Defines haptic feedback for each interaction type.
/// Each interaction maps to a `PatternBinding` (one pattern, or a sequence).
class CatoHapticProfile {
  const CatoHapticProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.save,
    required this.complete,
    required this.milestone,
    required this.tick,
    required this.delete,
    required this.error,
  });

  final String id;
  final String name;
  final String description;

  final PatternBinding save;
  final PatternBinding complete;
  final PatternBinding milestone;
  final PatternBinding tick;
  final PatternBinding delete;
  final PatternBinding error;

  /// Fire the appropriate binding for an interaction.
  /// Pre-fire before setState (§4b rule 5).
  void play(HapticInteraction interaction, {Intensity? intensityOverride}) {
    final binding = switch (interaction) {
      HapticInteraction.save => save,
      HapticInteraction.complete => complete,
      HapticInteraction.milestone => milestone,
      HapticInteraction.tick => tick,
      HapticInteraction.delete => delete,
      HapticInteraction.error => error,
    };
    binding.fire(intensityOverride: intensityOverride);
  }
}

enum HapticInteraction { save, complete, milestone, tick, delete, error }
