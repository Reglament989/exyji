import 'package:exyji/constants.dart';
import 'package:exyji/helpers/widgets.dart';
import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/screens/chat/components/body.dart';
import 'package:flutter/material.dart';

class ChatScreenArguments {
  final RoomModel room;

  ChatScreenArguments({required this.room});
}

class ChatScreen extends StatelessWidget {
  _showPopupMenu(Offset offset, BuildContext ctx) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: ctx,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            child:
                PopItem(icon: Icons.exit_to_app, descript: 'Leave from room'),
            value: 'leave'),
      ],
      elevation: 8.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ChatScreenArguments;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap:
                () {}, // , arguments: ChatDetailsViewArguments(chatId: args.roomId)
            child: Text(args.room.title)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(details.globalPosition, context);
            },
            child: Padding(
                padding: EdgeInsets.all(15),
                child: const Icon(Icons.more_vert)),
          ), // , arguments: InviteViewArguments(chatId: args.chatId)
        ],
      ),
      body: Body(
        room: args.room,
      ),
    );
  }
}
