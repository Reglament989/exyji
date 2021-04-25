// DO NOT EDIT. This is code generated via package:easy_localization/generate.dart

// ignore_for_file: prefer_single_quotes

import 'dart:ui';

import 'package:easy_localization/easy_localization.dart' show AssetLoader;

class CodegenLoader extends AssetLoader{
  const CodegenLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale ) {
    return Future.value(mapLocales[locale.toString()]);
  }

  static const Map<String,dynamic> en = {
  "title": "Exyji",
  "login": {
    "usernameInput": "Username",
    "passwordInput": "Password",
    "submitButton": "Sign in",
    "signUpTooltip": "Not have account? Sign up >",
    "changeServerTooltip": "Change server?"
  },
  "home": {
    "title": "Home",
    "navy": {
      "listWithAllRooms": "All",
      "listWithContacts": "Contacts",
      "listWithChannels": "Channels",
      "listWithBots": "Bots"
    },
    "createChatMenu": {
      "labelRoomName": "Room name",
      "labelRoomDescription": "Room description",
      "createButton": "Create"
    },
    "drawer": {
      "specialFeatures": "Special features",
      "dashboard": "Dashboard",
      "themes": "Themes",
      "news": "News",
      "settings": "Settings",
      "about": "About",
      "logout": "Log out"
    }
  },
  "discover": {
    "flexOptions": {
      "header": "Flex options",
      "lorem": "You can setup any of this application, beggining colors ended forms, position etc."
    },
    "aboutOpenSource": {
      "header": "We have support Open Source",
      "lorem": "All sources avalible on github, and can be reviewed. No secrets for users, only magic"
    },
    "aboutEncryption": {
      "header": "Fully encryption",
      "lorem": "All data stored on client, server work on message broker, he just delivered your message to others"
    },
    "pushButton": "Let's go to a meeting experiments",
    "skipButton": "Skip"
  },
  "chat": {
    "inputHint": "Your message..."
  }
};
static const Map<String,dynamic> ru = {
  "title": "Exyji",
  "login": {
    "usernameInput": "Ник-нейм",
    "passwordInput": "Пароль",
    "submitButton": "Войти",
    "signUpTooltip": "Нет аккаунта? Зарегистрировать >",
    "changeServerTooltip": "Изменить сервер?"
  },
  "home": {
    "title": "Exyji",
    "navy": {
      "listWithAllRooms": "Все",
      "listWithContacts": "Контакты",
      "listWithChannels": "Каналы",
      "listWithBots": "Боты"
    },
    "createChatMenu": {
      "labelRoomName": "Имя комнаты",
      "labelRoomDescription": "Описание комнаты",
      "createButton": "Создать"
    },
    "drawer": {
      "specialFeatures": "Особые возможности",
      "dashboard": "Статистика",
      "themes": "Внешний вид",
      "news": "Новости",
      "settings": "Настройки",
      "about": "О нас",
      "logout": "Выйти"
    }
  },
  "discover": {
    "flexOptions": {
      "header": "Гибкость",
      "lorem": "Вы можете настроить все в этом приложении, цвета, форми, и.т.д"
    },
    "aboutOpenSource": {
      "header": "Мы поддерживаем Open Source",
      "lorem": "Весь исходный код доступен на github. Никаких секретов для пользователей, только магия"
    },
    "aboutEncryption": {
      "header": "Полное шифрование",
      "lorem": "Все данные хранятся на клиенте, сервер работает с брокером сообщений, он просто доставляет ваше сообщение"
    },
    "pushButton": "Вперед на встречу к экспериментам",
    "skipButton": "Пропустить"
  },
  "chat": {
    "inputHint": "Твое сообщение..."
  }
};
static const Map<String, Map<String,dynamic>> mapLocales = {"en": en, "ru": ru};
}
