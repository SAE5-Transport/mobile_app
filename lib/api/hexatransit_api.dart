import 'dart:convert';

import 'package:http/http.dart' as http;

String host = '20-199-76-32.nip.io:8080';

Future<List<Map<String, dynamic>>> getLocations(String search) async {
  if (search.isEmpty) {
    return [];
  }

  var url = Uri.http(host, '/v1/search/findLocation', {'name': search});
  var response = await http.get(url).timeout(const Duration(seconds: 30));

  if (response.statusCode == 200) {
    List<Map<String, dynamic>> locations = [];

    // Get OTP records
    List<dynamic> records = jsonDecode(response.body)['otp'];
    locations.addAll(List<Map<String, dynamic>>.from(records));

    // Get real locations records
    List<dynamic> realLocations = jsonDecode(response.body)['osm'];
    locations.addAll(List<Map<String, dynamic>>.from(realLocations));

    return locations;
  } else {
    return [];
  }
}

Future<Map<String, dynamic>> getLocationByCoordinates(double lat, double lon) async {
  var url = Uri.http(host, '/v1/search/findLocationByCoordinates', {'lat': lat.toString(), 'lon': lon.toString()});
  var response = await http.get(url).timeout(const Duration(seconds: 30));

  if (response.statusCode == 200) {
    return jsonDecode(response.body)['osm'][0];
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> searchPaths(double departure_lat, double departure_lon, double arrival_lat, double arrival_lon, DateTime date, bool isArrival) async {
  var queryParams = {
    'departure_lat': departure_lat.toString(),
    'departure_lon': departure_lon.toString(),
    'arrival_lat': arrival_lat.toString(),
    'arrival_lon': arrival_lon.toString(),
    'start': date.toIso8601String().replaceFirst('Z', ''),
  };

  if (isArrival) {
    queryParams['arrival'] = isArrival.toString();
  }

  var url = Uri.http(host, '/v1/search/searchPaths', queryParams);
  print(url.toString());
  var response = await http.get(url).timeout(const Duration(seconds: 30));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return {};
  }
}

Future<List<Map<String, dynamic>>> getIncidentsOnLines(List<String> lines) async {
  try {
    var url = Uri.http(host, '/v1/search/incidentsOnLines', {'lineIds': lines});
    var response = await http.get(url).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)["lines"]);
    } else {
      return [];
    }
  } catch (e) {
    print('Error fetching incidents on lines: $e');
    return [];
  }
}