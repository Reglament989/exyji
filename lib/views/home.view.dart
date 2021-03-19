import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:fl_andro_x/views/chat.view.dart';
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
          /* only set when the previous state is false
             * Less widget rebuilds
             */
          // print("**** ${_isVisible} up"); //Move IO away from setState
          setState(() {
            _isVisible = false;
          });
        }
      } else {
        if (_hideButtonController.position.userScrollDirection ==
            ScrollDirection.forward) {
          if (_isVisible == false) {
            /* only set when the previous state is false
               * Less widget rebuilds
               */
            // print("**** ${_isVisible} down"); //Move IO away from setState
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
    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _goToChat(int idx) {
    print('Going to chat $idx');
  }

  CollectionReference rooms = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection('rooms');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: rooms.snapshots(),
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
                    title: Text("Welcome back"),
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
                  child: FloatingActionButton(
                    child: Icon(Icons.add),
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/createChat'),
                  ),
                ),
                body: Container(
                    child: ListView.separated(
                        controller: _hideButtonController,
                        itemBuilder: (ctx, idx) => GestureDetector(
                            onTap: () => {
                                  Navigator.of(context).pushNamed('/chat',
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
                                  title: Text(snapshot.data.docs[idx]
                                      .data()['roomName']),
                                  subtitle: Text('last message'),
                                  leading:
                                      Image.asset('lib/assets/icons/user.png'),
                                  trailing: Icon(Icons.circle),
                                ),
                              ),
                            )),
                        separatorBuilder: (context, index) => Divider(
                              color: Colors.black,
                            ),
                        itemCount: snapshot.data.docs.length))));
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
  final List data = List.of(['Settings', 'About', 'Contibution', 'Report']);
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
      final File rawFile = File(result.files.single.path);
      final Uint8List file = await FlutterImageCompress.compressWithFile(
        rawFile.absolute.path,
        minWidth: 1980,
        minHeight: 1080,
        quality: 50,
      );
      try {
        final ref = 'users/avatars/${FirebaseAuth.instance.currentUser.uid}';
        await firebase_storage.FirebaseStorage.instance.ref(ref).putData(file);
        final avatarUrl = await firebase_storage.FirebaseStorage.instance
            .ref(ref)
            .getDownloadURL();
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
                              child: Lottie.asset(
                                  'lib/assets/lottie/circleLoader.json'),
                            )
                          : GestureDetector(
                              onLongPress: _changeAvatar,
                              child: Container(
                                width: 120,
                                height: 120,
                                margin: EdgeInsets.only(top: 150),
                                child: CachedNetworkImage(
                                  imageUrl: FirebaseAuth
                                      .instance.currentUser.photoURL,
                                  imageBuilder: (ctx, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                        image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.fill,
                                    )),
                                  ),
                                  placeholder: (ctx, url) => Container(
                                    margin: EdgeInsets.only(top: 150),
                                    width: 120,
                                    height: 120,
                                    child: Lottie.asset(
                                        'lib/assets/lottie/circleLoader.json'),
                                  ),
                                ),
                              ),
                            ),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FirebaseAuth.instance.signOut();
        await Hive.deleteBoxFromDisk('SecureStore');
        Navigator.of(context).pushReplacementNamed('/login');
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
          var keys = box.get('store');
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
                child: Container(
              alignment: Alignment.center,
              child: Text(keys.toString()),
            )),
          );
        });
  }
}
