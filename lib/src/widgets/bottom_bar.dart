library bottom_bar;

// Flutter imports:
import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    Key? key,
    required this.selectedIndex,
    this.useCustomIndex,
    this.curve = Curves.easeOutQuint,
    this.duration = const Duration(milliseconds: 750),
    this.height,
    required this.backgroundColor,
    this.showActiveBackgroundColor = true,
    this.itemPadding = const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    required this.items,
    required this.onTap,
    this.textStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  }) : super(key: key);

  final int selectedIndex;

  /// Defines whether it is possible to use custom index
  final bool? useCustomIndex;

  /// Animation Curve of animation
  final Curve curve;

  /// Duration of the animation
  final Duration duration;

  /// Height of `BottomBar`
  final num? height;

  /// Background Color of `BottomBar`
  final Color backgroundColor;

  /// Shows the background color of `BottomBarItem` when it is active
  /// and when this is set to true
  final bool showActiveBackgroundColor;

  /// Padding between the background color and
  /// (`Row` that contains icon and title)
  final EdgeInsets itemPadding;

  /// List of `BottomBarItems` to display
  final List<BottomBarItem> items;

  /// Fires this callback whenever a `BottomBarItem` is tapped
  ///
  /// Use this callback to update the `selectedIndex`
  final ValueChanged<int> onTap;

  /// `TextStyle` of title
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height?.toDouble(),
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            items.length,
            (int index) {
              // final _index = (useCustomIndex ?? false) ? items[index].customIndex ?? index : index;

              // final _color = items[index].activeColor;
              // final _inactiveColor = items[index].inactiveColor ?? const Color(0xFF404040);

              // final _rightPadding = itemPadding.right;

              return _BottomBarItemWidget(
                  // index: _index,
                  // key: items.elementAt(index).key,
                  // isSelected: _index == selectedIndex,
                  // color: _color,
                  // backgroundColor: _backgroundColor,
                  // inactiveBackgroundColor: _inactiveBackgroundColor,
                  // inactiveColor: _inactiveColor,
                  // splashColor: _splashColor,
                  // showActiveBackgroundColor: showActiveBackgroundColor,
                  // rightPadding: _rightPadding,
                  // curve: curve,
                  // duration: duration,
                  // itemPadding: itemPadding,
                  // textStyle: textStyle,
                  // icon: items.elementAt(index).icon,
                  // inactiveIcon: items.elementAt(index).inactiveIcon,
                  // title: items.elementAt(index).title,
                  // onTap: () => onTap(_index),
                  );
            },
          ),
        ),
      ),
    );
  }
}

class BottomBarItem {}

class _BottomBarItemWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
