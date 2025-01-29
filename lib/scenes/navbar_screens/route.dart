import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({
    super.key,
  });

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController startController = TextEditingController();
    TextEditingController endController = TextEditingController();

    return Column(
      children: [
        // Buttons to switch between "Favoris / Prévu" and "Historique"
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToggleButtons(
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
                        child: TypeAheadField(
                          controller: startController,
                          suggestionsCallback: (search) {
                            // Fetch suggestions from the server
                            List<String> suggestions = [];

                            return suggestions;
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (value) {
                            print(value);
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
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
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
                          }
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                        child: TypeAheadField(
                          controller: endController,
                          suggestionsCallback: (search) {
                            // Fetch suggestions from the server
                            List<String> suggestions = [];

                            return suggestions;
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          onSelected: (value) {
                            print(value);
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
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
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
                          }
                        )
                      ),
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
                        },
                        child: const Icon(Icons.search),
                      ),
                    ),
                  ],
                )
              ],
            )
          ),
        ),
      ],
    );
  }
}