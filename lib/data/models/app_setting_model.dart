class UserSettings {
  const UserSettings({
    required this.grossMode,
    required this.notificationEnabled,
    required this.vibrationEnabled,
    required this.soundEnabled,
    required this.floatingWindowEnabled,
    required this.widgetEnabled,
    required this.minorSafeMode,
  });

  factory UserSettings.initial() {
    return const UserSettings(
      grossMode: true,
      notificationEnabled: true,
      vibrationEnabled: true,
      soundEnabled: true,
      floatingWindowEnabled: true,
      widgetEnabled: true,
      minorSafeMode: true,
    );
  }

  final bool grossMode;
  final bool notificationEnabled;
  final bool vibrationEnabled;
  final bool soundEnabled;
  final bool floatingWindowEnabled;
  final bool widgetEnabled;
  final bool minorSafeMode;

  Map<String, Object?> toJson() {
    return {
      'grossMode': grossMode,
      'notificationEnabled': notificationEnabled,
      'vibrationEnabled': vibrationEnabled,
      'soundEnabled': soundEnabled,
      'floatingWindowEnabled': floatingWindowEnabled,
      'widgetEnabled': widgetEnabled,
      'minorSafeMode': minorSafeMode,
    };
  }

  factory UserSettings.fromJson(Map<String, Object?> json) {
    final initial = UserSettings.initial();
    return UserSettings(
      grossMode: json['grossMode'] as bool? ?? initial.grossMode,
      notificationEnabled:
          json['notificationEnabled'] as bool? ?? initial.notificationEnabled,
      vibrationEnabled:
          json['vibrationEnabled'] as bool? ?? initial.vibrationEnabled,
      soundEnabled: json['soundEnabled'] as bool? ?? initial.soundEnabled,
      floatingWindowEnabled:
          json['floatingWindowEnabled'] as bool? ??
          initial.floatingWindowEnabled,
      widgetEnabled: json['widgetEnabled'] as bool? ?? initial.widgetEnabled,
      minorSafeMode: json['minorSafeMode'] as bool? ?? initial.minorSafeMode,
    );
  }

  UserSettings copyWith({
    bool? grossMode,
    bool? notificationEnabled,
    bool? vibrationEnabled,
    bool? soundEnabled,
    bool? floatingWindowEnabled,
    bool? widgetEnabled,
    bool? minorSafeMode,
  }) {
    return UserSettings(
      grossMode: grossMode ?? this.grossMode,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      floatingWindowEnabled:
          floatingWindowEnabled ?? this.floatingWindowEnabled,
      widgetEnabled: widgetEnabled ?? this.widgetEnabled,
      minorSafeMode: minorSafeMode ?? this.minorSafeMode,
    );
  }
}
