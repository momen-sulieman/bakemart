import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/services/location_services.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class MockDeliveryRepo extends Mock implements DeliveryRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockDeliveryRepo repo;
  late MockLocationCubit locationCubit;
  late StreamController<LocationState> locationStates;
  late LocationState currentLocation;

  final driver = UserModel(
    id: 'd1',
    firstName: 'Mo',
    secondName: 'Men',
    email: 'mo@test.com',
    phone: '1',
  );
  final accepted = fakeOrder().copyWith(orderId: 'o1');

  Future<DeliveryCubit> build() async {
    final cubit = DeliveryCubit(repo, locationCubit);
    addTearDown(cubit.close);
    await pumpEventQueue();
    return cubit;
  }

  List<DeliveryState> collect(DeliveryCubit cubit) {
    final states = <DeliveryState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  setUp(() {
    repo = MockDeliveryRepo();
    locationCubit = MockLocationCubit();
    locationStates = StreamController<LocationState>.broadcast();
    currentLocation = LocationUpdated(lat: 30, lng: 31);

    when(() => locationCubit.state).thenAnswer((_) => currentLocation);
    when(() => locationCubit.stream).thenAnswer((_) => locationStates.stream);
    when(
          () => repo.getUserData(),
    ).thenAnswer((_) async => SuccessResponse<UserModel>(driver));
    when(() => repo.fetchAcceptedOrders()).thenAnswer(
          (_) async => SuccessResponse<List<OrderModel>>([accepted]),
    );
    when(
          () => repo.receiveOrders(
        range: any(named: 'range'),
        driverLat: any(named: 'driverLat'),
        driverLng: any(named: 'driverLng'),
      ),
    ).thenAnswer((_) => const Stream<List<OrderModel>>.empty());
  });

  tearDown(() async {
    await locationStates.close();
  });

  group('init', () {
    test('starts loading', () async {
      final cubit = DeliveryCubit(repo, locationCubit);
      addTearDown(cubit.close);

      expect(cubit.state, isA<Loading>());
      await pumpEventQueue();
    });

    test('loads the user and accepted orders then idles', () async {
      final cubit = await build();

      expect(cubit.state, isA<NotReceiving>());
      expect(cubit.user.firstName, 'Mo');
      expect(cubit.acceptedOrders, [accepted]);
      expect(cubit.driverLat, 30);
      expect(cubit.driverLng, 31);
    });

    test('keeps the default user when the user cannot be loaded', () async {
      when(() => repo.getUserData()).thenAnswer(
            (_) async => FailureResponse<UserModel>('offline'),
      );

      final cubit = await build();

      expect(cubit.user.firstName, '');
      expect(cubit.state, isA<NotReceiving>());
    });

    test('fails when the accepted orders cannot be loaded', () async {
      when(() => repo.fetchAcceptedOrders()).thenAnswer(
            (_) async => FailureResponse<List<OrderModel>>('offline'),
      );

      final cubit = await build();

      expect(cubit.state, isA<Failure>());
      expect((cubit.state as Failure).error, 'offline');
    });

    test('can be initialised again', () async {
      final cubit = await build();
      final states = collect(cubit);

      cubit.initCubit(loading: true);
      await pumpEventQueue();

      expect(states, [isA<Loading>(), isA<NotReceiving>()]);
    });

    test('closing before it finishes does not throw', () async {
      final cubit = DeliveryCubit(repo, locationCubit);

      await cubit.close();
      await pumpEventQueue();

      expect(cubit.isClosed, true);
    });
  });

  group('receiving', () {
    test('startReceiving opens the live stream for the range', () async {
      final cubit = await build();
      final states = collect(cubit);

      cubit.startReceiving();
      await pumpEventQueue();

      expect(states, [isA<Receiving>()]);
      expect(cubit.isReceiving, true);
      expect(cubit.liveNearbyOrders, isNotNull);
      verify(
            () => repo.receiveOrders(range: 10, driverLat: 30, driverLng: 31),
      ).called(1);
    });

    test('waits with an unknown reason when there is no location', () async {
      currentLocation = LocationInitial();
      final cubit = await build();

      cubit.startReceiving();

      expect(cubit.state, isA<WaitingForLocation>());
      expect(
        (cubit.state as WaitingForLocation).reason,
        LocationFailureReason.unknown,
      );
      expect(cubit.liveNearbyOrders, isNull);
    });

    test('waits with the location failure reason', () async {
      currentLocation = LocationFailure(
        'denied',
        reason: LocationFailureReason.permissionDenied,
      );
      final cubit = await build();

      cubit.startReceiving();

      expect(
        (cubit.state as WaitingForLocation).reason,
        LocationFailureReason.permissionDenied,
      );
    });

    test('toggleReceiving turns receiving on and off', () async {
      final cubit = await build();
      final states = collect(cubit);

      cubit.toggleReceiving();
      cubit.toggleReceiving();
      await pumpEventQueue();

      expect(states, [isA<Receiving>(), isA<NotReceiving>()]);
      expect(cubit.isReceiving, false);
      expect(cubit.liveNearbyOrders, isNull);
    });

    test('updateRange only stores the range while idle', () async {
      final cubit = await build();

      cubit.updateRange(5);

      expect(cubit.range, 5);
      verifyNever(
            () => repo.receiveOrders(
          range: any(named: 'range'),
          driverLat: any(named: 'driverLat'),
          driverLng: any(named: 'driverLng'),
        ),
      );
    });

    test('updateRange reopens the stream while receiving', () async {
      final cubit = await build();
      cubit.startReceiving();
      final states = collect(cubit);

      cubit.updateRange(20);
      await pumpEventQueue();

      expect(states, [isA<Receiving>()]);
      verify(
            () => repo.receiveOrders(range: 20, driverLat: 30, driverLng: 31),
      ).called(1);
    });
  });

  group('location stream', () {
    test('starts receiving once a location arrives', () async {
      currentLocation = LocationInitial();
      final cubit = await build();
      final states = collect(cubit);

      cubit.startReceiving();
      locationStates.add(LocationUpdated(lat: 30, lng: 31));
      await pumpEventQueue();

      expect(states, [isA<WaitingForLocation>(), isA<Receiving>()]);
      expect(cubit.driverLat, 30);
    });

    test('falls back to waiting when the location fails', () async {
      final cubit = await build();
      cubit.startReceiving();
      final states = collect(cubit);

      locationStates.add(
        LocationFailure(
          'gps off',
          reason: LocationFailureReason.serviceDisabled,
        ),
      );
      await pumpEventQueue();

      expect(states, [isA<WaitingForLocation>()]);
      expect(
        (states.single as WaitingForLocation).reason,
        LocationFailureReason.serviceDisabled,
      );
      expect(cubit.driverLat, isNull);
      expect(cubit.liveNearbyOrders, isNull);
    });

    test('a failure while idle only clears the coordinates', () async {
      final cubit = await build();
      final states = collect(cubit);

      locationStates.add(LocationFailure('gps off'));
      await pumpEventQueue();

      expect(states, isEmpty);
      expect(cubit.driverLat, isNull);
    });
  });

  group('fixLocationIssue', () {
    for (final reason in [
      LocationFailureReason.permissionDenied,
      LocationFailureReason.timedOut,
      LocationFailureReason.unknown,
    ]) {
      test('retries tracking for $reason', () async {
        final cubit = await build();

        await cubit.fixLocationIssue(reason);

        verify(() => locationCubit.retryTracking()).called(1);
      });
    }
  });

  group('acceptOrder', () {
    test('tracks the loading action and reports success', () async {
      final completer = Completer<ResponseResult<void>>();
      when(() => repo.acceptOrder('o1')).thenAnswer((_) => completer.future);
      final cubit = await build();
      final states = collect(cubit);
      final results = <DeliveryActionResult>[];
      cubit.actionResults.listen(results.add);

      final future = cubit.acceptOrder(orderId: 'o1');
      await pumpEventQueue();

      expect(cubit.isActionLoading('o1', DeliveryActionType.accept), true);
      expect(cubit.isActionLoading('o1', DeliveryActionType.deliver), false);
      expect(cubit.isActionLoading('o2', DeliveryActionType.accept), false);

      completer.complete(SuccessResponse<void>(null));
      await future;
      await pumpEventQueue();

      expect(cubit.loadingOrderId, isNull);
      expect(cubit.loadingAction, isNull);
      expect(results.single.success, true);
      expect(results.single.type, DeliveryActionType.accept);
      expect(results.single.message, isNotEmpty);
      expect(states, hasLength(2));
      expect(states, everyElement(isA<NotReceiving>()));
      verify(() => repo.fetchAcceptedOrders()).called(2);
    });

    test('reports the error and does not reload on failure', () async {
      when(
            () => repo.acceptOrder('o1'),
      ).thenAnswer((_) async => FailureResponse<void>('taken'));
      final cubit = await build();
      final results = <DeliveryActionResult>[];
      cubit.actionResults.listen(results.add);

      await cubit.acceptOrder(orderId: 'o1');
      await pumpEventQueue();

      expect(results.single.success, false);
      expect(results.single.message, 'taken');
      expect(cubit.loadingOrderId, isNull);
      verify(() => repo.fetchAcceptedOrders()).called(1);
    });

    test('ignores a second action on the same order', () async {
      final completer = Completer<ResponseResult<void>>();
      when(() => repo.acceptOrder('o1')).thenAnswer((_) => completer.future);
      final cubit = await build();

      final first = cubit.acceptOrder(orderId: 'o1');
      await pumpEventQueue();
      await cubit.acceptOrder(orderId: 'o1');
      await cubit.changeOrderStatus(orderId: 'o1', delivered: true);
      completer.complete(SuccessResponse<void>(null));
      await first;

      verify(() => repo.acceptOrder('o1')).called(1);
      verifyNever(
            () => repo.changeOrderStatus(
          orderId: any(named: 'orderId'),
          delivered: any(named: 'delivered'),
        ),
      );
    });
  });

  group('changeOrderStatus', () {
    test('reports a delivered order', () async {
      when(
            () => repo.changeOrderStatus(orderId: 'o1', delivered: true),
      ).thenAnswer((_) async => SuccessResponse<void>(null));
      final cubit = await build();
      final results = <DeliveryActionResult>[];
      cubit.actionResults.listen(results.add);

      await cubit.changeOrderStatus(orderId: 'o1', delivered: true);
      await pumpEventQueue();

      expect(results.single.type, DeliveryActionType.deliver);
      expect(results.single.success, true);
      verify(() => repo.fetchAcceptedOrders()).called(2);
    });

    test('reports a cancelled order', () async {
      when(
            () => repo.changeOrderStatus(orderId: 'o1', delivered: false),
      ).thenAnswer((_) async => SuccessResponse<void>(null));
      final cubit = await build();
      final results = <DeliveryActionResult>[];
      cubit.actionResults.listen(results.add);

      await cubit.changeOrderStatus(orderId: 'o1', delivered: false);
      await pumpEventQueue();

      expect(results.single.type, DeliveryActionType.cancel);
      expect(results.single.success, true);
    });

    test('reports the error when the change fails', () async {
      when(
            () => repo.changeOrderStatus(orderId: 'o1', delivered: true),
      ).thenAnswer((_) async => FailureResponse<void>('locked'));
      final cubit = await build();
      final results = <DeliveryActionResult>[];
      cubit.actionResults.listen(results.add);

      await cubit.changeOrderStatus(orderId: 'o1', delivered: true);
      await pumpEventQueue();

      expect(results.single.success, false);
      expect(results.single.message, 'locked');
      expect(results.single.type, DeliveryActionType.deliver);
    });
  });
}