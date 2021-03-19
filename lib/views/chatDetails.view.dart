import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/components/bubble.component.dart';
import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/encryption/main.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

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

class ChatDetailsViewState extends State<ChatDetailsView> {
  static const platform = const MethodChannel('crypto');
  final List<dynamic> roomActions = [
    {'text': 'Invites', 'icon': Icon(Icons.group_add), 'traling': {'count': 0, 'icon': Icon(Icons.circle)}},
    {'text': 'Notification', 'icon': Icon(Icons.chat), 'traling': {'count': 0, 'icon': Icon(Icons.circle)}},
    {'text': 'Members filter', 'icon': Icon(Icons.filter_alt_outlined), 'traling': {'count': 0, 'icon': Icon(Icons.circle)}},
  ];

  @override
  Widget build(BuildContext context) {
    final ChatDetailsViewArguments args =
        ModalRoute.of(context).settings.arguments;
    final chat = FirebaseFirestore.instance.collection('Rooms');
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

        return Scaffold(
          appBar: AppBar(
            title: Text(room['roomName']),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.transparent,
          ),
          body: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 20),
                height: 200,
                child:
                    Image.asset('lib/assets/icons/user.png', fit: BoxFit.fill),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(width: 3, color: Colors.black),
                  borderRadius: BorderRadius.circular(25)
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: roomActions.length,
                  itemBuilder: (BuildContext ctx, idx) {
                    return Container(
                      // decoration: BoxDecoration(
                      //     border: Border.
                      // ),
                      child: ListTile(
                        leading: roomActions[idx]['icon'],
                        title: Text(roomActions[idx]['text']),
                        trailing: roomActions[idx]['traling']['count'] > 0 ? roomActions[idx]['traling']['icon'] : null,
                      ),
                    );
                  },
                ),
              ),
              ListView.separated(
                separatorBuilder: (context, index) => Divider(
                  color: Colors.black,
                ),
                itemCount: room['members'].length,
                itemBuilder: (BuildContext ctx, idx) {
                  final memberFuture = FirebaseFirestore.instance.collection('Users').doc(room['members'][idx]).get();
                  return FutureBuilder(
                    future: memberFuture,
                    builder: (BuildContext ctx, AsyncSnapshot<DocumentSnapshot> memberSnapshot) {
                      if (memberSnapshot.hasError) {
                        return Text('Something went wrong');
                      }

                      if (memberSnapshot.connectionState == ConnectionState.waiting) {
                        return Scaffold();
                      }

                      final member = memberSnapshot.data.data();

                      return ListTile(title: Text(member['username']), leading: Image.network(member['avatar']));
                    },
                  );
                },
              )
            ],
          ),
        );
      },
    );
  }
}
