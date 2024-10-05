import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/home.dart';
import 'package:flutter_app/router/router.dart';
import 'package:window_manager/window_manager.dart';

void main() {
  if (Platform.isWindows) {
    setupWindow();
  }
  runApp(MyApp());
}

const double windowWidth = 400;
const double windowHeight = 760;

void setupWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    title: 'WhatTodo',
    size: Size(windowWidth, windowHeight),
    minimumSize: Size(windowWidth, windowHeight),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF3543DE);
    final theme = ThemeData(
      primaryColor: primaryColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          secondary: Colors.purple,
          primary: primaryColor,
        ),
      ),
      routerConfig: goRouter,
    );
  }
}


