import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/location_picker_map/delivery_route_map_screen.dart';
import 'package:bakemart/core/shared/widgets/location_picker_map/location_picker_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockLocationCubit extends Mock implements LocationCubit {}

class IdleLocationState extends Fake implements LocationState {}

class FakeOrder extends Fake implements OrderModel {
  FakeOrder({
    required this.bakeries,
    required this.customerLat,
    required this.customerLng,
    this.street,
    this.building,
    this.apartment,
  });

  @override
  final List<BakeryModel> bakeries;
  @override
  final double customerLat;
  @override
  final double customerLng;
  @override
  final String? street;
  @override
  final String? building;
  @override
  final String? apartment;
}

void ignoreMapTileErrors() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    final text = details.exceptionAsString();
    if (text.contains('HTTP request failed') ||
        text.contains('NetworkImage') ||
        text.contains('tile.openstreetmap')) {
      return;
    }
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

void main() {
  late MockLocationCubit locationCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state).thenAnswer((_) => IdleLocationState());
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
  });

  FakeOrder buildOrder({
    String? street,
    String? building,
    String? apartment,
  }) {
    return FakeOrder(
      bakeries: [
        fakeBakery('b1', 30.0, 31.0),
        fakeBakery('b2', 30.1, 31.1),
      ],
      customerLat: 30.2,
      customerLng: 31.2,
      street: street,
      building: building,
      apartment: apartment,
    );
  }

  Future<void> openScreen(WidgetTester tester, OrderModel order) async {
    ignoreMapTileErrors();
    useTallSurface(tester, size: const Size(900, 1600));
    await pumpLocalizedWidget(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider<LocationCubit>.value(
                    value: locationCubit,
                    child: DeliveryRouteMapScreen(order: order),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('passes one marker per bakery plus the customer to the map',
          (tester) async {
        final order = buildOrder();
        await openScreen(tester, order);

        final map = tester.widget<LocationPickerMap>(find.byType(LocationPickerMap));

        expect(map.mode, LocationMapMode.viewer);
        expect(map.markers, hasLength(order.bakeries.length + 1));
        for (var i = 0; i < order.bakeries.length; i++) {
          expect(map.markers[i].lat, order.bakeries[i].bakeryLat);
          expect(map.markers[i].lng, order.bakeries[i].bakeryLng);
          expect(map.markers[i].icon, Icons.location_pin);
        }
        expect(map.markers.last.lat, order.customerLat);
        expect(map.markers.last.lng, order.customerLng);
        expect(map.markers.last.icon, Icons.person_pin_circle);
      });

  testWidgets('centres on the customer and draws no route without a live fix',
          (tester) async {
        final order = buildOrder();
        await openScreen(tester, order);

        final map = tester.widget<LocationPickerMap>(find.byType(LocationPickerMap));

        expect(map.initialLat, order.customerLat);
        expect(map.initialLng, order.customerLng);
        expect(map.deviceLat, isNull);
        expect(map.deviceLng, isNull);
        expect(map.routePoints, isEmpty);
      });

  testWidgets('the back arrow pops the screen', (tester) async {
    await openScreen(tester, buildOrder());
    expect(find.byType(DeliveryRouteMapScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DeliveryRouteMapScreen), findsNothing);
  });

  testWidgets('shows the customer address card when the address is present',
          (tester) async {
        await openScreen(
          tester,
          buildOrder(street: 'Main St', building: '7', apartment: '3B'),
        );

        expect(find.text('Main St'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('3B'), findsOneWidget);
      });
}