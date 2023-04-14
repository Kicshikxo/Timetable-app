// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  system,
  light,
  dark,
  snow,
  calm,
  random,
}

Map<String, ThemeType> _themeTypes = {
  'system': ThemeType.system,
  'light': ThemeType.light,
  'dark': ThemeType.dark,
  'snow': ThemeType.snow,
  'calm': ThemeType.calm,
  'random': ThemeType.random,
};

class ThemeProvider extends ChangeNotifier {
  static late SharedPreferences _prefs;
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ThemeType? _currentThemeType;
  ThemeType get currentThemeType => _currentThemeType ?? ThemeType.system;

  String get currentThemeName => _themeTypes.keys.firstWhere((key) => _themeTypes[key] == currentThemeType);
  ThemeData get currentTheme => _themes[currentThemeType]!();

  ThemeProvider() {
    String? savedTheme = _prefs.getString('theme') ?? 'system';
    setThemeByName(savedTheme);
  }

  late final Map<ThemeType, ThemeData Function()> _themes = {
    ThemeType.system: () => SchedulerBinding.instance.window.platformBrightness == Brightness.dark ? darkTheme : lightTheme,
    ThemeType.light: () => lightTheme,
    ThemeType.dark: () => darkTheme,
    ThemeType.snow: () => snowTheme,
    ThemeType.calm: () => calmTheme,
    ThemeType.random: () => randomTheme,
  };

  void setThemeByName(String themeName) {
    setTheme(_themeTypes[themeName] ?? currentThemeType);
  }

  void setTheme(ThemeType themeType) {
    _currentThemeType = themeType;
    _prefs.setString('theme', currentThemeName);
    notifyListeners();
  }

  final ThemeData _defaultTheme = ThemeData(
    fontFamily: 'Rubik',
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.standard,
    splashFactory: InkRipple.splashFactory,
    textTheme: const TextTheme(
      headline1: TextStyle(fontWeight: FontWeight.bold),
      headline2: TextStyle(fontWeight: FontWeight.bold),
      headline4: TextStyle(fontWeight: FontWeight.bold),
      headline5: TextStyle(fontWeight: FontWeight.bold),
      headline6: TextStyle(fontWeight: FontWeight.bold),
      subtitle1: TextStyle(fontWeight: FontWeight.bold),
      bodyText1: TextStyle(fontWeight: FontWeight.bold),
      bodyText2: TextStyle(fontWeight: FontWeight.bold),
      subtitle2: TextStyle(fontWeight: FontWeight.bold),
      overline: TextStyle(fontWeight: FontWeight.bold),
    ),
  );

  late final ThemeData lightTheme = _defaultTheme.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      //
      primary: Colors.blue,
      secondary: Color(0xFF1F2021),
      surface: Color(0xFFFAFAFA),
      background: Colors.blue,
      //
      onPrimary: Color(0xFF1F2021),
      onSecondary: Color(0xFF1F2021),
      onSurface: Color(0xFF1F2021),
      onBackground: Color(0xFFF9F9F9),
      //
      error: Color(0xFFE33036),
      onError: Color(0xFF1F2021),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFFAFAFA),
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
      ),
    ),
    splashColor: const Color(0xFF1F2021).withOpacity(0.125),
    highlightColor: const Color(0xFF1F2021).withOpacity(0.075),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(const Color(0xFF1F2021).withOpacity(0.125)),
      ),
    ),
  );

  late final ThemeData darkTheme = _defaultTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      //
      primary: Color(0xFF8D61BB),
      secondary: Color(0xFF8D61BB),
      surface: Color(0xFF261D32),
      background: Color(0xFF1A1126),

      // secondary: Color(0xFFF9F9F9),
      // surface: Color(0xFF1C1C1C),
      // background: Color(0xFF121212),

      onPrimary: Color(0xFFE6D9F5),
      onSecondary: Color(0xFFE6D9F5),
      onSurface: Color(0xFFE6D9F5),
      onBackground: Color(0xFFE6D9F5),
      //
      error: Color(0xFFE33036),
      onError: Color(0xFFF9F9F9),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF261D32),
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
      ),
    ),
    splashColor: const Color(0xFF8D61BB).withOpacity(0.125),
    highlightColor: const Color(0xFF8D61BB).withOpacity(0.075),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(const Color(0xFF8D61BB).withOpacity(0.125)),
      ),
    ),
  );

  late final ThemeData snowTheme = _defaultTheme.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      //
      primary: Color(0xFF52616B),
      secondary: Color(0xFF52616B),
      surface: Color(0xFFF0F5F9),
      background: Color(0xFFC9D6DF),
      //
      onPrimary: Color(0xFF1E2022),
      onSecondary: Color(0xFF1E2022),
      onSurface: Color(0xFF1E2022),
      onBackground: Color(0xFFF0F5F9),
      //
      error: Color(0xFFE33036),
      onError: Color(0xFF1F2021),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF0F5F9),
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
      ),
    ),
    splashColor: const Color(0xFF52616B).withOpacity(0.125),
    highlightColor: const Color(0xFF52616B).withOpacity(0.075),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(const Color(0xFF52616B).withOpacity(0.125)),
      ),
    ),
  );

  late final ThemeData calmTheme = _defaultTheme.copyWith(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      //
      primary: Color(0xFF57837B),
      secondary: Color(0xFF57837B),
      surface: Color(0xFFF1ECC3),
      background: Color(0xFFC9D8B6),
      //
      onPrimary: Color(0xFF515E63),
      onSecondary: Color(0xFF515E63),
      onSurface: Color(0xFF515E63),
      onBackground: Color(0xFF515E63),
      //
      error: Color(0xFFE33036),
      onError: Color(0xFF1F2021),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF1ECC3),
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
      ),
    ),
    splashColor: const Color(0xFF57837B).withOpacity(0.125),
    highlightColor: const Color(0xFF57837B).withOpacity(0.075),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(const Color(0xFF57837B).withOpacity(0.125)),
      ),
    ),
  );

  List<Color> randomColors = [
    const Color(0xFFEA047E),
    const Color(0xFFFF6D28),
    const Color(0xFFFCE700),
    const Color(0xFF00F5FF),
    const Color(0xFF38E54D),
    const Color(0xFF293462),
    const Color(0xFFF637EC),
    const Color(0xFF2E0249),
    const Color(0xFFF6F54D),
    const Color(0xFF000000),
    const Color(0xFFEEEEEE),
    const Color(0xFFFF6363),
    const Color(0xFF06FF00),
    const Color(0xFFFF5DA2),
    const Color(0xFF000D6B),
    const Color(0xFFFF95C5),
    const Color(0xFFC2FFD9),
    const Color(0xFFC400FF),
    const Color(0xFFF7FD04),
    const Color(0xFFF5F7B2),
    const Color(0xFF480032),
    const Color(0xFFC67ACE),
    const Color(0xFFDDFFBC),
    const Color(0xFF52734D),
    const Color(0xFF1C1427),
    const Color(0xFFFFE3FE),
    const Color(0xFF440A67),
    const Color(0xFF26001B),
    const Color(0xFF8C0000),
    const Color(0xFF252525),
    const Color(0xFF80FFDB),
    const Color(0xFFFF577F),
    const Color(0xFFFDB827),
    const Color(0xFF21209C),
    const Color(0xFFFFD369),
    const Color(0xFF3797A4),
    const Color(0xFF52057B),
    const Color(0xFFF6F7D4),
    const Color(0xFFEFF48E),
    const Color(0xFF3E978B),
    const Color(0xFF213E3B),
    const Color(0xFFFA26A0),
    const Color(0xFFFFC1F3),
    const Color(0xFFF9F7D9),
    const Color(0xFFC4FB6D),
    const Color(0xFFE71414),
    const Color(0xFF393E46),
    const Color(0xFFB6EB7A),
    const Color(0xFFFB7813),
    const Color(0xFF17706E),
    const Color(0xFFF35588),
    const Color(0xFF100303),
    const Color(0xFF9818D6),
    const Color(0xFF2C7873),
    const Color(0xFFF5DEA3),
    const Color(0xFF272121),
    const Color(0xFFFF0000),
    const Color(0xFF08FFC8),
    const Color(0xFFA32F80),
    const Color(0xFFFF0000),
    const Color(0xFFFF00C8),
    const Color(0xFF27AA80),
  ]..shuffle();

  late final ThemeData randomTheme = _defaultTheme.copyWith(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      //
      primary: randomColors[0],
      secondary: randomColors[1],
      surface: randomColors[2],
      background: randomColors[3],
      //
      onPrimary: randomColors[3],
      onSecondary: randomColors[2],
      onSurface: randomColors[1],
      onBackground: randomColors[0],
      //
      error: const Color(0xFFE33036),
      onError: const Color(0xFFF9F9F9),
    ),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarColor: randomColors[2],
        systemStatusBarContrastEnforced: true,
        systemNavigationBarContrastEnforced: true,
      ),
    ),
    splashColor: randomColors[0].withOpacity(0.125),
    highlightColor: randomColors[0].withOpacity(0.075),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(randomColors[0].withOpacity(0.125)),
      ),
    ),
  );
}
