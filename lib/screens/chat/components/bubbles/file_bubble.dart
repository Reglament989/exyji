import 'dart:typed_data';

import 'package:exyji/helpers/filesize.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class FileBubble extends StatelessWidget {
  final Widget extensionImage;
  final String caption;
  final int size;
  final Uint8List data;

  const FileBubble(
      {Key? key,
      required this.extensionImage,
      required this.caption,
      required this.data,
      required this.size})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 110, maxWidth: 250),
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          extensionImage,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      filesize(size),
                      style: TextStyle(fontSize: 11),
                    ),
                    new LinearPercentIndicator(
                      // alignment: MainAxisAlignment.spaceBetween,
                      width: 60.0,
                      lineHeight: 8.0,
                      percent: 0.5,
                      center: Text(
                        "50%",
                        style: TextStyle(fontSize: 8, color: Colors.indigo),
                      ),
                      linearStrokeCap: LinearStrokeCap.roundAll,
                      backgroundColor: Colors.grey,
                      progressColor: Colors.blue,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
