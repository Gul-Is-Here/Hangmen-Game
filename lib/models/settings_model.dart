class SettingsModel {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool timerEnabled;
  final bool darkMode;

  SettingsModel({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.timerEnabled = false,
    this.darkMode = false,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? timerEnabled,
    bool? darkMode,
  }) {
    return SettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      darkMode: darkMode ?? this.darkMode,
    );
  }
}