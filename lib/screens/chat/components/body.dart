import 'package:fl_reload/hivedb/messages.model.dart';
import 'package:fl_reload/hivedb/room.model.dart';
import 'package:fl_reload/hivedb/room_cache.model.dart';
import 'package:fl_reload/screens/chat/chat_screen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'bubble.dart';
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

  _BodyState({required this.room});

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
        Expanded(
          child: MessagesList(
            room: room,
            replyCallback: replyCallback,
          ),
        ),
        InputBlock(roomUid: room.uid)
      ],
    );
  }
}

class InputBlock extends StatefulWidget {
  final String roomUid;

  const InputBlock({Key? key, required this.roomUid}) : super(key: key);
  @override
  _InputBlockState createState() => _InputBlockState(roomUid);
}

class _InputBlockState extends State<InputBlock> {
  late final RoomCache cache;
  final inputMessageController = TextEditingController();
  final roomUid;

  _InputBlockState(this.roomUid);

  @override
  void initState() {
    // existsMessages = List.of(Hive.box<Room>('Room').get(roomId).existsMessages);
    cache = Hive.box<RoomCache>("Room-$roomUid-cache")
        .get('cache', defaultValue: RoomCache()) as RoomCache;
    inputMessageController.text = cache.lastInput;
    super.initState();
  }

  @override
  void dispose() {
    inputMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration:
            BoxDecoration(border: Border.all(color: Colors.black, width: 1)),
        height: 65,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 32,
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(top: 8),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FocusScope(
                  onFocusChange: (value) async {
                    if (!value) {
                      await cache.save();
                    }
                  },
                  child: TextField(
                    onChanged: (value) {
                      cache.lastInput = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    controller: inputMessageController,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Your message..."),
                  ),
                ),
              )),
              Container(
                // decoration: BoxDecoration(color: Colors.red),
                padding:
                    EdgeInsets.only(top: 14, bottom: 14, left: 10, right: 5),
                child: GestureDetector(
                  onTap: () async {
                    if (inputMessageController.text.length > 1) {
                      final newMessage = MessagesModel();
                      newMessage.messageData = inputMessageController.text;
                      newMessage.senderUid = "me";
                      final block = EncryptedBlock();
                      block..crypto = "";
                      block..hash = "";
                      block..prevHash = "";
                      block..signature = "";
                      newMessage.block = block;
                      await Hive.box<MessagesModel>("Room-$roomUid")
                          .add(newMessage);
                      inputMessageController.text = "";
                    }
                  },
                  child: Icon(Icons.send, size: 32),
                ),
              )
            ],
          ),
        ));
  }
}
