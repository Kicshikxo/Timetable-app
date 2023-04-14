// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week_of_year/week_of_year.dart';

const String apiHost = 'https://api.kicshikxo.ru';
// const String apiHost = 'http://localhost:3000';

class Week {
  late final String id;
  late final List<Day> days;

  Week({required this.id, required this.days});

  Week.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        days = [for (var day in json['days']) Day.fromJson(day)];

  Map<String, dynamic> toJson() => {
        'id': id,
        'days': [for (Day day in days) day.toJson()],
      };
}

class Day {
  late final DateTime date;
  late final List<Lesson> lessons;

  Day({required this.date, required this.lessons});

  Day.fromJson(Map<String, dynamic> json)
      : date = DateTime.parse(json['date']),
        lessons = [for (var lesson in json['lessons']) Lesson.fromJson(lesson)];

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T').first,
        'lessons': [for (Lesson lesson in lessons) lesson.toJson()]
      };
}

class Lesson {
  late final int index;
  late final String name;
  late final String cabinet;

  Lesson({required this.index, required this.name, required this.cabinet});

  Lesson.fromJson(Map<String, dynamic> json)
      : index = json['index'],
        name = json['name'].toString().trim(),
        cabinet = json['cabinet'].toString().trim();

  Map<String, dynamic> toJson() => {
        'index': index,
        'name': name,
        'cabinet': cabinet,
      };
}

class TimetableProvider extends ChangeNotifier {
  static late SharedPreferences _prefs;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  List<Week> _weeks = [];
  List<Week> get weeks => _weeks;

  String get currentWeekId {
    DateTime today = DateTime.now();
    return '${today.year}${today.weekOfYear.toString().padLeft(2, '0')}';
    // for (final week in _weeks) {
    //   for (final day in week.days) {
    //     if (today.day == day.date.day && today.month == day.date.month && today.year == day.date.year) {
    //       return week.id;
    //     }
    //   }
    // }
    // return null;
  }

  int _totalWeeksCount = 0;
  int get totalWeeksCount => _totalWeeksCount;

  bool get hasMoreWeeks => _weeks.length < _totalWeeksCount;

  TimetableProvider() {
    String? savedWeeks = _prefs.getString('timetable');
    if (savedWeeks != null) {
      _weeks = [for (var week in json.decode(savedWeeks)) Week.fromJson(week)];
      notifyListeners();
    }
  }

  Future<bool> fetchWeeks({required String authToken}) async {
    if (_weeks.isEmpty) {
      return getWeeks(authToken: authToken);
    } else {
      return updateWeeks(authToken: authToken);
    }
  }

  Future<bool> getWeeks({required String authToken}) async {
    final weeks = await _fetchWeeks(authToken: authToken, limit: 8, offset: _weeks.length);
    if (weeks != null) {
      _weeks.addAll(weeks);
      _saveWeeks();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> updateWeeks({required String authToken}) async {
    final weeks = await _fetchWeeks(authToken: authToken, limit: max(_weeks.length, 8), offset: 0);
    if (weeks != null) {
      _weeks = weeks;
      _saveWeeks();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<List<Week>?> _fetchWeeks({required String authToken, required int limit, required int offset}) async {
    try {
      final response = await Requests.get(
        '$apiHost/v2/timetable/weeks',
        queryParameters: {
          'limit': limit.toString(),
          'offset': offset.toString(),
        },
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonData = response.json();
        _totalWeeksCount = int.parse(jsonData['totalItemsCount'].toString());
        return [for (final week in jsonData['weeks'] as List<dynamic>) Week.fromJson(week)];
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }

    return null;
  }

  void _saveWeeks({limit = 8}) {
    _prefs.setString('timetable', json.encode([for (Week week in _weeks.sublist(0, min(_weeks.length, limit))) week.toJson()]));
  }

  void clearWeeks() {
    _weeks.clear();
    _prefs.remove('timetable');
  }
}
