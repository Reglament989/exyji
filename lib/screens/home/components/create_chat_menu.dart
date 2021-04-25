import 'dart:io';
import 'dart:typed_data';

import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/helpers/file_helper.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/hivedb/room_cache.model.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';

enum PageViewStruct { all, contact, channels, bots }

class CreateChatMenu extends StatefulWidget {
  final int currentIndexOfPageView;
  CreateChatMenu({required this.currentIndexOfPageView});
  @override
  _CreateChatMenuState createState() =>
      _CreateChatMenuState(currentIndexOfPageView: currentIndexOfPageView);
}

class _CreateChatMenuState extends State<CreateChatMenu> {
  final roomNameController = TextEditingController();
  final roomDescriptionController = TextEditingController();
  final int currentIndexOfPageView;
  late final String roomTypeDescriptor;
  late final RoomType roomType;
  bool loading = false;
  bool _roomUpdate = false;
  Uint8List? roomAvatar;

  _CreateChatMenuState({required this.currentIndexOfPageView});

  @override
  void initState() {
    switch (currentIndexOfPageView) {
      case 1:
        roomTypeDescriptor = "contact room";
        roomType = RoomType.contact;
        break;
      case 2:
        roomTypeDescriptor = "channel";
        roomType = RoomType.channel;
        break;
      case 3:
        roomTypeDescriptor = "bot";
        roomType = RoomType.bot;
        break;
      default:
        roomTypeDescriptor = "room";
        roomType = RoomType.contact;
    }
    super.initState();
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
    // args = ModalRoute.of(context).settings.arguments;
    super.didChangeDependencies();
  }

  Future _createNewRoom() async {
    if (roomNameController.text.trim().length > 0) {
      final newRoom = RoomModel();
      // newRoom.members = [im]
      newRoom.title = roomNameController.text.trim();
      newRoom.type = roomType;
      await Hive.box<RoomModel>("Rooms").add(newRoom);
      await Hive.openBox<MessagesModel>("Room-${newRoom.uid}");
      await Hive.openBox<RoomCache>("Room-${newRoom.uid}-cache");
      Navigator.of(context).pop();
    }
  }

  Future _changeRoomPhoto() async {
    final rawFile = await FileApi.pick(extensions: ['jpg', 'png']);
    setState(() {
      roomAvatar = rawFile!.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New $roomTypeDescriptor'),
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
                        labelText:
                            LocaleKeys.home_createChatMenu_labelRoomName.tr(),
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
                          labelText: LocaleKeys
                              .home_createChatMenu_labelRoomDescription
                              .tr(),
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
                    onPressed: () => _createNewRoom(),
                    label: Text(
                      LocaleKeys.home_createChatMenu_createButton.tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                    icon: Icon(Icons.create),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
