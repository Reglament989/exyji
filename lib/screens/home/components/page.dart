import 'package:animations/animations.dart';
import 'package:exyji/constants.dart';
import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

const uuid = Uuid();

class BodyPage extends StatelessWidget {
  final List<RoomModel> allRooms;
  final RoomType sortBy;

  const BodyPage({Key? key, required this.allRooms, this.sortBy = RoomType.any})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var rooms = [];
    if (sortBy == RoomType.any) {
      rooms = allRooms;
    } else {
      allRooms.forEach((r) {
        if (r.type == sortBy) {
          rooms.add(r);
        }
      });
    }
    if (rooms.length < 1) {
      var nameList;
      switch (sortBy) {
        case RoomType.contact:
          nameList = "contacts";
          break;
        case RoomType.channel:
          nameList = "channels";
          break;
        case RoomType.bot:
          nameList = "bots";
          break;
        default:
          nameList = "room";
      }
      return Center(
        child: Text("Your $nameList sheet is empty",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
      );
    }
    return Container(
      child: ListView.separated(
          physics: BouncingScrollPhysics(),
          itemCount: rooms.length,
          separatorBuilder: (BuildContext ctx, idx) => Divider(
                indent: 64,
                endIndent: 18,
                height: 1,
                color: Colors.black.withOpacity(0.6),
              ),
          itemBuilder: (BuildContext ctx, idx) => ListItem(
              ctx: ctx, idx: idx, key: Key(rooms[idx].uid), room: rooms[idx])),
    );
  }
}

class ListItem extends StatelessWidget {
  final ctx, idx;
  final RoomModel room;

  const ListItem(
      {Key? key, required this.ctx, required this.idx, required this.room})
      : assert(ctx != null, idx != null),
        super(key: key);

  _showMenu(Offset offset, BuildContext ctx) async {
    double left = offset.dx;
    double top = offset.dy;
    final returnFromMenu = await showMenu(
      context: ctx,
      position: RelativeRect.fromLTRB(left, top, left, top),
      items: [
        PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(Icons.volume_off),
                Padding(padding: EdgeInsets.all(12), child: const Text('Mute'))
              ],
            ),
            value: 'mute'),
        PopupMenuItem<String>(
            child: Row(
              children: [
                Icon(Icons.add_box_outlined),
                Padding(
                    padding: EdgeInsets.all(12), child: const Text('Invite'))
              ],
            ),
            value: 'invite'),
      ],
      elevation: 8.0,
    );
    if (returnFromMenu != null) {
      print(returnFromMenu);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(AppRouter.chat,
            arguments: ChatScreenArguments(room: room)),
        onLongPressStart: (LongPressStartDetails details) async =>
            await _showMenu(details.globalPosition, ctx),
        child: ListTile(
            title: Text(room.title),
            subtitle: Text(room.lastMessage),
            leading: Container(
              width: 56,
              height: 56,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: room.photoURL,
                  imageBuilder: (ctx, imageProvider) => Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        )),
                  ),
                ),
              ),
            )));
  }
}
