// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:provider/provider.dart';
// Project imports:
import 'package:timetable/src/app.dart';
import 'package:timetable/src/providers/auth_provider.dart';
import 'package:timetable/src/providers/messanger_provider.dart';
import 'package:timetable/src/providers/settings_provider.dart';
import 'package:timetable/src/providers/theme_provider.dart';
import 'package:timetable/src/providers/timetable_provider.dart';
import 'package:timetable/src/providers/update_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TimetableProvider.initialize();
  await SettingsProvider.initialize();
  await UpdateProvider.initialize();
  await ThemeProvider.initialize();
  await AuthProvider.initialize();

  ByteData data = await PlatformAssetBundle().load('assets/ca/lets-encrypt-r3.pem');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MessangerProvider()),
        ChangeNotifierProvider(create: (context) => TimetableProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => UpdateProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: const App(),
    ),
  );
}
