import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import '../app/sounds/sound_registry.dart';

class SoundService {
  SoundService() : _player = AudioPlayer(playerId: 'cato-sound');

  final AudioPlayer _player;
  final Set<String> _verifiedAssets = {};
  final Set<String> _missingAssets = {};

  Future<void> playSaveTap() async {
    await _playAsset('sounds/save_tap.wav');
  }

  Future<void> playEveningChime() async {
    await _playAsset('sounds/evening_chime.wav');
  }

  /// Play a specific interaction sound from a sound pack.
  /// Falls back to the default save_tap.wav for placeholder assets.
  Future<void> playPackSound(String packId, SoundInteraction interaction) async {
    final pack = soundPackById(packId);
    final asset = switch (interaction) {
      SoundInteraction.save => pack.save,
      SoundInteraction.complete => pack.complete,
      SoundInteraction.milestone => pack.milestone,
      SoundInteraction.tick => pack.tick,
      SoundInteraction.delete => pack.delete,
    };
    if (asset == null) return; // Silence pack
    if (asset.isPlaceholder) {
      // Use fallback sound for placeholders
      await _playAsset('sounds/save_tap.wav');
      return;
    }
    await _playAsset(asset.path);
  }

  /// Pre-verify assets at startup to avoid runtime latency.
  Future<void> warmUp() async {
    const commonAssets = ['sounds/save_tap.wav', 'sounds/evening_chime.wav'];
    for (final path in commonAssets) {
      try {
        await rootBundle.load('assets/$path');
        _verifiedAssets.add(path);
      } catch (_) {
        _missingAssets.add(path);
      }
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _playAsset(String assetPath) async {
    // Fast-path: already known missing
    if (_missingAssets.contains(assetPath)) return;

    try {
      // Only verify unknown assets
      if (!_verifiedAssets.contains(assetPath)) {
        await rootBundle.load('assets/$assetPath');
        _verifiedAssets.add(assetPath);
      }
      await _player.stop();
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.play(AssetSource(assetPath));
    } catch (_) {
      _missingAssets.add(assetPath);
    }
  }
}

enum SoundInteraction { save, complete, milestone, tick, delete }
