import 'package:flutter/material.dart';

class ReplyContent extends StatelessWidget {
  final String replyBody;
  final Function closeCallback;

  const ReplyContent(
      {Key? key, required this.replyBody, required this.closeCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.cyan[500],
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                      border: Border(
                          left: BorderSide(width: 2, color: Colors.black))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(replyBody),
                      )
                    ],
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async => await closeCallback(),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close),
              ),
            )
          ]),
    );
  }
}
