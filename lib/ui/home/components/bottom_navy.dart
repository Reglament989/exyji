import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BottomNavy extends StatelessWidget {
  const BottomNavy(
      {Key? key,
      required int currentIndex,
      required PageController pageController,
      required Function updateIndex})
      : _currentIndex = currentIndex,
        _pageController = pageController,
        updateIndex = updateIndex,
        super(key: key);

  final int _currentIndex;
  final PageController _pageController;
  final Function updateIndex;

  @override
  Widget build(BuildContext context) {
    return BottomNavyBar(
      selectedIndex: _currentIndex,
      onItemSelected: (index) {
        updateIndex(index);
        _pageController.animateToPage(index,
            duration: Duration(milliseconds: 300), curve: Curves.ease);
      },
      items: <BottomNavyBarItem>[
        BottomNavyBarItem(
            title: Text(
              LocaleKeys.home_navy_listWithAllRooms.tr(),
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.home)),
        BottomNavyBarItem(
            title: Text(
              LocaleKeys.home_navy_listWithContacts.tr(),
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.account_circle)),
        BottomNavyBarItem(
            title: Text(
              LocaleKeys.home_navy_listWithChannels.tr(),
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.public)),
        BottomNavyBarItem(
            title: Text(
              LocaleKeys.home_navy_listWithBots.tr(),
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.precision_manufacturing_sharp)),
      ],
    );
  }
}
