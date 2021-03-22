import 'package:fl_andro_x/views/acceptInvite.view.dart';
import 'package:fl_andro_x/views/chat.view.dart';
import 'package:fl_andro_x/views/chatDetails.view.dart';
import 'package:fl_andro_x/views/createChat.view.dart';
import 'package:fl_andro_x/views/home.view.dart';
import 'package:fl_andro_x/views/invite.view.dart';
import 'package:fl_andro_x/views/login.view.dart';
import 'package:flutter/foundation.dart';

const serverUrl = kReleaseMode ? '' : 'http://192.168.239.141:8083';

class Storage {
  static const defaultUserPhoto = 'defaults/user.png';
  static const avatarsRef = 'users/avatars/';
  static const roomsRef = 'rooms/avatars/';
}

class Assets {
  static const logo = 'lib/assets/icons/logo.png';
  static const circleLoader = 'lib/assets/lottie/circleLoader.json';
  static const userIcon = 'lib/assets/icons/user.png';
  static const timeLoader = 'lib/assets/lottie/timeLoader.json';
}

class AppRouter {
  static final home = HomeView.routeName;
  static final login = LoginView.routeName;
  static final createChat = CreateChatView.routeName;
  static final chat = ChatView.routeName;
  static final invite = InviteView.routeName;
  static final chatDetails = ChatDetailsView.routeName;
  static final acceptInvite = AcceptInviteView.routeName;
}

enum RoomType {
  contact,
  chat,
  channel
}