import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/screens/discover/components/screen_builder.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
            header: LocaleKeys.discover_flexOptions_header.tr(),
            lorem: LocaleKeys.discover_flexOptions_lorem.tr(),
            lottieAsset: Assets.flasksAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
            isSkiped: true,
            arrowDown: true,
          ),
          DiscoverScreen(
            header: LocaleKeys.discover_aboutOpenSource_header.tr(),
            lorem: LocaleKeys.discover_aboutOpenSource_lorem.tr(),
            lottieAsset: Assets.foss,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
          ),
          DiscoverScreen(
            header: LocaleKeys.discover_aboutEncryption_header.tr(),
            lorem: LocaleKeys.discover_aboutEncryption_lorem.tr(),
            lottieAsset: Assets.lockerAnimation,
            backgroundColor: Colors.cyan.withOpacity(0.5),
            nextScreen: this.nextScreen,
            buttonTitle: LocaleKeys.discover_pushButton.tr(),
          ),
        ],
      ),
    );
  }
}
