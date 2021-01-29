import 'package:flutter/material.dart';

ThemeData appTheme = appThemeDeepYellow;

ThemeData appThemeDeepYellow = ThemeData.light().copyWith(
  primaryColor: Color(0xffedc313),
  backgroundColor: Color(0xfff9f9f9),
  appBarTheme: AppBarTheme(brightness: Brightness.light),
);

ThemeData appThemeDefault = ThemeData.light().copyWith(
    primaryColor: Color(0xff1F81FF),
    backgroundColor: Color(0xfff9f9f9),
    appBarTheme: AppBarTheme(brightness: Brightness.light));

ThemeData appThemeDeepBlue = ThemeData.light().copyWith(
    primaryColor: Color(0xff228BA1),
    backgroundColor: Color(0xfff9f9f9),
    appBarTheme: AppBarTheme(brightness: Brightness.light));

ThemeData appThemeDeepRed = ThemeData.light().copyWith(
    primaryColor: Color(0xffcc5858),
    backgroundColor: Color(0xfff9f9f9),
    appBarTheme: AppBarTheme(brightness: Brightness.light));
