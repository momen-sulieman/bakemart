import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../network/response_result.dart';
import '../../../../utils/enums/order_statuses.dart';
import '../../../../utils/enums/tables.dart';
import '../../../functions/distance_calculator.dart';
import '../../../models/bakery_model.dart';
import '../../../models/cart.dart';
import '../../../models/order_model.dart';
import '../../../models/product_model.dart';

class CartRepo {
  final SupabaseClient _supabase;

  CartRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  Cart addItemToCart({
    required Cart currentCart,
    required BakeryModel bakery,
    required ProductModel product,
    required int selectedQuantity,
  }) {
    if (selectedQuantity <= 0) return currentCart;

    final String? productId = product.productId;
    final String bakeryId = bakery.bakeryId;

    if (productId == null) {
      assert(false, 'productId and bakeryId must not be null');
      return currentCart;
    }

    return currentCart.copyWith(
      bakeries: {...currentCart.bakeries, bakeryId: bakery},
      products: {...currentCart.products, productId: product},
      quantities: {
        ...currentCart.quantities,
        productId: (currentCart.quantities[productId] ?? 0) + selectedQuantity,
      },
    );
  }

  // each bakery counted once regardless of how many products it has
// each bakery counted once regardless of how many products it has
  double calculateDeliveryFee(Cart cart, double userLat, double userLng) {
    if (cart.bakeries.isEmpty) return 0.0;

    // 1. Convert map values to a modifiable list
    final List<BakeryModel> unvisitedBakeries = List.from(cart.bakeries.values);

    // 2. Find the absolute furthest bakery from the user to use as the starting point
    int furthestIndex = 0;
    double maxDistanceToUser = -1.0;

    for (int i = 0; i < unvisitedBakeries.length; i++) {
      final double dist = distanceBetweenUserAndBakery(
        unvisitedBakeries[i].bakeryLat,
        unvisitedBakeries[i].bakeryLng,
        userLat,
        userLng,
      );
      if (dist > maxDistanceToUser) {
        maxDistanceToUser = dist;
        furthestIndex = i;
      }
    }

    // Pick our starting bakery and remove it from the unvisited group
    final BakeryModel startingBakery = unvisitedBakeries.removeAt(
      furthestIndex,
    );

    double totalDistanceMeters = 0.0;
    double currentLat = startingBakery.bakeryLat;
    double currentLng = startingBakery.bakeryLng;

    // 3. Nearest Neighbor routing through the remaining bakeries
    while (unvisitedBakeries.isNotEmpty) {
      int closestIndex = 0;
      double minDistance = double.infinity;

      for (int i = 0; i < unvisitedBakeries.length; i++) {
        final double dist = distanceBetweenUserAndBakery(
          currentLat,
          currentLng,
          unvisitedBakeries[i].bakeryLat,
          unvisitedBakeries[i].bakeryLng,
        );
        if (dist < minDistance) {
          minDistance = dist;
          closestIndex = i;
        }
      }

      // Add distance to the next closest bakery node
      totalDistanceMeters += minDistance;

      // Advance our pointer coordinates
      final BakeryModel nextBakery = unvisitedBakeries.removeAt(closestIndex);
      currentLat = nextBakery.bakeryLat;
      currentLng = nextBakery.bakeryLng;
    }

    // 4. Final leg: from the last bakery visited to the user's house
    totalDistanceMeters += distanceBetweenUserAndBakery(
      currentLat,
      currentLng,
      userLat,
      userLng,
    );

    // 5. Apply formula: Base fee (10) + 0.005 per meter
    double rawFee = 10.0 + (totalDistanceMeters * 0.005);

    // 6. Truncate (floor) to whole number and convert back to double ending in .0
    return rawFee.roundToDouble();
  }

  double calculateOrderPrice(Cart cart) {
    return cart.products.entries.fold(0.0, (sum, entry) {
      final qty = cart.quantities[entry.key] ?? 0;
      return sum + (entry.value.productPrice * qty);
    });
  }

  OrderModel cartToOrder(Cart cart) {
    final List<ProductModel> orderedProducts = cart.products.values.toList();
    final List<int> orderedQuantities = cart.products.keys
        .map((id) => cart.quantities[id] ?? 0)
        .toList();

    return OrderModel(
      received: List<bool>.filled(cart.bakeries.length, false),
      date: DateTime.now(),
      customerName: '',
      customerId: '',
      bakeries: cart.bakeries.values.toList(),
      customerLat: cart.userLat,
      customerLng: cart.userLng,
      orderedProducts: orderedProducts,
      orderedQuantities: orderedQuantities,
      orderPrice: cart.orderPrice,
      deliveryFee: cart.deliveryFee,
      orderStatus: OrderStatuses.pending,
      street: cart.street,
      building: cart.building,
      apartment: cart.apartment,
    );
  }

  Future<ResponseResult<OrderModel>> makeOrder(OrderModel orderFromCart) async {
    try {
      final String? id = _supabase.auth.currentUser?.id;
      final userDataResponse = await _supabase
          .from(Tables.users)
          .select()
          .eq(UsersTableColumns.id, id!)
          .single();
      final userData = UserModel.fromJson(userDataResponse);
      final orderWithOutOrderId = orderFromCart.copyWith(
        customerId: id,
        customerName: "${userData.firstName} ${userData.secondName}",
      );
      final orderWithOrderId = await _supabase
          .from(Tables.orders)
          .insert(orderWithOutOrderId.toJson())
          .select()
          .single();
      final orderModel = OrderModel.fromJson(orderWithOrderId);
      return SuccessResponse(orderModel);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
