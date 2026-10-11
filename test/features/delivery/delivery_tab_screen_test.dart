import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/services/location_services.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/delivery_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockDeliveryRepo extends Mock implements DeliveryRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockDeliveryRepo repo;
  late MockLocationCubit locationCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockDeliveryRepo();
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    when(() => repo.fetchAcceptedOrders())
        .thenAnswer((_) async => SuccessResponse<List<OrderModel>>([]));
    when(() => repo.receiveOrders(
      range: any(named: 'range'),
      driverLat: any(named: 'driverLat'),
      driverLng: any(named: 'driverLng'),
    )).thenAnswer((_) => const Stream<List<OrderModel>>.empty());
  });

  DeliveryCubit buildCubit() {
    final cubit = DeliveryCubit(repo, locationCubit);
    addTearDown(cubit.close);
    return cubit;
  }

  Future<void> waitForLoad(WidgetTester tester, DeliveryCubit cubit) async {
    for (var i = 0; i < 20 && cubit.state is Loading; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpFrames(WidgetTester tester, {int frames = 10}) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> pumpScreen(WidgetTester tester, DeliveryCubit cubit) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      BlocProvider<DeliveryCubit>.value(
        value: cubit,
        child: const DeliveryTabScreen(),
      ),
      settle: false,
    );
    await waitForLoad(tester, cubit);
    await tester.pumpAndSettle();
  }

  testWidgets('starts not receiving, with the switch off', (tester) async {
    when(() => repo.getUserData()).thenAnswer(
          (_) async => SuccessResponse<UserModel>(
        UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
      ),
    );
    final cubit = buildCubit();

    await pumpScreen(tester, cubit);

    expect(cubit.state, isA<NotReceiving>());
    expect(tester.widget<Switch>(find.byType(Switch)).value, false);
  });

  testWidgets(
      'toggling the switch for a verified user starts receiving with an empty list',
          (tester) async {
        when(() => repo.getUserData()).thenAnswer(
              (_) async => SuccessResponse<UserModel>(
            UserModel(
              firstName: 'Mo',
              secondName: 'Amin',
              email: '',
              phone: '',
              verified: true,
            ),
          ),
        );
        final cubit = buildCubit();
        await pumpScreen(tester, cubit);

        await tester.tap(find.byType(Switch));
        await pumpFrames(tester);

        expect(cubit.state, isA<Receiving>());
        expect(tester.widget<Switch>(find.byType(Switch)).value, true);
        expect(find.text('0/5'), findsOneWidget);
      });

  testWidgets(
      'toggling for an unverified, non-pending user opens the verify prompt instead',
          (tester) async {
        when(() => repo.getUserData()).thenAnswer(
              (_) async => SuccessResponse<UserModel>(
            UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
          ),
        );
        final cubit = buildCubit();
        await pumpScreen(tester, cubit);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(cubit.state, isA<NotReceiving>());
        expect(tester.widget<Switch>(find.byType(Switch)).value, false);
      });

  testWidgets('shows the offline state and retries when tapped',
          (tester) async {
        when(() => repo.getUserData())
            .thenAnswer((_) async => FailureResponse<UserModel>('offline'));
        when(() => repo.fetchAcceptedOrders()).thenAnswer(
              (_) async => FailureResponse<List<OrderModel>>('offline'),
        );
        final cubit = buildCubit();
        await pumpScreen(tester, cubit);

        expect(cubit.state, isA<Failure>());
        expect(find.byIcon(Icons.error_outline), findsOneWidget);

        when(() => repo.getUserData()).thenAnswer(
              (_) async => SuccessResponse<UserModel>(
            UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
          ),
        );
        when(() => repo.fetchAcceptedOrders())
            .thenAnswer((_) async => SuccessResponse<List<OrderModel>>([]));
        await tester.tap(find.byIcon(Icons.error_outline));
        for (var i = 0; i < 40 && cubit.state is! NotReceiving; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        expect(cubit.state, isA<NotReceiving>());
      });

  testWidgets(
      'shows the waiting-for-location state when location fails while receiving',
          (tester) async {
        when(() => repo.getUserData()).thenAnswer(
              (_) async => SuccessResponse<UserModel>(
            UserModel(
              firstName: 'Mo',
              secondName: 'Amin',
              email: '',
              phone: '',
              verified: true,
            ),
          ),
        );
        when(() => locationCubit.state).thenAnswer(
              (_) => LocationFailure(
            'none',
            reason: LocationFailureReason.permissionDenied,
          ),
        );
        when(() => locationCubit.retryTracking()).thenReturn(null);
        final cubit = buildCubit();
        await pumpScreen(tester, cubit);

        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();

        expect(cubit.state, isA<WaitingForLocation>());
        expect(find.byIcon(Icons.location_disabled), findsOneWidget);

        await tester.tap(find.byIcon(Icons.location_disabled));
        verify(() => locationCubit.retryTracking()).called(1);
      });
}