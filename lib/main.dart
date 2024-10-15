import 'package:flutter/material.dart';

import 'package:mobile_app/scenes/main_screen.dart';
import 'package:mobile_app/assets/themes/mainThemeData.dart';
import 'package:mobile_app/hive/hive.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive
  HiveHandler.initHive();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: MainThemeData.mainThemeData,
      home: const MainScreen(),
    );
  }
}
