import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class LoginLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      body: Center(
        child: Lottie.asset('lib/assets/lottie/reactive-loading.json'),
      ),
    ),
    );
  }
}
