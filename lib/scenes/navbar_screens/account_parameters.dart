import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Column(
      children: [
        Container(
          height: 120,
          alignment: Alignment.center,
          child: Row(
            children: [
              const SizedBox(width: 10),

              const Icon(
                Icons.account_circle,
                size: 50,
              ),

              const SizedBox(width: 5),

              Text(
                "Bonjour ${username!} !",
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(
                    fontSize: 24,
                  )
                )
              ),
            ],
          )
        ),

        const Divider(
          height: 20,
          thickness: 2,
        ),
      ],
    );
  }
}