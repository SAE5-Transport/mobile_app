import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app/api/hexatransit_api.dart';

class NextDeparturesTable extends StatefulWidget {
  final String stationId;
  final DateTime startTime;
  final String toStationId;
  final String lineId;

  const NextDeparturesTable({
    super.key,
    required this.stationId,
    required this.startTime,
    required this.toStationId,
    required this.lineId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _NextDeparturesTableState createState() => _NextDeparturesTableState();
}

class _NextDeparturesTableState extends State<NextDeparturesTable> {
  final ValueNotifier<List<Widget>> _departuresRows = ValueNotifier<List<Widget>>([]);

  @override
  void initState() {
    super.initState();

    // Build the departures rows every 1minute
    buildDeparturesRows();

    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        buildDeparturesRows();
      }
    });
  }

  void buildDeparturesRows() async {
    // Get data
    Map<String, dynamic> data = await getNextDepartureByStation(
      widget.stationId,
      widget.startTime,
      999999, // Assuming 999999 is a placeholder for max departures
      3, // Assuming 3 is a placeholder for max lines
      true
    );

    if (data.isEmpty || data['quay'] == null || data['quay']['estimatedCalls'] == null) {
      _departuresRows.value = [];
      return;
    }

    // Simulate fetching data and building rows
    List<Widget> rows = [];
    int count = 0;
    for (var departure in data['quay']["estimatedCalls"]) {
      DateTime aimedDeparture = DateTime.parse(departure['aimedDepartureTime']).toLocal();
      DateTime estimatedDeparture = DateTime.parse(departure['expectedDepartureTime']).toLocal();

      bool realtime = departure['realtime'];
      Map<String, dynamic> line = departure['serviceJourney']['line'];
      List<dynamic> passingTimes = departure['serviceJourney']['passingTimes'];

      // Check if stationId or toStationId is not present in passingTimes
      bool hasStationId = passingTimes.any((pt) => pt['quay']['id'] == widget.stationId);
      // Check if toStationId is present after stationId in passingTimes
      int stationIdx = passingTimes.indexWhere((pt) => pt['quay']['id'] == widget.stationId);
      int toStationIdx = passingTimes.indexWhere((pt) => pt['quay']['id'] == widget.toStationId);
      bool hasToStationId = stationIdx != -1 && toStationIdx != -1 && toStationIdx > stationIdx;

      if (!hasStationId || !hasToStationId) {
        continue; // Skip this departure if either is missing
      }

      // Check if the line matches the specified lineId
      if (widget.lineId.isNotEmpty && line['id'] != widget.lineId) {
        continue; // Skip this departure if the line does not match
      }

      if (count >= 3) {
        break; // Limit to 3 departures
      }

      count++;

      // Build the row widget
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              title: Text(
                "${aimedDeparture.hour.toString().padLeft(2, '0')}:${aimedDeparture.minute.toString().padLeft(2, '0')}",
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                passingTimes.last['quay']['name'],
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (realtime)
                    const Icon(
                      Icons.rss_feed,
                      color: Colors.orange,
                      size: 20,
                    ),

                  if (realtime)
                    Text(
                      "${estimatedDeparture.hour.toString().padLeft(2, '0')}:${estimatedDeparture.minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  else
                    Text(
                      "${aimedDeparture.hour.toString().padLeft(2, '0')}:${aimedDeparture.minute.toString().padLeft(2, '0')}",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                ],
              )
            ),
          ),
        ),
      );
    }

    _departuresRows.value = rows;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ValueListenableBuilder<List<Widget>>(
        valueListenable: _departuresRows,
        builder: (context, rows, child) {
          if (rows.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: rows,
          );
        },
      ),
    );
  }
}