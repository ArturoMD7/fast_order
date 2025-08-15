import 'package:flutter/material.dart';

@override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFFD2691E);
    final secondaryColor = const Color(0xFFF4A460);
    final backgroundColor = const Color(0xFFFFF8F0);
  
    final textColor = const Color(0xFF000000);
    final accentColor = const Color(0xFF8B4513);

    return Theme(
      data: ThemeData(
        primaryColor: primaryColor,
        hintColor: accentColor,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: textColor),
          bodyMedium: TextStyle(color: textColor),
        ), colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryColor,
          background: backgroundColor,
          onPrimary: textColor,
          onSecondary: textColor,
        ).copyWith(background: backgroundColor),
      ),
      child: Container(), // Replace with your actual widget tree
    );
  }
