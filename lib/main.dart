import 'package:easy_localization/easy_localization.dart';
import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/screens/about/about_screen.dart';
import 'package:exyji/screens/chat/chat_screen.dart';
import 'package:exyji/screens/discover/discover_screen.dart';
import 'package:exyji/screens/home/home_screen.dart';
import 'package:exyji/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'generated/codegen_loader.g.dart';
import 'package:asynji_sdk/asynji_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Asynji().init();
  runApp(EasyLocalization(
      assetLoader: CodegenLoader(),
      supportedLocales: [Locale('en'), Locale('ru')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: LocaleKeys.title.tr(),
      routes: {
        AppRouter.discover: (ctx) => DiscoverScreen(),
        AppRouter.login: (ctx) => LoginScreen(),
        AppRouter.home: (ctx) => HomeScreen(),
        AppRouter.about: (ctx) => AboutScreen(),
        AppRouter.chat: (ctx) => ChatScreen(),
      },
      initialRoute: AppRouter.login,
      theme: ThemeData().copyWith(
        appBarTheme:
            Theme.of(context).appBarTheme.copyWith(brightness: Brightness.dark),
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
