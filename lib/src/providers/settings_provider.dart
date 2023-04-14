// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static late SharedPreferences _prefs;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

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
}

class Settings {
  late final VoidCallback? _onChangeCallback;

  late bool _openCurrentDayAtLaunch;
  bool get openCurrentDayAtLaunch => _openCurrentDayAtLaunch;
  set openCurrentDayAtLaunch(value) {
    _openCurrentDayAtLaunch = value;
    _emitCallback();
  }

  late bool _daysScrolling;
  bool get daysScrolling => _daysScrolling;
  set daysScrolling(value) {
    _daysScrolling = value;
    _emitCallback();
  }

  late bool _showProgressIndicator;
  bool get showProgressIndicator => _showProgressIndicator;
  set showProgressIndicator(value) {
    _showProgressIndicator = value;
    _emitCallback();
  }

  late bool _highlightCurrentLesson;
  bool get highlightCurrentLesson => _highlightCurrentLesson;
  set highlightCurrentLesson(value) {
    _highlightCurrentLesson = value;
    _emitCallback();
  }

  late bool _darkenCompletedLessons;
  bool get darkenCompletedLessons => _darkenCompletedLessons;
  set darkenCompletedLessons(value) {
    _darkenCompletedLessons = value;
    _emitCallback();
  }

  late bool _checkForUpdates;
  bool get checkForUpdates => _checkForUpdates;
  set checkForUpdates(value) {
    _checkForUpdates = value;
    _emitCallback();
  }

  late bool _enableHeavyAnimations;
  bool get enableHeavyAnimations => _enableHeavyAnimations;
  set enableHeavyAnimations(value) {
    _enableHeavyAnimations = value;
    _emitCallback();
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

  void _emitCallback() {
    if (_onChangeCallback != null) {
      _onChangeCallback!();
    }
  }
}
