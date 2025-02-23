import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/assets/themes/dark_theme__data.dart';
import 'package:mobile_app/assets/themes/main__theme_data.dart';
import 'package:mobile_app/states/connect_state.dart' as app_state;

class AccountParameters extends StatefulWidget {
  const AccountParameters({super.key});

  @override
  State<AccountParameters> createState() => _AccountParametersState();
}

class _AccountParametersState extends State<AccountParameters> {
  @override
  Widget build(BuildContext context) {
    String? username = app_state.cachedAuthedUser.of(context)?.userInfo['name'];
    String? gender = app_state.cachedAuthedUser.of(context)?.userInfo['gender'];
    String? profilePicture;

    return Scaffold(
      appBar: AppBar(title: const Text("Compte")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: profilePicture != null
                        ? NetworkImage(profilePicture)
                        : null,
                    child: profilePicture == null
                        ? const Icon(Icons.account_circle, size: 60)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Bonjour $username !",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
            ),
            const Divider(thickness: 2),
            ExpansionTile(
              title: const Text("Info Personnelle"),
              children: [
                ListTile(
                  title: const Text("Changer de prénom"),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _changeUsername(),
                ),
                ListTile(
                  title: const Text("Sexe"),
                  subtitle: Text(gender ?? "Non spécifié"),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _changeGender(),
                ),
                ListTile(
                  title: const Text("Photo de profil"),
                  trailing: const Icon(Icons.camera_alt),
                  onTap: () => _changeProfilePicture(),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Sécurité"),
              children: [
                ListTile(
                  title: const Text("Changer mot de passe"),
                  trailing: const Icon(Icons.lock),
                  onTap: () => _changePassword(),
                ),
                ListTile(
                  title: const Text("Changer email"),
                  trailing: const Icon(Icons.email),
                  onTap: () => _changeEmail(),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Personnalisation"),
              children: [
                ListTile(
                  title: const Text("Changer de thème"),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _changeTheme(),
                ),
              ],
            ),
            ExpansionTile(
              title: const Text("Zone de danger"),
              children: [
                ListTile(
                  title: const Text("Déconnexion"),
                  trailing: const Icon(Icons.logout),
                  onTap: () => _logout(context),
                ),
                ListTile(
                  title: const Text("Supprimer son compte"),
                  trailing: const Icon(Icons.delete, color: Colors.red),
                  onTap: () => _deleteAccount(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _changeUsername() {
    // Implémentation pour changer le prénom
  }

  void _changeGender() {
    // Implémentation pour changer le sexe
  }

  void _changeProfilePicture() {
    // Implémentation pour changer la photo de profil
  }

  void _changePassword() {
    // Implémentation pour changer le mot de passe
  }

  void _changeEmail() {
    // Implémentation pour changer l'email
  }

  void _logout(BuildContext context) async {
    try {
      print("Début de la déconnexion...");

      await app_state.currentManager.forgetUser();
      print("Utilisateur oublié localement.");

      app_state.cachedAuthedUser.$ = null;
      print("cachedAuthedUser effacé.");

      await Future.delayed(Duration.zero);

      if (context.mounted) {
        context.go('/'); // Redirige vers l'écran de connexion (LoginScreen)
        print("Redirection effectuée.");
      }
    } catch (e) {
      print("Erreur lors de la déconnexion : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Déconnexion échouée : ${e.toString()}")),
      );
    }
  }

  void _deleteAccount() {
    // Implémentation pour supprimer le compte
  }

  Future _changeTheme() {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Sélectionner un thème'),
            children: [
              SimpleDialogOption(
                child: const Text('Thème clair'),
                onPressed: () {
                },
              ),
              SimpleDialogOption(
                child: const Text('Thème sombre'),
                onPressed: () {
                },
              ),
              // Add more themes as needed
            ],
          );
        });
  }
}
