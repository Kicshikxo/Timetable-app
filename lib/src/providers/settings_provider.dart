// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';
// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  late final VoidCallback? _onChangeCallback;

  late bool _openCurrentDayAtLaunch;
  late bool _daysScrolling;
  late bool _showProgressIndicator;

  late bool _highlightCurrentLesson;
  late bool _darkenCompletedLessons;
  late bool _checkForUpdates;

  late bool _enableHeavyAnimations;
  Settings.fromJson(Map<String, dynamic> json, {VoidCallback? onChange}) {
    _onChangeCallback = onChange;
    _openCurrentDayAtLaunch = json['openCurrentDayAtLaunch'] ?? Settings.standart().openCurrentDayAtLaunch;
    _daysScrolling = json['daysScrolling'] ?? Settings.standart().daysScrolling;
    _enableHeavyAnimations = json['enableHeavyAnimations'] ?? Settings.standart().enableHeavyAnimations;
    _showProgressIndicator = json['showProgressIndicator'] ?? Settings.standart().showProgressIndicator;
    _highlightCurrentLesson = json['highlightCurrentLesson'] ?? Settings.standart().highlightCurrentLesson;
    _checkForUpdates = json['checkForUpdates'] ?? Settings.standart().checkForUpdates;
    _darkenCompletedLessons = json['darkenOldLessons'] ?? Settings.standart().darkenCompletedLessons;
  }
  Settings.standart({VoidCallback? onChange}) {
    _onChangeCallback = onChange;
    _openCurrentDayAtLaunch = true;
    _daysScrolling = false;
    _showProgressIndicator = true;
    _highlightCurrentLesson = true;
    _darkenCompletedLessons = true;
    _checkForUpdates = true;
    _enableHeavyAnimations = true;
  }

  bool get checkForUpdates => _checkForUpdates;
  set checkForUpdates(value) {
    _checkForUpdates = value;
    _emitCallback();
  }

  bool get darkenCompletedLessons => _darkenCompletedLessons;

  set darkenCompletedLessons(value) {
    _darkenCompletedLessons = value;
    _emitCallback();
  }

  bool get daysScrolling => _daysScrolling;
  set daysScrolling(value) {
    _daysScrolling = value;
    _emitCallback();
  }

  bool get enableHeavyAnimations => _enableHeavyAnimations;
  set enableHeavyAnimations(value) {
    _enableHeavyAnimations = value;
    _emitCallback();
  }

  bool get highlightCurrentLesson => _highlightCurrentLesson;

  set highlightCurrentLesson(value) {
    _highlightCurrentLesson = value;
    _emitCallback();
  }

  bool get openCurrentDayAtLaunch => _openCurrentDayAtLaunch;
  set openCurrentDayAtLaunch(value) {
    _openCurrentDayAtLaunch = value;
    _emitCallback();
  }

  bool get showProgressIndicator => _showProgressIndicator;

  set showProgressIndicator(value) {
    _showProgressIndicator = value;
    _emitCallback();
  }

  void _emitCallback() {
    if (_onChangeCallback != null) {
      _onChangeCallback!();
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  static late SharedPreferences _prefs;
  late final Settings settings;

  SettingsProvider() {
    _initSettings();
  }

  void _initSettings() {
    final String? savedSettings = _prefs.getString('settings');
    if (savedSettings != null) {
      final jsonData = json.decode(savedSettings);
      settings = Settings.fromJson(jsonData, onChange: _saveSettings);
    } else {
      settings = Settings.standart(onChange: _saveSettings);
    }
  }

  void _saveSettings() {
    Map<String, dynamic> jsonSettings = {
      "openCurrentDayAtLaunch": settings.openCurrentDayAtLaunch,
      "daysScrolling": settings.daysScrolling,
      "showProgressIndicator": settings.showProgressIndicator,
      "highlightCurrentLesson": settings.highlightCurrentLesson,
      "darkenCompletedLessons": settings.darkenCompletedLessons,
      "checkForUpdates": settings.checkForUpdates,
      "enableHeavyAnimations": settings.enableHeavyAnimations,
    };
    _prefs.setString('settings', json.encode(jsonSettings));
    notifyListeners();
  }

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
}
