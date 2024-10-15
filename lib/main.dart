import 'package:flutter/material.dart';

import 'package:mobile_app/scenes/main_screen.dart';
import 'package:mobile_app/assets/themes/mainThemeData.dart';
import 'package:mobile_app/hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive
  HiveHandler.initHive();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  @override
  void initState() {
    _requestLocationPermission();

    super.initState();
  }

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
