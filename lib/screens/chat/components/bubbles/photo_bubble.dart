import 'dart:typed_data';

import 'package:exyji/helpers/file_helper.dart';
import 'package:exyji/helpers/filesize.dart';
import 'package:exyji/helpers/widgets.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PhotoBubble extends StatelessWidget {
  final Uint8List photo;
  final String fileName;
  final String fileExt;
  final int fileSize;

  const PhotoBubble(
      {Key? key,
      required this.photo,
      required this.fileName,
      required this.fileExt,
      required this.fileSize})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 500, maxWidth: 300),
      decoration: BoxDecoration(
          color: Colors.lightBlue[400],
          border: Border.all(width: 1),
          borderRadius: BorderRadius.circular(13)),
      child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => HeroPhotoViewRouteWrapper(
                      fileName: fileName,
                      fileExt: fileExt,
                      fileSize: fileSize,
                      photoData: photo,
                    )));
          },
          child: Padding(
            padding: EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.memory(photo),
            ),
          )),
    );
  }
}

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper(
      {required this.photoData,
      this.backgroundDecoration,
      required this.fileName,
      required this.fileSize,
      required this.fileExt});

  final String fileName;
  final int fileSize;
  final String fileExt;
  final Uint8List photoData;
  final BoxDecoration? backgroundDecoration;

  _showPopupMenu(Offset offset, BuildContext ctx) async {
    double left = offset.dx;
    double top = offset.dy;
    final result = await showMenu(
      context: ctx,
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      items: [
        PopupMenuItem<String>(
            child:
                PopItem(icon: Icons.download, descript: 'Save to downloads.'),
            value: 'save'),
      ],
      elevation: 8.0,
    );
    if (result != null) {
      switch (result) {
        case 'save':
          FileApi.saveToExternal(photoData, [fileName, fileExt].join('.'), ctx);
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0x44000000),
        actions: [
          GestureDetector(
            onTapDown: (TapDownDetails details) {
              _showPopupMenu(details.globalPosition, context);
            },
            child: Padding(
                padding: EdgeInsets.all(15),
                child: const Icon(Icons.more_vert)),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: PhotoView(
              imageProvider: MemoryImage(photoData),
              backgroundDecoration: backgroundDecoration,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 1.8,
              initialScale: PhotoViewComputedScale.contained * 0.9,
              heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 45,
                decoration: BoxDecoration(color: Color(0x46000000)),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Text('$fileName\t${filesize(fileSize)}',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}
