// Dart imports:
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
// Package imports:
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
// Project imports:
import 'package:timetable/src/bottom_sheets/settings_bottom_sheet.dart';
import 'package:timetable/src/pages/login_page.dart';
import 'package:timetable/src/pages/test_page.dart';
import 'package:timetable/src/pages/timetable_page.dart';
import 'package:timetable/src/providers/auth_provider.dart';
import 'package:timetable/src/providers/settings_provider.dart';
import 'package:timetable/src/providers/theme_provider.dart';
import 'package:timetable/src/providers/update_provider.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final Map<String, WidgetBuilder> _routes = {
    '/login': (BuildContext context) => const LoginPage(),
    '/timetable': (BuildContext context) => const TimetablePage(),
    '/test': (BuildContext context) => const TestPage(),
  };

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расписание КТС',
      debugShowCheckedModeBanner: false,
      theme: context.watch<ThemeProvider>().currentTheme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
        overscroll: false,
      ),
      home: ResponsiveSizer(
        builder: (context, orientation, screenType) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).appBarTheme.systemOverlayStyle!,
            child: Column(
              children: [
                Expanded(
                  child: WillPopScope(
                    onWillPop: () async {
                      return !await _navigatorKey.currentState!.maybePop();
                    },
                    child: Navigator(
                      key: _navigatorKey,
                      onGenerateInitialRoutes: (navigator, initialRoute) => [
                        SwipeablePageRoute(
                          canSwipe: false,
                          builder: _routes[context.read<AuthProvider>().authInfo.isAuthenticated ? '/timetable' : '/login']!,
                        ),
                      ],
                      onGenerateRoute: (RouteSettings settings) => SwipeablePageRoute(
                        builder: _routes[settings.name]!,
                        settings: settings,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: context.watch<AuthProvider>().authInfo.isAuthenticated ? 56 : 0,
                  child: context.watch<AuthProvider>().authInfo.isAuthenticated
                      ? SingleChildScrollView(
                          child: Theme(
                            data: Theme.of(context).copyWith(highlightColor: Colors.transparent),
                            child: BottomNavigationBar(
                              elevation: 0,
                              type: BottomNavigationBarType.fixed,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              selectedItemColor: Theme.of(context).colorScheme.onSurface,
                              unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              selectedLabelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                fontWeight: FontWeight.bold,
                              ),
                              currentIndex: SettingsBottomSheet.isShown ? 1 : 0,
                              onTap: (index) async {
                                if (index == 0 && SettingsBottomSheet.isShown) {
                                  SettingsBottomSheet.close(context);
                                }
                                if (index == 1) {
                                  setState(() {});
                                  await SettingsBottomSheet.toggle(
                                    _navigatorKey.currentContext!,
                                    whenComplete: () => setState(() {}),
                                  );
                                }
                              },
                              items: const [
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.calendar_month_outlined),
                                  label: 'Расписание',
                                  tooltip: '',
                                ),
                                BottomNavigationBarItem(
                                  icon: Icon(Icons.settings_rounded),
                                  label: 'Настройки',
                                  tooltip: '',
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container(color: Theme.of(context).colorScheme.surface),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    if (context.read<ThemeProvider>().currentThemeType == ThemeType.system && mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();

    _checkLogin();

    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        if (context.read<SettingsProvider>().settings.checkForUpdates) {
          context.read<UpdateProvider>().checkForUpdateAndShowRequest(_navigatorKey.currentContext!);
        }
      },
    );

    WidgetsBinding.instance.addObserver(this);
  }

  void _checkLogin() async {
    if (context.read<AuthProvider>().authInfo.isAuthenticated || context.read<AuthProvider>().authInfo.authToken.isNotEmpty) {
      LoginStatus loginStatus = await context.read<AuthProvider>().checkLogin();
      if (loginStatus == LoginStatus.unauthorized) {
        if (mounted) {
          context.read<AuthProvider>().logout();
          _navigatorKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    }
  }
}
