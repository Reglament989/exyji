import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_reload/hivedb/messages.model.dart';
import 'package:fl_reload/hivedb/room.model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'bubble.dart';

class MessagesList extends StatelessWidget {
  MessagesList({Key? key, required this.room, required this.replyCallback})
      : super(key: key);

  final RoomModel room;
  final replyCallback;
  final SlidableController slidableController = SlidableController();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<MessagesModel>("Room-${room.uid}").listenable(),
      builder: (BuildContext ctx, Box<MessagesModel> box, widget) {
        final messages = box.values.toList().reversed.toList();
        return Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                      "https://source.unsplash.com/random"))),
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (BuildContext ctx, idx) => Bubble(
              isMedia: messages[idx].media != null ? true : false,
              isReply: messages[idx].reply != null ? true : false,
              replyBody: messages[idx].reply?.body,
              replyFrom: messages[idx].reply?.from,
              slidableController: slidableController,
              callbackReply: replyCallback,
              date: DateFormat.Hm().format(messages[idx].createdAt),
              media: messages[idx].media,
              uid: messages[idx].uid,
              sender: messages[idx].senderUid,
              isSender: messages[idx].senderUid == "me" ? true : false,
              body: messages[idx].messageData,
            ),
          ),
        );
      },
    );
  }
}
