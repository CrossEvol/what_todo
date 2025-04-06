import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/screen_enum.dart';

extension NavigatorExt on BuildContext {
  void safePop() {
    if (Navigator.of(this).canPop()) {
      Navigator.pop(this, true);
    }
  }

  bool isWiderScreen() {
    return MediaQuery.of(this).size.width > 600;
  }
}
