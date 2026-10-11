import 'dart:async';

import 'package:geolocator/geolocator.dart';

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  timedOut,
  unknown,
}

class LocationServiceException implements Exception {
  final String message;
  final LocationFailureReason reason;

  LocationServiceException(this.message, this.reason);

  @override
  String toString() => message;
}

class LocationServices {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled.',
        LocationFailureReason.serviceDisabled,
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permissions are denied.',
          LocationFailureReason.permissionDenied,
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied.',
        LocationFailureReason.permissionDeniedForever,
      );
    }

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw LocationServiceException(
        'Location request timed out.',
        LocationFailureReason.timedOut,
      );
    }
  }

  /// Converts Position to PostGIS Well-Known Text (WKT) format: "POINT(long lat)"
  String formatFromPositionToWKT(Position position) {
    return 'POINT(${position.longitude} ${position.latitude})';
  }

  Position formatFromWKTToPosition(String wkt) {
    try {
      final coords = wkt
          .replaceAll('POINT(', '')
          .replaceAll(')', '')
          .trim()
          .split(' ');

      if (coords.length != 2) throw const FormatException("Invalid Format");

      return Position(
        longitude: double.parse(coords[0]),
        latitude: double.parse(coords[1]),
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    } catch (e) {
      return Position(
        longitude: 0.0,
        latitude: 0.0,
        timestamp: DateTime.now(),
        accuracy: 0.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        headingAccuracy: 0.0,
      );
    }
  }
}