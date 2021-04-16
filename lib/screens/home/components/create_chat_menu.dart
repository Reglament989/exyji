import 'dart:io';
import 'dart:typed_data';

import 'package:fl_reload/helpers/file_helper.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class CreateChatMenu extends StatefulWidget {
  @override
  _CreateChatMenuState createState() => _CreateChatMenuState();
}

class _CreateChatMenuState extends State<CreateChatMenu> {
  final roomNameController = TextEditingController();
  final roomDescriptionController = TextEditingController();
  bool loading = false;
  bool _roomUpdate = false;
  Uint8List? roomAvatar;

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
    // args = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  Future _changeRoomPhoto() async {
    final rawFile =
        await FileApi.pick(extensions: ['jpg', 'png']);
    setState(() {
      roomAvatar = rawFile!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New room'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            GestureDetector(
              onTap: _changeRoomPhoto,
              child: Container(
                width: 120,
                height: 120,
                margin: EdgeInsets.only(top: 30),
                child: _roomUpdate
                    ? LinearProgressIndicator()
                    : roomAvatar != null
                        ? Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: Image.memory(roomAvatar!).image,
                                  fit: BoxFit.cover,
                                )),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.red),
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
                  child: ElevatedButton.icon(
                    onPressed: () => {},
                    label: Text('Create', style: TextStyle(fontSize: 16),),
                    icon: Icon(Icons.create),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                      shape: StadiumBorder(),
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
