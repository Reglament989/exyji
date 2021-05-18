import 'dart:typed_data';

import 'package:flutter/material.dart';

class PhotoBubble extends StatelessWidget {
  final Uint8List photo;

  const PhotoBubble({Key? key, required this.photo}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        constraints: BoxConstraints(maxHeight: 500, maxWidth: 300),
        decoration: BoxDecoration(
            color: Colors.lightBlue[400],
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(13)),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.memory(photo),
          ),
        ),
      ),
    );
  }
}

class FileBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
