import 'package:fl_andro_x/components/login.loader.dart';
import 'package:fl_andro_x/hivedb/room.dart';
import 'package:fl_andro_x/hivedb/secureStore.dart';
import 'package:fl_andro_x/hivedb/settings.dart';
import 'package:fl_andro_x/views/acceptInvite.view.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:fl_andro_x/views/chatDetails.view.dart';
import 'package:fl_andro_x/views/createChat.view.dart';
import 'package:fl_andro_x/views/home.view.dart';
import 'package:fl_andro_x/views/init.view.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_andro_x/views/login.view.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:cryptography_flutter/cryptography_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterCryptography.enable();
  Hive.registerAdapter(GlobalSettingsAdapter());
  Hive.registerAdapter(SecureStoreAdapter());
  Hive.registerAdapter(RoomAdapter());
  await Hive.initFlutter();
  await Hive.openBox<SecureStore>('SecureStore');
  await Hive.openBox<Room>('Room');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {}
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp(
              theme: ThemeData.from(colorScheme: ColorScheme.light()).copyWith(
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  },
                ),
              ),
              home: LoginView(),
              routes: <String, WidgetBuilder>{
                HomeView.routeName: (BuildContext context) => HomeView(), // /home
                LoginView.routeName: (BuildContext context) => LoginView(), // /login
                CreateChatView.routeName: (BuildContext context) => CreateChatView(), // /createChat
                ChatView.routeName: (BuildContext context) => ChatView(), // /chat
                InitView.routeName: (BuildContext context) => InitView(), // /init
                InviteView.routeName: (BuildContext context) => InviteView(), // /invite
                ChatDetailsView.routeName: (BuildContext context) => ChatDetailsView(), // /chat/details
                AcceptInviteView.routeName: (BuildContext context) => AcceptInviteView(), // /invite/accept
              },
              initialRoute: InitView.routeName,
            );
          }
          return LoginLoader();
        });
  }
}
