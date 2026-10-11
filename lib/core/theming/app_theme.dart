import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ThemingColors.black,
    appBarTheme: AppBarTheme(centerTitle: true),
  );

  static ThemeData lightMode = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ThemingColors.lightGrey,
    appBarTheme: AppBarTheme(centerTitle: true),
  );
}