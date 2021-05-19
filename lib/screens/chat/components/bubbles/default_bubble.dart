import 'package:flutter/material.dart';

class DefaultBubble extends StatelessWidget {
  final Widget extensibleBubble;
  final bool isSender;
  final bool isReply;
  final String? replyFrom;
  final String? replyBody;

  const DefaultBubble(
      {Key? key,
      required this.extensibleBubble,
      required this.isSender,
      required this.isReply,
      this.replyFrom,
      this.replyBody})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext ctx) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                constraints: BoxConstraints(maxWidth: 400, minWidth: 35),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                padding: isReply ? EdgeInsets.all(8) : null,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isReply)
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 3.5, horizontal: 10),
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                            border: Border(
                                left:
                                    BorderSide(width: 2, color: Colors.black))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(replyFrom!), Text(replyBody!)],
                        ),
                      ),
                    extensibleBubble
                  ],
                ))
          ],
        ),
      );
    });
  }
}
