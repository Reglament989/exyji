import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';

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
              'All',
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.home)),
        BottomNavyBarItem(
            title: Text(
              'Contacts',
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.apps)),
        BottomNavyBarItem(
            title: Text(
              'Channels',
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.chat_bubble)),
        BottomNavyBarItem(
            title: Text(
              'Bots',
              textAlign: TextAlign.center,
            ),
            icon: Icon(Icons.settings)),
      ],
    );
  }
}
