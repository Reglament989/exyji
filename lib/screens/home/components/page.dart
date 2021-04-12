import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:uuid/uuid.dart';
import 'package:cached_network_image/cached_network_image.dart';

const uuid = Uuid();

class BodyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
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
    return Slidable(
        key: key,
        actionPane: SlidableScrollActionPane(),
        child: ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Container(
            width: 56,
            height: 56,
            child: Center(
              child: ,
            ),
          ),
        ),
        closeOnScroll: true,
        // actions: [
        //   IconSlideAction(
        //     caption: "hello",
        //     icon: Icons.access_time,
        //   )
        // ],
        dismissal: SlidableDismissal(
            child: SlidableDrawerDismissal(),
            onDismissed: (actionType) {
              print(actionType);
            },
            dismissThresholds: <SlideActionType, double>{
              SlideActionType.primary: 0.2
            }));
  }
}
