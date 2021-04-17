import 'package:animations/animations.dart';
import 'package:fl_reload/screens/home/components/body.dart';
import 'package:fl_reload/screens/home/components/bottom_navy.dart';
import 'package:fl_reload/screens/home/components/create_chat_menu.dart';
import 'package:fl_reload/screens/home/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FabCircularMenuState> fabKey = GlobalKey();

  int _currentIndex = 0;
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

  void updateIndex(index) {
    fabKey.currentState?.close();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: HomeDrawer(),
      floatingActionButton: FabCircularMenu(
          key: fabKey,
          ringDiameter: 240,
          ringWidth: 70,
          fabSize: 52,
          children: <Widget>[
            OpenContainer(
                closedColor: Colors.transparent,
                closedElevation: 0,
                openColor: Colors.transparent,
                openElevation: 0,
                onClosed: (Object? _) {
                  fabKey.currentState?.close();
                },
                closedBuilder: (BuildContext ctx, VoidCallback _) =>
                    Padding(padding: EdgeInsets.all(15), child: Icon(Icons.create)),
                openBuilder: (BuildContext ctx, VoidCallback _) {
                  return CreateChatMenu(currentIndexOfPageView: _currentIndex);
                }),
            IconButton(
                icon: Icon(Icons.favorite),
                onPressed: () {
                  print('Favorite');
                })
          ]),
      body: Body(
        pageController: _pageController,
        updateIndex: updateIndex,
      ),
      bottomNavigationBar: BottomNavy(
          currentIndex: _currentIndex,
          pageController: _pageController,
          updateIndex: updateIndex),
    );
  }
}
