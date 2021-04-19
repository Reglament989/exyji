import 'package:fl_reload/constants.dart';
import 'package:fl_reload/hivedb/room.model.dart';
import 'package:fl_reload/screens/chat/components/body.dart';
import 'package:flutter/material.dart';

class ChatViewArguments {
  final String roomId;

  ChatViewArguments({required this.roomId});
}

class ChatScreen extends StatelessWidget {
  final RoomModel room;

  _showPopupMenu(Offset offset, BuildContext ctx) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: ctx,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(child: const Text('Doge'), value: 'Doge'),
        PopupMenuItem<String>(child: const Text('Lion'), value: 'Lion'),
      ],
      elevation: 8.0,
    );
  }

  const ChatScreen({Key? key, required this.room}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {}, // , arguments: ChatDetailsViewArguments(chatId: args.roomId)
            child: Text(room.title)),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(details.globalPosition, context);
            },
            child: Padding(padding: EdgeInsets.all(12), child: const Icon(Icons.more_vert)),
          ), // , arguments: InviteViewArguments(chatId: args.chatId)
        ],
      ),
      body: Body(
        room: room,
      ),
    );
  }
}
