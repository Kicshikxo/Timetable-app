// Flutter imports:
import 'package:flutter/material.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: Colors.transparent,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
    );
  }
}
