import 'package:animations/animations.dart';
import 'package:exyji/blocs/home/home_bloc.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/ui/home/components/body.dart';
import 'package:exyji/ui/home/components/bottom_navy.dart';
import 'package:exyji/ui/home/components/create_chat_menu.dart';
import 'package:exyji/ui/home/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return BlocBuilder(
      bloc: HomeBloc(),
      builder: (ctx, state) => Scaffold(
        appBar:
            AppBar(title: Text(LocaleKeys.home_title.tr()), centerTitle: true),
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
                  closedBuilder: (BuildContext ctx, VoidCallback _) => Padding(
                      padding: EdgeInsets.all(15), child: Icon(Icons.create)),
                  openBuilder: (BuildContext ctx, VoidCallback _) {
                    return CreateChatMenu(
                        currentIndexOfPageView: _currentIndex);
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
      ),
    );
  }
}
