import 'package:exyji/constants.dart';
import 'package:exyji/helpers/filesize.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/screens/chat/components/bubbles/default_bubble.dart';
import 'package:exyji/screens/chat/components/bubbles/file_bubble.dart';
import 'package:exyji/screens/chat/components/bubbles/photo_bubble.dart';
import 'package:exyji/screens/chat/components/bubbles/text_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
          iconWidget: Icon(Icons.reply_all_sharp, color: Colors.white),
          onTap: () => print('replyAll'),
        ),
        IconSlideAction(
          color: Colors.transparent,
          iconWidget: Icon(Icons.reply_sharp, color: Colors.white),
          onTap: _sendReply,
        ),
      ],
      actions: [
        SlideAction(
          child: Text(
            date,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      child: Builder(builder: (context) {
        Widget extensibleBubble = TextBubble(
          text: body,
          padding: isReply ? null : EdgeInsets.all(8),
        );
        if (isMedia) {
          extensibleBubble = MediaBubble(media: media!);
        }
        return DefaultBubble(
          isReply: isReply,
          isSender: isSender,
          replyBody: replyBody,
          replyFrom: replyFrom,
          extensibleBubble: extensibleBubble,
        );
      }),
    );
  }
}

class MediaBubble extends StatelessWidget {
  final MediaMessage media;

  const MediaBubble({Key? key, required this.media}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (imageExtension.contains(media.fileExtension)) {
      return PhotoBubble(
          photo: media.data,
          fileName: media.caption,
          fileExt: media.fileExtension,
          fileSize: media.size);
    }
    if (soundExtension.contains(media.fileExtension)) {}
    String asset = Assets.unknownFile;
    switch (media.fileExtension) {
      case 'txt':
        asset = Assets.txtFile;
        break;
      case 'pdf':
        asset = Assets.pdfFile;
        break;
      case 'zip':
        asset = Assets.zipFile;
        break;
    }
    return FileBubble(
        extensionImage: SizedBox(
          width: 30,
          height: 30,
          child: SvgPicture.asset(asset),
        ),
        size: media.size,
        caption: media.caption,
        data: media.data);
  }
}
