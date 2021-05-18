import 'dart:typed_data';

import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/helpers/file_helper.dart';
import 'package:exyji/hivedb/global.model.dart';
import 'package:exyji/screens/about/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

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
      // DrawerSpecItem(
      //     title: LocaleKeys.home_drawer_news.tr(),
      //     icon: Icons.assignment,
      //     callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_settings.tr(),
          icon: Icons.settings,
          callback: () {}),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_about.tr(),
          icon: Icons.info,
          callback: () {
            Navigator.of(context).pushNamed(AppRouter.about);
          }),
      DrawerSpecItem(
          title: LocaleKeys.home_drawer_logout.tr(),
          icon: Icons.logout,
          callback: () {}),
    ];
    return Drawer(
      child: Column(
        children: [
          Expanded(
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
                  itemCount: drawerItems.length)),
          Padding(
            padding: EdgeInsets.all(7),
            child: Text(
              "Version: alfa",
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          )
        ],
      ),
    );
  }
}

class DrawerItem extends StatefulWidget {
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
  _DrawerItemState createState() => _DrawerItemState(
      callback: callback, idx: idx, title: title, icon: icon, ctx: ctx);
}

class _DrawerItemState extends State<DrawerItem> {
  final BuildContext ctx;
  final int idx;
  final String title;
  final IconData icon;
  final Function callback;
  late Uint8List? avatar;

  @override
  void initState() {
    final global = Hive.box<Global>('Global').get('global');
    avatar = global?.avatar;
    super.initState();
  }

  Future<void> _changePhotoProfile() async {
    final List<Uint8List>? file =
        await FileApi.pick(extensions: ['jpg', 'png']);
    if (file == null) {
      return;
    }
    final global = Hive.box<Global>('Global').get('global')!;
    global..avatar = file.first;
    global.save();
    setState(() {
      avatar = file.first;
    });
  }

  _DrawerItemState(
      {required this.ctx,
      required this.idx,
      required this.title,
      required this.icon,
      required this.callback});
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
              child: InkWell(
                onTap: _changePhotoProfile,
                child: Container(
                    width: Config.drawerAvatarSize,
                    height: Config.drawerAvatarSize,
                    decoration: avatar != null
                        ? BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            image: DecorationImage(
                                image: MemoryImage(avatar!), fit: BoxFit.fill))
                        : BoxDecoration(
                            color: Colors.amber,
                            border: Border.all(),
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                          )),
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
