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

    if (productId == null) {
      assert(false, 'productId must not be null');
      return currentCart;
    }

    final String key = Cart.itemKey(productId, product.branchId);

    return currentCart.copyWith(
      bakeries: {...currentCart.bakeries, product.branchId: bakery},
      products: {...currentCart.products, key: product},
      quantities: {
        ...currentCart.quantities,
        key: (currentCart.quantities[key] ?? 0) + selectedQuantity,
      },
    );
  }

  double calculateDeliveryFee(Cart cart, double userLat, double userLng) {
    if (cart.bakeries.isEmpty) return 0.0;

    final List<BakeryModel> unvisitedBakeries = List.from(cart.bakeries.values);

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

    final BakeryModel startingBakery = unvisitedBakeries.removeAt(
      furthestIndex,
    );

    double totalDistanceMeters = 0.0;
    double currentLat = startingBakery.bakeryLat;
    double currentLng = startingBakery.bakeryLng;

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

      totalDistanceMeters += minDistance;

      final BakeryModel nextBakery = unvisitedBakeries.removeAt(closestIndex);
      currentLat = nextBakery.bakeryLat;
      currentLng = nextBakery.bakeryLng;
    }

    totalDistanceMeters += distanceBetweenUserAndBakery(
      currentLat,
      currentLng,
      userLat,
      userLng,
    );

    double rawFee = 10.0 + (totalDistanceMeters * 0.005);

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
        .map((key) => cart.quantities[key] ?? 0)
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