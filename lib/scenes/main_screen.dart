import 'package:flutter/material.dart';
import 'package:mobile_app/scenes/navbar_screens/account_parameters.dart';
import 'package:mobile_app/scenes/navbar_screens/follow.dart';
import 'package:mobile_app/scenes/navbar_screens/home.dart';
import 'package:mobile_app/scenes/navbar_screens/route.dart';
import 'package:mobile_app/scenes/navbar_screens/ticket.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
  });

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final ValueNotifier<Widget> _currentScreen;

  void _selectScreen(int index) {
    switch (index) {
      case 0:
        _currentScreen.value = Home(parent: this);
        break;
      case 1:
        _currentScreen.value = const RoutePage();
        break;
      case 2:
        _currentScreen.value = const TicketPage();
        break;
      case 3:
        _currentScreen.value = const FollowPage();
        break;
      case 4:
        _currentScreen.value = const AccountParameters();
        break;
    }
  }

  void onItemTapped(int index) {
    _selectScreen(index);

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _currentScreen = ValueNotifier<Widget>(Home(parent: this));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<Widget>(
          valueListenable: _currentScreen,
          builder: (BuildContext context, Widget value, Widget? child) {
            return value;
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type : BottomNavigationBarType.fixed,
        onTap: onItemTapped,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        selectedLabelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(inherit: true),
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