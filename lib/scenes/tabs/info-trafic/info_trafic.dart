import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/api/hexatransit_api.dart';
import 'package:mobile_app/scenes/tabs/info-trafic/info_trafic_details.dart';
import 'package:mobile_app/utils/assets.dart';

class InfoTraficPage extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const InfoTraficPage({
    super.key,
    required this.companyData,
  });

  @override
  State<InfoTraficPage> createState() => _InfoTraficPageState();
}

class _InfoTraficPageState extends State<InfoTraficPage> {
  ValueNotifier<List<Map<String, dynamic>>> alertData = ValueNotifier([]);
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  ValueNotifier<DateTime?> lastRefreshTime = ValueNotifier(null);

  Future<List<Widget>> getCompaniesAlertBoxes() async {
    List<Widget> companyAlertBoxes = [];
    List<Widget> companiesAlertBoxes = [];

    for (var lineCategory in widget.companyData["lines"]) {
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
            widget.companyData["companyLogo"],
            width: widget.companyData["width"],
            height: widget.companyData["height"],
          ),

          // Add a refresh button
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ) // Affiche une animation de chargement
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () async {
                        isLoading.value = true; // Début du chargement
                        lastRefreshTime = ValueNotifier(null); // Réinitialise l'heure du dernier rafraîchissement
                        List<Map<String, dynamic>> alerts = await getIncidentsOnLines(await getLineIds());
                        alertData.value = alerts;
                        lastRefreshTime.value = DateTime.now(); // Met à jour l'heure du dernier rafraîchissement
                        isLoading.value = false; // Fin du chargement
                      },
                    ),
                  const SizedBox(width: 8),
                  ValueListenableBuilder<DateTime?>(
                    valueListenable: lastRefreshTime,
                    builder: (context, lastRefresh, child) {
                      return Text(
                        lastRefresh != null
                            ? "Mis à jour à ${lastRefresh.hour}:${lastRefresh.minute.toString().padLeft(2, '0')}"
                            : "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // Insert the lines alert boxes
          ...companyAlertBoxes,
        ],
      )
    );

    return companiesAlertBoxes;
  }

  Future<List<String>> getLineIds() async {
    return widget.companyData["lines"]
               .expand((lineCategory) => lineCategory as Iterable)
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
          child: FutureBuilder(
            future: getCompaniesAlertBoxes(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                () async {
                  isLoading.value = true;
                  List<Map<String, dynamic>> alerts = await getIncidentsOnLines(await getLineIds());
                  alertData.value = alerts;
                  lastRefreshTime.value = DateTime.now();
                  isLoading.value = false;
                }();

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView(
                              padding: const EdgeInsets.only(left: 4, right: 4),
                              shrinkWrap: true, // Allow ListView to adapt to its content
                              physics: const NeverScrollableScrollPhysics(), // Disable internal scrolling
                              children: snapshot.data!,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return const CircularProgressIndicator();
              }
            },
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
  Map<String, dynamic> lineData = {};

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: widget.alertData,
      builder: (context, alerts, child) {
        Map<String, dynamic> lineLogoData = getLineLogoWithPerturbation(alerts, widget.lineId, widget.lineLogo, widget.isDisabled, context);
        lineData = lineLogoData['lineData'];

        return GestureDetector(
          onTap: () {
            if (lineData.isEmpty) return;

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => InfoTraficDetails(
                  lineData: lineData,
                  logo: lineLogoData['logo'],
                ),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0); // Start from the right
                  const end = Offset.zero; // End at the current position
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: lineLogoData['logo'],
        );
      },
    );
  }
}