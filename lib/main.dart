import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/scenes/login_screen.dart';
import 'package:mobile_app/assets/themes/mainThemeData.dart';
import 'package:mobile_app/hive/functions.dart';
import 'package:mobile_app/scenes/main_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive
  HiveHandler.initHive();

  runApp(
    SharedValue.wrapApp(
      MaterialApp.router(
        theme: MainThemeData.mainThemeData,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const MainScreen(),
            )
          ]
        ),
        builder: (context, child) {
          return child!;
        }
      ),
    )
  );
}