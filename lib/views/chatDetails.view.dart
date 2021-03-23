import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/components/bubble.component.dart';
import 'package:fl_andro_x/components/circleCachedImage.component.dart';
import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/utils/images.utils.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ChatDetailsViewArguments {
  final String chatId;

  ChatDetailsViewArguments({this.chatId});
}

class ChatDetailsView extends StatefulWidget {
  static final routeName = '/chat/details';

  @override
  State<StatefulWidget> createState() {
    return new ChatDetailsViewState();
  }
}

enum SecondaryType { members, invites }

class ChatDetailsViewState extends State<ChatDetailsView> {
  static const platform = const MethodChannel('crypto');
  ChatDetailsViewArguments args;
  bool loading = false;
  List secondaryList = [];
  SecondaryType secondaryType = SecondaryType.members;
  final List<dynamic> roomActions = [
    {
      'text': 'Invites',
      'icon': Icon(Icons.group_add),
      'traling': {'count': 0, 'icon': Icon(Icons.circle)}
    },
    {
      'text': 'Notification',
      'icon': Icon(Icons.chat),
      'traling': {'count': 0, 'icon': Icon(Icons.circle)}
    },
    {
      'text': 'Members filter',
      'icon': Icon(Icons.filter_alt_outlined),
      'traling': {'count': 0, 'icon': Icon(Icons.circle)}
    },
    {
      'text': 'Change background',
      'icon': Icon(Icons.gradient_rounded),
      'traling': {'count': 0, 'icon': Icon(Icons.circle)}
    },
    {
      'text': 'Delete room',
      'icon': Icon(
        Icons.close,
        color: Colors.red,
      ),
      'traling': {'count': 0}
    }
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    args = ModalRoute.of(context).settings.arguments;
  }

  Future _changeRoomAvatar() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        loading = true;
      });
      final File rawFile = File(result.files.single.path);
      final newPhotoUrl = await compressImage(
          ref: '${Storage.roomsRef}${args.chatId}',
          rawFile: rawFile,
          returnUrl: true);
      // debugPrint('New photo url $newPhotoUrl');
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(args.chatId)
          .update({'avatar': newPhotoUrl});
      setState(() {
        loading = false;
      });
    }
  }

  Future _onTapAction({String action}) async {
    if (action == 'Invites') {
      debugPrint('Set list to invites');
      secondaryList = (await FirebaseFirestore.instance
              .collection('Rooms')
              .doc(args.chatId)
              .collection('Invites')
              .get())
          .docs
          .map((e) => e.data())
          .toList();
      secondaryType = SecondaryType.invites;
    } else if (action == 'Change background') {
      FilePickerResult result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png'],
      );
      if (result != null) {
        final File rawFile = File(result.files.single.path);
        Directory appDocDir = await getApplicationDocumentsDirectory();
        String targetPath = '${appDocDir.absolute.path}/${args.chatId}-background-${Uuid().v4()}.jpeg';
        final backgroundImageFile = await compressImageAndSaveToFile(rawFile: rawFile, targetPath: targetPath);
        debugPrint(backgroundImageFile.toString());
        final roomDoc = Hive.box<Room>('Room').get(args.chatId);
        if (roomDoc.pathBackground != null) {
          await File(roomDoc.pathBackground).delete();
        }
        roomDoc.pathBackground = backgroundImageFile.path;
        await Hive.box<Room>('Room').put(args.chatId, roomDoc);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference chat =
        FirebaseFirestore.instance.collection('Rooms');
    return FutureBuilder(
      future: chat.doc(args.chatId).get(),
      builder: (BuildContext ctx, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold();
        }

        final room = snapshot.data.data();
        if (secondaryList.length < 1) {
          secondaryList = room['members'];
        }

        // debugPrint(room.toString());

        return Scaffold(
          appBar: AppBar(
            title: Text(room['roomName']),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
          body: Stack(
            children: [
              Positioned(
                top: 0,
                child: loading
                    ? Container(
                        height: 280,
                        child: Lottie.asset(Assets.timeLoader),
                      )
                    : GestureDetector(
                        onLongPress: _changeRoomAvatar,
                        child: Container(
                          height: 280,
                          width: MediaQuery.of(context).size.width * 1,
                          child: CachedNetworkImage(
                            imageUrl: room['avatar'],
                            fit: BoxFit.contain,
                            placeholder: (BuildContext ctx, url) => Container(
                              height: 280,
                              child: Lottie.asset(Assets.timeLoader),
                            ),
                          ),
                        ),
                      ),
              ),
              Container(
                margin: EdgeInsets.only(right: 10, left: 10, top: 300),
                height: 180,
                decoration: BoxDecoration(
                    border: Border.all(width: 3, color: Colors.black),
                    borderRadius: BorderRadius.circular(25)),
                child: ListView.builder(
                  itemCount: roomActions.length,
                  itemBuilder: (BuildContext ctx, idx) {
                    return Container(
                      // decoration: BoxDecoration(
                      //     border: Border.
                      // ),
                      child: GestureDetector(
                        onTap: () =>
                            _onTapAction(action: roomActions[idx]['text']),
                        child: ListTile(
                          leading: roomActions[idx]['icon'],
                          title: Text(roomActions[idx]['text']),
                          trailing: roomActions[idx]['traling']['count'] > 0
                              ? roomActions[idx]['traling']['icon']
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 500),
                child: SecondaryList(
                  array: secondaryList,
                  type: secondaryType,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class SecondaryList extends StatelessWidget {
  final array;
  final type;

  const SecondaryList(
      {Key key, @required List this.array, @required SecondaryType this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Container(padding: EdgeInsets.symmetric(vertical: 3),),
      itemCount: array.length,
      itemBuilder: (BuildContext ctx, idx) {
        final memberFuture = FirebaseFirestore.instance
            .collection('Users')
            .doc(array[idx])
            .get();
        return FutureBuilder(
          future: memberFuture,
          builder: (BuildContext ctx,
              AsyncSnapshot<DocumentSnapshot> memberSnapshot) {
            if (memberSnapshot.hasError) {
              return Text('Something went wrong');
            }

            if (memberSnapshot.connectionState == ConnectionState.waiting) {
              return ListTile();
            }

            final member = memberSnapshot.data.data();

            return UserTile(member: member);
          },
        );
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final member;

  UserTile({Key key, this.member}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          closedBuilder: (BuildContext context, VoidCallback _) => Slidable(
              actionPane: SlidableBehindActionPane(),
              actions: [
                IconSlideAction(
                  caption: 'Remove',
                  color: Colors.red[400],
                  icon: Icons.close,
                )
              ],
              closeOnScroll: true,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.background.withOpacity(0.8)]),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 2
                      )
                    ],
                    border: Border.all(width: 1.1, color: Colors.black.withOpacity(0.3)),
                    borderRadius: BorderRadius.all(Radius.circular(5))
                ),
                child: ListTile(
                    title: Text(member['username']),
                    leading: Container(
                      width: 52,
                      height: 52,
                      child: CircleCachedImage(
                        imageUrl: member['avatar'],
                        placeholder: Container(
                          width: 52,
                          height: 52,
                          child: Lottie.asset(Assets.circleLoader),
                        ),
                      ),
                    )),
              )),
          openBuilder: (BuildContext context, VoidCallback _) => Center(
            child: Text(member['username']),
          )),
    );
  }
}
