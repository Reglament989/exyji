import 'package:exyji/constants.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/screens/discover/discover_screen.dart';
import 'package:exyji/screens/home/home_screen.dart';
import 'package:exyji/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'hivedb/room_cache.model.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(RoomModelAdapter());
  Hive.registerAdapter(RoomTypeAdapter());
  Hive.registerAdapter(MessagesModelAdapter());
  Hive.registerAdapter(EncryptedBlockAdapter());
  Hive.registerAdapter(RoomCacheAdapter());
  Hive.registerAdapter(ReplyModelAdapter());
  Hive.registerAdapter(MediaMessageAdapter());
  Hive.registerAdapter(TypeMessageAdapter());

  final rooms = await Hive.openBox<RoomModel>("Rooms");
  await Future.forEach(rooms.values, (RoomModel r) async {
    await Hive.openBox<MessagesModel>("Room-${r.uid}");
    await Hive.openBox<RoomCache>("Room-${r.uid}-cache");
  });
  // await rooms.deleteFromDisk();
  // await Hive.openBox("Global");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Andro X',
      routes: {
        AppRouter.discover: (ctx) => DiscoverScreen(),
        AppRouter.login: (ctx) => LoginScreen(),
        AppRouter.home: (ctx) => HomeScreen()
      },
      initialRoute: AppRouter.login,
      theme: ThemeData(fontFamily: 'YTSans').copyWith(
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: <TargetPlatform, PageTransitionsBuilder>{
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
          },
        ),
      ),
      home: LoginScreen(),
    );
  }
}
