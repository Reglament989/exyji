import 'package:fl_reload/constants.dart';
import 'package:fl_reload/screens/chat/components/body.dart';
import 'package:flutter/material.dart';

class ChatViewArguments {
  final String roomId;

  ChatViewArguments({required this.roomId});
}

class ChatScreen extends StatelessWidget {
  final roomName = "Testify";
  @override
  Widget build(BuildContext context) {
    final ChatViewArguments args =
        ModalRoute.of(context)!.settings.arguments as ChatViewArguments;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRouter
                .chatDetails), // , arguments: ChatDetailsViewArguments(chatId: args.roomId)
            child: Text(roomName)),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.call),
              tooltip: 'Call',
              onPressed: () => {}),
          IconButton(
            icon: const Icon(Icons.group_add),
            tooltip: 'Add new members',
            onPressed: () => Navigator.of(context).pushNamed(
                '/invite'), // , arguments: InviteViewArguments(chatId: args.chatId)
          )
        ],
      ),
      body: Body(
        roomId: args.roomId,
      ),
    );
  }
}
