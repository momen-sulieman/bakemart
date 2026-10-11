import 'dart:async';
import 'dart:math';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';

class MockLocationCubit extends Mock implements LocationCubit {}

class FakeCartRepo extends CartRepo {
  FakeCartRepo() : super(supabase: MockSupabaseClient());

  final List<OrderModel> madeOrders = [];

  Future<ResponseResult<OrderModel>> Function(OrderModel order) onMakeOrder =
      (order) async => SuccessResponse<OrderModel>(order);

  @override
  Future<ResponseResult<OrderModel>> makeOrder(OrderModel orderFromCart) {
    madeOrders.add(orderFromCart);
    return onMakeOrder(orderFromCart);
  }
}

void main() {
  final feePerDegree = 6371000 * pi / 180 / 1000 * 5;
  final bakery1 = fakeBakery('b1', 2, 1);
  final bakery2 = fakeBakery('b2', 3, 1);

  late MockLocationCubit locationCubit;
  late StreamController<LocationState> locationStates;
  late LocationState currentLocation;
  late FakeCartRepo repo;

  ProductModel product(String id, String bakeryId, double price) {
    return fakeProduct(
      id: id,
      bakeryId: bakeryId,
      overrides: {ProductsTableColumns.productPrice: price},
    );
  }

  CartCubit build() {
    final cubit = CartCubit(repo, locationCubit);
    addTearDown(cubit.close);
    return cubit;
  }

  List<CartState> collect(CartCubit cubit) {
    final states = <CartState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  setUp(() {
    locationCubit = MockLocationCubit();
    locationStates = StreamController<LocationState>.broadcast();
    currentLocation = LocationUpdated(lat: 1, lng: 1);
    repo = FakeCartRepo();
    when(() => locationCubit.state).thenAnswer((_) => currentLocation);
    when(() => locationCubit.stream).thenAnswer((_) => locationStates.stream);
  });

  tearDown(() async {
    await locationStates.close();
  });

  group('creation', () {
    test('starts empty and picks up the current location', () {
      final cubit = build();

      expect(cubit.state, isA<CartInitial>());
      expect(cubit.cart.isEmpty, true);
      expect(cubit.cart.userLat, 1);
      expect(cubit.cart.userLng, 1);
      expect(cubit.hasValidUserLocation, true);
    });

    test('has no valid location before one is known', () {
      currentLocation = LocationInitial();

      final cubit = build();

      expect(cubit.hasValidUserLocation, false);
    });
  });

  group('addToCart', () {
    test('stores the product and recalculates the totals', () {
      final cubit = build();

      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 3,
      );

      expect(cubit.state, isA<CartUpdated>());
      expect(cubit.cart.quantities, {'p1': 3});
      expect(cubit.cart.bakeries.keys, ['b1']);
      expect(cubit.cart.orderPrice, 30);
      expect(cubit.cart.deliveryFee, closeTo(feePerDegree, 0.01));
      expect(cubit.cart.totalBill, closeTo(30 + feePerDegree, 0.01));
    });

    test('accumulates the quantity of the same product', () {
      final cubit = build();
      final p1 = product('p1', 'b1', 10);

      cubit.addToCart(bakery: bakery1, product: p1, quantity: 1);
      cubit.addToCart(bakery: bakery1, product: p1, quantity: 2);

      expect(cubit.cart.quantities, {'p1': 3});
      expect(cubit.cart.orderPrice, 30);
    });

    test('routes the delivery fee through every bakery', () {
      final cubit = build();

      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );
      cubit.addToCart(
        bakery: bakery2,
        product: product('p2', 'b2', 20),
        quantity: 2,
      );

      expect(cubit.cart.orderPrice, 50);
      expect(cubit.cart.deliveryFee, closeTo(feePerDegree * 2, 0.01));
    });
  });

  test('isInCart is true only for products with a quantity', () {
    final cubit = build();
    expect(cubit.isInCart('p1'), false);

    cubit.addToCart(
      bakery: bakery1,
      product: product('p1', 'b1', 10),
      quantity: 1,
    );

    expect(cubit.isInCart('p1'), true);
    expect(cubit.isInCart('p2'), false);
  });

  group('updateQuantity', () {
    test('changes the quantity and the price', () {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );

      cubit.updateQuantity(productId: 'p1', quantity: 4);

      expect(cubit.cart.quantities, {'p1': 4});
      expect(cubit.cart.orderPrice, 40);
      expect(cubit.state, isA<CartUpdated>());
    });

    test('removes the product when the quantity reaches zero', () {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );

      cubit.updateQuantity(productId: 'p1', quantity: 0);

      expect(cubit.cart.isEmpty, true);
      expect(cubit.state, isA<CartInitial>());
    });
  });

  group('removeFromCart', () {
    test('drops a bakery only when none of its products remain', () {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );
      cubit.addToCart(
        bakery: bakery1,
        product: product('p3', 'b1', 5),
        quantity: 1,
      );
      cubit.addToCart(
        bakery: bakery2,
        product: product('p2', 'b2', 20),
        quantity: 1,
      );

      cubit.removeFromCart(productId: 'p1');
      expect(cubit.cart.bakeries.keys.toSet(), {'b1', 'b2'});
      expect(cubit.cart.products.keys.toSet(), {'p3', 'p2'});

      cubit.removeFromCart(productId: 'p3');
      expect(cubit.cart.bakeries.keys.toSet(), {'b2'});
      expect(cubit.cart.orderPrice, 20);
      expect(cubit.state, isA<CartUpdated>());
    });

    test('resets the cart when the last product is removed', () {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );

      cubit.removeFromCart(productId: 'p1');

      expect(cubit.cart.isEmpty, true);
      expect(cubit.state, isA<CartInitial>());
    });
  });

  test('clearCart empties the cart and emits CartInitial', () async {
    final cubit = build();
    cubit.addToCart(
      bakery: bakery1,
      product: product('p1', 'b1', 10),
      quantity: 1,
    );
    final states = collect(cubit);

    cubit.clearCart();
    await pumpEventQueue();

    expect(cubit.cart.isEmpty, true);
    expect(states, [isA<CartInitial>()]);
  });

  group('setLocation', () {
    test('updates the cart silently while it is empty', () async {
      final cubit = build();
      final states = collect(cubit);

      cubit.setLocation(lat: 4, lng: 1);
      await pumpEventQueue();

      expect(cubit.cart.userLat, 4);
      expect(states, isEmpty);
    });

    test('recalculates and emits when the cart has items', () async {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );
      final states = collect(cubit);

      cubit.setLocation(lat: 4, lng: 1);
      await pumpEventQueue();

      expect(states, [isA<CartUpdated>()]);
      expect(cubit.cart.deliveryFee, closeTo(feePerDegree * 2, 0.01));
    });
  });

  group('location stream', () {
    test('recalculates the fee and emits when the cart has items', () async {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 1,
      );
      final states = collect(cubit);

      locationStates.add(LocationUpdated(lat: 4, lng: 1));
      await pumpEventQueue();

      expect(cubit.cart.userLat, 4);
      expect(cubit.cart.deliveryFee, closeTo(feePerDegree * 2, 0.01));
      expect(states, [isA<CartUpdated>()]);
    });

    test('updates the cart without emitting while it is empty', () async {
      final cubit = build();
      final states = collect(cubit);

      locationStates.add(LocationUpdated(lat: 4, lng: 1));
      await pumpEventQueue();

      expect(cubit.cart.userLat, 4);
      expect(states, isEmpty);
    });

    test('ignores non-update location states', () async {
      final cubit = build();

      locationStates.add(LocationFailure('gps off'));
      await pumpEventQueue();

      expect(cubit.cart.userLat, 1);
    });
  });

  group('address', () {
    test('initAddress fills the cart and the controllers', () {
      final cubit = build();

      cubit.initAddress(street: 'S', building: 'B', apartment: 'A');

      expect(cubit.cart.street, 'S');
      expect(cubit.cart.building, 'B');
      expect(cubit.cart.apartment, 'A');
      expect(cubit.streetController.text, 'S');
      expect(cubit.buildingController.text, 'B');
      expect(cubit.apartmentController.text, 'A');
    });

    test('initAddress empties the controllers for null values', () {
      final cubit = build();
      cubit.streetController.text = 'old';

      cubit.initAddress();

      expect(cubit.streetController.text, '');
    });

    test('setAddress copies the controllers into the cart', () {
      final cubit = build();
      cubit.streetController.text = 'Main';
      cubit.buildingController.text = '12';
      cubit.apartmentController.text = '3';

      cubit.setAddress();

      expect(cubit.cart.street, 'Main');
      expect(cubit.cart.building, '12');
      expect(cubit.cart.apartment, '3');
    });
  });

  group('map', () {
    test('setMapOpen toggles and saves the address on close', () {
      final cubit = build();
      cubit.streetController.text = 'Main';

      cubit.setMapOpen();
      expect(cubit.mapOpen, true);

      cubit.setMapOpen();
      expect(cubit.mapOpen, false);
      expect(cubit.cart.street, 'Main');
    });

    test('opening the map takes the latest known location', () {
      final cubit = build();
      currentLocation = LocationUpdated(lat: 5, lng: 6);

      cubit.setMapOpen();

      expect(cubit.cart.userLat, 5);
      expect(cubit.cart.userLng, 6);
    });

    test('closeMap closes it', () {
      final cubit = build();
      cubit.setMapOpen();

      cubit.closeMap();

      expect(cubit.mapOpen, false);
    });
  });

  group('placeOrder', () {
    CartCubit cubitWithItem() {
      final cubit = build();
      cubit.addToCart(
        bakery: bakery1,
        product: product('p1', 'b1', 10),
        quantity: 2,
      );
      return cubit;
    }

    test('places the order and clears the cart', () async {
      final cubit = cubitWithItem();
      final states = collect(cubit);

      cubit.placeOrder();
      await pumpEventQueue();

      expect(states, [
        isA<PlacingOrder>(),
        isA<OrderPlaced>(),
        isA<CartInitial>(),
      ]);
      expect(repo.madeOrders, hasLength(1));
      final order = repo.madeOrders.single;
      expect(order.orderedQuantities, [2]);
      expect(order.orderPrice, 20);
      expect(order.orderStatus, OrderStatuses.pending);
      expect(cubit.cart.isEmpty, true);
    });

    test('sends the address typed in the controllers', () async {
      final cubit = cubitWithItem();
      cubit.streetController.text = 'Main';
      cubit.buildingController.text = '12';
      cubit.apartmentController.text = '3';

      cubit.placeOrder();
      await pumpEventQueue();

      final order = repo.madeOrders.single;
      expect(order.street, 'Main');
      expect(order.building, '12');
      expect(order.apartment, '3');
    });

    test('keeps the cart and reports the error when the order fails', () async {
      repo.onMakeOrder = (_) async => FailureResponse<OrderModel>('boom');
      final cubit = cubitWithItem();
      final states = collect(cubit);

      cubit.placeOrder();
      await pumpEventQueue();

      expect(states, [
        isA<PlacingOrder>(),
        isA<OrderFailed>(),
        isA<CartUpdated>(),
      ]);
      expect((states[1] as OrderFailed).error, 'boom');
      expect(cubit.cart.isEmpty, false);
    });

    test('reports a location error when no location is known', () async {
      currentLocation = LocationInitial();
      final cubit = cubitWithItem();
      final states = collect(cubit);

      cubit.placeOrder();
      await pumpEventQueue();

      expect(states, [isA<LocationError>(), isA<CartUpdated>()]);
      expect(repo.madeOrders, isEmpty);
    });

    test('recovers the location from the location cubit', () async {
      currentLocation = LocationInitial();
      final cubit = cubitWithItem();
      currentLocation = LocationUpdated(lat: 1, lng: 1);

      cubit.placeOrder();
      await pumpEventQueue();

      expect(repo.madeOrders, hasLength(1));
      expect(repo.madeOrders.single.customerLat, 1);
      expect(repo.madeOrders.single.customerLng, 1);
    });

    test('ignores a second call while an order is being placed', () async {
      final completer = Completer<ResponseResult<OrderModel>>();
      repo.onMakeOrder = (_) => completer.future;
      final cubit = cubitWithItem();

      cubit.placeOrder();
      await pumpEventQueue();
      cubit.placeOrder();
      await pumpEventQueue();

      expect(repo.madeOrders, hasLength(1));
      completer.complete(SuccessResponse<OrderModel>(fakeOrder()));
      await pumpEventQueue();
      expect(cubit.state, isA<CartInitial>());
    });
  });
}