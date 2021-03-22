import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class AcceptInviteView extends StatefulWidget {
  static final routeName = '/invite/accept';
  @override
  State<StatefulWidget> createState() {
    return AcceptInviteViewState();
  }
}

class AcceptInviteViewState extends State<AcceptInviteView> {
  static const platform = const MethodChannel('crypto');
  bool loading = false;
  StreamSubscription<DocumentSnapshot> listenerController;
  final textController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    if (listenerController != null) {
      listenerController.cancel();
    }
  }

  Future tryAcceptInvite({roomId}) async {
    setState(() {
      loading = true;
    });
    final roomRef = FirebaseFirestore.instance.collection('Rooms').doc(roomId).collection('Invites').doc('invite');
    final room = await roomRef.get();
    if (room.exists) {
      bool keeysAccept = false;
      final secureStore = Hive.box<SecureStore>('SecureStore').get('store');
      await roomRef.update({'publicKeySubject': secureStore.publicKeyRsa, 'accepted': [true, {'name': FirebaseAuth.instance.currentUser.displayName, 'id': FirebaseAuth.instance.currentUser.uid}]});
      final stream = roomRef.snapshots();
      listenerController = stream.listen((event) async {
        final data = event.data();
        if (data['encryptedSharedSecret'] != null) {
          if (!keeysAccept) {
            keeysAccept = true;
            final privateRsa = secureStore.privateKeyRsa;
            final decryptedSecretKey = json.decode(await platform.invokeMethod('decryptRoomSecret', {'roomSecretEncrypted': data['encryptedSharedSecret'], 'rsaPrivateKey': privateRsa}));
            final newHiveRoom = new Room();
            newHiveRoom.secretKeyVersion = decryptedSecretKey['secretKeyVersion'];
            newHiveRoom.secretKey = List<String>.from(decryptedSecretKey['secretKeys']);
            await Hive.box<Room>('Room').put(roomId, newHiveRoom);
            await roomRef.update({'successfull': true});
          }
        }
        if (data['finish']) {
          await FirebaseFirestore.instance.collection('Rooms').doc(room.id).collection('Invites').doc('invite').delete();
          listenerController.cancel();
          // await Future.delayed(Duration(seconds: 1));
          Navigator.of(context).pushReplacementNamed(AppRouter.chat, arguments: ChatViewArguments(chatId: roomId));
        }
      });
    } else {
      await HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(Icons.info_outline_rounded)),
            Text(
              'Invite not found.',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
    setState(() {
      loading = false;
    });
  }

  Future _scanQr() async {
    await Permission.camera.request();
    final String cameraScanResult = await scanner.scan();
    await tryAcceptInvite(roomId: cameraScanResult);
  }

  Future _inviteByUid() async {
    if (textController.text.trim().length > 0) {
      await tryAcceptInvite(roomId: textController.text.trim());
    } else {
      await HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(Icons.info_outline_rounded)),
            Text(
              'Invite uid must be.',
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            )
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Invite'), centerTitle: true,),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: _scanQr,
            child: Icon(Icons.qr_code_scanner, size: 350,),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 25),
            child: Text('Or paste uid invite'),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
                controller: textController,
                decoration: InputDecoration(
                  labelText: 'Uid invite',
                  border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide(width: 3)),
                )),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 25),
            child: OutlinedButton(onPressed: _inviteByUid, child: Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              child: Text('Submit'),
            ),),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
