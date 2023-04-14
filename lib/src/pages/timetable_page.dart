// Dart imports:
import 'dart:async';
import 'dart:math';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:animate_do/animate_do.dart';
import 'package:backdrop/backdrop.dart';
import 'package:collection/collection.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:timetable/src/providers/auth_provider.dart';
import 'package:timetable/src/providers/messanger_provider.dart';
import 'package:timetable/src/providers/settings_provider.dart';
import 'package:timetable/src/providers/timetable_provider.dart';
import 'package:timetable/src/widgets/expanded_single_child_scroll_view.dart';

const Map<int, String> dayIndexToShortName = {
  1: 'ПН',
  2: 'ВТ',
  3: 'СР',
  4: 'ЧТ',
  5: 'ПТ',
  6: 'СБ',
  7: 'ВС',
};

const Map<int, String> dayIndexToName = {
  1: 'Понедельник',
  2: 'Вторник',
  3: 'Среда',
  4: 'Четверг',
  5: 'Пятница',
  6: 'Суббота',
  7: 'Воскресенье'
};

const Map<int, String> monthIndexToNominativeName = {
  1: 'Январь',
  2: 'Февраль',
  3: 'Март',
  4: 'Апрель',
  5: 'Май',
  6: 'Июнь',
  7: 'Июль',
  8: 'Август',
  9: 'Сентябрь',
  10: 'Октябрь',
  11: 'Ноябрь',
  12: 'Декабрь',
};

const Map<int, String> monthIndexToGenitiveName = {
  1: 'Января',
  2: 'Февраля',
  3: 'Марта',
  4: 'Апреля',
  5: 'Мая',
  6: 'Июня',
  7: 'Июля',
  8: 'Августа',
  9: 'Сентября',
  10: 'Октября',
  11: 'Ноября',
  12: 'Декабря',
};

const List<Map<String, String>> lessonsTime = [
  {'start': '7:40', 'end': '8:25'},
  {'start': '8:30', 'end': '9:10'},
  {'start': '9:20', 'end': '10:00'},
  {'start': '10:05', 'end': '10:45'},
  {'start': '10:50', 'end': '11:30'},
  {'start': '11:35', 'end': '12:15'},
  {'start': '12:20', 'end': '13:00'},
  {'start': '13:05', 'end': '13:45'},
  {'start': '13:50', 'end': '14:30'},
  {'start': '14:35', 'end': '15:15'},
  {'start': '15:20', 'end': '16:00'},
  {'start': '16:05', 'end': '16:45'},
  {'start': '16:50', 'end': '17:30'},
  {'start': '17:35', 'end': '18:15'},
  {'start': '18:20', 'end': '19:00'},
];

const List<Map<String, Duration>> lessonsDuration = [
  {'start': Duration(hours: 7, minutes: 40), 'end': Duration(hours: 8, minutes: 15), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 8, minutes: 30), 'end': Duration(hours: 9, minutes: 10), 'break': Duration(minutes: 10)},
  {'start': Duration(hours: 9, minutes: 20), 'end': Duration(hours: 10, minutes: 0), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 10, minutes: 5), 'end': Duration(hours: 10, minutes: 45), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 10, minutes: 50), 'end': Duration(hours: 11, minutes: 30), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 11, minutes: 35), 'end': Duration(hours: 12, minutes: 15), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 12, minutes: 20), 'end': Duration(hours: 13, minutes: 0), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 13, minutes: 05), 'end': Duration(hours: 13, minutes: 45), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 13, minutes: 50), 'end': Duration(hours: 14, minutes: 30), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 14, minutes: 35), 'end': Duration(hours: 15, minutes: 15), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 15, minutes: 20), 'end': Duration(hours: 16, minutes: 0), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 16, minutes: 05), 'end': Duration(hours: 16, minutes: 45), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 16, minutes: 50), 'end': Duration(hours: 17, minutes: 30), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 17, minutes: 35), 'end': Duration(hours: 18, minutes: 15), 'break': Duration(minutes: 5)},
  {'start': Duration(hours: 18, minutes: 20), 'end': Duration(hours: 19, minutes: 0), 'break': Duration(minutes: 5)},
];

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  @override
  void initState() {
    super.initState();

    _invalidateWeeks();

    if (context.read<SettingsProvider>().settings.openCurrentDayAtLaunch) {
      final currentWeekId = context.read<TimetableProvider>().currentWeekId;
      _selectedWeekId = context.read<TimetableProvider>().weeks.firstWhereOrNull((week) => week.id == currentWeekId)?.id;
    }
  }

  void _invalidateWeeks() {
    context.read<TimetableProvider>().fetchWeeks(authToken: context.read<AuthProvider>().authInfo.authToken).then(
      (success) {
        if (success && _selectedWeekId == null && context.read<SettingsProvider>().settings.openCurrentDayAtLaunch) {
          setState(() {
            final currentWeekId = context.read<TimetableProvider>().currentWeekId;
            _selectedWeekId = context.read<TimetableProvider>().weeks.firstWhereOrNull((week) => week.id == currentWeekId)?.id;
            _frontLayerKey = UniqueKey();
          });
          Backdrop.of(_backdropScaffold.currentContext!).concealBackLayer();
        } else if (!success) {
          context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных', bottomMargin: 64);
        }
      },
    );
  }

  String? _selectedWeekId;
  Week? get selectedWeek => _selectedWeekId != null
      ? context.watch<TimetableProvider>().weeks.firstWhereOrNull((week) => week.id == _selectedWeekId)
      : null;

  final _backdropScaffold = GlobalKey<ScaffoldState>();

  UniqueKey _frontLayerKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedWeekId == null && Backdrop.of(_backdropScaffold.currentContext!).isBackLayerRevealed) {
          SystemNavigator.pop();
        }
        return true;
      },
      child: BackdropScaffold(
        scaffoldKey: _backdropScaffold,
        revealBackLayerAtStart: selectedWeek == null,
        appBar: BackdropAppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
          title: Builder(builder: (context) {
            if (selectedWeek != null && Backdrop.of(context).isBackLayerConcealed) {
              final firstDayDate = selectedWeek!.days.first.date;
              final lastDayDate = selectedWeek!.days.last.date;
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${firstDayDate.day} — ${lastDayDate.day} ${firstDayDate.month == lastDayDate.month ? monthIndexToNominativeName[firstDayDate.month] : '${monthIndexToNominativeName[firstDayDate.month]} — ${monthIndexToNominativeName[lastDayDate.month]}'} ${firstDayDate.year}',
                ),
              );
            } else {
              return const Text('Список недель');
            }
          }),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: selectedWeek != null
              ? Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: Colors.transparent,
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: Backdrop.of(context).fling,
                        child: Center(
                          child: AnimatedIcon(
                            icon: AnimatedIcons.close_menu,
                            color: Theme.of(context).colorScheme.onBackground,
                            progress: Backdrop.of(context).animationController,
                          ),
                        ),
                      ),
                    ),
                  );
                })
              : null,
        ),
        onBackLayerRevealed: (() {
          setState(() {});
        }),
        onBackLayerConcealed: () {
          setState(() {});
          if (_selectedWeekId == null ||
              // context.read<TimetableProvider>().weeks.firstWhereOrNull((week) => week.id == _selectedWeekId) == null ||
              context.read<TimetableProvider>().weeks.isEmpty) {
            Backdrop.of(_backdropScaffold.currentContext!).revealBackLayer();
          }
        },
        headerHeight: 64,
        frontLayerElevation: 8,
        backLayerScrim: Colors.transparent,
        frontLayerScrim: Colors.transparent,
        backLayerBackgroundColor: Theme.of(context).colorScheme.background,
        frontLayerBackgroundColor: Theme.of(context).colorScheme.surface,
        backLayer: Builder(builder: (context) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 64),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale:
                  context.watch<SettingsProvider>().settings.enableHeavyAnimations && Backdrop.of(context).isBackLayerConcealed
                      ? 0.95
                      : 1,
              curve: Curves.ease,
              child: WeeksLayer(
                selectedWeekId: _selectedWeekId,
                onWeekSelected: ((weekId) {
                  setState(() {
                    _selectedWeekId = weekId;
                    _frontLayerKey = UniqueKey();
                  });
                  Backdrop.of(context).concealBackLayer();
                }),
              ),
            ),
          );
        }),
        frontLayer: TimetableLayer(
          key: _frontLayerKey,
          selectedWeek: selectedWeek,
        ),
      ),
    );
  }
}

class WeeksLayer extends StatelessWidget {
  const WeeksLayer({
    super.key,
    required this.onWeekSelected,
    this.selectedWeekId,
  });

  final void Function(String weekId) onWeekSelected;
  final String? selectedWeekId;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TimetableProvider>().fetchWeeks(authToken: context.read<AuthProvider>().authInfo.authToken).then(
        (success) {
          if (!success) {
            context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных', bottomMargin: 64);
          }
        },
      ),
      color: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: context.watch<TimetableProvider>().weeks.isEmpty
          ? ExpandedSingleChildScrollView(
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            )
          : EasyRefresh.builder(
              noMoreLoad: context.watch<TimetableProvider>().hasMoreWeeks,
              onLoad: () => context
                  .read<TimetableProvider>()
                  .getWeeks(authToken: context.read<AuthProvider>().authInfo.authToken)
                  .then<IndicatorResult>(
                    (success) => context.read<TimetableProvider>().hasMoreWeeks
                        ? success
                            ? IndicatorResult.success
                            : IndicatorResult.fail
                        : IndicatorResult.noMore,
                  ),
              footer: ClassicFooter(
                clamping: true,
                infiniteOffset: null,
                hapticFeedback: true,
                triggerOffset: 72,
                triggerWhenReach: true,
                backgroundColor: Theme.of(context).colorScheme.background,
                iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                pullIconBuilder: (context, state, animation) {
                  return Transform.rotate(
                    angle: pi * animation,
                    child: Transform.scale(
                      scale: 1.5,
                      child: const Icon(
                        Icons.keyboard_arrow_up_rounded,
                      ),
                    ),
                  );
                },
                noMoreIcon: const Icon(Icons.done),
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                dragText: 'Потяните, чтобы загрузить больше',
                armedText: 'Отпустите, чтобы загрузить больше',
                readyText: 'Загрузка...',
                processingText: 'Загрузка...',
                processedText: 'Загружено',
                noMoreText: 'Все недели загружены',
                failedText: 'Ошибка',
                showMessage: false,
                progressIndicatorSize: 24,
                progressIndicatorStrokeWidth: 3,
              ),
              childBuilder: (context, physics) {
                final List<Week> weeks = context.read<TimetableProvider>().weeks;
                final String currentWeekId = context.read<TimetableProvider>().currentWeekId;
                final String? firstNextWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == 1)?.id;
                final String? firstLastWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == -1)?.id;

                return AnimationLimiter(
                  child: ListView.builder(
                    physics: physics,
                    itemCount: context.watch<TimetableProvider>().weeks.length,
                    itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        child: FadeInAnimation(
                          child: Builder(builder: (context) {
                            final Week week = context.read<TimetableProvider>().weeks[index];
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((week.id == currentWeekId || week.id == firstLastWeekId || week.id == firstNextWeekId))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    child: Text(
                                      week.id == currentWeekId
                                          ? 'Текущая неделя'
                                          : week.id == firstLastWeekId
                                              ? 'Прошедшие недели'
                                              : 'Предстоящие недели',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                WeekWidget(
                                  isSelected: week.id == selectedWeekId,
                                  days: week.days,
                                  onTap: () {
                                    onWeekSelected(week.id);
                                  },
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                );
              }),
    );

    // return RefreshIndicator(
    //   onRefresh: () async {
    //     final success =
    //         await context.read<TimetableProvider>().fetchWeeks(authToken: context.read<AuthProvider>().authInfo.authToken);
    //     if (!success && mounted) {
    //       context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных', bottomMargin: 64);
    //     }
    //   },
    //   color: Theme.of(context).colorScheme.onSurface,
    //   backgroundColor: Theme.of(context).colorScheme.surface,
    //   child: EasyRefresh(
    //     noMoreLoad: !context.read<TimetableProvider>().hasMoreWeeks,
    //     onLoad: () async =>
    //         await context.read<TimetableProvider>().getWeeks(authToken: context.read<AuthProvider>().authInfo.authToken),
    //     footer: const MaterialFooter(),
    //     child: ExpandedSingleChildScrollView(
    //         child: context.watch<TimetableProvider>().weeks.isEmpty
    //             ? Center(
    //                 child: CircularProgressIndicator(
    //                   color: Theme.of(context).colorScheme.onBackground,
    //                 ),
    //               )
    //             : Builder(builder: (context) {
    //                 List<Week> weeks = context.read<TimetableProvider>().weeks;
    //                 String? firstNextWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == 1)?.id;
    //                 String? firstLastWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == -1)?.id;

    //                 // return AnimationLimiter(
    //                 //   child: PaginatedList(
    //                 //     onLoadMore: (index) async {
    //                 //       final success = await context
    //                 //           .read<TimetableProvider>()
    //                 //           .getWeeks(authToken: context.read<AuthProvider>().authInfo.authToken);
    //                 //       if (!success && mounted) {
    //                 //         context
    //                 //             .read<MessangerProvider>()
    //                 //             .showSnackBar(context: context, text: 'Ошибка загрузки данных', bottomMargin: 64);
    //                 //       }
    //                 //     },
    //                 //     isLastPage: !context.watch<TimetableProvider>().hasMoreWeeks,
    //                 //     shrinkWrap: true,
    //                 //     physics: const NeverScrollableScrollPhysics(),
    //                 //     items: context.watch<TimetableProvider>().weeks,
    //                 //     loadingIndicator: Padding(
    //                 //       padding: const EdgeInsets.only(bottom: 12),
    //                 //       child: ListTile(
    //                 //         title: Center(
    //                 //           child: CircularProgressIndicator(
    //                 //             color: Theme.of(context).colorScheme.onBackground,
    //                 //           ),
    //                 //         ),
    //                 //       ),
    //                 //     ),
    //                 //     builder: (week, index) => AnimationConfiguration.staggeredList(
    //                 //       position: index,
    //                 //       duration: const Duration(milliseconds: 375),
    //                 //       child: SlideAnimation(
    //                 //         child: FadeInAnimation(
    //                 //           child: Builder(builder: (context) {
    //                 //             return Column(
    //                 //               mainAxisAlignment: MainAxisAlignment.center,
    //                 //               crossAxisAlignment: CrossAxisAlignment.start,
    //                 //               children: [
    //                 //                 if ((week.id == currentWeekId || week.id == firstLastWeekId || week.id == firstNextWeekId))
    //                 //                   Padding(
    //                 //                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    //                 //                     child: Text(
    //                 //                       week.id == currentWeekId
    //                 //                           ? 'Текущая неделя'
    //                 //                           : week.id == firstLastWeekId
    //                 //                               ? 'Прошедшие недели'
    //                 //                               : 'Предстоящие недели',
    //                 //                       style: TextStyle(
    //                 //                         color: Theme.of(context).colorScheme.onBackground,
    //                 //                         fontWeight: FontWeight.bold,
    //                 //                         fontSize: 18,
    //                 //                       ),
    //                 //                     ),
    //                 //                   ),
    //                 //                 WeekWidget(
    //                 //                   isSelected: week.id == widget.selectedWeekId,
    //                 //                   days: week.days,
    //                 //                   onTap: () {
    //                 //                     widget.onWeekSelected(week.id);
    //                 //                   },
    //                 //                 ),
    //                 //               ],
    //                 //             );
    //                 //           }),
    //                 //         ),
    //                 //       ),
    //                 //     ),
    //                 //   ),
    //                 // );
    //                 return AnimationLimiter(
    //                   child: ListView.builder(
    //                     shrinkWrap: true,
    //                     physics: const NeverScrollableScrollPhysics(),
    //                     itemCount: context.watch<TimetableProvider>().weeks.length,
    //                     itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
    //                       position: index,
    //                       duration: const Duration(milliseconds: 375),
    //                       child: SlideAnimation(
    //                         child: FadeInAnimation(
    //                           child: Builder(builder: (context) {
    //                             final Week week = context.read<TimetableProvider>().weeks[index];
    //                             return Column(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               children: [
    //                                 if ((week.id == currentWeekId || week.id == firstLastWeekId || week.id == firstNextWeekId))
    //                                   Padding(
    //                                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    //                                     child: Text(
    //                                       week.id == currentWeekId
    //                                           ? 'Текущая неделя'
    //                                           : week.id == firstLastWeekId
    //                                               ? 'Прошедшие недели'
    //                                               : 'Предстоящие недели',
    //                                       style: TextStyle(
    //                                         color: Theme.of(context).colorScheme.onBackground,
    //                                         fontWeight: FontWeight.bold,
    //                                         fontSize: 18,
    //                                       ),
    //                                     ),
    //                                   ),
    //                                 WeekWidget(
    //                                   isSelected: week.id == widget.selectedWeekId,
    //                                   days: week.days,
    //                                   onTap: () {
    //                                     widget.onWeekSelected(week.id);
    //                                   },
    //                                 ),
    //                               ],
    //                             );
    //                           }),
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //                 );
    //                 // return AnimationLimiter(
    //                 //   child: ListView.builder(
    //                 //     shrinkWrap: true,
    //                 //     physics: const NeverScrollableScrollPhysics(),
    //                 //     itemCount: context.watch<TimetableProvider>().weeks.length,
    //                 //     itemBuilder: (context, index) => AnimationConfiguration.staggeredList(
    //                 //       position: index,
    //                 //       duration: const Duration(milliseconds: 375),
    //                 //       child: SlideAnimation(
    //                 //         child: FadeInAnimation(
    //                 //           child: Builder(builder: (context) {
    //                 //             final Week week = context.read<TimetableProvider>().weeks[index];
    //                 //             return Column(
    //                 //               mainAxisAlignment: MainAxisAlignment.center,
    //                 //               crossAxisAlignment: CrossAxisAlignment.start,
    //                 //               children: [
    //                 //                 if ((week.id == currentWeekId || week.id == firstLastWeekId || week.id == firstNextWeekId))
    //                 //                   Padding(
    //                 //                     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    //                 //                     child: Text(
    //                 //                       week.id == currentWeekId
    //                 //                           ? 'Текущая неделя'
    //                 //                           : week.id == firstLastWeekId
    //                 //                               ? 'Прошедшие недели'
    //                 //                               : 'Предстоящие недели',
    //                 //                       style: TextStyle(
    //                 //                         color: Theme.of(context).colorScheme.onBackground,
    //                 //                         fontWeight: FontWeight.bold,
    //                 //                         fontSize: 18,
    //                 //                       ),
    //                 //                     ),
    //                 //                   ),
    //                 //                 WeekWidget(
    //                 //                   isSelected: week.id == widget.selectedWeekId,
    //                 //                   days: week.days,
    //                 //                   onTap: () {
    //                 //                     widget.onWeekSelected(week.id);
    //                 //                   },
    //                 //                 ),
    //                 //               ],
    //                 //             );
    //                 //           }),
    //                 //         ),
    //                 //       ),
    //                 //     ),
    //                 //   ),
    //                 // );
    //               })
    //         // child: ExpandedSingleChildScrollView(
    //         //   child: context.watch<TimetableProvider>().weeks.isEmpty
    //         //       ? Center(
    //         //           child: CircularProgressIndicator(
    //         //             color: Theme.of(context).colorScheme.onBackground,
    //         //           ),
    //         //         )
    //         //       : Builder(builder: (context) {
    //         //           List<Week> weeks = context.read<TimetableProvider>().weeks;
    //         //           String? firstNextWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == 1)?.id;
    //         //           String? firstLastWeekId = weeks.firstWhereOrNull((week) => week.id.compareTo(currentWeekId) == -1)?.id;

    //         //           return LiveList(
    //         //             shrinkWrap: true,
    //         //             physics: const NeverScrollableScrollPhysics(),
    //         //             showItemDuration: const Duration(milliseconds: 375),
    //         //             showItemInterval: const Duration(milliseconds: 375 ~/ 6),
    //         //             itemCount: context.watch<TimetableProvider>().weeks.length,
    //         //             itemBuilder: ((context, index, animation) => FadeTransition(
    //         //                   opacity: Tween<double>(begin: 0, end: 1).animate(
    //         //                     CurvedAnimation(
    //         //                       parent: animation,
    //         //                       curve: const Interval(0, 1, curve: Curves.ease),
    //         //                     ),
    //         //                   ),
    //         //                   child: SlideTransition(
    //         //                     position: Tween<Offset>(begin: const Offset(0, 56 / 50), end: Offset.zero).animate(
    //         //                       CurvedAnimation(
    //         //                         parent: animation,
    //         //                         curve: const Interval(0, 1, curve: Curves.ease),
    //         //                       ),
    //         //                     ),
    //         //                     child: Builder(builder: (context) {
    //         //                       final Week week = context.read<TimetableProvider>().weeks[index];
    //         //                       return Column(
    //         //                         mainAxisAlignment: MainAxisAlignment.center,
    //         //                         crossAxisAlignment: CrossAxisAlignment.start,
    //         //                         children: [
    //         //                           if ((week.id == currentWeekId || week.id == firstLastWeekId || week.id == firstNextWeekId))
    //         //                             Padding(
    //         //                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    //         //                               child: Text(
    //         //                                 week.id == currentWeekId
    //         //                                     ? 'Текущая неделя'
    //         //                                     : week.id == firstLastWeekId
    //         //                                         ? 'Прошедшие недели'
    //         //                                         : 'Предстоящие недели',
    //         //                                 style: TextStyle(
    //         //                                   color: Theme.of(context).colorScheme.onBackground,
    //         //                                   fontWeight: FontWeight.bold,
    //         //                                   fontSize: 18,
    //         //                                 ),
    //         //                               ),
    //         //                             ),
    //         //                           WeekWidget(
    //         //                             isSelected: week.id == widget.selectedWeekId,
    //         //                             days: week.days,
    //         //                             onTap: () {
    //         //                               widget.onWeekSelected(week.id);
    //         //                             },
    //         //                           ),
    //         //                         ],
    //         //                       );
    //         //                     }),
    //         //                   ),
    //         //                 )),
    //         //           );
    //         //         }),
    //         // ),
    //         ),
    //   ),
    // );
  }
}

class WeekWidget extends StatelessWidget {
  const WeekWidget({
    Key? key,
    required this.days,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  final List<Day> days;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final firstDayDate = days.first.date;
    final lastDayDate = days.last.date;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        elevation: 2,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              ListTile(
                title: Row(
                  children: [
                    Text(
                      '${firstDayDate.day} — ${lastDayDate.day} ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${firstDayDate.month == lastDayDate.month ? monthIndexToNominativeName[firstDayDate.month] : '${monthIndexToNominativeName[firstDayDate.month]} — ${monthIndexToNominativeName[lastDayDate.month]}'} ${firstDayDate.year}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: isSelected ? 1 : 0,
                  curve: Curves.ease,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4),
                          bottomLeft: Radius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimetableLayer extends StatefulWidget {
  const TimetableLayer({
    super.key,
    required this.selectedWeek,
  });

  final Week? selectedWeek;

  @override
  State<TimetableLayer> createState() => _TimetableLayerState();
}

class _TimetableLayerState extends State<TimetableLayer> {
  int _selectedDayIndex = 0;
  int get selectedDayIndex =>
      widget.selectedWeek != null && _selectedDayIndex < widget.selectedWeek!.days.length ? _selectedDayIndex : 0;

  Day? get selectedDay => widget.selectedWeek != null ? widget.selectedWeek!.days[selectedDayIndex] : null;

  late final Timer _rebuildTimer;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _rebuildTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      setState(() {});
    });

    if (widget.selectedWeek != null && context.read<SettingsProvider>().settings.openCurrentDayAtLaunch) {
      final DateTime today = DateTime.now();
      for (final day in widget.selectedWeek!.days) {
        if (today.day == day.date.day && today.month == day.date.month && today.year == day.date.year) {
          _selectedDayIndex = widget.selectedWeek!.days.indexOf(day);
          break;
        }
      }
    }

    _pageController = PageController(initialPage: _selectedDayIndex);
  }

  @override
  void dispose() {
    super.dispose();
    _rebuildTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _subheader(context),
        widget.selectedWeek != null ? _timetableView() : Container(),
        widget.selectedWeek != null
            ? Theme(
                data: Theme.of(context).copyWith(highlightColor: Colors.transparent),
                child: _bottomNavigationBar(context),
              )
            : Container(),
      ],
    );
  }

  Widget _subheader(BuildContext context) {
    return SizedBox(
      height: 64,
      child: selectedDay != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${selectedDay!.date.day} ${monthIndexToGenitiveName[selectedDay!.date.month]}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    dayIndexToName[selectedDay!.date.weekday] ?? '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Text(
                'Выберите неделю',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
    );
  }

  Widget _timetableView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        physics: context.watch<SettingsProvider>().settings.daysScrolling
            ? const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics())
            : const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState((() {
            _selectedDayIndex = index;
          }));
        },
        itemCount: widget.selectedWeek!.days.length,
        itemBuilder: (context, dayIndex) => _timetablePage(widget.selectedWeek!.days[dayIndex]),
      ),
    );
  }

  Widget _timetablePage(Day day) {
    return RefreshIndicator(
      onRefresh: () async {
        final success =
            await context.read<TimetableProvider>().fetchWeeks(authToken: context.read<AuthProvider>().authInfo.authToken);
        if (!success && mounted) {
          context.read<MessangerProvider>().showSnackBar(context: context, text: 'Ошибка загрузки данных', bottomMargin: 64);
        }
      },
      color: Theme.of(context).colorScheme.onSurface,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: ExpandedSingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Builder(builder: (context) {
            final lessonIndexes = day.lessons.map((lesson) => lesson.index);
            final int minLessonIndex = lessonIndexes.reduce(min);
            final int maxLessonIndex = lessonIndexes.reduce(max);

            final int dayStartTime = day.date
                .add(lessonsDuration[minLessonIndex.clamp(0, lessonsDuration.length)]['start'] ?? Duration.zero)
                .millisecondsSinceEpoch;
            final int dayEndTime = day.date
                .add(lessonsDuration[maxLessonIndex.clamp(0, lessonsDuration.length)]['end'] ?? Duration.zero)
                .millisecondsSinceEpoch;
            final int todayTime = DateTime.now().millisecondsSinceEpoch;

            return Stack(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: day.lessons.length,
                  itemBuilder: (context, lessonIndex) => Builder(builder: (context) {
                    final int lessonStartTime = day.date
                        .add(lessonsDuration[day.lessons[lessonIndex].index.clamp(0, lessonsDuration.length)]['start'] ??
                            Duration.zero)
                        .millisecondsSinceEpoch;
                    final int lessonEndTime = day.date
                        .add(lessonsDuration[day.lessons[lessonIndex].index.clamp(0, lessonsDuration.length)]['end'] ??
                            Duration.zero)
                        .millisecondsSinceEpoch;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: context.watch<SettingsProvider>().settings.darkenCompletedLessons && todayTime > lessonEndTime
                          ? 0.5
                          : 1,
                      child: LessonWidget(
                        lesson: day.lessons[lessonIndex],
                        highlight: context.read<SettingsProvider>().settings.highlightCurrentLesson &&
                            lessonStartTime < todayTime &&
                            todayTime < lessonEndTime,
                        underline: lessonIndex == 0 && day.lessons[lessonIndex].index != 1,
                      ),
                    );
                  }),
                ),
                if (context.watch<SettingsProvider>().settings.showProgressIndicator)
                  Positioned.fill(
                    right: MediaQuery.of(context).size.width - 4,
                    child: Builder(builder: (context) {
                      final double progress = ((todayTime - dayStartTime) / (dayEndTime - dayStartTime) * 100).clamp(0, 100);
                      return FAProgressBar(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(4),
                          bottomRight: Radius.circular(4),
                        ),
                        direction: Axis.vertical,
                        progressColor: Theme.of(context).colorScheme.primary,
                        animatedDuration: const Duration(milliseconds: 300),
                        currentValue: progress,
                      );
                    }),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
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
      currentIndex: selectedDayIndex,
      onTap: (index) {
        if (selectedDayIndex == index) return;
        setState(() {
          _selectedDayIndex = index;
        });
        _pageController.animateToPage(
          index,
          curve: standardEasing,
          duration: const Duration(milliseconds: 400),
        );
      },
      items: [
        for (final day in widget.selectedWeek!.days)
          BottomNavigationBarItem(
            tooltip: '',
            icon: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: widget.selectedWeek!.days.indexOf(day) == selectedDayIndex ? 1 : 0.5,
              child: Text(
                day.date.day.toString(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            label: dayIndexToShortName[day.date.weekday],
          ),
      ],
    );
  }
}

class LessonWidget extends StatelessWidget {
  const LessonWidget({
    Key? key,
    required this.lesson,
    this.highlight = false,
    this.underline = false,
  }) : super(key: key);

  final Lesson lesson;
  final bool highlight;
  final bool underline;

  String _lessonTime(int index) {
    try {
      return '${lessonsTime[index]['start']} — ${lessonsTime[index]['end']}';
    } on RangeError {
      return 'Без сроков';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: lesson.index >= 0
                      ? SizedBox(
                          width: 30,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Flash(
                                key: ValueKey<bool>(highlight),
                                animate: highlight,
                                infinite: true,
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(seconds: 2),
                                child: Text(
                                  lesson.index.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ),
                              if (underline)
                                Positioned.fill(
                                  child: Flash(
                                    animate: true,
                                    delay: const Duration(milliseconds: 400),
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        decoration: ShapeDecoration(
                                          color: Theme.of(context).colorScheme.onSurface,
                                          shape: const StadiumBorder(),
                                        ),
                                        margin: const EdgeInsets.symmetric(horizontal: 8),
                                        height: 2,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        )
                      : null,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.name,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _lessonTime(lesson.index),
                          softWrap: false,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              lesson.cabinet,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
