import 'package:fl_reload/constants.dart';
import 'package:flutter/material.dart';

class DiscoverScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRouter.home),
            child: Text("Skip")),
      ),
    );
  }
}
