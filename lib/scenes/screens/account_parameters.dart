import 'package:flutter/material.dart';

class AccountParameters extends StatefulWidget {
  const AccountParameters({
    Key? key,
  });

  @override
  State<AccountParameters> createState() => _AccountParametersState();
}

class _AccountParametersState extends State<AccountParameters> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 120,
          alignment: Alignment.center,
          child: const Row(
            children: [
              const SizedBox(width: 10),

              const Icon(
                Icons.account_circle,
                size: 50,
              ),

              const SizedBox(width: 5),

              Text(
                'Bonjour {username} !',
                style: TextStyle(
                  fontSize: 24,
                ),
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