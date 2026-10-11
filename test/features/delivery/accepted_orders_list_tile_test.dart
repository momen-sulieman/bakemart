import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/data/delivery_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/logic/delivery_cubit/delivery_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/accepted_orders_list_tile.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/order_details_screen.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
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
    orderStatus: OrderStatuses.accepted,
    customerId: 'cust-1',
    customerName: 'Sam',
    orderPrice: 10,
    deliveryFee: 2,
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
        .thenAnswer((_) async => SuccessResponse<List<OrderModel>>([order]));
    cubit = DeliveryCubit(repo, locationCubit);
  });

  tearDown(() {
    cubit.close();
  });

  Future<void> pumpTile(WidgetTester tester, {VoidCallback? onCancel, VoidCallback? onDelivered}) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<DeliveryCubit>.value(
          value: cubit,
          child: AcceptedOrdersListTile(
            order: order,
            routeDistance: 3.2,
            onCancel: onCancel ?? () {},
            onDelivered: onDelivered ?? () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the total bill and the customer', (tester) async {
    await pumpTile(tester);

    expect(find.text('12.00'), findsOneWidget);
    expect(find.textContaining('Sam'), findsWidgets);
  });

  testWidgets('tapping the tile opens the order details dialog',
          (tester) async {
        await pumpTile(tester);

        await tester.tap(find.text('12.00'));
        await tester.pumpAndSettle();

        expect(find.byType(OrderDetailsScreen), findsOneWidget);
      });

  testWidgets('tapping cancel calls onCancel', (tester) async {
    var cancelled = false;
    await pumpTile(tester, onCancel: () => cancelled = true);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(cancelled, true);
  });

  testWidgets('tapping deliver calls onDelivered', (tester) async {
    var delivered = false;
    await pumpTile(tester, onDelivered: () => delivered = true);

    await tester.tap(find.byIcon(Icons.done_all));
    await tester.pump();

    expect(delivered, true);
  });

  testWidgets('shows a spinner instead of the close icon while cancelling',
          (tester) async {
        when(() => repo.changeOrderStatus(
          orderId: any(named: 'orderId'),
          delivered: any(named: 'delivered'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return SuccessResponse<void>(null);
        });
        await pumpTile(tester, onCancel: () => cubit.changeOrderStatus(orderId: order.orderId!, delivered: false));

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump();

        expect(find.byIcon(Icons.close), findsNothing);
        await tester.pumpAndSettle();
      });
}