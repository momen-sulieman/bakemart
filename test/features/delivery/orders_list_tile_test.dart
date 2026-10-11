import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/orders_list_tile.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/order_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockDeliveryRepo extends Mock implements DeliveryRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockDeliveryRepo repo;
  late MockLocationCubit locationCubit;
  late DeliveryCubit cubit;

  final order = fakeOrder(bakeries: [fakeBakery('b1', 30, 31)]).copyWith(
    orderId: 'order-1',
    customerId: 'cust-1',
    customerName: 'Sam',
    orderPrice: 10.0,
    deliveryFee: 2.0,
  );

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
    when(() => repo.getUserData()).thenAnswer(
          (_) async => SuccessResponse<UserModel>(
        UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
      ),
    );
    when(() => repo.fetchAcceptedOrders())
        .thenAnswer((_) async => SuccessResponse<List<OrderModel>>([]));
    cubit = DeliveryCubit(repo, locationCubit);
  });

  tearDown(() {
    cubit.close();
  });

  Future<RouteRecorder> pumpTile(
      WidgetTester tester, {
        VoidCallback? onAccept,
      }) async {
    useTallSurface(tester);
    final observer = RouteRecorder();
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<DeliveryCubit>.value(
          value: cubit,
          child: OrdersListTile(
            order: order,
            routeDistance: 4.5,
            onAccept: onAccept ?? () {},
          ),
        ),
      ),
      observers: [observer],
    );
    await tester.pumpAndSettle();
    return observer;
  }

  testWidgets('renders the order price and delivery fee', (tester) async {
    await pumpTile(tester);

    expect(find.text('10.0'), findsOneWidget);
    expect(find.text('2.0'), findsOneWidget);
  });

  testWidgets('tapping the tile opens the order details dialog',
          (tester) async {
        await pumpTile(tester);

        await tester.tap(find.text('10.0'));
        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailsScreen), findsOneWidget);
      });

  // "accept" is a translation key, and its rendered English text isn't known
  // ahead of time here, so the button is located structurally instead: it's
  // the only green GlassCard in this tile (the route badge next to it is
  // dark, not green).
  final acceptButtonFinder =
  find.byWidgetPredicate((widget) => widget is GlassCard && widget.green);

  testWidgets('tapping accept calls onAccept', (tester) async {
    var accepted = false;
    await pumpTile(tester, onAccept: () => accepted = true);

    await tester.tap(acceptButtonFinder);
    await tester.pump();

    expect(accepted, true);
  });

  testWidgets('tapping the route badge pushes a route carrying the order',
          (tester) async {
        final observer = await pumpTile(tester);

        await tester.tap(find.byIcon(Icons.route));
        await tester.pumpAndSettle();

        expect(observer.pushed, hasLength(1));
        expect(observer.pushed.single.arguments, same(order));
      });
}