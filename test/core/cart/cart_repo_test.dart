import 'dart:math';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/cart.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/orders_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

void main() {
  final feePerDegree = 6371000 * pi / 180 / 1000 * 5;
  final bakeryNear = fakeBakery('b1', 2, 1);
  final bakeryFar = fakeBakery('b2', 3, 1);

  ProductModel product(String id, String bakeryId, double price) {
    return fakeProduct(
      id: id,
      bakeryId: bakeryId,
      overrides: {ProductsTableColumns.productPrice: price},
    );
  }

  late CartRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    await setupTestEnvironment();
  });

  setUp(() {
    repo = CartRepo(supabase: MockSupabaseClient());
  });

  group('addItemToCart', () {
    test('returns the same cart for a non-positive quantity', () {
      final cart = Cart();

      expect(
        repo.addItemToCart(
          currentCart: cart,
          bakery: bakeryNear,
          product: product('p1', 'b1', 10),
          selectedQuantity: 0,
        ),
        same(cart),
      );
      expect(
        repo.addItemToCart(
          currentCart: cart,
          bakery: bakeryNear,
          product: product('p1', 'b1', 10),
          selectedQuantity: -2,
        ),
        same(cart),
      );
    });

    test('asserts when the product has no id', () {
      final noId = ProductModel.fromJson({
        ProductsTableColumns.bakeryId: 'b1',
      });

      expect(
            () => repo.addItemToCart(
          currentCart: Cart(),
          bakery: bakeryNear,
          product: noId,
          selectedQuantity: 1,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('adds the bakery, product and quantity', () {
      final p1 = product('p1', 'b1', 10);

      final cart = repo.addItemToCart(
        currentCart: Cart(),
        bakery: bakeryNear,
        product: p1,
        selectedQuantity: 2,
      );

      expect(cart.bakeries, {'b1': bakeryNear});
      expect(cart.products, {'p1': p1});
      expect(cart.quantities, {'p1': 2});
    });

    test('accumulates the quantity of an existing product', () {
      final p1 = product('p1', 'b1', 10);
      var cart = repo.addItemToCart(
        currentCart: Cart(),
        bakery: bakeryNear,
        product: p1,
        selectedQuantity: 2,
      );

      cart = repo.addItemToCart(
        currentCart: cart,
        bakery: bakeryNear,
        product: p1,
        selectedQuantity: 3,
      );

      expect(cart.quantities, {'p1': 5});
      expect(cart.bakeries, hasLength(1));
    });

    test('keeps products from several bakeries', () {
      var cart = repo.addItemToCart(
        currentCart: Cart(),
        bakery: bakeryNear,
        product: product('p1', 'b1', 10),
        selectedQuantity: 1,
      );

      cart = repo.addItemToCart(
        currentCart: cart,
        bakery: bakeryFar,
        product: product('p2', 'b2', 20),
        selectedQuantity: 1,
      );

      expect(cart.bakeries.keys.toSet(), {'b1', 'b2'});
      expect(cart.products.keys.toSet(), {'p1', 'p2'});
    });
  });

  group('calculateOrderPrice', () {
    test('is zero for an empty cart', () {
      expect(repo.calculateOrderPrice(Cart()), 0.0);
    });

    test('sums price times quantity', () {
      final cart = Cart(
        products: {
          'p1': product('p1', 'b1', 10),
          'p2': product('p2', 'b2', 2.5),
        },
        quantities: {'p1': 3, 'p2': 4},
      );

      expect(repo.calculateOrderPrice(cart), 40.0);
    });

    test('treats a missing quantity as zero', () {
      final cart = Cart(
        products: {'p1': product('p1', 'b1', 10)},
        quantities: const {},
      );

      expect(repo.calculateOrderPrice(cart), 0.0);
    });
  });

  group('calculateDeliveryFee', () {
    test('is zero without bakeries', () {
      expect(repo.calculateDeliveryFee(Cart(), 1, 1), 0.0);
    });

    test('charges 5 per km for a single bakery', () {
      final cart = Cart(bakeries: {'b1': bakeryNear});

      expect(
        repo.calculateDeliveryFee(cart, 1, 1),
        closeTo(feePerDegree, 0.01),
      );
    });

    test('routes from the furthest bakery through the rest to the user', () {
      final cart = Cart(bakeries: {'b1': bakeryNear, 'b2': bakeryFar});

      expect(
        repo.calculateDeliveryFee(cart, 1, 1),
        closeTo(feePerDegree * 2, 0.01),
      );
    });

    test('does not depend on the insertion order', () {
      final first = Cart(bakeries: {'b1': bakeryNear, 'b2': bakeryFar});
      final second = Cart(bakeries: {'b2': bakeryFar, 'b1': bakeryNear});

      expect(
        repo.calculateDeliveryFee(first, 1, 1),
        closeTo(repo.calculateDeliveryFee(second, 1, 1), 0.01),
      );
    });
  });

  group('cartToOrder', () {
    test('copies products, quantities, prices, location and address', () {
      final p1 = product('p1', 'b1', 10);
      final p2 = product('p2', 'b2', 20);
      final cart = Cart(
        bakeries: {'b1': bakeryNear, 'b2': bakeryFar},
        products: {'p1': p1, 'p2': p2},
        quantities: {'p1': 2, 'p2': 3},
        orderPrice: 80,
        deliveryFee: 12,
        userLat: 1.5,
        userLng: 2.5,
        street: 'S',
        building: 'B',
        apartment: 'A',
      );

      final order = repo.cartToOrder(cart);

      expect(order.orderedProducts, [p1, p2]);
      expect(order.orderedQuantities, [2, 3]);
      expect(order.bakeries, [bakeryNear, bakeryFar]);
      expect(order.received, [false, false]);
      expect(order.orderPrice, 80);
      expect(order.deliveryFee, 12);
      expect(order.customerLat, 1.5);
      expect(order.customerLng, 2.5);
      expect(order.orderStatus, OrderStatuses.pending);
      expect(order.customerId, '');
      expect(order.street, 'S');
      expect(order.building, 'B');
      expect(order.apartment, 'A');
      expect(order.date, isNotNull);
    });
  });

  group('makeOrder', () {
    late MockSupabaseClient supabase;
    late MockGoTrueClient auth;
    late MockUser authUser;
    late MockSupabaseQueryBuilder usersQuery;
    late MockSupabaseQueryBuilder ordersQuery;

    final userJson = UserModel(
      id: 'user-1',
      firstName: 'Mo',
      secondName: 'Men',
      email: 'mo@test.com',
      phone: '123',
    ).toJson();
    final savedOrder = fakeOrder(bakeries: [bakeryNear]).copyWith(
      orderId: 'o1',
      customerId: 'user-1',
      customerName: 'Mo Men',
    );

    setUp(() {
      supabase = MockSupabaseClient();
      auth = MockGoTrueClient();
      authUser = MockUser();
      usersQuery = MockSupabaseQueryBuilder();
      ordersQuery = MockSupabaseQueryBuilder();

      when(() => supabase.auth).thenAnswer((_) => auth);
      when(() => auth.currentUser).thenAnswer((_) => authUser);
      when(() => authUser.id).thenAnswer((_) => 'user-1');
      when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
      when(() => supabase.from(Tables.orders)).thenAnswer((_) => ordersQuery);
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: userJson,
        ),
      );

      repo = CartRepo(supabase: supabase);
    });

    test('inserts the order with the customer id and name', () async {
      when(() => ordersQuery.insert(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(
          null,
          single: savedOrder.toJson(),
        ),
      );

      final result = await repo.makeOrder(fakeOrder());

      expect(result, isA<SuccessResponse<OrderModel>>());
      expect((result as SuccessResponse<OrderModel>).data.orderId, 'o1');
      final inserted =
      verify(() => ordersQuery.insert(captureAny())).captured.single
      as Map<String, dynamic>;
      expect(inserted[OrdersTableColumns.customerId], 'user-1');
      expect(inserted[OrdersTableColumns.customerName], 'Mo Men');
    });

    test('fails when nobody is signed in', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.makeOrder(fakeOrder());

      expect(result, isA<FailureResponse<OrderModel>>());
      verifyNever(() => ordersQuery.insert(any()));
    });

    test('fails when the insert throws', () async {
      when(() => ordersQuery.insert(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(
          PostgrestException(message: 'rejected'),
        ),
      );

      final result = await repo.makeOrder(fakeOrder());

      expect(result, isA<FailureResponse<OrderModel>>());
    });
  });
}