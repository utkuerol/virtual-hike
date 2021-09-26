import 'package:flutter/material.dart';

class MyAppTheme {
  static final ThemeData themeData = ThemeData.from(
      colorScheme: ColorScheme(
          primary: Colors.black,
          primaryVariant: Colors.black,
          secondary: Colors.white,
          secondaryVariant: Colors.white,
          surface: Colors.grey,
          background: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.red,
          brightness: Brightness.light));
}
