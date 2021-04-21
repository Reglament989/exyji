import 'dart:ui';

import 'package:exyji/constants.dart';
import 'package:exyji/screens/login/components/footer.dart';
import 'package:flutter/material.dart';

import 'header_and_inputs.dart';

class Body extends StatelessWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                Colors.blue,
                Colors.pink,
                Colors.purple,
                Colors.black
              ])),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dPadding * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [HeaderAndInputs(), Footer()],
            ),
          ),
        )
      ],
    );
  }
}
