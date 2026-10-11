import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/core/utils/enums/orders_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fake_stream_builder.dart';
import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late MockUser authUser;
  late MockSupabaseQueryBuilder usersQuery;
  late MockSupabaseQueryBuilder ordersQuery;
  late DeliveryRepo repo;

  final userJson = UserModel(
    id: 'driver-1',
    firstName: 'Mo',
    secondName: 'Men',
    email: 'mo@test.com',
    phone: '123',
  ).toJson();

  Map<String, dynamic> orderJson(
      String id,
      List<BakeryModel> bakeries, {
        String status = OrderStatuses.pending,
      }) {
    return fakeOrder(
      bakeries: bakeries,
    ).copyWith(orderId: id, orderStatus: status).toJson();
  }

  void stubUser() {
    when(() => usersQuery.select()).thenAnswer(
          (_) => FakePostgrestBuilder<PostgrestList>.value(
        const <Map<String, dynamic>>[],
        single: userJson,
      ),
    );
  }

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(<String>[]);
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    authUser = MockUser();
    usersQuery = MockSupabaseQueryBuilder();
    ordersQuery = MockSupabaseQueryBuilder();

    when(() => supabase.auth).thenAnswer((_) => auth);
    when(() => auth.currentUser).thenAnswer((_) => authUser);
    when(() => authUser.id).thenAnswer((_) => 'driver-1');
    when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
    when(() => supabase.from(Tables.orders)).thenAnswer((_) => ordersQuery);

    repo = DeliveryRepo(supabase: supabase);
  });

  group('fetchAcceptedOrders', () {
    test('fails when nobody is signed in', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.fetchAcceptedOrders();

      expect(result, isA<FailureResponse<List<OrderModel>>>());
      expect(
        (result as FailureResponse<List<OrderModel>>).error,
        'ID error',
      );
    });

    test('returns the parsed orders', () async {
      when(() => ordersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value([
          orderJson('o1', const [], status: OrderStatuses.accepted),
          orderJson('o2', const [], status: OrderStatuses.accepted),
        ]),
      );

      final result = await repo.fetchAcceptedOrders();

      final orders = (result as SuccessResponse<List<OrderModel>>).data;
      expect(orders.map((o) => o.orderId), ['o1', 'o2']);
    });

    test('returns a failure when the query throws', () async {
      when(() => ordersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.error(Exception('offline')),
      );

      final result = await repo.fetchAcceptedOrders();

      expect(result, isA<FailureResponse<List<OrderModel>>>());
    });
  });

  group('getUserData', () {
    test('fails when nobody is signed in', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.getUserData();

      expect(
        (result as FailureResponse<UserModel>).error,
        'User is not authenticated',
      );
    });

    test('returns the parsed user', () async {
      stubUser();

      final result = await repo.getUserData();

      expect((result as SuccessResponse<UserModel>).data.id, 'driver-1');
    });
  });

  group('acceptOrder', () {
    test('assigns the driver and marks the order accepted', () async {
      stubUser();
      when(() => ordersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.acceptOrder('o1');

      expect(result, isA<SuccessResponse<void>>());
      final sent = Map<String, dynamic>.from(
        verify(() => ordersQuery.update(captureAny())).captured.single as Map,
      );
      expect(sent, {
        OrdersTableColumns.deliveryManId: 'driver-1',
        OrdersTableColumns.deliveryManName: 'Mo Men',
        OrdersTableColumns.orderStatus: OrderStatuses.accepted,
      });
    });

    test('fails without touching orders when the user is unknown', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.acceptOrder('o1');

      expect(result, isA<FailureResponse<void>>());
      expect(
        (result as FailureResponse).error,
        'User is not authenticated',
      );
      verifyNever(() => ordersQuery.update(any()));
    });

    test('returns a failure when the update throws', () async {
      stubUser();
      when(() => ordersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(
          PostgrestException(message: 'denied'),
        ),
      );

      final result = await repo.acceptOrder('o1');

      expect(result, isA<FailureResponse<void>>());
    });
  });

  group('changeOrderStatus', () {
    setUp(() {
      when(() => ordersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );
    });

    test('marks the order delivered', () async {
      final result = await repo.changeOrderStatus(
        orderId: 'o1',
        delivered: true,
      );

      expect(result, isA<SuccessResponse<void>>());
      final sent = Map<String, dynamic>.from(
        verify(() => ordersQuery.update(captureAny())).captured.single as Map,
      );
      expect(sent, {OrdersTableColumns.orderStatus: OrderStatuses.delivered});
    });

    test('puts a cancelled order back to pending without a driver', () async {
      final result = await repo.changeOrderStatus(
        orderId: 'o1',
        delivered: false,
      );

      expect(result, isA<SuccessResponse<void>>());
      final sent = Map<String, dynamic>.from(
        verify(() => ordersQuery.update(captureAny())).captured.single as Map,
      );
      expect(sent, {
        OrdersTableColumns.deliveryManId: null,
        OrdersTableColumns.deliveryManName: null,
        OrdersTableColumns.orderStatus: OrderStatuses.pending,
      });
    });

    test('returns a failure when the update throws', () async {
      when(() => ordersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(Exception('offline')),
      );

      final result = await repo.changeOrderStatus(
        orderId: 'o1',
        delivered: true,
      );

      expect(result, isA<FailureResponse<void>>());
    });
  });

  group('receiveOrders', () {
    final near = fakeBakery('b1', 30.01, 31.0);
    final far = fakeBakery('b2', 31.0, 31.0);
    late StreamController<SupabaseStreamEvent> source;
    late List<List<OrderModel>> results;
    late StreamSubscription<List<OrderModel>> subscription;

    void listen({int range = 10}) {
      subscription = repo
          .receiveOrders(range: range, driverLat: 30.0, driverLng: 31.0)
          .listen(results.add);
    }

    setUp(() {
      source = StreamController<SupabaseStreamEvent>.broadcast();
      results = [];
      when(() => ordersQuery.stream(primaryKey: any(named: 'primaryKey')))
          .thenAnswer((_) => FakeStreamFilterBuilder(source.stream));
    });

    tearDown(() async {
      await subscription.cancel();
      source.close();
    });

    test('keeps pending orders whose bakeries are all in range', () async {
      listen();

      source.add([
        orderJson('o1', [near]),
        orderJson('o2', [near, far]),
        orderJson('o3', [near], status: OrderStatuses.accepted),
        orderJson('o4', const []),
        {...orderJson('o5', [near]), OrdersTableColumns.orderedProducts: 'x'},
      ]);
      await pumpEventQueue();

      expect(results.single.map((o) => o.orderId), ['o1']);
    });

    test('a wider range lets far bakeries in', () async {
      listen(range: 200);

      source.add([
        orderJson('o1', [near]),
        orderJson('o2', [near, far]),
      ]);
      await pumpEventQueue();

      expect(results.single.map((o) => o.orderId), ['o1', 'o2']);
    });

    test('swallows stream errors and keeps delivering', () async {
      listen();

      source.addError('boom');
      await pumpEventQueue();
      source.add([
        orderJson('o1', [near]),
      ]);
      await pumpEventQueue();

      expect(results.single.map((o) => o.orderId), ['o1']);
    });
  });
}