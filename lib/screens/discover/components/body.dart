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
            arrowDown: true,
          ),
          DiscoverScreen(
            header: "We have support Open Source",
            lorem:
                "All sources avalible on notabug, and can be reviewed. No secrets for users, only magic",
            lottieAsset: Assets.flasksAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
          ),
          DiscoverScreen(
            header: "Fully encryption",
            lorem:
                "All data stored on client, server work on message broker, he just delivered your message to others",
            lottieAsset: Assets.lockerAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
            buttonTitle: "Let's go to a meeting experiments",
          ),
        ],
      ),
    );
  }
}
