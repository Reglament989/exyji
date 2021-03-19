import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';

class CreateChatView extends StatefulWidget {
  static final routeName = '/createChat';
  @override
  State<StatefulWidget> createState() {
    return new CreateChatViewState();
  }
}

class CreateChatViewState extends State<CreateChatView> {
  final roomNameController = TextEditingController();
  final roomDescriptionController = TextEditingController();
  static const platform = const MethodChannel('crypto');

  Future _createNewRoom() async {
    if (roomDescriptionController.text.trim().length >= 0 &&
        roomNameController.text.trim().length > 4) {
      final newRoom = await FirebaseFirestore.instance.collection('Rooms').add({
        'roomName': roomNameController.text.trim(),
        'members': [FirebaseAuth.instance.currentUser.uid],
        'owner': FirebaseAuth.instance.currentUser.uid
      });
      final secretRoom = await platform.invokeMethod('generateRoomSecret');
      final Room room = new Room();
      room.secretKey = List.of([secretRoom]);
      room.secretKeyVersion = 0;
      await Hive.box<Room>('Room').put(newRoom.id, room);
      Navigator.pushReplacementNamed(context, '/chat', arguments: ChatViewArguments(chatId: newRoom.id)); //argumetns: ???
    } else {
      print('error');
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New room.'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              margin: EdgeInsets.only(top: 30),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          'https://source.unsplash.com/random/120x120'))),
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
                            borderRadius: BorderRadius.all(Radius.circular(15)),
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
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
