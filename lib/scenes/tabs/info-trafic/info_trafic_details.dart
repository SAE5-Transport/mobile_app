import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mobile_app/utils/assets.dart' as assets;

class InfoTraficDetails extends StatefulWidget {
  final Map<String, dynamic> lineData;
  final Widget logo;

  const InfoTraficDetails({
    super.key,
    required this.lineData,
    required this.logo,
  });

  @override
  State<InfoTraficDetails> createState() => _InfoTraficDetailsState();
}

class _InfoTraficDetailsState extends State<InfoTraficDetails> {
  final ValueNotifier<List<bool>> isSelected = ValueNotifier([true, false, false]);

  List<Map<String, dynamic>> rightNow = [];
  List<Map<String, dynamic>> today = [];
  List<Map<String, dynamic>> future = [];

  void buildAlertMessages() {
    final Set<String> addedAlertIds = {}; // Track added alert IDs
    const severityOrder = {"severe": 1, "normal": 2, "unknown": 3}; // Define severity order

    for (var alert in widget.lineData["situations"]) {
      String alertId = alert['id']; // Assuming each alert has a unique 'id'

      // Skip if the alert ID is already added
      if (addedAlertIds.contains(alertId)) {
        continue;
      }

      // Get validity periods
      DateTime startTime = DateTime.parse(alert['validityPeriod']["startTime"]);
      DateTime endTime = DateTime.parse(alert['validityPeriod']["endTime"]);
      DateTime now = DateTime.now();

      // Check if the alert is valid right now
      if (now.isAfter(startTime) && now.isBefore(endTime)) {
        rightNow.add(alert);
        addedAlertIds.add(alertId); // Mark the alert as added
      } 
      // Check if the alert is valid today (same day as 'now')
      else if (startTime.day == now.day && startTime.month == now.month && startTime.year == now.year && now.isBefore(endTime)) {
        today.add(alert);
        addedAlertIds.add(alertId); // Mark the alert as added
      }
      // Check if the alert is valid in the future (but not today)
      else if (now.isBefore(startTime) &&
          !(startTime.day == now.day &&
            startTime.month == now.month &&
            startTime.year == now.year)) {
        future.add(alert);
        addedAlertIds.add(alertId); // Mark the alert as added
      }
    }

    // Sort each list by severity and startTime
    rightNow.sort((a, b) {
      int severityA = severityOrder[a['severity']] ?? severityOrder.length;
      int severityB = severityOrder[b['severity']] ?? severityOrder.length;
      if (severityA == severityB) {
        return DateTime.parse(a['validityPeriod']["startTime"])
            .compareTo(DateTime.parse(b['validityPeriod']["startTime"]));
      }
      return severityA.compareTo(severityB);
    });

    today.sort((a, b) {
      int severityA = severityOrder[a['severity']] ?? severityOrder.length;
      int severityB = severityOrder[b['severity']] ?? severityOrder.length;
      if (severityA == severityB) {
        return DateTime.parse(a['validityPeriod']["startTime"])
            .compareTo(DateTime.parse(b['validityPeriod']["startTime"]));
      }
      return severityA.compareTo(severityB);
    });

    future.sort((a, b) {
      int severityA = severityOrder[a['severity']] ?? severityOrder.length;
      int severityB = severityOrder[b['severity']] ?? severityOrder.length;
      if (severityA == severityB) {
        return DateTime.parse(a['validityPeriod']["startTime"])
            .compareTo(DateTime.parse(b['validityPeriod']["startTime"]));
      }
      return severityA.compareTo(severityB);
    });
  }

  @override
  void initState() {
    super.initState();
    buildAlertMessages();
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: assets.HexColor.fromHex(widget.lineData["presentation"]["colour"]),
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity
    );

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.lineData['name'],
          maxFontSize: 22,
          maxLines: 2,
          softWrap: true,
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous page
          },
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Material(
        color: colorScheme.primaryContainer,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  child: FittedBox(
                    fit: BoxFit.contain, // Ensures the logo scales properly
                    child: widget.logo,
                  ),
                )
              ),

              const SizedBox(height: 12),

              // Buttons to filter the information
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 4.0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 48, // Explicit height for ToggleButtons
                      child: ToggleButtons(
                        color: Colors.black.withOpacity(0.60),
                        selectedColor: Colors.white,
                        selectedBorderColor: Colors.white,
                        fillColor: Colors.white.withOpacity(0.08),
                        splashColor: Colors.white.withOpacity(0.4),
                        hoverColor: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4.0),
                        constraints: const BoxConstraints(
                          minHeight: 48, // Ensure consistent height
                          minWidth: 100, // Optional: Set a minimum width for buttons
                        ),
                        isSelected: isSelected.value,
                        onPressed: (index) {
                          setState(() {
                            for (int buttonIndex = 0; buttonIndex < isSelected.value.length; buttonIndex++) {
                              isSelected.value[buttonIndex] = buttonIndex == index;
                            }
                          });
                        },
                        children: const [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'En cours',
                                maxLines: 2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.today, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Dans la journée',
                                maxLines: 2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.schedule, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Prévu',
                                maxLines: 2,
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Display the information
              ValueListenableBuilder(
                valueListenable: isSelected,
                builder: (context, value, child) {
                  // Debug stuffs
                  /*JsonDecoder decoder = JsonDecoder();
                  JsonEncoder encoder = JsonEncoder.withIndent('  ');
                  var object = decoder.convert(jsonEncode(widget.lineData));
                  var prettyString = encoder.convert(object);
                  prettyString.split('\n').forEach((element) => print(element));*/

                  return Expanded(
                    child: ListView.builder(
                      itemCount: isSelected.value[0] ? rightNow.length : (isSelected.value[1] ? today.length : future.length),
                      itemBuilder: (context, index) {
                        var alert = isSelected.value[0] ? rightNow[index] : (isSelected.value[1] ? today[index] : future[index]);
                        return Card(
                          color: colorScheme.primary,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ExpansionTile(
                            leading: SizedBox(
                              width: 40, // Set the desired width
                              height: 40, // Set the desired height
                              child: assets.getLogoPerturbation(alert),
                            ),
                            title: Text(
                              alert['summary'][0]['value'],
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            iconColor: Colors.white,
                            collapsedIconColor: Colors.white.withOpacity(0.7), // Color of the arrow when collapsed
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                child: Html(
                                  data: alert['description'][0]['value'], // Render the HTML content
                                  style: {
                                    "body": Style(
                                      color: colorScheme.onPrimary, // Apply color scheme
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                                  }
              ),
            ],
          ),
        )
      )
    );
  }
}