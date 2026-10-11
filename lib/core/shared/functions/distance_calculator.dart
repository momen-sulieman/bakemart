import 'dart:math';

import '../models/bakery_model.dart';
import '../models/order_model.dart';

double distanceBetweenUserAndBakery(
    double lat1, double lon1,
    double lat2, double lon2,
    ) {
  const double earthRadius = 6371000;
  final double dLat = toRadians(lat2 - lat1);
  final double dLon = toRadians(lon2 - lon1);

  final double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(toRadians(lat1)) *
          cos(toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double toRadians(double degrees) => degrees * (pi / 180);
double calculateTotalDeliveryDistance(OrderModel order) {
  if (order.bakeries.isEmpty) return 0.0;

  return order.bakeries.fold(0.0, (total, bakery) {
    return total + distanceBetweenUserAndBakery(
      bakery.bakeryLat,
      bakery.bakeryLng,
      order.customerLat,
      order.customerLng,
    );
  });
}
/// Calculates the total optimized sequential route distance (in meters) starting
/// from the delivery man's location, hitting the closest unvisited bakeries
/// one-by-one, and ending at the customer's location.
double calculateOptimizedDeliveryRouteDistance({
  required OrderModel order,
  required double deliveryManLat,
  required double deliveryManLng,
}) {
  if (order.bakeries.isEmpty) return 0.0;

  double totalDistance = 0.0;

  // Track current coordinates as we move along the route
  double currentLat = deliveryManLat;
  double currentLng = deliveryManLng;

  // Maintain a shallow copy list of unvisited bakeries to manipulate
  final List<BakeryModel> unvisitedBakeries = List.from(order.bakeries);

  // 1. Traverse through all bakeries sequentially using the Nearest Neighbor approach
  while (unvisitedBakeries.isNotEmpty) {
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < unvisitedBakeries.length; i++) {
      final bakery = unvisitedBakeries[i];
      final dist = distanceBetweenUserAndBakery(
        currentLat,
        currentLng,
        bakery.bakeryLat,
        bakery.bakeryLng,
      );

      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    // Add the distance to the closest found bakery
    totalDistance += minDistance;

    // Move our current position to this bakery and remove it from our unvisited checklist
    final visitedBakery = unvisitedBakeries.removeAt(closestIndex);
    currentLat = visitedBakery.bakeryLat;
    currentLng = visitedBakery.bakeryLng;
  }

  // 2. Add the final leg: from the last bakery to the ordering user
  totalDistance += distanceBetweenUserAndBakery(
    currentLat,
    currentLng,
    order.customerLat,
    order.customerLng,
  );

  return totalDistance;
}

/// Returns the chronologically sorted coordinates of the optimized delivery route.
/// Useful for drawing polyline paths on a map view.
List<Map<String, double>> getOptimizedRouteWaypoints({
  required OrderModel order,
  required double deliveryManLat,
  required double deliveryManLng,
}) {
  final List<Map<String, double>> routePoints = [];

  // Start with delivery man position
  routePoints.add({'lat': deliveryManLat, 'lng': deliveryManLng});
  if (order.bakeries.isEmpty) {
    routePoints.add({'lat': order.customerLat, 'lng': order.customerLng});
    return routePoints;
  }

  double currentLat = deliveryManLat;
  double currentLng = deliveryManLng;
  final List<BakeryModel> unvisited = List.from(order.bakeries);

  while (unvisited.isNotEmpty) {
    int closestIndex = 0;
    double minDistance = double.infinity;

    for (int i = 0; i < unvisited.length; i++) {
      final dist = distanceBetweenUserAndBakery(
        currentLat, currentLng,
        unvisited[i].bakeryLat, unvisited[i].bakeryLng,
      );
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    final nextBakery = unvisited.removeAt(closestIndex);
    currentLat = nextBakery.bakeryLat;
    currentLng = nextBakery.bakeryLng;

    routePoints.add({'lat': currentLat, 'lng': currentLng});
  }

  // Final destination: Customer
  routePoints.add({'lat': order.customerLat, 'lng': order.customerLng});
  return routePoints;
}