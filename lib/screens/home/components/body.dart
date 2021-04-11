import 'package:fl_reload/screens/home/components/page.dart';
import 'package:flutter/material.dart';

class Body extends StatelessWidget {
  const Body(
      {Key? key,
      required PageController pageController,
      required Function updateIndex})
      : _pageController = pageController,
        updateIndex = updateIndex,
        super(key: key);

  final PageController _pageController;
  final Function updateIndex;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: PageView(
        controller: _pageController,
        onPageChanged: (index) => updateIndex(index),
        children: <Widget>[
          BodyPage(),
          BodyPage(),
          BodyPage(),
          BodyPage(),
        ],
      ),
    );
  }
}
