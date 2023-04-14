// Dart imports:
import 'dart:io';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:timetable/src/bottom_sheets/update_bottom_sheet.dart';
import 'package:timetable/src/providers/update_provider.dart';

class UpdateRequestBottomSheet {
  static bool _isShown = false;
  static bool get isShown => _isShown;

  static Future<void> show(BuildContext context, {String? newVersion, VoidCallback? whenComplete}) async {
    if (_isShown) return;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    _isShown = true;
    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UpdateRequestBottomSheet(
        currentVersion: packageInfo.version,
        newVersion: newVersion,
      ),
    ).whenComplete(() {
      if (whenComplete != null) whenComplete();
    });
    _isShown = false;
  }

  static void close(BuildContext context) {
    Navigator.of(context).maybePop();
    _isShown = false;
  }

  static Future<void> toggle(BuildContext context, {String? newVersion, VoidCallback? whenComplete}) async {
    if (_isShown) {
      close(context);
    } else {
      show(context, newVersion: newVersion, whenComplete: whenComplete);
    }
  }
}

class _UpdateRequestBottomSheet extends StatefulWidget {
  const _UpdateRequestBottomSheet({
    Key? key,
    this.currentVersion,
    this.newVersion,
  }) : super(key: key);

  final String? currentVersion;
  final String? newVersion;

  @override
  State<_UpdateRequestBottomSheet> createState() => _UpdateRequestBottomSheetState();
}

class _UpdateRequestBottomSheetState extends State<_UpdateRequestBottomSheet> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          elevation: 4,
          child: Wrap(
            children: [
              ListTile(
                title: Text(
                  'Доступна новая версия',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              ListTile(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Текущая версия',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.currentVersion.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Новая версия',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.newVersion.toString(),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: !_loading ? () => Navigator.of(context).pop() : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: _loading ? 0.5 : 1,
                      child: Text(
                        'Игнорировать',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: !_loading
                        ? () async {
                            if (Platform.isAndroid &&
                                ((await DeviceInfoPlugin().androidInfo).version.sdkInt >= 29 ||
                                    await Permission.storage.request().isGranted)) {
                              setState(() {
                                _loading = true;
                              });
                              context.read<UpdateProvider>().updateToLatestVersion().then((isSuccess) {
                                if (isSuccess) {
                                  Navigator.of(context).pop();
                                  UpdateBottomSheet.show(context);
                                }
                                setState(() {
                                  _loading = false;
                                });
                              });
                            }
                          }
                        : null,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: _loading ? 0.5 : 1,
                      child: Text(
                        'Обновить сейчас',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
