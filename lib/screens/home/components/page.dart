import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

const uuid = Uuid();

class BodyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.separated(
          itemCount: 20,
          separatorBuilder: (BuildContext ctx, idx) => Divider(
                indent: 64,
                endIndent: 18,
                height: 1,
                color: Colors.black.withOpacity(0.6),
              ),
          itemBuilder: (BuildContext ctx, idx) => ListItem(
                ctx: ctx,
                idx: idx,
                key: Key(uuid.v4()),
                title: "Hello",
                subtitle: "How are you?",
                icon: "https://source.unsplash.com/random/56x56",
              )),
    );
  }
}

class ListItem extends StatelessWidget {
  final ctx, idx;
  final String title, subtitle, icon;

  const ListItem(
      {Key? key,
      required this.ctx,
      required this.idx,
      required this.title,
      required this.subtitle,
      required this.icon})
      : assert(ctx != null, idx != null),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Container(
          width: 56,
          height: 56,
          child: Center(
            child: CachedNetworkImage(
              imageUrl: icon,
              imageBuilder: (ctx, imageProvider) => Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )),
              ),
            ),
          ),
        ));
  }
}
