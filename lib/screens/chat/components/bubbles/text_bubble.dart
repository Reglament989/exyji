import 'package:exyji/helpers/linkify.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TextBubble extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry? padding;

  const TextBubble({Key? key, required this.text, this.padding})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Stack(children: [
        LinkText(
            text: text,
            onOpen: (link) async {
              await launch(link.url);
            })
      ]),
    );
  }
}
