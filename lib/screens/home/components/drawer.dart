import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
          title: LocaleKeys.home_drawer_specialFeatures.tr(),
          icon: Icons.extension,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_dashboard.tr(),
          icon: Icons.dashboard,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_themes.tr(),
          icon: Icons.color_lens,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_news.tr(),
          icon: Icons.assignment,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_settings.tr(),
          icon: Icons.settings,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_about.tr(),
          icon: Icons.info,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_logout.tr(),
          icon: Icons.logout,
          callback: () {}),
    ];
    return Drawer(
      child: ListView.separated(
          padding: EdgeInsets.zero,
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                width: Config.drawerAvatarSize,
                height: Config.drawerAvatarSize,
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
