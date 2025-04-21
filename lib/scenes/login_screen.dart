import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'Utilisateur',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de Passe',
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await app_state.currentManager.loginPassword(
                      username: userNameController.text,
                      password: passwordController.text,
                    );
                    if(context.mounted) {
                      context.pop();
                    }
                  } catch (e) {
                    app_state.exampleLogger.severe(e.toString());
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'L\'authentification a échoué. Vérifier vos informations d\'identification au près de FranceConnect',
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Se connecter'),
              ),
            ]
          ),
        ),
      ),
    );
  }
}