import 'package:bakemart/core/services/location_services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  final services = LocationServices();

  test('formatFromPositionToWKT writes longitude before latitude', () {
    expect(
      services.formatFromPositionToWKT(fakePosition(30.5, 31.5)),
      'POINT(31.5 30.5)',
    );
  });

  test('formatFromWKTToPosition parses a point', () {
    final position = services.formatFromWKTToPosition('POINT(31.5 30.5)');

    expect(position.longitude, 31.5);
    expect(position.latitude, 30.5);
  });

  test('formatFromWKTToPosition falls back to zero on invalid input', () {
    final position = services.formatFromWKTToPosition('garbage');

    expect(position.longitude, 0.0);
    expect(position.latitude, 0.0);
  });

  test('LocationServiceException prints its message', () {
    final error = LocationServiceException(
      'Location request timed out.',
      LocationFailureReason.timedOut,
    );

    expect(error.toString(), 'Location request timed out.');
    expect(error.reason, LocationFailureReason.timedOut);
  });
}