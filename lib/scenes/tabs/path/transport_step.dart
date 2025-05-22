import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/utils/assets.dart';
import 'package:mobile_app/utils/functions.dart';

class TransportStep extends StatefulWidget {
  final Map<String, dynamic> pathData;
  final String startName;
  final String endName;

  const TransportStep({
    super.key,
    required this.pathData,
    required this.startName,
    required this.endName,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TransportStepState createState() => _TransportStepState();
}

// Custom painter for drawing a hatched (dashed) vertical line
class HatchedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double dashHeight = 10, dashSpace = 3;
    double startY = 0;
    final paint = Paint()
      ..color = const Color.fromARGB(255, 85, 85, 85)
      ..strokeWidth = size.width;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for drawing a horizontal line
class HorizontalLinePainter extends CustomPainter {
  final Color color;

  HorizontalLinePainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TransportStepState extends State<TransportStep> {
  Future<List<Widget>> buildTripCards() async {
    List<Widget> widgets = [];

    // Add start column
    widgets.add(
      Row(
        children: [
          const Icon(
            Icons.location_pin,
            size: 40,
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Départ",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold
                ),
              ),

              Text(
                // Show hour & end name
                "${DateTime.parse(widget.pathData["start"]).hour.toString().padLeft(2, '0')}:${DateTime.parse(widget.pathData["start"]).minute.toString().padLeft(2, '0')} - ${widget.startName}",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            ],
          )
        ],
      )
    );

    int legIndex = 0;
    for (var leg in widget.pathData['legs']) {
      DateTime scheduledStart = DateTime.parse(leg["start"]["scheduledTime"]);
      DateTime scheduledEnd = DateTime.parse(leg["end"]["scheduledTime"]);
      DateTime? estimatedStart = (leg["start"]["estimated"] != null)
          ? DateTime.parse(leg["start"]["estimated"]['time'])
          : null;
      DateTime? estimatedEnd = (leg["end"]["estimated"] != null)
          ? DateTime.parse(leg["end"]["estimated"]['time'])
          : null;

      Widget? lineDrawing;
      Widget? card;
      Widget? startInfo;

      if (legIndex > 0) {
        startInfo = Text(
          "${scheduledStart.hour.toString().padLeft(2, '0')}:${scheduledStart.minute.toString().padLeft(2, '0')} - ${leg["from"]["name"]}",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        );
      }

      if (leg["mode"] == "WALK") {
        if (convertSecondsToMinutes(double.parse(leg['duration'].toString())).floor() == 0) {
          // Write correspondance
          // Draw card
          card = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              startInfo ?? Container(),

              Expanded(
                child: Card(
                  child: Container(
                    width: double.infinity, // Forces the Card to take full width
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Correspondance",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ]
          );

          // We'll size the lineDrawing to match the card's height using IntrinsicHeight and Expanded
          lineDrawing = Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: const Size(3, double.infinity),
                  painter: HatchedLinePainter(),
                ),
              ),
              Container(
                color: Colors.grey[300] ?? Colors.grey,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(
                  Icons.directions_walk,
                  size: 40,
                ),
              ),
              Expanded(
                child: CustomPaint(
                  size: const Size(3, double.infinity),
                  painter: HatchedLinePainter(),
                ),
              ),
            ],
          );
        } else {
          // Draw card
          card = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              startInfo ?? Container(),

              Expanded(
                child: Card(
                  child: Container(
                    width: double.infinity, // Forces the Card to take full width
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Marche",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${convertSecondsToMinutes(double.parse(leg['duration'].toString())).floor()} minutes",
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ]
          );

          // We'll size the lineDrawing to match the card's height using IntrinsicHeight and Expanded
          lineDrawing = Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: const Size(3, double.infinity),
                  painter: HatchedLinePainter(),
                ),
              ),
              Container(
                color: Colors.grey[300] ?? Colors.grey,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: const Icon(
                  Icons.directions_walk,
                  size: 40,
                ),
              ),
              Expanded(
                child: CustomPaint(
                  size: const Size(3, double.infinity),
                  painter: HatchedLinePainter(),
                ),
              ),
            ],
          );
        }
      } else {
        String? transportIcon = getMainTransportModeAsset([leg["mode"]], context);
        Widget lineLogo = await getLineLogo(leg, context);

        Widget expansionTile = ExpansionTile(
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            "${leg["intermediateStops"].length} arrêts",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          childrenPadding: EdgeInsets.zero, // Remove extra padding
          tilePadding: EdgeInsets.zero, // Optional: remove padding around the tile itself
          children: [
            ...List<Widget>.generate(
              leg["intermediateStops"].length,
              (index) {
                final stop = leg["intermediateStops"][index];

                // Create a key for each station text
                final stationKey = GlobalKey();

                Widget children = Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0, bottom: 4.0), // Reduce left indent
                  key: stationKey,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      stop["name"] ?? "",
                      style: GoogleFonts.nunito(),
                    ),
                  ),
                );

                return children;
              },
            ),
          ],
        );

        // Draw card
        card = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            startInfo ?? Container(),

            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (transportIcon != null)
                            SizedBox(
                              width: 30,
                              height: 30,
                              child: Image.asset(
                                transportIcon,
                              ),
                            ),
                          const SizedBox(width: 4),
                          lineLogo,
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${leg["from"]["name"]}",
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Vers ${leg["to"]["name"]}",
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Dropdown for stops
                      if (leg["intermediateStops"] != null && leg["intermediateStops"] is List && leg["intermediateStops"].isNotEmpty)
                        Theme(
                          // ignore: use_build_context_synchronously
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: expansionTile,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

        lineDrawing = Stack(
          alignment: Alignment.center,
          children: [
            Expanded(
              child: CustomPaint(
                size: const Size(8, double.infinity),
                painter: HorizontalLinePainter(
                  color: HexColor(leg["route"]["color"] ?? "#000000"),
                ),
              ),
            ),
          ],
        );
      }

      widgets.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 40,
                child: lineDrawing,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: card,
              ),
            ],
          ),
        )
      );

      legIndex++;
    }

    // Add end column
    widgets.add(
      Row(
        children: [
          const Icon(
            Icons.location_pin,
            size: 40,
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Arrivée",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold
                ),
              ),

              Text(
                // Show hour & end name
                "${DateTime.parse(widget.pathData["end"]).hour.toString().padLeft(2, '0')}:${DateTime.parse(widget.pathData["end"]).minute.toString().padLeft(2, '0')} - ${widget.endName}",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )
            ],
          )
        ],
      )
    );

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true, // Always show scrollbar (optional)
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          FutureBuilder(
            future: buildTripCards(),
            builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Erreur : ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Aucun résultat trouvé.'));
              } else {
                return Column(
                  children: snapshot.data!,
                );
              }
            },
          )
        ],
      ),
    );
  }
}