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

  const ChatScreen({Key? key, required this.room}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRouter
                .chatDetails), // , arguments: ChatDetailsViewArguments(chatId: args.roomId)
            child: Text(room.title)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.more_vert),
              tooltip: 'More',
              onPressed: () =>
                  {}), // , arguments: InviteViewArguments(chatId: args.chatId)
        ],
      ),
      body: Body(
        room: room,
      ),
    );
  }
}
