import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:say_anything_to_muavia/widgets/theme.dart';

class Themeprovider extends ChangeNotifier {
  ThemeData _themeData = lightmode;
  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void changeTheme() {
    if (_themeData == lightmode) {
      const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
          statusBarColor: Colors.black,
        ),
      );
      themeData = darkmode;
    } else {
      const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          statusBarColor: Colors.white,
        ),
      );
      themeData = lightmode;
    }
  }
}
