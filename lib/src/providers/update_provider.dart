// Dart imports:
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:requests/requests.dart';

// Project imports:
import 'package:timetable/src/bottom_sheets/update_request_bottom_sheet.dart';

const apiHost = 'https://api.kicshikxo.ru';

enum CheckUpdateStatus {
  newVersion,
  sameVersion,
  socketError,
  error,
}

class CheckUpdateInfo {
  CheckUpdateStatus status;
  String? latestVersion;

  CheckUpdateInfo(this.status, this.latestVersion);

  CheckUpdateInfo.error() : status = CheckUpdateStatus.error;
  CheckUpdateInfo.socketError() : status = CheckUpdateStatus.socketError;
}

class UpdateProvider extends ChangeNotifier {
  static final ReceivePort _port = ReceivePort();
  static const String _portName = 'update';

  static Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await FlutterDownloader.initialize();
  }

  String? _taskId;
  DownloadTask? _task;
  DownloadTask? get task => _task;

  UpdateProvider() {
    if (!Platform.isAndroid) return;
    _bindBackgroundIsolate();
    _port.listen((dynamic data) async {
      _taskId = data as String;
      _task = (await FlutterDownloader.loadTasks())?.firstWhereOrNull((task) => task.taskId == _taskId);
      notifyListeners();
    });
    FlutterDownloader.registerCallback(_downloadCallback);
  }

  @override
  void dispose() {
    _unbindBackgroundIsolate();
    super.dispose();
  }

  void _bindBackgroundIsolate() {
    if (!IsolateNameServer.registerPortWithName(_port.sendPort, _portName)) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping(_portName);
  }

  @pragma('vm:entry-point')
  static void _downloadCallback(String taskId, DownloadTaskStatus status, int progress) {
    IsolateNameServer.lookupPortByName(_portName)?.send(taskId);
  }

  Future<CheckUpdateInfo> checkForUpdate({bool autoInstall = false}) async {
    if (!Platform.isAndroid) return CheckUpdateInfo.error();
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      final response = await Requests.get(
        '$apiHost/v2/timetable/updates/is-available',
        queryParameters: {
          'platform': 'android',
          'version': packageInfo.version,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> jsonData = response.json();
        return CheckUpdateInfo(
          jsonData['isUpdateAvailable'] ? CheckUpdateStatus.newVersion : CheckUpdateStatus.sameVersion,
          jsonData['latestVersion'],
        );
      }
    } on SocketException {
      return CheckUpdateInfo.socketError();
    } catch (e) {
      return CheckUpdateInfo.error();
    }

    return CheckUpdateInfo.error();
  }

  Future<bool> checkForUpdateAndShowRequest(BuildContext context) async {
    if (!Platform.isAndroid) return false;
    return await checkForUpdate().then<bool>((updateInfo) {
      if (updateInfo.status == CheckUpdateStatus.newVersion) {
        UpdateRequestBottomSheet.show(context, newVersion: updateInfo.latestVersion);
        return true;
      }
      return false;
    });
  }

  Future<bool> updateToLatestVersion() async {
    if (!Platform.isAndroid) return false;
    try {
      final response = await Requests.get(
        '$apiHost/v2/timetable/updates/latest',
        queryParameters: {
          'platform': 'android',
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        Map<String, dynamic> jsonData = response.json();
        update(url: jsonData['url'], fileName: jsonData['fileName']);
        return true;
      }
    } on SocketException {
      return false;
    } catch (e) {
      return false;
    }

    return false;
  }

  Future<void> update({required String url, required String fileName}) async {
    if (!Platform.isAndroid) return;
    final cacheDirectories = await getExternalCacheDirectories();
    if (cacheDirectories == null || cacheDirectories.isEmpty) return;

    final directory = cacheDirectories.first;

    try {
      await File('${directory.path}/$fileName').delete();
    } catch (e) {
      null;
    }

    // directory.listSync().forEach((file) => file.deleteSync(recursive: true));

    if (_task != null) {
      await FlutterDownloader.remove(taskId: _task!.taskId, shouldDeleteContent: true);
    }
    _taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: directory.path,
      fileName: fileName,
      requiresStorageNotLow: false,
    );
  }

  Future<void> cancel() async {
    if (!Platform.isAndroid) return;
    if (_taskId != null) {
      await FlutterDownloader.cancel(taskId: _taskId!);
      await FlutterDownloader.remove(taskId: _taskId!, shouldDeleteContent: true);
      _task = _taskId = null;
    }
  }

  Future<void> retry() async {
    if (!Platform.isAndroid) return;
    if (_task?.status == DownloadTaskStatus.failed) {
      _taskId = await FlutterDownloader.retry(taskId: task!.taskId);
    }
  }

  Future<void> install() async {
    if (!Platform.isAndroid) return;
    if (_task?.status == DownloadTaskStatus.complete) {
      await FlutterDownloader.open(taskId: task!.taskId);
    }
  }
}
