import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _enabled = true;

  Future<void> playGuessSound(bool correct) async {
    if (!_enabled) return;
    await _player.play(AssetSource(correct ? 'sounds/correct.wav' : 'sounds/loose.wav'));
  }

  Future<void> playWinSound() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/win.wav'));
  }

  Future<void> playLoseSound() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/loose.wav'));
  }

  Future<void> playHintSound() async {
    if (!_enabled) return;
    await _player.play(AssetSource('sounds/win.wav'));
  }

  void toggleEnabled(bool enabled) {
    _enabled = enabled;
  }
}