// Flutter imports:
import 'package:flutter/material.dart';

class MessangerProvider extends ChangeNotifier {
  void showSnackBar({
    required BuildContext context,
    required String text,
    double? bottomMargin,
    DismissDirection dismissDirection = DismissDirection.none,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: dismissDirection,
        duration: duration,
        content: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        margin: EdgeInsets.fromLTRB(15, 5, 15, bottomMargin != null ? bottomMargin + 10 : 10),
        padding: const EdgeInsets.all(18),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
