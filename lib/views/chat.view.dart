import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/components/bubble.component.dart';
import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/views/chatDetails.view.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class ChatViewArguments {
  final String chatId;

  ChatViewArguments({this.chatId});
}

class ChatView extends StatefulWidget {
  static final routeName = '/chat';

  @override
  State<StatefulWidget> createState() {
    return new ChatViewState();
  }
}

class ChatViewState extends State<ChatView> {
  final inputMessageController = TextEditingController();
  static const platform = const MethodChannel('crypto');

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    inputMessageController.dispose();
    super.dispose();
  }

  _sendMessage({room, roomID}) async {
    if (inputMessageController.text.trim().length > 0) {
      final ChatViewArguments args = ModalRoute.of(context).settings.arguments;
      final roomSecret = Hive.box<Room>('Room').get(args.chatId);
      var msg = json.encode({
        'msg': inputMessageController.text.trim(),
        'sender': FirebaseAuth.instance.currentUser.uid,
        'date': DateFormat(DateFormat.HOUR24_MINUTE).format(DateTime.now())
      });
      var encryptedMessage = await platform.invokeMethod('encryptMessage', {
        'message': msg,
        'roomSecretKey': roomSecret.secretKey[roomSecret.secretKeyVersion]
      });
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomID)
          .collection('Messages')
          .add({
        "encryptedMessage": encryptedMessage['encryptedMessage'],
        'IV': encryptedMessage['IV'],
        "createdAt": Timestamp.now()
      });
      inputMessageController.text = '';
    }
  }

  _inviteMember({chatId}) {
    Navigator.of(context).pushNamed('/invite',
        arguments: InviteViewArguments(
            chatId: chatId));
  }

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
                  onTap: () => Navigator.of(context).pushNamed('/chat/details', arguments: ChatDetailsViewArguments(chatId: args.chatId)),
                  child: Text(room['roomName'])),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.group_add),
                  tooltip: 'Add new members',
                  onPressed: () => _inviteMember(chatId: args.chatId),
                )
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: MessagesList(chatId: args.chatId, chat: chat),
                ),
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1)),
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
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              controller: inputMessageController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Your message..."),
                            ),
                          )),
                          GestureDetector(
                            onTap: () async {
                              _sendMessage(
                                  room: room, roomID: snapshot.data.id);
                            },
                            child: Icon(Icons.send, size: 32),
                          )
                        ],
                      ),
                    ))
              ],
            ),
          );
        });
  }
}

class MessagesList extends StatefulWidget {
  final String chatId;
  final CollectionReference chat;

  MessagesList({@required this.chatId, @required this.chat});

  @override
  State<StatefulWidget> createState() {
    return new MessagesListState(chatId: chatId, chat: chat);
  }
}

class MessagesListState extends State<MessagesList> {
  static const platform = const MethodChannel('crypto');
  final String chatId;
  final CollectionReference chat;
  List messages = List.of([]);
  List existsMessages = List.of([]);
  StreamSubscription<QuerySnapshot> listenerController;

  MessagesListState({@required this.chatId, @required this.chat});

  @override
  void initState() {
    super.initState();
    this.listenMessages();
  }

  @override
  void dispose() {
    super.dispose();
    // this.listenMessages();
    listenerController.cancel();
  }

  listenMessages() {
    final roomSecret = Hive.box<Room>('Room').get(chatId);
    // debugPrint(roomSecret.toString());
    // debugPrint(chatId.toString());
    final streamMessages = chat
        .doc(chatId)
        .collection('Messages')
        .orderBy('createdAt')
        .snapshots();
    listenerController = streamMessages.listen((message) {
      message.docs.forEach((element) async {
        if (existsMessages.contains(element.id)) {
          return;
        } else {
          final decryptedMessage =
              await decryptMessage(element, roomSecret: roomSecret);
          if (this.mounted) {
            setState(() {
              messages.add(decryptedMessage);
              existsMessages.add(element.id);
            });
          }
        }
      });
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
    return messages.length < 1
        ? Center(
            child: Text("Not Have messages"),
          )
        : ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (BuildContext ctx, idx) {
              final msgs = messages.reversed.toList();
              return Bubble(
                body: msgs[idx]['msg'],
                // date: DateFormat("HH:mm").format(DateTime.now()),
                date: msgs[idx]['date'] != null ? msgs[idx]['date'] : DateFormat("HH:mm").format(DateTime.now()),
                isSender:
                    msgs[idx]['sender'] == FirebaseAuth.instance.currentUser.uid
                        ? true
                        : false,
              );
            });
  }
}
