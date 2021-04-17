import 'package:fl_reload/constants.dart';
import 'package:fl_reload/hivedb/room.model.dart';
import 'package:fl_reload/screens/discover/discover_screen.dart';
import 'package:fl_reload/screens/home/home_screen.dart';
import 'package:fl_reload/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(RoomModelAdapter());
  Hive.registerAdapter(RoomTypeAdapter());

  await Hive.openBox<RoomModel>("Rooms");
  // await box.deleteFromDisk();
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
      theme: ThemeData.light().copyWith(
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
