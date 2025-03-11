import 'package:google_maps_flutter/google_maps_flutter.dart';

double convertSecondsToMinutes(double seconds) {
  return seconds / 60;
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;

    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    poly.add(p);
  }

  return poly;
}

LatLngBounds calculateBounds(List<LatLng> points) {
  double minLat = points.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
  double maxLat = points.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
  double minLng = points.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
  double maxLng = points.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

  return LatLngBounds(
    southwest: LatLng(minLat, minLng),
    northeast: LatLng(maxLat, maxLng),
  );
}