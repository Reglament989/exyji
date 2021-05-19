import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/helpers/file_helper.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/hivedb/room_cache.model.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

class InputBlock extends StatefulWidget {
  final String roomUid;
  final Function closeCallback;

  const InputBlock(
      {Key? key, required this.roomUid, required this.closeCallback})
      : super(key: key);
  @override
  _InputBlockState createState() => _InputBlockState(roomUid, closeCallback);
}

class _InputBlockState extends State<InputBlock> {
  late final RoomCache cache;
  final Function closeCallback;
  final inputMessageController = TextEditingController();
  final roomUid;

  _InputBlockState(this.roomUid, this.closeCallback);

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

  Future<void> _sendAttachment() async {
    final List<EFile>? eFiles = await FileApi.pick(extensions: []);
    if (eFiles == null) {
      return;
    }
    final newMessage = MessagesModel();
    newMessage.type = TypeMessage.photo;
    final media = MediaMessage();
    media..data = eFiles.first.data;
    media..fileExtension = eFiles.first.fileExtension;
    media..size = eFiles.first.size;
    media..caption = eFiles.first.caption;
    newMessage.media = media;
    newMessage.senderUid = "me";
    newMessage.isDecrypted = true;
    final block = EncryptedBlock();
    block..crypto = "";
    block..hash = "";
    block..prevHash = "";
    block..signature = "";
    newMessage.block = block;
    // debugPrint(cache.replyBodyMessage);
    if (cache.replyBodyMessage != null) {
      newMessage.replyUid = cache.replyMessageId;
      final newReply = ReplyModel();
      newReply..body = cache.replyBodyMessage!;
      newReply..from = cache.replyFrom!;
      newReply..fromUid = cache.replyMessageId!;
      newMessage.reply = newReply;
    }
    await closeCallback();
    await Hive.box<MessagesModel>("Room-$roomUid").add(newMessage);
  }

  Future<void> _sendTextMessage() async {
    if (inputMessageController.text.trim().length > 0) {
      final newMessage = MessagesModel();
      newMessage.messageData = inputMessageController.text.trim();
      newMessage.senderUid = "me";
      final block = EncryptedBlock();
      block..crypto = "";
      block..hash = "";
      block..prevHash = "";
      block..signature = "";
      newMessage.block = block;
      newMessage.isDecrypted = true;
      // debugPrint(cache.replyBodyMessage);
      if (cache.replyBodyMessage != null) {
        newMessage.replyUid = cache.replyMessageId;
        final newReply = ReplyModel();
        newReply..body = cache.replyBodyMessage!;
        newReply..from = cache.replyFrom!;
        newReply..fromUid = cache.replyMessageId!;
        newMessage.reply = newReply;
      }
      await Hive.box<MessagesModel>("Room-$roomUid").add(newMessage);
      inputMessageController.text = "";
      cache.lastInput = "";
      await closeCallback();
      await cache.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border(
          top: BorderSide(color: Colors.black, width: 1),
        )),
        height: 65,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              InkWell(
                onTap: _sendAttachment,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Transform.rotate(
                    angle: 20,
                    child: Icon(
                      Icons.attachment,
                      size: 28,
                    ),
                  ),
                ),
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
                        border: InputBorder.none,
                        hintText: LocaleKeys.chat_inputHint.tr()),
                  ),
                ),
              )),
              Container(
                // decoration: BoxDecoration(color: Colors.red),
                padding:
                    EdgeInsets.only(top: 14, bottom: 14, left: 10, right: 5),
                child: GestureDetector(
                  onTap: _sendTextMessage,
                  child: Icon(Icons.send, size: 32),
                ),
              )
            ],
          ),
        ));
  }
}
