import 'package:flutter/services.dart';

/// Native haptic channel — bypasses Flutter's HapticFeedback bridge.
/// Calls go directly to our Kotlin HapticEngine via MethodChannel.
const _channel = MethodChannel('com.cato.cato/haptics');

/// Defines haptic feedback intensities for each interaction type.
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
  });

  final String id;
  final String name;
  final String description;

  final HapticType save;
  final HapticType complete;
  final HapticType milestone;
  final HapticType tick;
  final HapticType delete;

  /// Fire the appropriate haptic for a given interaction.
  /// This is designed to be called BEFORE setState (pre-fire strategy).
  void play(HapticInteraction interaction) {
    final type = switch (interaction) {
      HapticInteraction.save => save,
      HapticInteraction.complete => complete,
      HapticInteraction.milestone => milestone,
      HapticInteraction.tick => tick,
      HapticInteraction.delete => delete,
    };
    fireHaptic(type);
  }
}

/// Fire a haptic through the native engine.
/// Non-blocking — sends to native and returns immediately.
/// The native side handles cancel-before-fire and overdrive internally.
void fireHaptic(HapticType type) {
  if (type == HapticType.none) return;
  _channel.invokeMethod('fire', {'type': type.index});
}

/// Cancel any queued vibration. Call before rapid-fire sequences.
void cancelHaptic() {
  _channel.invokeMethod('cancel');
}

enum HapticType { none, selection, light, medium, heavy }

enum HapticInteraction { save, complete, milestone, tick, delete }
