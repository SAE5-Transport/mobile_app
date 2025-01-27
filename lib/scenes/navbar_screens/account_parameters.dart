import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:mobile_app/states/connect_state.dart' as app_state;

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
    String? email = app_state.cachedAuthedUser.of(context)?.userInfo['email'];

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
                ),
              ),
            ],
          )
        ),

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
    );
  }
}