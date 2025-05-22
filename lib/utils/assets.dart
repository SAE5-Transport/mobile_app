import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/utils/functions.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  // Add the fromHex method
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

String? getMainTransportModeAsset(List<String> modes, BuildContext context) {
  String? topMode;

  // Get top mode from the list
  if (isNightMode(context)) {
    if (modes.contains('BUS')) {
      topMode = 'assets/icons/transportMode/bus_white.png';
    }
    if (modes.contains('TRAM')) {
      topMode = 'assets/icons/transportMode/tram_white.png';
    }
    if (modes.contains('SUBWAY')) {
      topMode = 'assets/icons/transportMode/metro_white.png';
    }
    if (modes.contains('RAIL')) {
      topMode = 'assets/icons/transportMode/train_white.png';
    }
    if (modes.contains('CABLE_CAR')) {
      topMode = 'assets/icons/transportMode/cable_white.png';
    } 
    if (modes.contains('FERRY')) {
      topMode = 'assets/icons/transportMode/ferry_white.png';
    }
  } else {
    if (modes.contains('BUS')) {
      topMode = 'assets/icons/transportMode/bus.png';
    }
    if (modes.contains('TRAM')) {
      topMode = 'assets/icons/transportMode/tram.png';
    }
    if (modes.contains('SUBWAY')) {
      topMode = 'assets/icons/transportMode/metro.png';
    }
    if (modes.contains('RAIL')) {
      topMode = 'assets/icons/transportMode/train.png';
    }
    if (modes.contains('CABLE_CAR')) {
      topMode = 'assets/icons/transportMode/cable.png';
    } 
    if (modes.contains('FERRY')) {
      topMode = 'assets/icons/transportMode/ferry.png';
    }
  }

  return topMode;
}

const Map<String, int> gtfsRouteTypeOrder = {
  'SUBWAY': 0,
  'RAIL': 1,
  'TRAM': 2,
  'FERRY': 3,
  'CABLE_CAR': 4,
  'BUS': 5,
  // Add other GTFS route types if needed
};

Future<Map<String, dynamic>> loadPriorityData() async {
  final csvData = await rootBundle.loadString('assets/data/lines_picto.csv');
  List<List<dynamic>> csvTable = const CsvToListConverter().convert(csvData, fieldDelimiter: ";");

  Map<String, dynamic> priorityMap = {};
  for (var row in csvTable) {
    String lineId = row[0];
    String picto = row[2];
    bool isPriority = row[4] == 1;
    bool darkMode = row[5] == 1;
    priorityMap[lineId] = {
      'picto': picto,
      'isPriority': isPriority,
      'darkMode': darkMode,
    };
  }
  return priorityMap;
}

List<dynamic> sortLinesByGtfsRouteType(Map<String, Map<String, dynamic>> lines, Map<String, dynamic> priorityMap) {
  List<dynamic> linesList = lines.values.toList();
  linesList.sort((a, b) {
    int orderA = gtfsRouteTypeOrder[a['mode']] ?? gtfsRouteTypeOrder.length;
    int orderB = gtfsRouteTypeOrder[b['mode']] ?? gtfsRouteTypeOrder.length;

    bool isPriorityA = priorityMap[a['gtfsId']]?['isPriority'] ?? false;
    bool isPriorityB = priorityMap[b['gtfsId']]?['isPriority'] ?? false;

    if (isPriorityA && !isPriorityB) {
      return -1;
    } else if (!isPriorityA && isPriorityB) {
      return 1;
    } else if (orderA != orderB) {
      return orderA.compareTo(orderB);
    } else {
      return (a['shortName'] ?? '').compareTo(b['shortName'] ?? '');
    }
  });
  return linesList;
}

Future<Widget> getTransportIconFromPath(Map<String, dynamic> line, context, bool darkModeParam) async {
  Map<String, dynamic> priorityMap = await loadPriorityData();

  String lineId = line['gtfsId'];

  if (priorityMap[lineId] != null) {
    String darkMode = isNightMode(context) && priorityMap[lineId]['darkMode'] && darkModeParam ? '_dark' : '';

    return Image.asset(
      priorityMap[lineId]['picto'].replaceFirst('.png', '${darkMode}.png'),
      width: 24,
      height: 24,
    );
  } else {
    Widget iconPlus = Container();
    if (lineId.contains("fr-sncf-tgv")) {
      iconPlus = Image.asset(
        'assets/logo/fr-sncf-tgv/logo.png',
        height: 32,
        width: 42,
      );
    } else if (lineId.contains("fr-sncf-ter")) {
      iconPlus = Image.asset(
        'assets/logo/fr-sncf-ter/logo.png',
        height: 32,
        width: 28,
      );
    }

    return IntrinsicWidth(
      child: Row(
        children: [
          iconPlus,
          Container(
            height: 24,
            decoration: BoxDecoration(
              color: HexColor(line['color'] ?? '#000000'),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                line['shortName'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HexColor(line['textColor'] ?? '#FFFFFF'),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

Future<Row> getTransportsIcons(Map<String, Map<String, dynamic>> linesData, BuildContext context, bool darkModeParam) async {
  List<Widget> icons = [];
  List<String> linesIds = [];
  Map<String, dynamic> priorityMap = await loadPriorityData();

  List<dynamic> sortedLines = sortLinesByGtfsRouteType(linesData, priorityMap);

  for (var line in sortedLines) {
    String lineId = line['gtfsId'];

    if (linesIds.contains(lineId)) {
      continue; // Skip if the line ID is already added
    }

    // Check if an icon is available for this line
    if (priorityMap[lineId] != null) {
      String darkMode = isNightMode(context) && priorityMap[lineId]['darkMode'] && darkModeParam ? '_dark' : '';

      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            priorityMap[lineId]['picto'].replaceFirst('.png', '${darkMode}.png'),
            width: 24,
            height: 24,
          ),
        ),
      );
    } else {
      // If no icon is available
      icons.add(
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: line['color'] != null ? HexColor(line['color']) : Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                line['shortName'],
                style: TextStyle(
                  color: line['textColor'] != null ? HexColor(line['textColor']) : Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  return Row(
    children: icons,
  );
}

Future<Widget> getLineLogo(Map<String, dynamic> lineData, BuildContext context) async {
  Map<String, dynamic>? route = lineData['route'];

  if (route == null) {
    return Container();
  }

  Map<String, dynamic> priorityMap = await loadPriorityData();
  String lineId = route['gtfsId'];

  if (priorityMap[lineId] != null) {
    // ignore: use_build_context_synchronously
    String darkMode = isNightMode(context) && priorityMap[lineId]['darkMode'] ? '_dark' : '';

    return Image.asset(
      priorityMap[lineId]['picto'].replaceFirst('.png', '$darkMode.png'),
      width: 30,
      height: 30,
    );
  } else {
    Widget iconPlus = Container();

    if (lineId.contains("fr-sncf-tgv")) {
      iconPlus = Image.asset(
        'assets/logo/fr-sncf-tgv/logo.png',
        height: 38,
        width: 48,
      );
    } else if (lineId.contains("fr-sncf-ter")) {
      iconPlus = Image.asset(
        'assets/logo/fr-sncf-ter/logo.png',
        height: 38,
        width: 36,
      );
    }

    return IntrinsicWidth(
      child: Row(
        children: [
          iconPlus,
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: HexColor(route['color'] ?? '#000000'),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                route['shortName'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: HexColor(route['textColor'] ?? '#FFFFFF'),
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

Map<String, dynamic> getLineLogoWithPerturbation(List<Map<String, dynamic>> alerts, String lineId, String lineLogo, bool? isDisabled, BuildContext context) {
  Map<String, dynamic> lineData = {};
  
  Color borderColor = Colors.lightGreen;
  Widget logoPerturbation = Container();
  bool hasWorks = false;
  String maxSeverity = "unknown";

  for (var line in alerts) {
    if (line["id"] == lineId) {
      lineData = line;

      for (var alert in line["situations"]) {
        final severity = alert["severity"];
        final validityPeriod = alert["validityPeriod"];
        final isValid = DateTime.now().isAfter(DateTime.parse(validityPeriod["startTime"]).toLocal()) &&
                        DateTime.now().isBefore(DateTime.parse(validityPeriod["endTime"]).toLocal());

        if (severity == "severe") {
          if (!isValid) continue;

          borderColor = Colors.red;

          maxSeverity = "severe";

          if (alert["description"][0]["value"].toLowerCase().contains("travaux")) {
            logoPerturbation = Image.asset(
              'assets/icons/trafic/works.png',
            );
          } else {
            logoPerturbation = Image.asset(
              'assets/icons/trafic/servicestopped.png',
            );
          }
          
          break;
        } else if (severity == "normal" && maxSeverity != "severe") {
          if (alert["description"][0]["value"].toLowerCase().contains("travaux")) {
            if (!isValid && !hasWorks) {
              logoPerturbation = Image.asset(
                'assets/icons/trafic/works_future.png',
              );
            } else if (alert["description"][0]["value"].toLowerCase().contains("interrompu") && isValid && !hasWorks) {
              hasWorks = true;
              maxSeverity = "severe";
              borderColor = Colors.red;
              logoPerturbation = Image.asset(
                'assets/icons/trafic/works.png',
              );
            } else if (isValid && !hasWorks) {
              hasWorks = true;
              maxSeverity = "normal";
              borderColor = Colors.orange;
              logoPerturbation = Image.asset(
                'assets/icons/trafic/works.png',
              );
            }
          } else {
            if (!isValid) continue;

            maxSeverity = "severe";

            borderColor = Colors.orange;
            logoPerturbation = Image.asset(
              'assets/icons/trafic/servicedisrupted.png',
            );
          }
        } else if (severity == "unknown" && maxSeverity != "normal" && maxSeverity != "severe") {
          if (!isValid) continue;

          maxSeverity = "unknown";

          logoPerturbation = Image.asset(
            'assets/icons/trafic/info.png',
          );
        }
      }
    }
  }

  if (alerts.isEmpty) {
    borderColor = Colors.grey;
  }

  if (isDisabled == true) {
    borderColor = Colors.grey;
  }

  return {
    'logo': Stack(
      fit: StackFit.passthrough,
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
            lineLogo
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.05, // Adjust size dynamically
            height: MediaQuery.of(context).size.width * 0.05,
            child: FittedBox(
              fit: BoxFit.contain,
              child: logoPerturbation,
            ),
          ),
        ),
      ],
    ),
    'lineData': lineData,
  };
}

Widget getLogoPerturbation(Map<String, dynamic> alert) {
  final severity = alert["severity"];
  final validityPeriod = alert["validityPeriod"];
  final isValid = DateTime.now().isAfter(DateTime.parse(validityPeriod["startTime"]).toLocal()) &&
                  DateTime.now().isBefore(DateTime.parse(validityPeriod["endTime"]).toLocal());

  if (severity == "severe") {
    if (alert["description"][0]["value"].toLowerCase().contains("travaux")) {
      if (!isValid) {
        return Image.asset(
          'assets/icons/trafic/works_future.png',
        );
      } else if (isValid) {
        return Image.asset(
          'assets/icons/trafic/works.png',
        );
      }
    } else {
      return Image.asset(
        'assets/icons/trafic/servicestopped.png',
      );
    }
  } else if (severity == "normal") {
    if (alert["description"][0]["value"].toLowerCase().contains("travaux")) {
      if (!isValid) {
        return Image.asset(
          'assets/icons/trafic/works_future.png',
        );
      } else if (alert["description"][0]["value"].toLowerCase().contains("interrompu") && isValid) {
        return Image.asset(
          'assets/icons/trafic/works.png',
        );
      } else if (isValid) {
        return Image.asset(
          'assets/icons/trafic/works.png',
        );
      }
    } else {
      return Image.asset(
        'assets/icons/trafic/servicedisrupted.png',
      );
    }
  } else if (severity == "unknown") {
    return Image.asset(
      'assets/icons/trafic/info.png',
    );
  }

  return Container(); // Default case if none of the conditions match
}