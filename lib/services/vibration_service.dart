import 'package:vibration/vibration.dart';

class VibrationService {
  bool _enabled = true;

  Future<void> vibrate() async {
    if (!_enabled) return;
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void toggleEnabled(bool enabled) {
    _enabled = enabled;
  }
}