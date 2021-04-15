import 'package:fl_reload/screens/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Body extends StatefulWidget {
  final roomId;
  Body({required this.roomId});
  @override
  _BodyState createState() => _BodyState(roomId: roomId);
}

class _BodyState extends State<Body> {
  static const uuid = const Uuid();
  final TextEditingController inputMessageController = TextEditingController();
  final String roomId;
  bool isReplyed = false;
  String replyBodyMessage = '';
  String replyMessageId = '';
  dynamic replyFrom;
  List existsMessages = [];

  _BodyState({required this.roomId});

  @override
  void initState() {
    // existsMessages = List.of(Hive.box<Room>('Room').get(roomId).existsMessages);
    // inputMessageController.text = Hive.box<Room>('Room').get(roomId).lastInput;
    super.initState();
  }

  @override
  void dispose() {
    inputMessageController.dispose();
    super.dispose();
  }

  void closeReplyCallback() {
    setState(() {
      isReplyed = false;
      replyBodyMessage = '';
      replyMessageId = '';
    });
  }

  void replyCallback(
      {required String replyBody, required String uid, replyFromBody}) {
    debugPrint('replyUID=$uid');
    setState(() {
      isReplyed = true;
      replyBodyMessage = replyBody;
      replyMessageId = uid;
      replyFrom = replyFromBody;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Expanded(
        //   child: ValueListenableBuilder(
        //     builder: (BuildContext ctx, widget),
        //   ),
        // )
      ],
    );
  }
}
