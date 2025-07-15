import 'package:flutter/material.dart';

class CustomTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.grey,
      onSecondary: Colors.black,
      error: Colors.red,
      onError: Colors.black,
      surface: Colors.grey,
      onSurface: Colors.black,
    ),
  );
}
