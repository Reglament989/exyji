import 'package:flutter/painting.dart';

const dBackgroundColorsForGradient = [Color(0xFF2BED80), Color(0xFF34A1E0)];

const dDarkPurple = Color(0xFF5E2BED);

const dBlue = Color(0xFF365BF7);

const dLigthBlue = Color(0xFF34A1E0);

const dLigthGreen = Color(0xFF2BED80);

const dPadding = 14.0;

class AppRouter {
  static const discover = "discover";
  static const login = "login";
  static const home = "home";
  static const chatDetails = "chat/details";
  static const about = "about";
  static const chat = "chat";
}

class Assets {
  static const flasksAnimation = "assets/lottie/flasks.json";
  static const lockerAnimation = "assets/lottie/locker.json";
  static const arrowDownAnimation = "assets/lottie/arrow-down.json";
  static const foss = "assets/lottie/foss.json";
  static const github = "assets/icons/logo-github.svg";
  static const unknownFile = "assets/icons/file-icon.svg";
  static const zipFile = "assets/icons/file-zip.svg";
  static const pdfFile = "assets/icons/file-pdf.svg";
  static const txtFile = "assets/icons/file-txt.svg";
}

class Config {
  static const double drawerHeight = 190;
  static const double drawerAvatarSize = 80;
}

const List<String> imageExtension = ['jpg', 'png'];

const List<String> soundExtension = ['mp3', 'aac'];
