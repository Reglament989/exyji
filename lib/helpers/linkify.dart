import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class LinkText extends StatelessWidget {
  final String text;
  final Function(LinkableElement) onOpen;

  const LinkText({Key? key, required this.text, required this.onOpen})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final elements = linkify(
      text,
      options: const LinkifyOptions(),
      linkifiers: defaultLinkifiers,
    );

    return RichText(
        text: TextSpan(
      style: TextStyle(color: Colors.black),
      children: elements.map<InlineSpan>(
        (element) {
          if (element is LinkableElement) {
            return TextSpan(
                text: element.text,
                style: TextStyle(
                    color: Colors.indigo, decoration: TextDecoration.underline),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => onOpen(element));
          } else {
            return TextSpan(
              text: element.text,
              // style: style,
            );
          }
        },
      ).toList(),
    ));
  }
}

const _urlLinkifier = UrlLinkifier();
const _emailLinkifier = EmailLinkifier();
const defaultLinkifiers = [_urlLinkifier, _emailLinkifier];

List<LinkifyElement> linkify(
  String text, {
  LinkifyOptions options = const LinkifyOptions(),
  List<Linkifier> linkifiers = defaultLinkifiers,
}) {
  var list = <LinkifyElement>[TextElement(text)];

  if (text.isEmpty) {
    return [];
  }

  if (linkifiers.isEmpty) {
    return list;
  }

  linkifiers.forEach((linkifier) {
    list = linkifier.parse(list, options);
  });

  return list;
}
