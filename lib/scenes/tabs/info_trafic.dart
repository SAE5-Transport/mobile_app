import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/api/hexatransit_api.dart';

class InfoTraficPage extends StatefulWidget {
  const InfoTraficPage({
    super.key,
  });

  @override
  State<InfoTraficPage> createState() => _InfoTraficPageState();
}

class _InfoTraficPageState extends State<InfoTraficPage> {
  ValueNotifier<List<Map<String, dynamic>>> alertData = ValueNotifier([]);

  Future<List<Widget>> getCompaniesAlertBoxes() async {
    List<Widget> companiesAlertBoxes = [];

    // Load data from assets
    final jsonData = await rootBundle.loadString('assets/data/trafic.json');

    // Parse JSON
    List<dynamic> data = jsonDecode(jsonData);

    for (var company in data) {
      List<Widget> companyAlertBoxes = [];

      for (var lineCategory in company["lines"]) {
        List<Widget> linesAlertBoxes = [];
        Widget? lineTransportLogo;

        for (var line in lineCategory) {
          if (line["transportLogo"] != null) {
            lineTransportLogo = Image.asset(
              line["transportLogo"],
              width: line["width"],
              height: line["height"],
            );
          } else {
            linesAlertBoxes.add(
              LineAlertBox(
                lineId: line["lineId"],
                lineLogo: line["lineLogo"],
                scale: line["scale"],
                isDisabled: line["isDisabled"],
                alertData: alertData,
              )
            );
          }
        }

        companyAlertBoxes.add(
          Row(
            children: [
              lineTransportLogo ?? Container(),

              const SizedBox(width: 8),

              Expanded( // Allow the Wrap to expand and wrap its children
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: linesAlertBoxes,
                ),
              ),
            ],
          )
        );

        companyAlertBoxes.add(const SizedBox(height: 12));
      }

      // Wrap each company's alert boxes in a Column
      companiesAlertBoxes.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Insert logo of the company
            Image.asset(
              company["companyLogo"],
              width: company["width"],
              height: company["height"],
            ),

            // Insert the lines alert boxes
            ...companyAlertBoxes,
          ],
        )
      );
    }

    return companiesAlertBoxes;
  }

  Future<List<String>> getLineIds() async {
    final jsonData = await rootBundle.loadString('assets/data/trafic.json');
    final data = jsonDecode(jsonData) as List<dynamic>;

    return data.expand((company) => company["lines"])
               .expand((lineCategory) => lineCategory)
               .where((line) => line["lineId"] != null)
               .map<String>((line) => line["lineId"] as String)
               .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Trafic'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous page
          },
        ),
      ),
      body: Material(
        color: Theme.of(context).colorScheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              FutureBuilder(
                future: getCompaniesAlertBoxes(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    () async {
                      List<Map<String, dynamic>> alerts = await getIncidentsOnLines(await getLineIds());
                      alertData.value = alerts;
                    }();

                    // Create loop catching data every 1 minute
                    Timer.periodic(const Duration(seconds: 10), (timer) async {
                      List<Map<String, dynamic>> alerts = await getIncidentsOnLines(await getLineIds());
                      alertData.value = alerts;
                    });

                    return ListView(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      shrinkWrap: true,
                      children: snapshot.data!,
                    );
                  } else if (snapshot.hasError) {
                    if (kDebugMode) {
                      print(snapshot.error);
                    }
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LineAlertBox extends StatefulWidget {
  final String lineId;
  final String lineLogo;
  final double scale;
  final bool? isDisabled;
  final ValueNotifier<List<Map<String, dynamic>>> alertData;

  const LineAlertBox({
    super.key,
    required this.lineId,
    required this.lineLogo,
    required this.scale,
    required this.alertData,
    this.isDisabled = false,
  });

  @override
  State<LineAlertBox> createState() => _LineAlertBoxState();
}

class _LineAlertBoxState extends State<LineAlertBox> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.alertData,
      builder: (context, alerts, child) {
        Color borderColor = Colors.grey;
        Widget logoPerturbation = Container();
        bool hasWorks = false;

        for (var line in alerts) {
          if (line["id"] == widget.lineId) {
            for (var alert in line["situations"]) {
              final severity = alert["severity"];
              final validityPeriod = alert["validityPeriod"];
              final isValid = DateTime.now().isAfter(DateTime.parse(validityPeriod["startTime"]).toLocal()) &&
                              DateTime.now().isBefore(DateTime.parse(validityPeriod["endTime"]).toLocal());

              if (severity == "severe") {
                if (!isValid) continue;

                borderColor = Colors.red;
                logoPerturbation = Image.asset(
                  'assets/icons/trafic/servicestopped.png',
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.width * 0.05,
                );
                break;
              } else if (severity == "normal") {
                if (alert["description"][0]["value"].toLowerCase().contains("travaux")) {
                  if (!isValid && !hasWorks) {
                    logoPerturbation = Image.asset(
                      'assets/icons/trafic/works_future.png',
                      width: MediaQuery.of(context).size.width * 0.05,
                      height: MediaQuery.of(context).size.width * 0.05,
                    );
                  } else {
                    hasWorks = true;
                    borderColor = Colors.red;
                    logoPerturbation = Image.asset(
                      'assets/icons/trafic/works.png',
                      width: MediaQuery.of(context).size.width * 0.05,
                      height: MediaQuery.of(context).size.width * 0.05,
                    );
                  }
                } else {
                  if (!isValid) continue;

                  borderColor = Colors.orange;
                  logoPerturbation = Image.asset(
                    'assets/icons/trafic/servicedisrupted.png',
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: MediaQuery.of(context).size.width * 0.05,
                  );
                }
              } else if (severity == "unknown" && borderColor == Colors.grey) {
                if (!isValid) continue;

                logoPerturbation = Image.asset(
                  'assets/icons/trafic/info.png',
                  width: MediaQuery.of(context).size.width * 0.05,
                  height: MediaQuery.of(context).size.width * 0.05,
                );
              }
            }
          }
        }

        if (widget.isDisabled == true) {
          borderColor = Colors.grey;
        }

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: 5,
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.13,
              height: MediaQuery.of(context).size.width * 0.13,
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                widget.lineLogo,
                scale: widget.scale,
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: logoPerturbation,
            ),
          ],
        );
      },
    );
  }
}