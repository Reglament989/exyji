import 'package:flutter/material.dart';

class QuickWidgetTest extends StatelessWidget {
  final List<Widget> childs;

  const QuickWidgetTest(this.childs);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: childs,
        ),
      ),
    );
  }
}
