import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/hivedb/room_cache.model.dart';
import 'package:exyji/screens/chat/components/reply_content.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'input_block.dart';
import 'messages_list.dart';

class Body extends StatefulWidget {
  final room;
  Body({required this.room});
  @override
  _BodyState createState() => _BodyState(room: room);
}

class _BodyState extends State<Body> {
  static const uuid = const Uuid();
  final TextEditingController inputMessageController = TextEditingController();
  final RoomModel room;
  bool isReplyed = false;
  String replyBodyMessage = '';
  String replyMessageId = '';
  dynamic replyFrom;
  List existsMessages = [];
  late RoomCache cache;

  _BodyState({required this.room});

  @override
  void initState() {
    // existsMessages = List.of(Hive.box<Room>('Room').get(roomId).existsMessages);
    // inputMessageController.text = Hive.box<Room>('Room').get(roomId).lastInput;
    cache = Hive.box<RoomCache>("Room-${room.uid}-cache")
        .get('cache', defaultValue: RoomCache()) as RoomCache;
    super.initState();
  }

  @override
  void dispose() {
    inputMessageController.dispose();
    super.dispose();
  }

  void closeReplyCallback() async {
    setState(() {
      isReplyed = false;
    });
    cache.replyBodyMessage = null;
    cache.replyMessageId = null;
    cache.replyFrom = null;
    await cache.save();
  }

  void replyCallback(
      {required String replyBody, required String uid, replyFromBody}) async {
    // debugPrint('replyUID=$uid');
    setState(() {
      isReplyed = true;
    });
    cache.replyBodyMessage = replyBody;
    cache.replyMessageId = uid;
    cache.replyFrom = replyFromBody;
    await cache.save();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MessagesList(
            room: room,
            replyCallback: replyCallback,
          ),
        ),
        if (isReplyed)
          ReplyContent(
              replyBody: cache.replyBodyMessage!,
              closeCallback: closeReplyCallback),
        InputBlock(roomUid: room.uid, closeCallback: closeReplyCallback)
      ],
    );
  }
}
