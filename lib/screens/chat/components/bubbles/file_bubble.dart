import 'dart:typed_data';

import 'package:exyji/helpers/filesize.dart';
import 'package:flutter/material.dart';

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
              children: [Text(caption), Text(filesize(size))],
            ),
          )
        ],
      ),
    );
  }
}
