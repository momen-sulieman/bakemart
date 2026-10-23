import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/location_cubit/location_cubit.dart';
import '../../../../cubits/location_cubit/location_state.dart';
import '../../../../models/bakery_model.dart';
import '../../../../models/cart.dart';
import '../../../../models/product_model.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRepo _repo;
  final LocationCubit _locationCubit;
  late final StreamSubscription _locationSubscription;

  CartCubit(this._repo, this._locationCubit) : super(CartInitial()) {
    final currentLocationState = _locationCubit.state;
    if (currentLocationState is LocationUpdated) {
      cart = cart.copyWith(
        userLat: currentLocationState.lat,
        userLng: currentLocationState.lng,
      );
      _recalculate();
    }
    _locationSubscription = _locationCubit.stream.listen((locationState) {
      if (locationState is LocationUpdated) {
        cart = cart.copyWith(
          userLat: locationState.lat,
          userLng: locationState.lng,
        );
        _recalculate();
        if (state is CartUpdated) {
          emit(CartUpdated(cart));
        }
      }
    });
  }

  Cart cart = Cart();
  bool mapOpen = false;
  final TextEditingController streetController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();

  void setLocation({required double lat, required double lng}) {
    cart = cart.copyWith(userLat: lat, userLng: lng);
    _recalculate();
    if (state is CartUpdated) {
      emit(CartUpdated(cart));
    }
  }

  void closeMap() {
    mapOpen = false;
    _rebuildUI();
  }

  void setMapOpen() {
    if (mapOpen) {
      setAddress();
    } else {
      final currentLocationState = _locationCubit.state;
      if (currentLocationState is LocationUpdated) {
        cart = cart.copyWith(
          userLat: currentLocationState.lat,
          userLng: currentLocationState.lng,
        );
        _recalculate();
      }
    }
    mapOpen = !mapOpen;
    _rebuildUI();
  }

  void initAddress({String? street, String? building, String? apartment}) {
    cart = cart.copyWith(
      street: street,
      building: building,
      apartment: apartment,
    );
    streetController.text = street ?? "";
    buildingController.text = building ?? "";
    apartmentController.text = apartment ?? "";
    _rebuildUI();
  }

  void setAddress() {
    cart = cart.copyWith(
      street: streetController.text,
      building: buildingController.text,
      apartment: apartmentController.text,
    );
  }

  void updateQuantity({
    required String productId,
    required String branchId,
    required int quantity,
  }) {
    if (quantity <= 0) {
      removeFromCart(productId: productId, branchId: branchId);
      return;
    }
    final key = Cart.itemKey(productId, branchId);
    cart = cart.copyWith(quantities: {...cart.quantities, key: quantity});
    _recalculate();
    emit(CartUpdated(cart));
  }

  void removeFromCart({required String productId, required String branchId}) {
    final key = Cart.itemKey(productId, branchId);
    final updatedProducts = Map<String, ProductModel>.from(cart.products)
      ..remove(key);
    final updatedQuantities = Map<String, int>.from(cart.quantities)
      ..remove(key);

    final updatedBakeries = Map<String, BakeryModel>.from(cart.bakeries);
    final remainingBranchIds = updatedProducts.values
        .map((p) => p.branchId)
        .toSet();
    updatedBakeries.removeWhere((id, _) => !remainingBranchIds.contains(id));
    if (updatedBakeries.isEmpty) {
      cart = Cart();
      emit(CartInitial());
      return;
    }
    cart = cart.copyWith(
      products: updatedProducts,
      quantities: updatedQuantities,
      bakeries: updatedBakeries,
    );
    _recalculate();
    emit(CartUpdated(cart));
  }

  void addToCart({
    required BakeryModel bakery,
    required ProductModel product,
    required int quantity,
  }) {
    cart = _repo.addItemToCart(
      currentCart: cart,
      bakery: bakery,
      product: product,
      selectedQuantity: quantity,
    );
    _recalculate();
    emit(CartUpdated(cart));
  }

  bool get hasValidUserLocation => cart.userLat != 0 && cart.userLng != 0;

  void placeOrder() async {
    if (state is PlacingOrder) return;
    if (!hasValidUserLocation) {
      final currentLocationState = _locationCubit.state;
      if (currentLocationState is LocationUpdated) {
        cart = cart.copyWith(
          userLat: currentLocationState.lat,
          userLng: currentLocationState.lng,
        );
        _recalculate();
      }
    }
    if (!hasValidUserLocation) {
      emit(LocationError("Location error"));
      emit(CartUpdated(cart));
      return;
    }
    emit(PlacingOrder());
    setAddress();
    final cartOrderModel = _repo.cartToOrder(cart);
    final issuedOrder = await _repo.makeOrder(cartOrderModel);
    if (issuedOrder is SuccessResponse<OrderModel>) {
      emit(OrderPlaced());
      clearCart();
    } else {
      emit(OrderFailed((issuedOrder as FailureResponse).error));
      emit(CartUpdated(cart));
    }
  }

  String cartKey(String productId, String branchId) =>
      Cart.itemKey(productId, branchId);

  bool isInCart(String productId, String branchId) {
    final current = state;
    if (current is CartUpdated) {
      return (current.cart.quantities[Cart.itemKey(productId, branchId)] ?? 0) >
          0;
    }
    return false;
  }

  void clearCart() {
    cart = Cart();
    emit(CartInitial());
  }

  void _rebuildUI() {
    if (state is CartInitial) {
      emit(CartInitial());
    }
    if (state is LocationError) {
      emit(LocationError("Location error"));
    }
    if (state is CartUpdated) {
      emit(CartUpdated(cart));
    }
    if (state is OrderFailed) {
      emit(OrderFailed("Order failed"));
    }
    if (state is PlacingOrder) {
      emit(PlacingOrder());
    }
    if (state is OrderPlaced) {
      emit(OrderPlaced());
    }
  }

  void _recalculate() {
    final orderPrice = _repo.calculateOrderPrice(cart);
    final deliveryFee = _repo.calculateDeliveryFee(
      cart,
      cart.userLat,
      cart.userLng,
    );
    cart = cart.copyWith(
      orderPrice: orderPrice,
      deliveryFee: deliveryFee,
      totalBill: orderPrice + deliveryFee,
    );
  }

  @override
  Future<void> close() {
    _locationSubscription.cancel();
    return super.close();
  }
}
