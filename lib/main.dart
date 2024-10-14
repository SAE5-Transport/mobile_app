import 'package:flutter/material.dart';
import 'package:mobile_app/scenes/parameters.dart';
import 'package:mobile_app/themes/mainThemeData.dart';

void main() {
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
      home: const Parameters(),
    );
  }
}
