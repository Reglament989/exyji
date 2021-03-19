import 'dart:ui';

import 'package:fl_andro_x/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BluredLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: BackdropFilter(
            child: Lottie.asset(Assets.timeLoader),
            filter: ImageFilter.blur(
              sigmaX: 50,
              sigmaY: 50,
            )));
  }
}
