import 'package:exyji/helpers/linkify.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/screens/chat/components/other_bubbels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class Bubble extends StatelessWidget {
  final SlidableController slidableController;
  final String body;
  final String date;
  final sender;
  final bool isSender;
  final bool isReply;
  final String? replyBody;
  final String? replyFrom;
  final Function callbackReply;
  final String uid;
  final bool isMedia;
  final MediaMessage? media;
  Bubble(
      {required this.body,
      required this.date,
      this.isSender = true,
      this.isReply = false,
      this.replyBody,
      this.replyFrom,
      required this.callbackReply,
      required this.uid,
      required this.sender,
      required this.slidableController,
      this.isMedia = false,
      this.media});

  Future<void> _sendReply() async {
    if (isMedia) {
      await callbackReply(uid: uid, replyBody: "Photo", replyFromBody: sender);
      return;
    }
    await callbackReply(uid: uid, replyBody: body, replyFromBody: sender);
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: Key(uid),
      controller: slidableController,
      actionExtentRatio: 0.1,
      actionPane: SlidableScrollActionPane(),
      secondaryActions: [
        IconSlideAction(
          color: Colors.transparent,
          iconWidget: Icon(Icons.reply_all_sharp, color: Colors.black),
          onTap: () => print('replyAll'),
        ),
        IconSlideAction(
          color: Colors.transparent,
          iconWidget: Icon(Icons.reply_sharp, color: Colors.black),
          onTap: _sendReply,
        ),
      ],
      actions: [
        SlideAction(
          child: Text(
            date,
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
      child: Builder(builder: (BuildContext ctx) {
        if (isMedia) {
          return Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                PhotoBubble(
                  photo: media!.data!,
                )
              ],
            ),
          );
        }
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment:
                isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints(maxWidth: 400, minWidth: 35),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                    color: Colors.lightBlue[400],
                    border: Border.all(
                      color: Colors.lightBlue,
                    ),
                    borderRadius: BorderRadius.circular(15)),
                child: isReply
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 3.5, horizontal: 10),
                            decoration: BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        width: 2, color: Colors.black))),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [Text(replyFrom!), Text(replyBody!)],
                            ),
                          ),
                          LinkText(
                              text: body,
                              onOpen: (link) async {
                                await launch(link.url);
                              })
                        ],
                      )
                    : Stack(
                        children: [
                          LinkText(
                              text: body,
                              onOpen: (link) async {
                                await launch(link.url);
                              })
                          // Linkify(
                          //   onOpen: (link) async {
                          //     await launch(link.url);
                          //   },
                          //   text: body,
                          //   textAlign: TextAlign.left,
                          //   textDirection: TextDirection.ltr,
                          //   style: TextStyle(fontSize: 17, color: Colors.black),
                          //   linkStyle: TextStyle(color: Colors.indigo),
                          // ),
                        ],
                      ),
              )
            ],
          ),
        );
      }),
    );
  }
}
