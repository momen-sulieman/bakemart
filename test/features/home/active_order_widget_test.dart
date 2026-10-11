import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/widgets/active_orders_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

Finder priceStartingWith(String prefix) => find.byWidgetPredicate(
      (widget) =>
  widget is RichText && widget.text.toPlainText().startsWith(prefix),
);

final Finder cancelArea = find.byType(StreamBuilder<Set<String>>);
final Finder cancelButton =
find.descendant(of: cancelArea, matching: find.byType(InkWell));

void main() {
  late MockHomeRepo repo;
  late ActiveOrdersCubit cubit;
  late StreamController<List<OrderModel>> ordersController;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockHomeRepo();
    ordersController = StreamController<List<OrderModel>>.broadcast();
    when(() => repo.streamActiveOrders())
        .thenAnswer((_) => ordersController.stream);
    when(() => repo.cancelOrder(orderId: any(named: 'orderId')))
        .thenAnswer((_) async => SuccessResponse<void>(null));
    cubit = ActiveOrdersCubit(repo);
    cubit.checkActiveOrders();
  });

  tearDown(() async {
    await cubit.close();
    await ordersController.close();
  });

  Future<void> pumpWidget(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Material(
        child: BlocProvider<ActiveOrdersCubit>.value(
          value: cubit,
          child: const ActiveOrdersWidget(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  OrderModel buildOrder({
    String orderId = 'o1',
    String orderStatus = OrderStatuses.pending,
    List<BakeryModel>? bakeries,
    List<bool>? received,
    String? deliveryManName,
  }) {
    final defaultBakeries = bakeries ?? [fakeBakery('b1', 30, 31)];
    return fakeOrder(bakeries: defaultBakeries).copyWith(
      orderId: orderId,
      orderStatus: orderStatus,
      received: received ?? List.filled(defaultBakeries.length, false),
      deliveryManName: deliveryManName,
      orderPrice: 10,
      deliveryFee: 2,
    );
  }

  testWidgets('renders nothing while there are no active orders',
          (tester) async {
        await pumpWidget(tester);
        ordersController.add([]);
        await tester.pumpAndSettle();

        expect(cancelArea, findsNothing);
        expect(find.byType(GestureDetector), findsNothing);
      });

  testWidgets('shows a pending order with its price breakdown and cancel button',
          (tester) async {
        await pumpWidget(tester);
        ordersController.add([buildOrder()]);
        await tester.pumpAndSettle();

        expect(priceStartingWith('10.00'), findsOneWidget);
        expect(priceStartingWith('2.00'), findsOneWidget);
        expect(priceStartingWith('12.00'), findsOneWidget);
        expect(cancelButton, findsOneWidget);
      });

  testWidgets('shows the delivery man name instead of cancel once accepted',
          (tester) async {
        await pumpWidget(tester);
        final order = buildOrder(
          orderStatus: OrderStatuses.accepted,
          deliveryManName: 'Sam',
        );
        ordersController.add([order]);
        await tester.pumpAndSettle();

        expect(find.text('Sam'), findsOneWidget);
        expect(cancelArea, findsNothing);
      });

  testWidgets('tapping cancel calls the repo with the order id',
          (tester) async {
        await pumpWidget(tester);
        ordersController.add([buildOrder(orderId: 'order-42')]);
        await tester.pumpAndSettle();

        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        verify(() => repo.cancelOrder(orderId: 'order-42')).called(1);
      });

  testWidgets('shows a loading indicator on the tapped order while cancelling',
          (tester) async {
        final completer = Completer<ResponseResult<void>>();
        when(() => repo.cancelOrder(orderId: any(named: 'orderId')))
            .thenAnswer((_) => completer.future);
        await pumpWidget(tester);
        ordersController.add([buildOrder(orderId: 'order-42')]);
        await tester.pumpAndSettle();
        expect(loadingDots, findsNothing);

        await tester.tap(cancelButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(loadingDots, findsOneWidget);

        completer.complete(SuccessResponse<void>(null));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
      });
}