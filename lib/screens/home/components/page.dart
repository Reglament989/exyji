import 'package:fl_reload/hivedb/room.model.dart';
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
                ctx: ctx,
                idx: idx,
                key: Key(rooms[idx].uid),
                title: rooms[idx].title,
                subtitle: rooms[idx].lastMessage,
                icon: rooms[idx].photoURL,
              )),
    );
  }
}

class ListItem extends StatelessWidget {
  final ctx, idx;
  final String title, subtitle, icon;

  const ListItem(
      {Key? key,
      required this.ctx,
      required this.idx,
      required this.title,
      required this.subtitle,
      required this.icon})
      : assert(ctx != null, idx != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Container(
          width: 56,
          height: 56,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: icon,
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
        ));
  }
}
