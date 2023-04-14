// Flutter imports:
import 'package:flutter/material.dart';

class ExpandedSingleChildScrollView extends StatelessWidget {
  final Widget? child;

  final ScrollPhysics physics;
  const ExpandedSingleChildScrollView({
    super.key,
    this.child,
    this.physics = const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        physics: physics,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: constraints.maxHeight,
          ),
          child: child,
        ),
      );
    });
  }
}
