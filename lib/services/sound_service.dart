import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService() : _player = AudioPlayer(playerId: 'cato-sound');

  final AudioPlayer _player;

  Future<void> playSaveTap() async {
    await _playAsset('sounds/save_tap.wav');
  }

  Future<void> playEveningChime() async {
    await _playAsset('sounds/evening_chime.wav');
  }

  Future<void> dispose() async {
    await _player.dispose();
  }

  Future<void> _playAsset(String assetPath) async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.play(AssetSource(assetPath));
  }
}

