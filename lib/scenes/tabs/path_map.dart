import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mobile_app/utils/assets.dart';
import 'package:mobile_app/utils/functions.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class PathMap extends StatefulWidget {
  final Map<String, dynamic> pathData;

  const PathMap({
    super.key,
    required this.pathData,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PathMapState createState() => _PathMapState();
}

class _PathMapState extends State<PathMap> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(48.866667, 2.333333),
    zoom: 14.4746,
  );

  Set<Polyline> polylines = {};
  Set<Marker> markers = {};

  final ValueNotifier<double> _mapHeightFactor = ValueNotifier<double>(0.9);

  void _zoomToFitPolygon() {
    List<LatLng> coordinates = polylines.expand((polyline) => polyline.points).toList();

    LatLngBounds bounds = calculateBounds(coordinates);
    _controller.future.then((controller) {
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
  }

  Future<List<Widget>> buildTransportIcons() async {
    List<Widget> transportIcons = [];

    for (var leg in widget.pathData['legs']) {
      // Add a separator
      transportIcons.add(
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Icon(
            Icons.circle,
            size: 4,
          )
        )
      );

      if (leg["route"] != null) {
        transportIcons.add(await getTransportIconFromPath(leg["route"]));
      } else {
        transportIcons.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.directions_walk,
                size: 24,
              ),

              Text(
                "${convertSecondsToMinutes(double.parse(leg['duration'].toString())).floor()}",
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                  color: Colors.black
                )
              )
            ],
          )
        );
      }
    }

    // Remove the first separator
    transportIcons.removeAt(0);

    return transportIcons;
  }

  @override
  void initState() {
    super.initState();
    
    // Add polylines to the map
    for (var leg in widget.pathData['legs']) {
      List<LatLng> points = decodePolyline(leg['legGeometry']['points']);
      Map<String, dynamic>? line = leg['route'];
      String color = line != null ? (line['color'] ?? '#000000') : '#000000';

      Polyline polyline = Polyline(
        polylineId: PolylineId(leg['legGeometry']['points']),
        color: HexColor(color),
        points: points,
        width: 5,
      );

      polylines.add(polyline);
    }

    // Add from station marker
    markers.add(
      Marker(
        markerId: const MarkerId('from'),
        position: LatLng(polylines.first.points.first.latitude, polylines.first.points.first.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      )
    );

    // Add to station marker
    markers.add(
      Marker(
        markerId: const MarkerId('to'),
        position: LatLng(polylines.last.points.last.latitude, polylines.last.points.last.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[300] ?? Colors.grey,
            ),

            ValueListenableBuilder<double>(
              valueListenable: _mapHeightFactor,
              builder: (context, value, child) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height * value,
                  width: MediaQuery.of(context).size.width,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      _zoomToFitPolygon();
                    },
                    polylines: polylines,
                    markers: markers,
                  ),
                );
              },
            ),

            // Button return
            Positioned(
              top: 16,
              left: 16,
              child: IconButton.filled(
                icon: const Icon(Icons.arrow_back),
                color: Colors.black,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),

            // Register button
            Positioned(
              top: 16,
              right: 16,
              child: IconButton.filled(
                icon: const Icon(Icons.bookmark_border),
                color: Colors.black,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.white),
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
                onPressed: () {}
              ),
            ),

            SlidingUpPanel(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              minHeight: MediaQuery.of(context).size.height * 0.1,
              color: Colors.grey[300] ?? Colors.grey,
              onPanelSlide: (double position) {
                _mapHeightFactor.value = (0.9 - (position * 0.4)).clamp(0.1, 0.9);
              },
              panel: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Lines and duration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: buildTransportIcons(),
                          builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                            if (snapshot.connectionState == ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.6, // Adjust the width as needed
                                  child: Wrap(
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: snapshot.data!,
                                  ),
                                );
                              } else {
                                return const CircularProgressIndicator();
                              }
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                        
                        Flexible(
                          child: Text(
                            '${convertSecondsToMinutes(double.parse(widget.pathData['duration'].toString())).floor().toString()} min',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.normal,
                              color: Colors.black
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}