import 'package:bakemart/core/shared/functions/distance_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  const metersPerDegree = 111194.9;

  group('distanceBetweenUserAndBakery', () {
    test('is zero for identical points', () {
      expect(distanceBetweenUserAndBakery(30, 31, 30, 31), 0);
    });

    test('measures one degree of latitude', () {
      expect(
        distanceBetweenUserAndBakery(0, 0, 1, 0),
        closeTo(metersPerDegree, 100),
      );
    });

    test('is symmetric', () {
      final forward = distanceBetweenUserAndBakery(30, 31, 30.5, 31.5);
      final backward = distanceBetweenUserAndBakery(30.5, 31.5, 30, 31);

      expect(forward, closeTo(backward, 0.001));
    });
  });

  test('toRadians converts degrees', () {
    expect(toRadians(180), closeTo(3.14159265, 1e-6));
    expect(toRadians(0), 0);
  });

  group('calculateTotalDeliveryDistance', () {
    test('is zero without bakeries', () {
      expect(calculateTotalDeliveryDistance(fakeOrder()), 0.0);
    });

    test('sums the distance from each bakery to the customer', () {
      final order = fakeOrder(
        bakeries: [fakeBakery('b1', 0, 1), fakeBakery('b2', 0, 2)],
        customerLat: 0,
        customerLng: 0,
      );

      expect(
        calculateTotalDeliveryDistance(order),
        closeTo(metersPerDegree * 3, 300),
      );
    });
  });

  group('calculateOptimizedDeliveryRouteDistance', () {
    test('is zero without bakeries', () {
      expect(
        calculateOptimizedDeliveryRouteDistance(
          order: fakeOrder(),
          deliveryManLat: 0,
          deliveryManLng: 0,
        ),
        0.0,
      );
    });

    test('follows the nearest bakery first regardless of list order', () {
      final order = fakeOrder(
        bakeries: [fakeBakery('far', 0, 2), fakeBakery('near', 0, 1)],
        customerLat: 0,
        customerLng: 3,
      );

      final distance = calculateOptimizedDeliveryRouteDistance(
        order: order,
        deliveryManLat: 0,
        deliveryManLng: 0,
      );

      expect(distance, closeTo(metersPerDegree * 3, 300));
    });
  });

  group('getOptimizedRouteWaypoints', () {
    test('goes straight to the customer without bakeries', () {
      final points = getOptimizedRouteWaypoints(
        order: fakeOrder(customerLat: 5, customerLng: 6),
        deliveryManLat: 1,
        deliveryManLng: 2,
      );

      expect(points, [
        {'lat': 1.0, 'lng': 2.0},
        {'lat': 5.0, 'lng': 6.0},
      ]);
    });

    test('orders bakeries by nearest neighbour', () {
      final order = fakeOrder(
        bakeries: [fakeBakery('far', 0, 2), fakeBakery('near', 0, 1)],
        customerLat: 0,
        customerLng: 3,
      );

      final points = getOptimizedRouteWaypoints(
        order: order,
        deliveryManLat: 0,
        deliveryManLng: 0,
      );

      expect(points, [
        {'lat': 0.0, 'lng': 0.0},
        {'lat': 0.0, 'lng': 1.0},
        {'lat': 0.0, 'lng': 2.0},
        {'lat': 0.0, 'lng': 3.0},
      ]);
    });
  });
}