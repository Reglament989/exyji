import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/components/bubble.component.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/views/chatDetails.view.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ChatViewArguments {
  final String chatId;

  ChatViewArguments({this.chatId});
}

class ChatView extends StatelessWidget {
  static final routeName = '/chat';

  @override
  Widget build(BuildContext context) {
    final ChatViewArguments args = ModalRoute.of(context).settings.arguments;
    final chat = FirebaseFirestore.instance.collection('Rooms');
    return FutureBuilder<DocumentSnapshot>(
        future: chat.doc(args.chatId).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold();
          }

          final room = snapshot.data.data();
          // print('Room has data? ${room['roomName']}');

          return Scaffold(
            appBar: AppBar(
              title: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/chat/details',
                      arguments: ChatDetailsViewArguments(chatId: args.chatId)),
                  child: Text(room['roomName'])),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.group_add),
                  tooltip: 'Add new members',
                  onPressed: () => Navigator.of(context)
                      .pushNamed('/invite', arguments: InviteViewArguments(chatId: args.chatId)),
                )
              ],
            ),
            body: ChatViewBody(
                chat: chat, args: args, room: room, roomId: snapshot.data.id),
          );
        });
  }
}

class ChatViewBody extends StatefulWidget {
  final chat;
  final ChatViewArguments args;
  final room;
  final roomId;

  const ChatViewBody(
      {Key key,
      @required this.chat,
      @required this.args,
      @required this.room,
      @required this.roomId})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new ChatViewBodyState(
        chat: this.chat, args: this.args, room: this.room, roomId: this.roomId);
  }
}

class ChatViewBodyState extends State<ChatViewBody> {
  final chat;
  final ChatViewArguments args;
  final room;
  final roomId;
  bool isReplyed = false;
  String replyBodyMessage = '';
  String replyMessageId = '';

  ChatViewBodyState(
      {Key key,
      @required this.chat,
      @required this.args,
      @required this.room,
      @required this.roomId});

  void replyCallback({String replyBody, String uid}) {
    debugPrint('replyBody=$replyBody');
    setState(() {
      isReplyed = true;
      replyBodyMessage = replyBody;
      replyMessageId = uid;
    });
  }

  void closeReplyCallback() {
    setState(() {
      isReplyed = false;
      replyBodyMessage = '';
      replyMessageId = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ValueListenableBuilder(
              valueListenable:
                  Hive.box<Room>('Room').listenable(keys: ['pathBackground']),
              builder: (context, box, widget) {
                debugPrint('updated');
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: box.get(args.chatId).pathBackground != null
                              ? FileImage(
                                  File(box.get(args.chatId).pathBackground))
                              : AssetImage(Assets.defaultChatBackground))),
                  child: MessagesList(
                    chatId: args.chatId,
                    chat: chat,
                    callbackReply: replyCallback,
                  ),
                );
              }),
        ),
        isReplyed
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isReplyed
                      ? Container(
                          // height: 45,
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          color: Colors.cyan[400],
                          child: ReplyContent(
                              replyBody: replyBodyMessage,
                              closeCallback: closeReplyCallback),
                        )
                      : Container(),
                  InputBlock(
                    room: room,
                    roomID: roomId,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputBlock(
                    room: room,
                    roomID: roomId,
                  ),
                ],
              )
      ],
    );
  }
}

class MessagesList extends StatefulWidget {
  final String chatId;
  final CollectionReference chat;
  final callbackReply;

  MessagesList(
      {@required this.chatId,
      @required this.chat,
      @required this.callbackReply});

  @override
  State<StatefulWidget> createState() {
    return new MessagesListState(
        chatId: chatId, chat: chat, callbackReply: callbackReply);
  }
}

class MessagesListState extends State<MessagesList> {
  static const platform = const MethodChannel('crypto');
  final String chatId;
  final CollectionReference chat;
  final callbackReply;
  // List messages = List.of([]);
  List existsMessages = List.of([]);
  StreamSubscription<QuerySnapshot> listenerController;

  MessagesListState(
      {@required this.chatId,
      @required this.chat,
      @required this.callbackReply});

  @override
  void initState() {
    existsMessages = Hive.box<Room>('Room').get(chatId).existsMessages;
    this.listenMessages();
    super.initState();
  }

  @override
  void dispose() {
    // this.listenMessages();
    listenerController.cancel();
    super.dispose();
  }

  listenMessages() {
    final roomSecret = Hive.box<Room>('Room').get(chatId);
    // messages = roomSecret.messages;
    // debugPrint(roomSecret.messages.toString());
    // debugPrint(chatId.toString());
    final streamMessages = chat
        .doc(chatId)
        .collection('Messages')
        .orderBy('createdAt')
        .snapshots();
    listenerController = streamMessages.listen((message) async {
      if (this.mounted) {
        await Future.forEach(message.docs, (element) async {
          if (existsMessages.contains(element.id)) {
            return;
          } else {
            final decryptedMessage =
            await decryptMessage(element, roomSecret: roomSecret);
            final defaultMessage = {'uid': element.id};
            defaultMessage.addAll(decryptedMessage);
            roomSecret.messages.add(decryptedMessage);
            roomSecret.existsMessages.add(element.id);
            await roomSecret.save();
            setState(() {
              existsMessages.add(element.id);
            });
          }
        });
      }
    });
  }

  decryptMessage(QueryDocumentSnapshot encryptedMessage, {roomSecret}) async {
    var data = encryptedMessage.data();
    final decryptedSource = await platform.invokeMethod('decryptMessage', {
      'encryptedMessage': data['encryptedMessage'],
      'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion],
      'IV': data['IV']
    });
    return json.decode(decryptedSource);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box<Room>('Room').listenable(keys: ['messages', 'existsMessages']),
        builder: (context, box, widget) {
          final List messages = box.get(chatId).messages.toList();
              return messages.length < 1
            ? Center(
                child: Text("Not Have messages"),
              )
            : ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (BuildContext ctx, index) {
                  final msgs = messages.reversed.toList();
                  final idx = index.toInt();
                  return Bubble(
                    isReply: msgs[idx]['isReply'] != null
                        ? msgs[idx]['isReply']
                        : false,
                    replyBody: msgs[idx]['replyBody'] != null
                        ? msgs[idx]['replyBody']
                        : '',
                    replyFrom: msgs[idx]['replyFrom'] != null
                        ? msgs[idx]['replyFrom']
                        : '',
                    body: msgs[idx]['msg'],
                    // date: DateFormat("HH:mm").format(DateTime.now()),
                    date: msgs[idx]['date'] != null
                        ? msgs[idx]['date']
                        : DateFormat("HH:mm").format(DateTime.now()),
                    isSender: msgs[idx]['sender'] ==
                            FirebaseAuth.instance.currentUser.uid
                        ? true
                        : false,
                    uid: msgs[idx]['uid'],
                    callbackReply: callbackReply,
                  );
                });});
  }
}

class ReplyContent extends StatelessWidget {
  final String replyBody;
  final Function closeCallback;

  const ReplyContent({Key key, this.replyBody, this.closeCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(width: 2, color: Colors.black))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(replyBody),
                    )
                  ],
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: closeCallback,
            child: Icon(Icons.close),
          )
        ]);
  }
}

class InputBlock extends StatefulWidget {
  final roomID;
  final room;

  InputBlock({Key key, @required this.roomID, @required this.room})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new InputBlockState(room: room, roomID: roomID);
  }
}

class InputBlockState extends State<InputBlock> {
  final inputMessageController = TextEditingController();
  static const platform = const MethodChannel('crypto');
  final roomID;
  final room;

  InputBlockState({Key key, @required this.roomID, @required this.room});

  sendMessage({room, roomID}) async {
    final text = inputMessageController.text.trim();
    if (text.length > 0) {
      inputMessageController.text = '';
      final ChatViewArguments args = ModalRoute.of(context).settings.arguments;
      final roomSecret = Hive.box<Room>('Room').get(args.chatId);
      final msgBody = {
        'msg': text,
        'sender': FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat(DateFormat.HOUR24_MINUTE).format(DateTime.now())
      };
      var msg = json.encode(msgBody);
      var encryptedMessage = await platform.invokeMethod('encryptMessage', {
        'message': msg,
        'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion]
      });
      // final roomDoc = Hive.box<Room>('Room').get(roomID);
      // roomDoc.messages.add(msgBody);

      final roomUid = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomID)
          .collection('Messages')
          .add({
        "encryptedMessage": encryptedMessage['encryptedMessage'],
        'IV': encryptedMessage['IV'],
        "createdAt": Timestamp.now()
      });
      // roomDoc.existsMessages.add(roomUid.id);
      // await roomDoc.save();
    }
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
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  // onEditingComplete: () => inputMessageController.text = inputMessageController.text.capitalize(),
                  controller: inputMessageController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Your message..."),
                ),
              )),
              GestureDetector(
                onTap: () async {
                  sendMessage(room: room, roomID: roomID);
                },
                child: Icon(Icons.send, size: 32),
              )
            ],
          ),
        ));
  }
}
