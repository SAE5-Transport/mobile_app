import 'package:bdaya_shared_value/bdaya_shared_value.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mobile_app/scenes/login_screen.dart';
import 'package:mobile_app/assets/themes/main__theme_data.dart';
import 'package:mobile_app/hive/functions.dart';
import 'package:mobile_app/scenes/main_screen.dart';
import 'package:mobile_app/states/connect_state.dart' as app_state;
import 'package:oidc/oidc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // init Hive
  HiveHandler.initHive();

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  runApp(
    SharedValue.wrapApp(
      MaterialApp.router(
        theme: MainThemeData.mainThemeData,
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const LoginScreen(),
              redirect: (context, state) {
                final OidcUser? user = app_state.cachedAuthedUser.of(context);

                if (user == null) {
                  return null;
                }
                return '/main';
              },
            ),
            GoRoute(
              path: '/main',
              builder: (context, state) => const MainScreen(),
            ),
          ]
        ),
        builder: (context, child) {
          return FutureBuilder(
            future: app_state.initApp(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              return child!;
            },
          );
        }
      ),
    )
  );
}