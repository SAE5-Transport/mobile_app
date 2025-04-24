import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mobile_app/scenes/main_screen.dart';
import 'package:mobile_app/scenes/tabs/info-trafic/select_operator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  final MainScreenState parent;

  const Home({
    super.key,
    required this.parent,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LocationData? _currentLocation;
  final Location _location = Location();

  final List<Map<String, dynamic>> _favoriteAddresses = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadFavorites();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final hasPermission = await _location.requestPermission();
      if (hasPermission == PermissionStatus.granted) {
        final currentLocation = await _location.getLocation();
        setState(() {
          _currentLocation = currentLocation;
        });
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                currentLocation.latitude ?? 0.0,
                currentLocation.longitude ?? 0.0,
              ),
              zoom: 14.4746,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erreur lors de l'obtention de la localisation : $e");
    }
  }

  Map<int, IconData> iconDataMap = {
    0xe88a: Icons.home,
    0xe84f: Icons.apartment,
    0xe87d: Icons.favorite,
    0xe7fd: Icons.person,
  };

  Future<void> _loadFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedFavorites = prefs.getString('favorites');
    if (savedFavorites != null) {
      setState(() {
        _favoriteAddresses.addAll(List<Map<String, dynamic>>.from(
          json.decode(savedFavorites).map((item) => {
            'address': item['address'],
            'name': item['name'],
            'icon': iconDataMap[item['icon']] ?? Icons.home,
            'color': Color(item['color'])
          })
        ));
      });
    }
  }

  Future<void> _saveFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
      'favorites',
      json.encode(_favoriteAddresses.map((item) => {
        'address': item['address'],
        'name': item['name'],
        'icon': item['icon'].codePoint,
        'color': item['color'].value
      }).toList())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Carte Google Maps
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _currentLocation != null
                ? CameraPosition(
                    target: LatLng(
                      _currentLocation!.latitude ?? 0.0,
                      _currentLocation!.longitude ?? 0.0,
                    ),
                    zoom: 14.4746,
                  )
                : const CameraPosition(
                    target: LatLng(48.866667, 2.333333),
                    zoom: 14.4746,
                  ),
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          // Barre d'options en bas
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remove Expanded and directly use the Container
                      GestureDetector(
                        onTap: () {
                          // Open route search
                          widget.parent.onItemTapped(1);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: const AutoSizeText(
                            'Où souhaitez-vous aller ?',
                            minFontSize: 6,
                            maxFontSize: 18,
                            style: TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      // Button to add a favorite address
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: _addFavoriteAddress,
                      ),

                      // Button for showing info trafic
                      IconButton(
                        icon: const Icon(Icons.warning, color: Colors.white),
                        onPressed: () {
                          // Show info trafic
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectOperatorInfoTrafic()
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _favoriteAddresses.isEmpty
                      ? const Text(
                          'Aucun trajet préféré',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        )
                      : Wrap(
                          spacing: 10,
                          children: _favoriteAddresses
                              .map((fav) => _buildFavoriteIcon(fav))
                              .toList(),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteIcon(Map<String, dynamic> favorite) {
    return GestureDetector(
      onLongPress: () => _confirmDeleteFavorite(favorite),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              favorite['icon'],
              color: favorite['color'],
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            favorite['name'],
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _addFavoriteAddress() {
    final TextEditingController addressController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    IconData selectedIcon = Icons.home;
    Color selectedColor = Colors.green;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Ajouter un trajet préféré'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(hintText: 'Adresse'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(hintText: 'Nom du favori'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<IconData>(
                    value: selectedIcon,
                    items: const [
                      DropdownMenuItem(
                        value: Icons.home,
                        child: Icon(Icons.home, color: Colors.green),
                      ),
                      DropdownMenuItem(
                        value: Icons.apartment,
                        child: Icon(Icons.apartment, color: Colors.purple),
                      ),
                      DropdownMenuItem(
                        value: Icons.favorite,
                        child: Icon(Icons.favorite, color: Colors.red),
                      ),
                      DropdownMenuItem(
                        value: Icons.person,
                        child: Icon(Icons.person, color: Colors.blue),
                      ),
                    ],
                    onChanged: (icon) {
                      if (icon != null) {
                        setStateDialog(() {
                          selectedIcon = icon;
                          selectedColor = _getColorForIcon(icon);
                        });
                      }
                    },
                    selectedItemBuilder: (context) {
                      return [
                        const Icon(Icons.home, color: Colors.green),
                        const Icon(Icons.apartment, color: Colors.purple),
                        const Icon(Icons.favorite, color: Colors.red),
                        const Icon(Icons.person, color: Colors.blue),
                      ];
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () {
                    if (addressController.text.isNotEmpty &&
                        nameController.text.isNotEmpty) {
                      setState(() {
                        _favoriteAddresses.add({
                          'address': addressController.text,
                          'name': nameController.text,
                          'icon': selectedIcon,
                          'color': selectedColor,
                        });
                        _saveFavorites();
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color _getColorForIcon(IconData icon) {
    if (icon == Icons.home) return Colors.green;
    if (icon == Icons.apartment) return Colors.purple;
    if (icon == Icons.favorite) return Colors.red;
    if (icon == Icons.person) return Colors.blue;
    return Colors.black;
  }

  void _confirmDeleteFavorite(Map<String, dynamic> favorite) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le favori'),
          content:
              Text('Voulez-vous vraiment supprimer "${favorite['name']}" ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _favoriteAddresses.remove(favorite);
                  _saveFavorites();
                });
                Navigator.of(context).pop();
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }
}
