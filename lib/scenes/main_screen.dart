import 'package:flutter/material.dart';
import 'package:mobile_app/scenes/screens/account_parameters.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    Key? key,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final ValueNotifier<Widget> _currentScreen = ValueNotifier<Widget>(Container());

  void _selectScreen(int index) {
    switch (index) {
      case 0:
        _currentScreen.value = Container();
        break;
      case 1:
        _currentScreen.value = Container();
        break;
      case 2:
        _currentScreen.value = Container();
        break;
      case 3:
        _currentScreen.value = Container();
        break;
      case 4:
        _currentScreen.value = const AccountParameters();
        break;
    }
  }

  void _onItemTapped(int index) {
    _selectScreen(index);

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ValueListenableBuilder<Widget>(
        valueListenable: _currentScreen,
        builder: (BuildContext context, Widget value, Widget? child) {
          return value;
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type : BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.route),
            label: 'Trajet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet),
            label: 'Titres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Suivie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}