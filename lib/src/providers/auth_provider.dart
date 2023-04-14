// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String apiHost = 'https://api.kicshikxo.ru';
// const String apiHost = 'http://localhost:3000';

enum LoginStatus {
  ok,
  error,
  socketError,
  unauthorized,
}

class AuthInfo {
  final bool isAuthenticated;
  final String authToken;
  final String groupName;
  final String groupAcademicYear;
  final bool isAdmin;

  AuthInfo({
    required this.isAuthenticated,
    required this.authToken,
    required this.groupName,
    required this.groupAcademicYear,
    this.isAdmin = false,
  });

  AuthInfo.unauthorized()
      : isAuthenticated = false,
        authToken = '',
        groupName = '',
        groupAcademicYear = '',
        isAdmin = false;

  AuthInfo.authorized({
    required this.authToken,
    required this.groupName,
    required this.groupAcademicYear,
    this.isAdmin = false,
  }) : isAuthenticated = true;

  AuthInfo.fromPrefs(SharedPreferences prefs)
      : isAuthenticated = prefs.getBool('wasAuthorized') ?? false,
        authToken = prefs.getString('authToken') ?? '',
        groupName = prefs.getString('groupName') ?? '',
        groupAcademicYear = prefs.getString('groupAcademicYear') ?? '',
        isAdmin = prefs.getBool('wasAdmin') ?? false;

  void save(SharedPreferences prefs) async {
    prefs.setBool('wasAuthorized', isAuthenticated);
    prefs.setString('authToken', authToken);
    prefs.setString('groupName', groupName);
    prefs.setString('groupAcademicYear', groupAcademicYear);
    prefs.setBool('wasAdmin', isAdmin);
  }
}

class Group {
  final String id;
  final String name;
  final String academicYear;

  Group({
    required this.id,
    required this.name,
    required this.academicYear,
  });

  Group.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        academicYear = json['academicYear'];

  @override
  String toString() {
    return '$id ($name-$academicYear)';
  }
}

class AuthProvider extends ChangeNotifier {
  static late SharedPreferences _prefs;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  AuthInfo _authInfo = AuthInfo.unauthorized();
  AuthInfo get authInfo => _authInfo;

  AuthProvider() {
    _authInfo = AuthInfo.fromPrefs(_prefs);
  }

  Future<List<String>?> getAcademicYears() async {
    try {
      final response = await Requests.get(
        '$apiHost/v2/timetable/academic-years',
      );

      if (response.statusCode == HttpStatus.ok) {
        return List<String>.from(response.json() as List<dynamic>);
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<List<Group>?> getGroups({String? academicYear}) async {
    try {
      final response = await Requests.get(
        '$apiHost/v2/timetable/groups',
        queryParameters: {
          'academic-year': academicYear ?? '',
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return [for (final group in response.json() as List<dynamic>) Group.fromJson(group)];
      }
    } on SocketException {
      return null;
    } catch (e) {
      return null;
    }

    return null;
  }

  Future<LoginStatus> tryLogin({required String group, required String academicYear, String? password}) async {
    try {
      final response = await Requests.post(
        '$apiHost/v2/timetable/auth/login',
        body: {
          'group': group,
          'academicYear': academicYear,
          'password': password ?? '',
        },
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonData = response.json();
        _authInfo = AuthInfo.authorized(
          authToken: jsonData['token'],
          groupName: jsonData['groupName'],
          groupAcademicYear: jsonData['groupAcademicYear'],
          isAdmin: jsonData['isAdmin'],
        );
        _authInfo.save(_prefs);
        notifyListeners();
        return LoginStatus.ok;
      } else if (response.statusCode == HttpStatus.unauthorized) {
        return LoginStatus.unauthorized;
      }
    } on SocketException {
      return LoginStatus.socketError;
    } catch (e) {
      return LoginStatus.error;
    }

    return LoginStatus.error;
  }

  Future<LoginStatus> checkLogin({String? authToken}) async {
    try {
      final response = await Requests.get(
        '$apiHost/v2/timetable/auth/check-login',
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken ?? _authInfo.authToken}',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonData = response.json();
        if (jsonData['valid'] != true) {
          return LoginStatus.unauthorized;
        }
        return LoginStatus.ok;
      } else if (response.statusCode == HttpStatus.unauthorized) {
        logout();
        return LoginStatus.unauthorized;
      }
    } on SocketException {
      return LoginStatus.socketError;
    } catch (e) {
      return LoginStatus.error;
    }

    return LoginStatus.error;
  }

  void logout() {
    _authInfo = AuthInfo.unauthorized();
    _authInfo.save(_prefs);
    notifyListeners();
  }
}
