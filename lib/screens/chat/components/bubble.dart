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
  final String replyBody;
  final String replyFrom;
  final Function callbackReply;
  final String uid;
  Bubble(
      {required this.body,
      required this.date,
      this.isSender = true,
      this.isReply = false,
      this.replyBody = "",
      this.replyFrom = "",
      required this.callbackReply,
      required this.uid,
      required this.sender,
      required this.slidableController});
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
          onTap: () =>
              callbackReply(uid: uid, replyBody: body, replyFromBody: sender),
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
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 400, minWidth: 35),
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                          padding:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                          decoration: BoxDecoration(
                              border: Border(
                                  left: BorderSide(
                                      width: 2, color: Colors.black))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [Text(replyFrom), Text(replyBody)],
                          ),
                        ),
                        SelectableLinkify(
                          onOpen: (link) async {
                            if (await canLaunch(link.url)) {
                              await launch(link.url);
                            }
                          },
                          text: body,
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 17, color: Colors.black),
                          linkStyle: TextStyle(color: Colors.red),
                        )
                      ],
                    )
                  : Stack(
                      children: [
                        SelectableLinkify(
                          onOpen: (link) async {
                            await launch(link.url);
                          },
                          text: body,
                          textAlign: TextAlign.left,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(fontSize: 17, color: Colors.black),
                          linkStyle: TextStyle(color: Colors.indigo),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}
