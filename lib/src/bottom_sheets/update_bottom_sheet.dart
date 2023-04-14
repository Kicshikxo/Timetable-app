// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:timetable/src/providers/update_provider.dart';

class UpdateBottomSheet {
  static bool _isShown = false;
  static bool get isShown => _isShown;

  static Future<void> show(BuildContext context, {VoidCallback? whenComplete}) async {
    if (_isShown) return;

    _isShown = true;
    await showModalBottomSheet(
      context: context,
      enableDrag: false,
      isDismissible: false,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _UpdateBottomSheet(),
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

class _UpdateBottomSheet extends StatelessWidget {
  const _UpdateBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog<bool>(context: context, builder: (context) => const _ConfirmExitDialog()).then<bool?>((value) {
              if (value == true) {
                context.read<UpdateProvider>().cancel();
              }
              return value;
            }) ??
            false;
      },
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
                  context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.complete
                      ? 'Установите обновление'
                      : context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.failed
                          ? 'Повторите попытку'
                          : 'Пожалуйста, подождите...',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.running
                          ? 'Загрузка обновления...'
                          : context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.complete
                              ? 'Загрузка завершена'
                              : context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.failed
                                  ? 'Ошибка загрузки'
                                  : context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.canceled
                                      ? 'Загрузка отменена'
                                      : context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.paused
                                          ? 'Загрузка на паузе'
                                          : 'Ожидание...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${context.watch<UpdateProvider>().task?.progress.toInt() ?? 0}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                subtitle: FAProgressBar(
                  size: 8,
                  progressColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  animatedDuration: const Duration(milliseconds: 100),
                  currentValue: context.watch<UpdateProvider>().task?.progress.toDouble() ?? 0,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog<bool>(context: context, builder: (context) => const _ConfirmExitDialog()).then((value) {
                        if (value == true) {
                          Navigator.of(context).pop();
                          context.read<UpdateProvider>().cancel();
                        }
                      });
                    },
                    child: Text(
                      'Отменить',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  context.watch<UpdateProvider>().task?.status != DownloadTaskStatus.failed
                      ? TextButton(
                          onPressed: context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.complete
                              ? context.read<UpdateProvider>().install
                              : null,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 100),
                            opacity: context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.complete ? 1 : 0.5,
                            child: Text(
                              'Установить',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : TextButton(
                          onPressed: context.watch<UpdateProvider>().task?.status == DownloadTaskStatus.failed
                              ? context.read<UpdateProvider>().retry
                              : null,
                          child: Text(
                            'Повторить',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
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

class _ConfirmExitDialog extends StatelessWidget {
  const _ConfirmExitDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(top: 20),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Отменить обновление?',
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
