import 'package:fl_reload/constants.dart';
import 'package:fl_reload/screens/discover/components/screen_builder.dart';
import 'package:flutter/material.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void nextScreen() {
    _pageController.nextPage(
        duration: Duration(milliseconds: 400), curve: Curves.easeInOutQuad);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          DiscoverScreen(
            header: "Flex options",
            lorem:
                "You can setup any of this application, beggining colors ended forms, position etc.",
            lottieAsset: Assets.flasksAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
            isSkiped: true,
          ),
          DiscoverScreen(
            header: "Flex options",
            lorem:
                "You can setup any of this application, beggining colors ended forms, position etc.",
            lottieAsset: Assets.flasksAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
          ),
          DiscoverScreen(
            header: "Flex options",
            lorem:
                "You can setup any of this application, beggining colors ended forms, position etc.",
            lottieAsset: Assets.flasksAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
            buttonTitle: "Lets go to adventures",
          ),
        ],
      ),
    );
  }
}
