import 'package:flutter/material.dart';

class CustomColor {
  CustomColor._();

  static const stone = MaterialColor(0xFF78716C, <int, Color>{
    50: Color(0xFFFAFAF9),
    100: Color(0xFFF5F5F4),
    200: Color(0xFFE7E5E4),
    300: Color(0xFFD6D3D1),
    400: Color(0xFFA8A29E),
    500: Color(0xFF78716C),
    600: Color(0xFF57534E),
    700: Color(0xFF44403C),
    800: Color(0xFF292524),
    900: Color(0xFF1C1917),
  });
}

class CustomTheme {
  static final light = ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: CustomColor.stone.shade800,
      onSecondary: CustomColor.stone.shade800,
      error: Colors.red,
      onError: Colors.black,
      surface: Colors.white,
      surfaceDim: CustomColor.stone.shade100,
      onSurface: Colors.black,
      outline: CustomColor.stone.shade200,
      outlineVariant: CustomColor.stone.shade400,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: CustomColor.stone.shade800,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CustomColor.stone.shade800,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        textStyle: TextStyle(fontSize: 16),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 0,
      backgroundColor: CustomColor.stone.shade800,
      foregroundColor: Colors.white,
      shape: const CircleBorder(),
    ),
    chipTheme: ChipThemeData(
      disabledColor: CustomColor.stone.shade200,
      backgroundColor: CustomColor.stone.shade200,
      selectedColor: CustomColor.stone.shade800,
      showCheckmark: false,
      shape: const CircleBorder(side: BorderSide(color: Colors.transparent)),
      labelPadding: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      labelStyle: TextStyle(fontSize: 16),
    ),
    dividerTheme: DividerThemeData(color: CustomColor.stone.shade200),
    inputDecorationTheme: InputDecorationTheme(
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColor.stone.shade400),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColor.stone.shade400),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: CustomColor.stone.shade400),
      ),
    ),
  );
}
