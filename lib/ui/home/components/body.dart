import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/screens/home/components/page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    return ValueListenableBuilder(
      valueListenable: Hive.box<RoomModel>('Rooms').listenable(),
      builder: (ctx, Box<RoomModel> box, widget) {
        final allRooms = box.values.toList();
        allRooms.sort((a, b) {
          return a.lastUpdate.compareTo(b.lastUpdate);
        });
        return SizedBox.expand(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => updateIndex(index),
            children: <Widget>[
              BodyPage(allRooms: allRooms), // All
              BodyPage(
                  allRooms: allRooms, sortBy: RoomType.contact), // Contacts
              BodyPage(
                  allRooms: allRooms, sortBy: RoomType.channel), // Channels
              BodyPage(allRooms: allRooms, sortBy: RoomType.bot), // Bots
            ],
          ),
        );
      },
    );
  }
}
