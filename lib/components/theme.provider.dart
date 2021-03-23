import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class Themes with ChangeNotifier {
  final currentTheme;


  Themes(this.currentTheme) {
    this.init();
  }

  init() {
    currentTheme = Hive.box('Themes').get('default');
    _loadedThemes = List.empty();
    for (var i = 0; i < Hive.box('Themes').length; i ++) {
      final theme = Hive.box('Themes').getAt(i);
      _loadedThemes.add(new AppTheme(theme));
    }
  }

  switchTheme(int themeIdx) {
    currentTheme = _loadedThemes[themeIdx];
    notifyListeners();
  }

  changePrimaryColor(Color value) {
    currentTheme.primaryColor = value;
  }
}
