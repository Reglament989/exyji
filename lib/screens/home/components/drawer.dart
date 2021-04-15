import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView.separated(
          itemBuilder: (BuildContext ctx, int idx) => DrawerItem(
                ctx: ctx,
                title: idx.toString(),
                idx: idx,
              ),
          separatorBuilder: (BuildContext ctx, idx) => Divider(
                height: 1,
              ),
          itemCount: 20),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final BuildContext ctx;
  final int idx;
  final String title;

  const DrawerItem(
      {Key? key, required this.ctx, required this.idx, required this.title})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (idx == 0) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.red,
        child: Text("Account"),
      );
    }
    return ListTile(
      onTap: () {},
      title: Text(title),
    );
  }
}
