import 'package:easy_localization/easy_localization.dart';
import 'package:exyji/constants.dart';
import 'package:exyji/generated/locale_keys.g.dart';
import 'package:exyji/hivedb/messages.model.dart';
import 'package:exyji/hivedb/room.model.dart';
import 'package:exyji/hivedb/global.model.dart';
import 'package:exyji/screens/about/about_screen.dart';
import 'package:exyji/screens/discover/discover_screen.dart';
import 'package:exyji/screens/home/home_screen.dart';
import 'package:exyji/screens/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'generated/codegen_loader.g.dart';
import 'hivedb/room_cache.model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(RoomModelAdapter());
  Hive.registerAdapter(RoomTypeAdapter());
  Hive.registerAdapter(MessagesModelAdapter());
  Hive.registerAdapter(EncryptedBlockAdapter());
  Hive.registerAdapter(RoomCacheAdapter());
  Hive.registerAdapter(ReplyModelAdapter());
  Hive.registerAdapter(MediaMessageAdapter());
  Hive.registerAdapter(TypeMessageAdapter());
  Hive.registerAdapter(GlobalAdapter());

  final rooms = await Hive.openBox<RoomModel>("Rooms");
  await Future.forEach(rooms.values, (RoomModel r) async {
    await Hive.openBox<MessagesModel>("Room-${r.uid}");
    await Hive.openBox<RoomCache>("Room-${r.uid}-cache");
  });
  // await rooms.deleteFromDisk();
  final globalBox = await Hive.openBox<Global>("Global");
  final global = globalBox.get('global');
  if (global == null) {
    debugPrint("Fallback create global");
    await Hive.box<Global>("Global").put('global', Global());
  }
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
        AppRouter.about: (ctx) => AboutScreen()
      },
      initialRoute: AppRouter.login,
      theme: ThemeData().copyWith(
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
