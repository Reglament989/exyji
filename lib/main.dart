import 'package:fl_reload/constants.dart';
import 'package:fl_reload/screens/discover/discover_screen.dart';
import 'package:fl_reload/screens/home/home_screen.dart';
import 'package:fl_reload/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

void main() {
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
