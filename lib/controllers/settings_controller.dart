import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/audio_service.dart';
import '../services/vibration_service.dart';

class SettingsController extends GetxController {
  final AudioService _audioService = Get.put(AudioService());
  final VibrationService _vibrationService = Get.put(VibrationService());

  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool timerEnabled = false.obs;
  final RxBool darkMode = false.obs;

  @override
  void onInit() {
    // Load settings from storage
    loadSettings();
    super.onInit();
  }

  void loadSettings() {
    // In a real app, load from SharedPreferences
    soundEnabled.value = true;
    vibrationEnabled.value = true;
    timerEnabled.value = false;
    darkMode.value = false;

    _audioService.toggleEnabled(soundEnabled.value);
    _vibrationService.toggleEnabled(vibrationEnabled.value);
  }

  void toggleSound(bool value) {
    soundEnabled.value = value;
    _audioService.toggleEnabled(value);
    // Save to storage
  }

  void toggleVibration(bool value) {
    vibrationEnabled.value = value;
    _vibrationService.toggleEnabled(value);
    // Save to storage
  }

  void toggleTimer(bool value) {
    timerEnabled.value = value;
    // Save to storage
  }

  void toggleTheme(bool value) {
    darkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
    // Save to storage
  }
}
