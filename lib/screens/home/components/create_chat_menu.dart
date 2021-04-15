import 'dart:io';

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
  File? roomAvatar;

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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      final String path = result.files.single.path as String;
      final File rawFile = File(path);
      setState(() {
        roomAvatar = rawFile;
      });
    }
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
                                  image: FileImage(roomAvatar as File),
                                  fit: BoxFit.fill,
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
                  child: OutlinedButton(
                    onPressed: () => {},
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
