import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_app/states/connect_state.dart' as app_state;

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userNameController,
              decoration: const InputDecoration(
                labelText: 'username',
              ),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'password',
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  final result = await app_state.currentManager.loginPassword(
                    username: userNameController.text,
                    password: passwordController.text,
                  );

                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'loginPassword returned user id: ${result?.uid}',
                      ),
                    ),
                  );
                } catch (e) {
                  app_state.exampleLogger.severe(e.toString());
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'loginPassword failed!',
                      ),
                    ),
                  );
                }
              },
              child: const Text('login with Resource owner grant'),
            ),
          ]
        )
      ),
    );
  }
}