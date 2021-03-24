import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'package:uuid/uuid.dart';

import 'package:jitsi_meet/feature_flag/feature_flag.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:jitsi_meet/room_name_constraint.dart';
import 'package:jitsi_meet/room_name_constraint_type.dart';

class ChatViewArguments {
  final String chatId;

  ChatViewArguments({this.chatId});
}

class ChatView extends StatelessWidget {
  static final routeName = '/chat';
  final chat = FirebaseFirestore.instance.collection('Rooms');

  _joinMeeting(ChatViewArguments args) async {
    try {
      FeatureFlag featureFlag = FeatureFlag();
      featureFlag.welcomePageEnabled = false;
      featureFlag.resolution = FeatureFlagVideoResolution.HD_RESOLUTION; // Limit video resolution to 360p

      var options = JitsiMeetingOptions()
        ..room = args.chatId // Required, spaces will be trimmed
        ..serverURL = "https://meet.i2pd.xyz"
        ..userDisplayName = FirebaseAuth.instance.currentUser.displayName
        ..userAvatarURL = FirebaseAuth.instance.currentUser.photoURL // or .png
        ..audioMuted = true
        ..videoMuted = true
        ..featureFlag = featureFlag;

      await JitsiMeet.joinMeeting(options);
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ChatViewArguments args = ModalRoute.of(context).settings.arguments;
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
                  icon: const Icon(Icons.call),
                  tooltip: 'Call',
                  onPressed: () => _joinMeeting(args)
                ),
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
  static const platform = const MethodChannel('crypto');
  static const uuid = const Uuid();
  final TextEditingController inputMessageController = TextEditingController();
  final chat;
  final ChatViewArguments args;
  final room;
  final String roomId;
  bool isReplyed;
  String replyBodyMessage;
  String replyMessageId;
  dynamic replyFrom;
  List existsMessages;

  @override
  void initState() {
    isReplyed = false;
    existsMessages = List.of(Hive.box<Room>('Room').get(roomId).existsMessages);
    inputMessageController.text = Hive.box<Room>('Room').get(roomId).lastInput;

    super.initState();
  }

  @override
  void dispose() {
    inputMessageController.dispose();
    super.dispose();
}

  ChatViewBodyState(
      {Key key,
      @required this.chat,
      @required this.args,
      @required this.room,
      @required this.roomId});

  void replyCallback({String replyBody, String uid, replyFromBody}) {
    debugPrint('replyUID=$uid');
    setState(() {
      isReplyed = true;
      replyBodyMessage = replyBody;
      replyMessageId = uid;
      replyFrom = replyFromBody;
    });
  }

  sendMessage() async {
    final text = inputMessageController.text.trim();
    if (text.length > 0) {
      final ChatViewArguments args = ModalRoute.of(context).settings.arguments;
      final roomSecret = Hive.box<Room>('Room').get(args.chatId);
      final messageId = uuid.v4();
      final msgBody = {
        'msg': text,
        'sender': {'name':FirebaseAuth.instance.currentUser.displayName, 'uid': FirebaseAuth.instance.currentUser.uid},
        'date': DateFormat(DateFormat.HOUR24_MINUTE).format(DateTime.now()),
        'isReply': isReplyed,
        'uid': messageId,
      };
      if (isReplyed) {
        msgBody.addAll({'replyId': replyMessageId, 'replyBody': replyBodyMessage, 'replyFrom': replyFrom});
      }
      // debugPrint(msgBody.toString());
      roomSecret.messages = [...roomSecret.messages, msgBody];
      setState(() {
        existsMessages.add(messageId);
      });
      roomSecret.existsMessages = [...roomSecret.existsMessages, messageId];
      await roomSecret.save();
      setState(() {
        inputMessageController.text = '';
        roomSecret.lastInput = '';
        isReplyed = false;
        replyMessageId = '';
        replyBodyMessage = '';
        replyFrom = {};
      });
      var msg = json.encode(msgBody);
      var encryptedMessage = await platform.invokeMethod('encryptMessage', {
        'message': msg,
        'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion]
      });

      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomId)
          .collection('Messages')
          .doc(messageId)
          .set({
        "encryptedMessage": encryptedMessage['encryptedMessage'],
        'IV': encryptedMessage['IV'],
        "createdAt": Timestamp.now()
      });
    }
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
                return Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: box.get(args.chatId).pathBackground != null
                              ? FileImage(
                                  File(box.get(args.chatId).pathBackground))
                              : AssetImage(Assets.defaultChatBackground))),
                  child: MessagesList(
                    existsMessages: existsMessages,
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
                  InputBlock(controller: inputMessageController, callbackSendMessage: sendMessage, roomId: roomId,),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputBlock(controller: inputMessageController, callbackSendMessage: sendMessage, roomId: roomId,),
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
  final List existsMessages;

  MessagesList(
      {@required this.chatId,
        @required this.existsMessages,
      @required this.chat,
      @required this.callbackReply});

  @override
  State<StatefulWidget> createState() {
    return new MessagesListState(
        existsMessages: existsMessages,
        chatId: chatId, chat: chat, callbackReply: callbackReply);
  }
}

class MessagesListState extends State<MessagesList> {
  static const platform = const MethodChannel('crypto');
  final String chatId;
  final CollectionReference chat;
  final callbackReply;
  // List messages = List.of([]);
  List existsMessages;
  StreamSubscription<QuerySnapshot> listenerController;

  MessagesListState(
      {@required this.chatId,
        @required this.existsMessages,
      @required this.chat,
      @required this.callbackReply});

  @override
  void initState() {
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
    var returnMessage = {};
    var data = encryptedMessage.data();
    final decryptedSource = await platform.invokeMethod('decryptMessage', {
      'encryptedMessage': data['encryptedMessage'],
      'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion],
      'IV': data['IV']
    });
    final message = json.decode(decryptedSource);
    debugPrint(message);
    returnMessage.addAll(message);
    if (message['isReply'] != null && message['isReply'] == true) {
      final replyMessage = await getReplyMessage(replyId: message['replyId']);
      if (replyMessage != null && replyMessage != false) {
        final decryptedReplyMessage = await platform.invokeMethod('decryptMessage', {
          'encryptedMessage': replyMessage['encryptedMessage'],
          'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion],
          'IV': replyMessage['IV']
        });
        final replyMessageBody = json.decode(decryptedReplyMessage);
        debugPrint('reply message detected with body ${replyMessageBody['msg']}');
        returnMessage.addAll({'replyBody': replyMessageBody['msg'], 'replyFrom': replyMessageBody['sender']['name']});
      }
    }
    return new Map<String, dynamic>.from(returnMessage);
  }

  getReplyMessage({replyId}) async {
    final reply = await FirebaseFirestore.instance.collection('Rooms').doc(chatId).collection('Messages').doc(replyId).get();
    if (reply.exists) {
      return reply.data();
    } else {
      return false;
    }
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
                itemBuilder: (BuildContext ctx, idx) {
                  final msgs = messages.reversed.toList();
                  // debugPrint(msgs[idx].toString());
                  return Bubble(
                    isReply: msgs[idx]['isReply'] != null
                        ? msgs[idx]['isReply']
                        : false,
                    replyBody: msgs[idx]['replyBody'] != null
                        ? msgs[idx]['replyBody']
                        : '',
                    replyFrom: msgs[idx]['replyFrom'] != null
                          ? msgs[idx]['replyFrom']['name']
                        : '',
                    body: msgs[idx]['msg'],
                    // date: DateFormat("HH:mm").format(DateTime.now()),
                    date: msgs[idx]['date'] != null
                        ? msgs[idx]['date']
                        : DateFormat("HH:mm").format(DateTime.now()),
                    sender: msgs[idx]['sender'],
                    isSender: msgs[idx]['sender']['uid'] ==
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

class InputBlock extends StatelessWidget {
  final TextEditingController controller;
  final Function callbackSendMessage;
  final String roomId;

  const InputBlock({Key key, @required this.controller, @required this.callbackSendMessage, @required this.roomId}) : super(key: key);

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
                      await Hive.box<Room>('Room').get(roomId).save();
                    }
                  },
                  child: TextField(
                    onChanged: (value) {
                      Hive.box<Room>('Room').get(roomId).lastInput = value;
                    },
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    // onEditingComplete: () => inputMessageController.text = inputMessageController.text.capitalize(),
                    controller: controller,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: "Your message..."),
                  ),
                ),
              )),
              GestureDetector(
                onTap: () async {
                  await callbackSendMessage();
                },
                child: Icon(Icons.send, size: 32),
              )
            ],
          ),
        ));
  }
}
