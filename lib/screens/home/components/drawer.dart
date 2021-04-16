import 'package:fl_reload/constants.dart';
import 'package:flutter/material.dart';

class DrawerSpecItem {
  final String title;
  final IconData icon;
  final Function callback;
  // trailing

  DrawerSpecItem(
      {required this.title, required this.icon, required this.callback});
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<DrawerSpecItem> drawerItems = [
      DrawerSpecItem(
          title: "Image Header (It not visible)",
          icon: Icons.info,
          callback: () {}),
      DrawerSpecItem(
          title: "Special features", icon: Icons.extension, callback: () {}),
      DrawerSpecItem(
          title: "Dashboard", icon: Icons.dashboard, callback: () {}),
      DrawerSpecItem(title: "Themes", icon: Icons.color_lens, callback: () {}),
      DrawerSpecItem(title: "News", icon: Icons.assignment, callback: () {}),
      DrawerSpecItem(title: "Settings", icon: Icons.settings, callback: () {}),
      DrawerSpecItem(title: "About", icon: Icons.info, callback: () {}),
      DrawerSpecItem(title: "Log out", icon: Icons.logout, callback: () {}),
    ];
    return Drawer(
      child: ListView.separated(
          itemBuilder: (BuildContext ctx, int idx) => DrawerItem(
              ctx: ctx,
              title: drawerItems[idx].title,
              icon: drawerItems[idx].icon,
              idx: idx,
              callback: drawerItems[idx].callback),
          separatorBuilder: (BuildContext ctx, idx) => Divider(
                height: 1,
              ),
          itemCount: drawerItems.length),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final BuildContext ctx;
  final int idx;
  final String title;
  final IconData icon;
  final Function callback;

  const DrawerItem(
      {Key? key,
      required this.ctx,
      required this.idx,
      required this.title,
      required this.icon,
      required this.callback})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (idx == 0) {
      return Container(
        height: Config.drawerHeight,
        width: double.infinity,
        color: Colors.red,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  border: Border.all(),
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: const Text(
                    "Account",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                  child: const Text(
                    "Id",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }
    return ListTile(
      onTap: () => callback(),
      leading: Icon(
        icon,
        color: Colors.black.withOpacity(0.8),
      ),
      title: Text(title),
    );
  }
}
