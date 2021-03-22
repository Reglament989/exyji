import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_andro_x/components/circleCachedImage.component.dart';
import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:fl_andro_x/utils/images.utils.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:fl_andro_x/views/createChat.view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class HomeView extends StatefulWidget {
  static final routeName = '/home';

  @override
  State<StatefulWidget> createState() {
    return new HomeViewState();
  }
}

ScrollController _hideButtonController;
var _isVisible;

class HomeViewState extends State<HomeView> {
  //  Current State of InnerDrawerState
  final GlobalKey<InnerDrawerState> _innerDrawerKey =
      GlobalKey<InnerDrawerState>();

  @override
  initState() {
    super.initState();
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_isVisible == true) {
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            setState(() {
              _isVisible = true;
            });
          }
        }
      }
    });
  }

  void _toggleDrawer() {
    _innerDrawerKey.currentState.toggle(
        // direction is optional
        // if not set, the last direction will be used
        //InnerDrawerDirection.start OR InnerDrawerDirection.end
        direction: InnerDrawerDirection.end);
  }

  Future<void> _signOut(context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacementNamed(AppRouter.login);
  }

  void _goToChat(int idx) {
    print('Going to chat $idx');
  }

  Query roomsStream = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection('rooms')
      .orderBy('createdAt')
      .orderBy('lastUpdatedAt');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: roomsStream.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoginLoader();
        }

        return InnerDrawer(
            key: _innerDrawerKey,
            onTapClose: true,
            // default false
            swipe: true,
            // default true
            colorTransitionChild: Colors.red,
            // default Color.black54
            colorTransitionScaffold: Colors.black54,
            // default Color.black54

            //When setting the vertical offset, be sure to use only top or bottom
            offset: IDOffset.only(bottom: 0.05, right: 0.0, left: 0.0),
            scale: IDOffset.horizontal(0.8),
            // set the offset in both directions

            proportionalChildArea: true,
            // default true
            borderRadius: 50,
            // default 0
            leftAnimationType: InnerDrawerAnimation.static,
            // default static
            rightAnimationType: InnerDrawerAnimation.quadratic,
            backgroundDecoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.red, Colors.orange])),
            // default  Theme.of(context).backgroundColor

            //when a pointer that is in contact with the screen and moves to the right or left
            onDragUpdate: (double val, InnerDrawerDirection direction) {
              // return values between 1 and 0
              // print(val);
              // check if the swipe is to the right or to the left
              // print(direction == InnerDrawerDirection.start);
            },
            // innerDrawerCallback: (a) =>
            // print(a), // return  true (open) or false (close)
            leftChild: LeftMenuDrawer(),
            // required if rightChild is not set
            rightChild: RightMenuDrawer(),
            // required if leftChild is not set

            //  A Scaffold is generally used but you are free to use other widgets
            // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
            scaffold: Scaffold(
                appBar: AppBar(
                    title: Text("Andro X"),
                    centerTitle: true,
                    automaticallyImplyLeading: false),
                bottomNavigationBar: CurvedNavigationBar(
                  height: 50,
                  color: Colors.white,
                  buttonBackgroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  animationCurve: Curves.easeInOut,
                  animationDuration: Duration(milliseconds: 600),
                  items: <Widget>[
                    Icon(Icons.add, size: 30),
                    Icon(Icons.list, size: 30),
                    Icon(Icons.compare_arrows, size: 30),
                  ],
                  onTap: (index) {
                    //Handle button tap
                  },
                ),
                floatingActionButton: AnimatedOpacity(
                  opacity: _isVisible ? 1 : 0,
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 300),
                  child: FabCircularMenu(
                      fabSize: 52,
                      ringDiameter: 300,
                      ringWidth: 80,
                      animationCurve: Curves.easeInOutQuint,
                      animationDuration: Duration(milliseconds: 500),
                        children: <Widget>[
                          IconButton(icon: Icon(Icons.edit), onPressed: () async {
                            final roomDefaultPhotoUrl = await firebase_storage
                                .FirebaseStorage.instance
                                .ref(Storage.defaultUserPhoto)
                                .getDownloadURL();
                            Navigator.of(context).pushNamed(AppRouter.createChat,
                                arguments:
                                CreateChatViewArguments(roomDefaultPhotoUrl));
                          }),
                          IconButton(icon: Icon(Icons.search), onPressed: () {
                            Navigator.of(context).pushNamed(AppRouter.acceptInvite);
                          })
                        ]
                    ),
                ),
                body: Container(
                    child: snapshot.data.docs.length > 0
                        ? ListView.separated(
                            separatorBuilder: (context, index) => Divider(
                                  height: 3,
                                  color: Colors.black,
                                ),
                            itemCount: snapshot.data.docs.length,
                            controller: _hideButtonController,
                            itemBuilder: (ctx, idx) {
                              final room = snapshot.data.docs[idx].data();
                              return GestureDetector(
                                  onTap: () => {
                                        Navigator.of(context).pushNamed(
                                            AppRouter.chat,
                                            arguments: ChatViewArguments(
                                                chatId: snapshot.data.docs[idx]
                                                    .data()['chatId']))
                                      },
                                  child: Slidable(
                                    actionPane: SlidableBehindActionPane(),
                                    actions: <Widget>[
                                      IconSlideAction(
                                        caption: 'To Favourites',
                                        color: Colors.red[400],
                                        icon: Icons.favorite,
                                      ),
                                      IconSlideAction(
                                          caption: 'About',
                                          color: Colors.blue,
                                          icon: Icons.info_outline),
                                    ],
                                    secondaryActions: [
                                      IconSlideAction(
                                        caption: 'Archive',
                                        color: Colors.cyan,
                                        icon: Icons.archive,
                                      ),
                                      IconSlideAction(
                                          caption: 'Mute',
                                          color: Colors.grey,
                                          icon: Icons.notifications_off),
                                    ],
                                    child: Container(
                                      color: Colors.white,
                                      child: ListTile(
                                        title: Text(room['roomName']),
                                        subtitle: Text('last message'),
                                        leading: Container(
                                          width: 52,
                                          height: 52,
                                          child: CircleCachedImage(
                                              imageUrl: room['avatar'],
                                              placeholder: Container(
                                                  width: 52,
                                                  height: 52,
                                                  child: Lottie.asset(
                                                      Assets.circleLoader))),
                                        ),
                                        trailing: Icon(Icons.circle),
                                      ),
                                    ),
                                  ));
                            })
                        : Center(
                            child:
                                Text("Just hold on plus for creating new room"),
                          ))));
      },
    );
  }
}

class LeftMenuDrawer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LeftMenuDrawerState();
  }
}

class LeftMenuDrawerState extends State<LeftMenuDrawer> {
  final List data = List.of(
      ['Account', 'Themify', 'Settings', 'Log out', 'Report of bug', 'About']);
  bool _updateAvatar = false;

  @override
  void initState() {
    super.initState();
  }

  Future _changeAvatar() async {
    FilePickerResult result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png'],
    );
    if (result != null) {
      setState(() {
        _updateAvatar = true;
      });
      try {
        final File rawFile = File(result.files.single.path);
        final ref =
            '${Storage.avatarsRef}${FirebaseAuth.instance.currentUser.uid}';
        final avatarUrl = await compressAndPutIntoRef(
            ref: ref, rawFile: rawFile, returnUrl: true);
        await FirebaseAuth.instance.currentUser
            .updateProfile(photoURL: avatarUrl);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser.uid)
            .update({'avatar': avatarUrl});
        setState(() {
          _updateAvatar = false;
        });
      } on firebase_core.FirebaseException catch (e) {
        // e.g, e.code == 'canceled'
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      _updateAvatar
                          ? Container(
                              margin: EdgeInsets.only(top: 150),
                              width: 120,
                              height: 120,
                              child: Lottie.asset(Assets.circleLoader),
                            )
                          : GestureDetector(
                              onLongPress: _changeAvatar,
                              child: Container(
                                width: 120,
                                height: 120,
                                margin: EdgeInsets.only(top: 150),
                                child: CircleCachedImage(
                                  imageUrl: FirebaseAuth
                                      .instance.currentUser.photoURL,
                                  placeholder: Container(
                                    margin: EdgeInsets.only(top: 150),
                                    width: 120,
                                    height: 120,
                                    child: Lottie.asset(Assets.circleLoader),
                                  ),
                                ),
                              )),
                      Container(
                          margin: EdgeInsets.only(top: 275, bottom: 10),
                          child: Text(
                              FirebaseAuth.instance.currentUser.displayName,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2)))
                    ],
                  ),
                  Container(
                    width: 200,
                    height: 370,
                    child: ListView.builder(
                      itemBuilder: (ctx, idx) =>
                          ItemLeftMenuDrawer(data[idx], idx),
                      itemCount: data.length,
                    ),
                  )
                ],
              )),
        ));
  }
}

class ItemLeftMenuDrawer extends StatelessWidget {
  final String titleButton;
  final int indexPush;

  ItemLeftMenuDrawer(this.titleButton, this.indexPush);

  // final List data = List.of(['Account', 'Themify', 'Settings', 'Log out', 'Report of bug', 'About']);
  Future _onItemTap({item, context}) async {
    debugPrint('tapped on $item');
    if (item == 'Log out') {
      await FirebaseAuth.instance.signOut();
      await Hive.deleteBoxFromDisk('SecureStore');
      await Hive.deleteBoxFromDisk('Room');
      await Hive.openBox<SecureStore>('SecureStore');
      await Hive.openBox<Room>('Room');
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    } else if (item == 'About') {
      return showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) => AlertDialog(
            elevation: 24,
                  title: Text('About - Andro X'),
                  content: Text(
                      'The small chat application development of student 17yo on flutter and this chat dreaming be most expandable and most customizable'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _onItemTap(item: titleButton, context: context);
        // await FirebaseAuth.instance.signOut();
        // await Hive.deleteBoxFromDisk('SecureStore');
        // Navigator.of(context).pushReplacementNamed('/login');
      },
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 5),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black, width: 4, style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Text(titleButton),
      ),
    );
  }
}

class RightMenuDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: Hive.box<SecureStore>('SecureStore').listenable(),
        builder: (ctx, Box<dynamic> box, widget) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                    'Coming soon, you can offer what do you want to see here'),
              ),
            ),
          );
        });
  }
}
