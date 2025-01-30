import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
<<<<<<< Updated upstream
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
=======
import 'package:go_router/go_router.dart';
>>>>>>> Stashed changes
import 'package:mobile_app/states/connect_state.dart' as app_state;
import 'package:mobile_app/scenes/login_screen.dart';

class AccountParameters extends StatefulWidget {
  const AccountParameters({
    super.key
  });

  @override
  State<AccountParameters> createState() => _AccountParametersState();
}

class _AccountParametersState extends State<AccountParameters> {
  @override
  Widget build(BuildContext context) {
    String? username = app_state.cachedAuthedUser.of(context)?.userInfo['name'];
    String? gender = app_state.cachedAuthedUser.of(context)?.userInfo['gender'];
    String? profilePicture;

<<<<<<< Updated upstream
    return ListView(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.1,
          alignment: Alignment.center,
          child: Row(
            children: [
              const SizedBox(width: 10),

              const Icon(
                Icons.account_circle,
                size: 50,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: AutoSizeText(
                  "Bonjour ${username!} !",
                  maxLines: 1,
                  minFontSize: 12,
                  style: Theme.of(context).textTheme.headlineLarge,
=======
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
                        ? NetworkImage(profilePicture!)
                        : null,
                    child: profilePicture == null
                        ? const Icon(Icons.account_circle, size: 60)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Bonjour $username !",
                    style: const TextStyle(fontSize: 24),
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
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream

        const Divider(
          height: 20,
          thickness: 2,
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.01),

        // Create buttons for user infos
        Container(
          height: MediaQuery.of(context).size.height * 0.1,
          color: Colors.grey[600],
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ListTile(
                leading: const Icon(
                  Icons.account_circle,
                  size: 30,
                ),
                title: Text(
                  "Compte",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        )
      ],
=======
      ),
>>>>>>> Stashed changes
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
}
