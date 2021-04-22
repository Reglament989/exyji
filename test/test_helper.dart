import 'package:flutter/material.dart';

class QuickWidgetTest extends StatelessWidget {
  final Widget child;

  const QuickWidgetTest(this.child);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }
}
