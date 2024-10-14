import 'package:flutter/material.dart';

class Parameters extends StatefulWidget {
  const Parameters({
    Key? key,
  });

  @override
  State<Parameters> createState() => _ParametersState();
}

class _ParametersState extends State<Parameters> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Hello, World!'),
      ),
    );
  }
}