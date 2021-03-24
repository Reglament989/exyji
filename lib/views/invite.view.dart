import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

class InviteViewArguments {
  final String chatId;

  InviteViewArguments({this.chatId});
}

class InviteView extends StatefulWidget {
  static final routeName = '/invite';

  @override
  State<StatefulWidget> createState() {
    return InviteViewState();
  }
}

class InviteViewState extends State<InviteView> {
  static const platform = const MethodChannel('crypto');
  InviteViewArguments args;
  bool loading = true;
  String _status = 'Waiting for subscribers';
  StreamSubscription<DocumentSnapshot> listenerController;
  bool isFinish = false;
  bool sended = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              child: Text(
                "Share this qr code or url for invite someone to your room",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            QrImage(
              data: args.chatId,
              version: QrVersions.auto,
              size: 400.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Container(
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Text(_status),
              )],
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 30),
              child: TextButton(
                  onPressed: () => Share.share(args.chatId.toString(),
                      subject: 'Link for joining in my room'),
                  child: Text("Click to share link")),
            )
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
    this.initInvite();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  dispose() async {
    super.dispose();
    await listenerController.cancel();
    if (!isFinish) {
      await FirebaseFirestore.instance.collection('Rooms').doc(args.chatId).collection('Invites').doc('invite').delete();
    }
  }

  Future initInvite() async {
    await FirebaseFirestore.instance
        .collection('Rooms')
        .doc(args.chatId)
        .collection('Invites')
        .doc('invite')
        .set({
      'finish': false,
      'successfull': false,
      'accepted': [false, null],
      'publicKeySubject': null,
      'encryptedSharedSecret': null,
    });
    final stream = FirebaseFirestore.instance
        .collection('Rooms')
        .doc(args.chatId)
        .collection('Invites')
        .doc('invite')
        .snapshots();
    listenerController = stream.listen((event) async {
      if (this.mounted) {
        final data = event.data();
        if (data['successfull']) {
          setState(() {
            _status = 'Adding new member to room';
          });
          final List members = (await FirebaseFirestore.instance.collection('Rooms').doc(args.chatId).get()).data()['members'];
          if (!members.contains(data['accepted'][1]['id'])) {
            await FirebaseFirestore.instance.collection('Rooms').doc(args.chatId).update({'members': [...members, data['accepted'][1]['id']]});
          }
          await FirebaseFirestore.instance.collection('Rooms').doc(args.chatId).collection('Invites').doc('invite').update({'finish': true});
          setState(() {
            isFinish = true;
          });
          await Future.delayed(Duration(seconds: 1));
          listenerController.cancel();
          Navigator.of(context).popAndPushNamed(AppRouter.chat, arguments: ChatViewArguments(chatId: args.chatId));
          return;
        }
        if (data['publicKeySubject'] != null) {
          if (sended != true) {
            setState(() {
              sended = true;
              _status = 'Public key recived encrypt...';
            });
            final roomSecret = Hive.box<Room>('Room').get(args.chatId);
            final encryptedSharedSecret =
            await platform.invokeMethod('encryptRoomSecret', {
              'roomSecret': json.encode({'secretKeys': roomSecret.secretKey, 'secretKeyVersion': roomSecret.secretKeyVersion}),
              'rsaPublicKey': data['publicKeySubject']
            });
            await FirebaseFirestore.instance
                .collection('Rooms')
                .doc(args.chatId)
                .collection('Invites')
                .doc('invite')
                .update({
              'encryptedSharedSecret': encryptedSharedSecret
            });
            setState(() {
              _status = 'Keys sended';
            });
            await Future.delayed(Duration(seconds: 1));
          }
        }
        if (data['accepted'][0]) {
          setState(() {
            _status = 'Accepted by ${data['accepted'][1]['name']}';
          });
          await Future.delayed(Duration(seconds: 1));
          return;
        }
      }
    });
  }
}
