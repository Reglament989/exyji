import 'package:flutter/material.dart';

class Bubble extends StatelessWidget {
  final String body;
  final String date;
  final bool isSender;
  Bubble({@required this.body, @required this.date, @required this.isSender});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 400, minWidth: 35),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
              color: Colors.lightBlue[400],
              border: Border.all(
                color: Colors.lightBlue,
              ),
              borderRadius: BorderRadius.circular(15)),
          child: Stack(
            children: [
              SelectableText(
                body,
                textAlign: TextAlign.start,
                textDirection: TextDirection.ltr,
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
              // Positioned(
              //     bottom: 0,
              //     right: -14,
              //     child: Container(
              //       margin: isSender ? EdgeInsets.only(left: 140) : EdgeInsets.only(right: 140),
              //       child: Text(date,
              //           style:
              //               TextStyle(color: Colors.grey[800], fontSize: 12)),
              //     ))
            ],
          ),
        )
      ],
    );
  }
}


