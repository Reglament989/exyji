import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/components/circleCachedImage.component.dart';
import 'package:fl_andro_x/components/fullscreenLoader.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:fl_andro_x/utils/images.utils.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:lottie/lottie.dart';

class CreateChatViewArguments {
  final roomDefaultPhotoUrl;

  CreateChatViewArguments(this.roomDefaultPhotoUrl);
}

class CreateChatView extends StatefulWidget {
  static final routeName = '/createChat';

  @override
  State<StatefulWidget> createState() {
    return new CreateChatViewState();
  }
}

class CreateChatViewState extends State<CreateChatView> {
  static const platform = const MethodChannel('crypto');
  CreateChatViewArguments args;
  final roomNameController = TextEditingController();
  final roomDescriptionController = TextEditingController();
  bool loading = false;
  bool _roomUpdate = false;
  File roomAvatar;

  Future _createNewRoom() async {
    if (roomDescriptionController.text.trim().length >= 0 &&
        roomNameController.text.trim().length >= 4) {
      setState(() {
        loading = true;
      });
      final newRoom = await FirebaseFirestore.instance.collection('Rooms').add({
        'roomName': roomNameController.text.trim(),
        'members': [FirebaseAuth.instance.currentUser.uid],
        'owner': FirebaseAuth.instance.currentUser.uid,
        'roomType': RoomType.contact.index,
        'lastUpdatedAt': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });
      await newRoom.update({'avatar': await _getRoomAvatar(newRoom.id)});
      final secretRoom = await platform.invokeMethod('generateRoomSecret');
      final Room room = new Room();
      room.secretKey = List.of([secretRoom]);
      room.secretKeyVersion = 0;
      room.messages = [];
      final backupSecret = await platform.invokeMethod('encryptRoomSecret', {
        'roomSecret': json.encode({
          'secretKey': room.secretKey,
          'secretKeyVersion': room.secretKeyVersion
        }),
        'rsaPublicKey':
            Hive.box<SecureStore>('SecureStore').get('store').publicKeyRsa
      });
      await FirebaseFirestore.instance.collection('Users').doc(FirebaseAuth.instance.currentUser.uid).collection('rooms').doc(newRoom.id).set({'backup': backupSecret});
      await Hive.box<Room>('Room').put(newRoom.id, room);
      Navigator.pushReplacementNamed(context, '/chat',
          arguments: ChatViewArguments(chatId: newRoom.id)); //argumetns: ???
    } else {
      await HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: Icon(Icons.info_outline_rounded)),
            Text(
              'Room name should be longer than 3',
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

  Future _getRoomAvatar(roomId) async {
    if (roomAvatar != null) {
      final ref = '${Storage.roomsRef}/$roomId';
      return await compressImage(
          ref: ref, rawFile: roomAvatar, returnUrl: true);
    } else {
      return args.roomDefaultPhotoUrl;
    }
  }

  Future _changeRoomPhoto() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      final File rawFile = File(result.files.single.path);
      setState(() {
        roomAvatar = rawFile;
      });
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    roomNameController.dispose();
    roomDescriptionController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    args = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New room.'),
      ),
      body: loading
          ? Center(child: BluredLoader())
          : Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: _changeRoomPhoto,
                    child: Container(
                      width: 120,
                      height: 120,
                      margin: EdgeInsets.only(top: 30),
                      child: _roomUpdate
                          ? Lottie.asset(Assets.circleLoader)
                          : roomAvatar != null
                              ? Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: FileImage(roomAvatar),
                                        fit: BoxFit.fill,
                                      )),
                                )
                              : CircleCachedImage(
                                  imageUrl: args.roomDefaultPhotoUrl,
                                  placeholder: Container(),
                                ),
                    ),
                  ),
                  Form(
                      child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 15),
                        width: 250,
                        child: TextFormField(
                            controller: roomNameController,
                            maxLength: 21,
                            decoration: InputDecoration(
                              labelText: 'Room name',
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(width: 3)),
                            )),
                      ),
                      Container(
                          width: 350,
                          child: TextFormField(
                              controller: roomDescriptionController,
                              maxLines: 4,
                              maxLength: 300,
                              decoration: InputDecoration(
                                labelText: 'Room description',
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(width: 3)),
                              ))),
                      Container(
                        alignment: Alignment.center,
                        width: 200,
                        height: 65,
                        child: OutlinedButton(
                          onPressed: _createNewRoom,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Create new room.'),
                                Icon(Icons.create),
                              ]),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.all(8),
                            shape: StadiumBorder(),
                            side: BorderSide(width: 2, color: Colors.indigo),
                          ),
                        ),
                      ),
                    ],
                  ))
                ],
              ),
            ),
    );
  }
}
