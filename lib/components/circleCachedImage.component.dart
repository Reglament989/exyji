import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_andro_x/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CircleCachedImage extends StatelessWidget {
  final String imageUrl;
  final placeholder;

  const CircleCachedImage(
      {Key key, @required this.imageUrl, @required this.placeholder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (ctx, imageProvider) => Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            )),
      ),
      placeholder: (ctx, url) => placeholder,
    );
  }
}
