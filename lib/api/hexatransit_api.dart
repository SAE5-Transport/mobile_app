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