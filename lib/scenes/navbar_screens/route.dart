import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/api/hexatransit_api.dart';
import 'package:mobile_app/scenes/tabs/path_map.dart';
import 'package:mobile_app/utils/assets.dart';
import 'package:mobile_app/utils/functions.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({
    super.key,
  });

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  bool movingCamera = false;
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  SuggestionsController startSuggestionsController = SuggestionsController();
  SuggestionsController endSuggestionsController = SuggestionsController();
  PanelController panelController = PanelController();

  Marker? startMarker;
  Marker? endMarker;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  Map<String, dynamic> startLocation = {};
  Map<String, dynamic> endLocation = {};
  DateTime selectedDate = DateTime.now();
  bool arrivingDate = false;

  bool lookingForStart = true;

  ValueNotifier<bool> isSelectingSearch = ValueNotifier(true);
  
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(48.866667, 2.333333),
    zoom: 14.4746,
  );

  void drawRoute() {
    polylines.clear();

    // Plot the line between the two points
    if (startLocation.isNotEmpty && endLocation.isNotEmpty) {
      polylines.add(Polyline(
        polylineId: const PolylineId('route'),
        points: [
          LatLng(startLocation["lat"], startLocation["lon"]),
          LatLng(endLocation["lat"], endLocation["lon"]),
        ],
        color: const Color.fromARGB(255, 80, 80, 80),
        width: 5,
        patterns: [PatternItem.dot, PatternItem.gap(10)], // Add pattern for dotted line
      ));
    }
  }

  Future<List<Widget>> buildPathButtons(Map<String, dynamic> data) async {
    List<Widget> buttons = [];

    for (var path in data["trip"]["tripPatterns"]) {
      List<Widget> linesIcons = [];

      for (var leg in path["legs"]) {
        if (leg["line"] != null) {
          linesIcons.add(await getTransportIconFromPath(leg["line"]));

          // Add a separator
          linesIcons.add(
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: Icon(
                Icons.circle,
                size: 4,
              )
            )
          );
        }
      }

      // Remove the last separator
      if (linesIcons.isNotEmpty) {
        linesIcons.removeLast();
      

        buttons.add(
          ElevatedButton(
            onPressed: () {
              // Navigate to PathMap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PathMap(
                    pathData: path,
                  )
                )
              );

            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.transparent),
              elevation: WidgetStateProperty.all(0),
            ),
            child: Column(
              children: [
                // Lines | Duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lines
                    Expanded(
                      child: Wrap(
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: linesIcons,
                      ),
                    ),

                    // Duration
                    Flexible(
                      child: Text(
                        "${convertSecondsToMinutes(double.parse(path["duration"].toString())).floor().toString()} min",
                        style: GoogleFonts.nunito(
                          fontSize: 18
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                // Start & End
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Start
                    Text(
                      "${DateTime.parse(path["expectedStartTime"]).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(path["expectedStartTime"]).toLocal().minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.nunito(
                        fontSize: 18
                      ),
                    ),

                    // End
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(106, 138, 175, 255),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "Arrivé à ${DateTime.parse(path["expectedEndTime"]).toLocal().hour.toString().padLeft(2, '0')}:${DateTime.parse(path["expectedEndTime"]).toLocal().minute.toString().padLeft(2, '0')}",
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: const Color.fromARGB(255, 11, 88, 255),
                        ),
                      )
                    )
                  ],
                )
              ],
            )
          )
        );
      }
    }

    return buttons;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Map
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          onCameraMove: (position) {
            setState(() {
              movingCamera = true;
            });
          },
          onCameraIdle: () {
            setState(() {
              movingCamera = false;
            });
          },
          rotateGesturesEnabled: isSelectingSearch.value,
          scrollGesturesEnabled: isSelectingSearch.value,
          zoomGesturesEnabled: isSelectingSearch.value,
          markers: markers,
          polylines: polylines,
          onTap: (position) {
            if (lookingForStart) {
              // Get location name
              getLocationByCoordinates(position.latitude, position.longitude).then((location) {
                if (location["name"].length <= 3) {
                  startController.text = location["subname"].split(", ")[0];
                } else {
                  startController.text = location["name"];
                }

                startLocation = {
                  "lat": double.parse(location["lat"].toString()),
                  "lon": double.parse(location["lon"].toString())
                };

                // Add marker to the map
                markers.remove(startMarker);
                startMarker = Marker(
                  markerId: const MarkerId('start'),
                  position: LatLng(startLocation["lat"], startLocation["lon"]),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                );
                markers.add(startMarker!);

                // Draw the route
                drawRoute();

                setState(() {
                  markers = markers;
                  lookingForStart = false;
                });
              });
            } else {
              // Get location name
              getLocationByCoordinates(position.latitude, position.longitude).then((location) {
                if (location["name"].length <= 3) {
                  endController.text = location["subname"].split(", ")[0];
                } else {
                  endController.text = location["name"];
                }

                endLocation = {
                  "lat": double.parse(location["lat"].toString()),
                  "lon": double.parse(location["lon"].toString())
                };

                // Add marker to the map
                markers.remove(endMarker);
                endMarker = Marker(
                  markerId: const MarkerId('end'),
                  position: LatLng(endLocation["lat"], endLocation["lon"]),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                );
                markers.add(endMarker!);

                // Draw the route
                drawRoute();

                setState(() {
                  markers = markers;
                  lookingForStart = true;
                });
              });
            }

            // Unfocus the text boxes
            startSuggestionsController.close(retainFocus: false);
            endSuggestionsController.close(retainFocus: false);
          },
        ),

        AnimatedPositioned(
          duration: const Duration(milliseconds: 500),
          top: movingCamera || !isSelectingSearch.value ? -500 : MediaQuery.of(context).size.height * 0.03,
          left: 0,
          right: 0,
          curve: Curves.easeInOut,
          child: Column(
            children: [
              // Buttons to switch between "Favoris / Prévu" and "Historique"
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ToggleButtons(
                      color: Colors.black.withOpacity(0.60),
                      selectedColor: const Color(0xFF6200EE),
                      selectedBorderColor: const Color(0xFF6200EE),
                      fillColor: const Color(0xFF6200EE).withOpacity(0.08),
                      splashColor: const Color(0xFF6200EE).withOpacity(0.12),
                      hoverColor: const Color(0xFF6200EE).withOpacity(0.04),
                      borderRadius: BorderRadius.circular(4.0),
                      constraints: const BoxConstraints(
                        minHeight: 36.0
                      ),
                      isSelected: const [false, false],
                      onPressed: (index) {
                        // Respond to button selection
                      },
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.star),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text('Favoris / Prévu'),
                              ),
                            ],
                          )
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.history),
                              Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Text('Historique'),
                              ),
                            ],
                          )
                        ),
                      ],
                    )
                  )
                ],
              ),

              // Search bar box
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF88D795),
                    borderRadius: BorderRadius.circular(4.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 4.0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Start & End text boxes
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: TypeAheadField( // Start text box
                                controller: startController,
                                suggestionsController: startSuggestionsController,
                                suggestionsCallback: (search) async {
                                  // Fetch suggestions from the server
                                  List<Map<String, dynamic>> suggestions = await getLocations(search);

                                  return suggestions;
                                },
                                itemBuilder: (context, suggestion) {
                                  dynamic leading;
                                  dynamic subtitle;
                                  if (suggestion.containsKey("stops")) {
                                    List<String> modes = [];
                                    Map<String, Map<String, dynamic>> linesData = {};

                                    // Get the lines data
                                    for (var stop in suggestion["stops"]) {
                                      for (var route in stop["routes"]) {
                                        linesData.putIfAbsent(route["gtfsId"], () => route);
                                      }
                                    }

                                    // Get the transport modes
                                    for (var line in linesData.values) {
                                      modes.add(line["mode"]);
                                    }

                                    // Get the icon for the transport mode
                                    String? modeTop = getMainTransportModeAsset(modes);
                                    leading = modeTop != null ? Image.asset(
                                      modeTop,
                                      width: 36,
                                      height: 36,
                                    ) : const Icon(Icons.directions_bus);

                                    // Get lines icons
                                    subtitle = FutureBuilder(
                                      future: getTransportsIcons(linesData),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return ScrollLoopAutoScroll(
                                              scrollDirection: Axis.horizontal,
                                              enableScrollInput: false,
                                              duplicateChild: 1,
                                              gap: MediaQuery.of(context).size.width * 0.25,
                                              delay: const Duration(milliseconds: 300),
                                              duration: const Duration(seconds: 20),
                                              child: snapshot.data!,
                                            );
                                          } else {
                                            return const Text('No data available');
                                          }
                                        } else if (snapshot.hasError) {
                                          print(snapshot.error);
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    );

                                    return ListTile(
                                      leading: leading,
                                      title: Text(suggestion["name"]),
                                      subtitle: subtitle,
                                    );
                                  } else {
                                    if (suggestion["type"] == "town") {
                                      leading = const Icon(Icons.location_city);

                                      return ListTile(
                                        leading: leading,
                                        title: Text(suggestion["name"]),
                                        subtitle: Text(suggestion["subname"]),
                                      );
                                    } else {
                                      leading = const Icon(Icons.location_on);

                                      return ListTile(
                                        leading: leading,
                                        title: Text(suggestion["name"]),
                                        subtitle: Text(suggestion["subname"]),
                                      );
                                    }
                                  }
                                },
                                onSelected: (value) {
                                  startController.text = value["name"];
                                  startLocation = {
                                    "lat": double.parse(value["lat"].toString()),
                                    "lon": double.parse(value["lon"].toString())
                                  };

                                  // Close suggestion (retain focus)
                                  startSuggestionsController.close(retainFocus: false);

                                  // Add marker to the map
                                  markers.remove(startMarker);
                                  startMarker = Marker(
                                    markerId: const MarkerId('start'),
                                    position: LatLng(startLocation["lat"], startLocation["lon"]),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                  );
                                  markers.add(startMarker!);

                                  // Draw the route
                                  drawRoute();
                                  
                                  setState(() {
                                    markers = markers;
                                    lookingForStart = false;
                                  });
                                },
                                transitionBuilder: (context, animation, child) {
                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.fastOutSlowIn
                                    ),
                                    child: child,
                                  );
                                },
                                hideOnEmpty: true,
                                hideOnError: true,
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          // Clear the text box & values
                                          controller.clear();

                                          startLocation = {};

                                          // Remove the marker
                                          if (startMarker != null) {
                                            markers.remove(startMarker);
                                          }

                                          // Draw the route
                                          drawRoute();

                                          setState(() {
                                            markers = markers;
                                          });

                                          lookingForStart = true;
                                        },
                                        icon: const Icon(Icons.clear),
                                      ),
                                      hintText: 'Départ',
                                      hintStyle: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                        )
                                      ),
                                      labelStyle: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        )
                                      ),
                                      border: InputBorder.none,
                                      filled: true
                                    ),
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.next,
                                  );
                                },
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                                ),
                              )
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: TypeAheadField(
                                controller: endController,
                                suggestionsController: endSuggestionsController,
                                suggestionsCallback: (search) async {
                                  // Fetch suggestions from the server
                                  List<Map<String, dynamic>> suggestions = await getLocations(search);

                                  return suggestions;
                                },
                                itemBuilder: (context, suggestion) {
                                  dynamic leading;
                                  dynamic subtitle;
                                  if (suggestion.containsKey("stops")) {
                                    List<String> modes = [];
                                    Map<String, Map<String, dynamic>> linesData = {};

                                    // Get the lines data
                                    for (var stop in suggestion["stops"]) {
                                      for (var route in stop["routes"]) {
                                        linesData.putIfAbsent(route["gtfsId"], () => route);
                                      }
                                    }

                                    // Get the transport modes
                                    for (var line in linesData.values) {
                                      modes.add(line["mode"]);
                                    }

                                    // Get the icon for the transport mode
                                    String? modeTop = getMainTransportModeAsset(modes);
                                    leading = modeTop != null ? Image.asset(
                                      modeTop,
                                      width: 36,
                                      height: 36,
                                    ) : const Icon(Icons.directions_bus);

                                    // Get lines icons
                                    subtitle = FutureBuilder(
                                      future: getTransportsIcons(linesData),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.done) {
                                          if (snapshot.hasData && snapshot.data != null) {
                                            return ScrollLoopAutoScroll(
                                              scrollDirection: Axis.horizontal,
                                              enableScrollInput: false,
                                              duplicateChild: 1,
                                              gap: MediaQuery.of(context).size.width * 0.25,
                                              delay: const Duration(milliseconds: 300),
                                              duration: const Duration(seconds: 20),
                                              child: snapshot.data!,
                                            );
                                          } else {
                                            return const Text('No data available');
                                          }
                                        } else if (snapshot.hasError) {
                                          print(snapshot.error);
                                          return Text('Error: ${snapshot.error}');
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    );

                                    return ListTile(
                                      leading: leading,
                                      title: Text(suggestion["name"]),
                                      subtitle: subtitle,
                                    );
                                  } else {
                                    if (suggestion["type"] == "town") {
                                      leading = const Icon(Icons.location_city);

                                      return ListTile(
                                        leading: leading,
                                        title: Text(suggestion["name"]),
                                        subtitle: Text(suggestion["subname"]),
                                      );
                                    } else {
                                      leading = const Icon(Icons.location_on);

                                      return ListTile(
                                        leading: leading,
                                        title: Text(suggestion["name"]),
                                        subtitle: Text(suggestion["subname"]),
                                      );
                                    }
                                  }
                                },
                                onSelected: (value) {
                                  endController.text = value["name"];
                                  endLocation = {
                                    "lat": double.parse(value["lat"].toString()),
                                    "lon": double.parse(value["lon"].toString())
                                  };

                                  // Close suggestion (retain focus)
                                  endSuggestionsController.close(retainFocus: false);

                                  // Add marker to the map
                                  markers.remove(endMarker);
                                  endMarker = Marker(
                                    markerId: const MarkerId('end'),
                                    position: LatLng(endLocation["lat"], endLocation["lon"]),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                                  );
                                  markers.add(endMarker!);

                                  // Draw the route
                                  drawRoute();
                                  
                                  setState(() {
                                    markers = markers;
                                    lookingForStart = true;
                                  });
                                },
                                transitionBuilder: (context, animation, child) {
                                  return FadeTransition(
                                    opacity: CurvedAnimation(
                                      parent: animation,
                                      curve: Curves.fastOutSlowIn
                                    ),
                                    child: child,
                                  );
                                },
                                hideOnEmpty: true,
                                hideOnError: true,
                                builder: (context, controller, focusNode) {
                                  return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.search),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          // Clear the text box & values
                                          controller.clear();

                                          endLocation = {};

                                          // Remove the marker
                                          if (endMarker != null) {
                                            markers.remove(endMarker);
                                          }

                                          // Draw the route
                                          drawRoute();

                                          setState(() {
                                            markers = markers;
                                          });

                                          // If the start location is not empty, we make the possibility to put the end location by hand
                                          if (startLocation.isNotEmpty) {
                                            lookingForStart = false;
                                          } else {
                                            lookingForStart = true;
                                          }
                                        },
                                        icon: const Icon(Icons.clear),
                                      ),
                                      hintText: 'Arrivée',
                                      hintStyle: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontSize: 18,
                                        )
                                      ),
                                      labelStyle: GoogleFonts.nunito(
                                        textStyle: const TextStyle(
                                          fontSize: 12,
                                        )
                                      ),
                                      border: InputBorder.none,
                                      filled: true
                                    ),
                                    textAlign: TextAlign.center,
                                    textInputAction: TextInputAction.done,
                                  );
                                },
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                                ),
                              )
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.65,
                              child: DateTimeFormField(
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  hintText: 'Date',
                                  hintStyle: Theme.of(context).textTheme.bodySmall,
                                  labelStyle: Theme.of(context).textTheme.bodySmall,
                                  border: InputBorder.none,
                                  filled: true,
                                ),
                                style: Theme.of(context).textTheme.displayLarge,
                                initialPickerDateTime: DateTime.now(),
                                initialValue: selectedDate,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      selectedDate = value;
                                    });
                                  }
                                },
                                canClear: false,
                              )
                            )
                          ),
                        ],
                      ),
                      
                      Column(
                        children: [
                          // Swap button
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Swap the start and end text boxes
                                String temp = startController.text;
                                startController.text = endController.text;
                                endController.text = temp;

                                Map<String, dynamic> tempLocation = startLocation;
                                startLocation = endLocation;
                                endLocation = tempLocation;

                                // Remove the markers
                                if (startMarker != null) {
                                  markers.remove(startMarker);
                                }
                                if (endMarker != null) {
                                  markers.remove(endMarker);
                                }

                                // Swap the markers coordinates
                                if (startLocation.isNotEmpty) {
                                  startMarker = Marker(
                                    markerId: const MarkerId('start'),
                                    position: LatLng(startLocation["lat"], startLocation["lon"]),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                  );
                                  markers.add(startMarker!);
                                }

                                if (endLocation.isNotEmpty) {
                                  endMarker = Marker(
                                    markerId: const MarkerId('end'),
                                    position: LatLng(endLocation["lat"], endLocation["lon"]),
                                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                                  );
                                  markers.add(endMarker!);
                                }

                                // Draw the route
                                drawRoute();

                                setState(() {
                                  markers = markers;
                                });
                              },
                              child: const Icon(Icons.swap_vert),
                            ),
                          ),

                          // Search button
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Search for the route

                                setState(() {
                                  isSelectingSearch.value = false;
                                  panelController.open();
                                });
                              },
                              child: const Icon(Icons.search),
                            ),
                          ),

                          // Switch for arriving date
                          Column(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.2,
                                ),
                                child: AutoSizeText(
                                  "Date d'arrivée ?",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.nunito(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Switch(
                                value: arrivingDate,
                                activeColor: Colors.blue,
                                onChanged: (bool value) {
                                  // This is called when the user toggles the switch.
                                  setState(() {
                                    arrivingDate = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  )
                ),
              ),
            ],
          ),
        ),

        SlidingUpPanel(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
          minHeight: 0,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50.0),
            topRight: Radius.circular(50.0)
          ),
          controller: panelController,
          color: const Color(0xFF88D795),
          onPanelClosed: () {
            setState(() {
              isSelectingSearch.value = true;
            });
          },
          panel: ValueListenableBuilder(
            valueListenable: isSelectingSearch,
            builder: (context, value, child) {
              if (!value) {
                return FutureBuilder(
                  future: searchPaths(
                    startLocation["lat"],
                    startLocation["lon"],
                    endLocation["lat"],
                    endLocation["lon"],
                    selectedDate,
                    arrivingDate
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 16.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          padding: const EdgeInsets.only(
                            top: 16.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50.0),
                              topRight: Radius.circular(50.0)
                            ),
                          ),
                          child: FutureBuilder(
                            future: buildPathButtons(snapshot.data!),
                            builder: (context, snapshot2) {
                              if (snapshot2.connectionState == ConnectionState.done) {
                                if (snapshot2.hasData && snapshot2.data != null) {
                                  return ListView.separated(
                                    itemBuilder: (context, index) {
                                      return AnimatedOpacity(
                                        opacity: 1.0,
                                        curve: Curves.easeInOut,
                                        duration: const Duration(milliseconds: 500),
                                        child: snapshot2.data![index],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(
                                        color: Colors.black.withOpacity(0.40),
                                      );
                                    },
                                    itemCount: snapshot2.data!.length,
                                  );
                                } else {
                                  print(snapshot2.error);
                                  return const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error),
                                      Text('Aucun chemin trouvé :('),
                                    ],
                                  );
                                }
                              } else if (snapshot2.hasError) {
                                print(snapshot2.error);
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error),
                                    Text('Une erreur est survenue, veuillez rééssayer plus tard :('),
                                  ],
                                );
                              } else {
                                return Container();
                              }
                            },
                          )
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.only(
                            top: 16.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          padding: const EdgeInsets.only(
                            top: 16.0,
                          ),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(50.0),
                              topRight: Radius.circular(50.0)
                            ),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error),
                              Text('Aucun chemin trouvé :('),
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return Container(
                        margin: const EdgeInsets.only(
                          top: 16.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0)
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error),
                            Text('Une erreur est survenue, veuillez rééssayer plus tard :('),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.only(
                          top: 16.0,
                          left: 8.0,
                          right: 8.0,
                        ),
                        padding: const EdgeInsets.only(
                          top: 16.0,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0)
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Text('Recherche en cours...'),
                          ],
                        ),
                      );
                    }
                  },
                );
              } else {
                return Container();
              }
            },
          )
        )
      ],
    );
  }
}