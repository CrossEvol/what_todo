import 'package:flutter/material.dart';

const primaryColor = Color(0xFF3543DE);

final theme = ThemeData(
  primaryColor: primaryColor,
  visualDensity: VisualDensity.adaptivePlatformDensity,
);

class ThemeDataStyle {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: theme.colorScheme.copyWith(
      secondary: Colors.purple,
      primary: primaryColor,
      tertiary: Colors.grey.shade100,
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      // background: Colors.grey.shade900,
      onSurface: Colors.grey.shade900,
      primary: Colors.deepPurple.shade700,
      secondary: Colors.deepPurple.shade900,
      tertiary: Colors.blueGrey,
    ),
  );
}
