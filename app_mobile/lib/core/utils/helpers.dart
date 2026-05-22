import 'package:flutter/material.dart';

class Helpers {
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<void> delay(int milliseconds) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
