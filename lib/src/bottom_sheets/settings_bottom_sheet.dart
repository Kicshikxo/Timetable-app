// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:timetable/src/providers/auth_provider.dart';
import 'package:timetable/src/providers/settings_provider.dart';
import 'package:timetable/src/providers/theme_provider.dart';
import 'package:timetable/src/providers/timetable_provider.dart';
import 'package:timetable/src/providers/update_provider.dart';

class SettingsBottomSheet {
  static bool _isShown = false;
  static bool get isShown => _isShown;

  static Future<void> show(BuildContext context, {VoidCallback? whenComplete}) async {
    if (_isShown) return;
    _isShown = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SettingsBottomSheet(),
    ).whenComplete(() {
      if (whenComplete != null) whenComplete();
    });
    _isShown = false;
  }

  static void close(BuildContext context) {
    Navigator.of(context).maybePop();
    _isShown = false;
  }

  static Future<void> toggle(BuildContext context, {VoidCallback? whenComplete}) async {
    if (_isShown) {
      close(context);
    } else {
      show(context, whenComplete: whenComplete);
    }
  }
}

class _SettingsBottomSheet extends StatelessWidget {
  const _SettingsBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        elevation: 4,
        child: Wrap(
          children: [
            if (context.watch<AuthProvider>().authInfo.isAuthenticated) const _AuthInfoListTile(),
            if (context.watch<AuthProvider>().authInfo.isAuthenticated) const _ListTileDivider(),
            if (context.watch<AuthProvider>().authInfo.isAuthenticated && context.watch<AuthProvider>().authInfo.isAdmin)
              const _OpenControlPageListTile(),
            const _ConfigurationListTile(),
            const _ThemeChoiceListTile(),
            if (context.watch<AuthProvider>().authInfo.isAuthenticated) const _ExitListTile(),
          ],
        ),
      ),
    );
  }
}

class _AuthInfoListTile extends StatelessWidget {
  const _AuthInfoListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsListTile(
      leadingIcon: const Icon(Icons.person_rounded),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            children: [
              const TextSpan(text: 'Вы '),
              TextSpan(
                text: context.read<AuthProvider>().authInfo.isAdmin ? 'админ' : 'участник',
                style: TextStyle(
                  color: context.read<AuthProvider>().authInfo.isAdmin
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              const TextSpan(text: ' группы '),
              TextSpan(
                text: context.read<AuthProvider>().authInfo.groupName,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }
}

class _OpenControlPageListTile extends StatelessWidget {
  const _OpenControlPageListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsListTile(
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('/test');
      },
      leadingIcon: const Icon(Icons.edit_rounded),
      titleText: 'Перейти в управление',
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ConfigurationListTile extends StatelessWidget {
  const _ConfigurationListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsListTile(
      onTap: () => showDialog(
        context: context,
        builder: (context) => const _ConfigurationDialog(),
      ),
      leadingIcon: const Icon(Icons.tune),
      titleText: 'Настройки приложения',
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ConfigurationDialog extends StatelessWidget {
  const _ConfigurationDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      contentPadding: const EdgeInsets.only(top: 20),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Настройки',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ListTileDivider(),
          _SettingsExpansionTile(
            leadingIcon: const Icon(Icons.app_settings_alt_rounded),
            titleText: 'Общие настройки',
            children: [
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.openCurrentDayAtLaunch,
                onChanged: (value) {
                  context.read<SettingsProvider>().settings.openCurrentDayAtLaunch = value;
                },
                leadingIcon: const Icon(Icons.flash_on_rounded),
                titleText: 'Быстрый старт',
              ),
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.daysScrolling,
                onChanged: (value) {
                  context.read<SettingsProvider>().settings.daysScrolling = value;
                },
                leadingIcon: const Icon(Icons.swipe_rounded),
                titleText: 'Прокрутка дней',
              ),
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.enableHeavyAnimations,
                onChanged: (value) => context.read<SettingsProvider>().settings.enableHeavyAnimations = value,
                leadingIcon: const Icon(Icons.animation_rounded),
                titleText: 'Тяжёлые',
                subtitleText: 'анимации',
              )
            ],
          ),
          _SettingsExpansionTile(
            leadingIcon: const Icon(Icons.access_time_rounded),
            titleText: 'Индикаторы прогресса',
            children: [
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.showProgressIndicator,
                onChanged: (value) {
                  context.read<SettingsProvider>().settings.showProgressIndicator = value;
                },
                leadingIcon: const Icon(Icons.visibility_rounded),
                titleText: 'Отображать',
                subtitleText: 'прогресс дня',
              ),
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.highlightCurrentLesson,
                onChanged: (value) {
                  context.read<SettingsProvider>().settings.highlightCurrentLesson = value;
                },
                leadingIcon: const Icon(Icons.lightbulb_outline_rounded),
                titleText: 'Выделять',
                subtitleText: 'текущий урок',
              ),
              _SettingsSwitchListTile(
                value: context.watch<SettingsProvider>().settings.darkenCompletedLessons,
                onChanged: (value) {
                  context.read<SettingsProvider>().settings.darkenCompletedLessons = value;
                },
                leadingIcon: const Icon(Icons.opacity_rounded),
                titleText: 'Затемнять',
                subtitleText: 'прошедшие уроки',
              )
            ],
          ),
          if (Platform.isAndroid)
            _SettingsExpansionTile(
              leadingIcon: const Icon(Icons.download_rounded),
              titleText: 'Обновления',
              children: [
                _SettingsSwitchListTile(
                  value: context.watch<SettingsProvider>().settings.checkForUpdates,
                  onChanged: (value) {
                    context.read<SettingsProvider>().settings.checkForUpdates = value;
                  },
                  leadingIcon: const Icon(Icons.security_update_warning_rounded),
                  titleText: 'Проверять',
                  subtitleText: 'автоматически',
                ),
                _SettingsListTile(
                  onTap: () => context.read<UpdateProvider>().checkForUpdateAndShowRequest(context).then((isSuccess) {
                    if (!isSuccess) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          contentPadding: const EdgeInsets.only(top: 20),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          title: Text(
                            'Обновления не найдены',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Ок',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
                  leadingIcon: const Icon(Icons.refresh_rounded),
                  titleText: 'Проверить',
                  subtitleText: 'наличие обновлений',
                ),
              ],
            ),
          _SettingsListTile(
            onTap: () async {
              PackageInfo packageInfo = await PackageInfo.fromPlatform();
              showDialog(
                context: context,
                builder: (context) => _AboutDialog(packageInfo: packageInfo),
              );
            },
            leadingIcon: const Icon(Icons.info_outline_rounded),
            titleText: 'О приложении',
          )
        ],
      ),
    );
  }
}

class _AboutDialog extends StatelessWidget {
  const _AboutDialog({
    Key? key,
    required this.packageInfo,
  }) : super(key: key);

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.symmetric(vertical: 12),
      contentPadding: EdgeInsets.zero,
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: ListTile(
        leading: const Image(
          image: AssetImage('assets/icon.png'),
        ),
        minLeadingWidth: 0,
        title: Text(
          packageInfo.appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        subtitle: Text(
          '${packageInfo.version}\nCopyright © Kicshikxo, ${DateTime.now().year}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ListTileDivider(),
          const SizedBox(
            height: 12,
          ),
          _SettingsListTile(
            leading: Transform.scale(
              scale: 1.5,
              child: Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            titleText: 'Приложение для получения и редактирования расписания занятий учащихся КТС',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Закрыть',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeChoiceListTile extends StatelessWidget {
  const _ThemeChoiceListTile({Key? key}) : super(key: key);

  static Map<String, String> themesTranscription = {
    'system': 'Как на устройстве',
    'light': 'Светлая',
    'dark': 'Тёмная',
    'snow': 'Снежная',
    'calm': 'Спокойная',
    'random': 'Случайная',
  };

  @override
  Widget build(BuildContext context) {
    return _SettingsListTile(
      onTap: () => showDialog(
        context: context,
        builder: (context) => const _ThemeChoiceDialog(),
      ),
      leadingIcon: const Icon(Icons.color_lens_rounded),
      titleText: 'Текущая тема',
      subtitleText: themesTranscription[context.watch<ThemeProvider>().currentThemeName] ?? 'Неизвестна',
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _ThemeChoiceDialog extends StatelessWidget {
  const _ThemeChoiceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 20),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: GestureDetector(
        onLongPress: () => context.read<ThemeProvider>().setThemeByName('random'),
        child: Text(
          'Выберите тему',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ListTileDivider(),
          _SettingsListTile(
            onTap: () => context.read<ThemeProvider>().setThemeByName('system'),
            leadingIcon: const Icon(Icons.devices_rounded),
            titleText: 'Как на устройстве',
            trailing: context.watch<ThemeProvider>().currentThemeName == 'system' ? const Icon(Icons.check) : null,
          ),
          _SettingsListTile(
            onTap: () => context.read<ThemeProvider>().setThemeByName('dark'),
            leadingIcon: const Icon(Icons.dark_mode_rounded),
            titleText: 'Тёмная тема',
            trailing: context.watch<ThemeProvider>().currentThemeName == 'dark' ? const Icon(Icons.check) : null,
          ),
          _SettingsListTile(
            onTap: () => context.read<ThemeProvider>().setThemeByName('light'),
            leadingIcon: const Icon(Icons.light_mode_rounded),
            titleText: 'Светлая тема',
            trailing: context.watch<ThemeProvider>().currentThemeName == 'light' ? const Icon(Icons.check) : null,
          ),
          _SettingsListTile(
            onTap: () => context.read<ThemeProvider>().setThemeByName('snow'),
            leadingIcon: const Icon(Icons.ac_unit_rounded),
            titleText: 'Снежная тема',
            trailing: context.watch<ThemeProvider>().currentThemeName == 'snow' ? const Icon(Icons.check) : null,
          ),
          _SettingsListTile(
            onTap: () => context.read<ThemeProvider>().setThemeByName('calm'),
            leadingIcon: const Icon(Icons.grass_rounded),
            titleText: 'Спокойная тема',
            trailing: context.watch<ThemeProvider>().currentThemeName == 'calm' ? const Icon(Icons.check) : null,
          )
        ],
      ),
    );
  }
}

class _ExitListTile extends StatelessWidget {
  const _ExitListTile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _SettingsListTile(
      onTap: () {
        showDialog<bool>(context: context, builder: (context) => const _ConfirmExitDialog()).then((value) {
          if (value == true) {
            context.read<AuthProvider>().logout();
            context.read<TimetableProvider>().clearWeeks();
            Navigator.of(context).pop();
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        });
      },
      leadingIcon: Icon(
        Icons.logout_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(
        'Выйти',
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ConfirmExitDialog extends StatelessWidget {
  const _ConfirmExitDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 20),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Выйти из группы?',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      // content: const _ListTileDivider(),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Нет',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            'Да',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  const _SettingsListTile({
    Key? key,
    this.onTap,
    this.leading,
    this.leadingIcon,
    this.title,
    this.titleText,
    this.subtitleText,
    this.trailing,
    this.contentPadding,
  }) : super(key: key);

  final VoidCallback? onTap;
  final Widget? leading;
  final Icon? leadingIcon;
  final Widget? title;
  final String? titleText;
  final String? subtitleText;
  final Widget? trailing;
  final EdgeInsets? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minLeadingWidth: 0,
      iconColor: Theme.of(context).colorScheme.onSurface,
      leading: SizedBox(
        height: double.infinity,
        child: leading ?? leadingIcon,
      ),
      title: title ??
          Text(
            titleText ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText ?? '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      trailing: trailing,
      contentPadding: contentPadding,
    );
  }
}

class _SettingsSwitchListTile extends StatelessWidget {
  const _SettingsSwitchListTile({
    Key? key,
    required this.value,
    required this.onChanged,
    this.leadingIcon,
    this.titleText = '',
    this.subtitleText,
  }) : super(key: key);

  final bool value;
  final void Function(bool) onChanged;
  final Icon? leadingIcon;
  final String? titleText;
  final String? subtitleText;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: SizedBox(
        height: double.infinity,
        child: leadingIcon != null
            ? Icon(
                leadingIcon!.icon,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : null,
      ),
      title: Transform(
        transform: Matrix4.translationValues(-16, 0, 0),
        child: Text(
          titleText ?? '',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: subtitleText != null
          ? Transform(
              transform: Matrix4.translationValues(-16, 0, 0),
              child: Text(
                subtitleText ?? '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      activeColor: Theme.of(context).colorScheme.primary,
      inactiveThumbColor: Theme.of(context).colorScheme.surface,
    );
  }
}

class _SettingsExpansionTile extends StatelessWidget {
  const _SettingsExpansionTile({
    Key? key,
    this.leadingIcon,
    this.titleText,
    required this.children,
  }) : super(key: key);

  final Icon? leadingIcon;
  final String? titleText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
      child: ExpansionTile(
        iconColor: Theme.of(context).colorScheme.onSurface,
        collapsedIconColor: Theme.of(context).colorScheme.onSurface,
        leading: leadingIcon != null
            ? Icon(
                leadingIcon!.icon,
                color: Theme.of(context).colorScheme.onSurface,
              )
            : null,
        title: Transform(
          transform: Matrix4.translationValues(-16, 0, 0),
          child: Text(
            titleText ?? '',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: children,
      ),
    );
  }
}

class _ListTileDivider extends StatelessWidget {
  const _ListTileDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
    );
  }
}
