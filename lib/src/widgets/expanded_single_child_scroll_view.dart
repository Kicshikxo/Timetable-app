// Flutter imports:
import 'package:flutter/material.dart';

class ExpandedSingleChildScrollView extends StatelessWidget {
  const ExpandedSingleChildScrollView({
    super.key,
    this.child,
    this.physics = const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
  });

  final Widget? child;
  final ScrollPhysics physics;

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
