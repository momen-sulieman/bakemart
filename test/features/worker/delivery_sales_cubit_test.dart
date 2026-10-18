import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

void main() {
  late MockWorkerRepo repo;
  late DeliverySalesCubit cubit;

  final productA = fakeProduct().copyWith(productId: 'p1', productPrice: 5.0);
  final productB = fakeProduct().copyWith(productId: 'p2', productPrice: 2.0);

  OrderModel buildOrder({
    required String orderId,
    List<ProductModel>? products,
    List<int>? quantities,
  }) {
    final items = products ?? [productA, productB];
    final qty = quantities ?? [2, 3];
    var price = 0.0;
    for (var i = 0; i < items.length; i++) {
      price += items[i].productPrice * qty[i];
    }
    return fakeOrder(bakeries: [fakeBakery('b1', 0, 0)]).copyWith(
      orderId: orderId,
      orderedProducts: items,
      orderedQuantities: qty,
      orderPrice: price,
      received: [false],
    );
  }

  setUpAll(() async {
    await setupTestEnvironment();
    registerFallbackValue(buildOrder(orderId: 'fallback'));
  });

  setUp(() {
    repo = MockWorkerRepo();
    cubit = DeliverySalesCubit(repo);
  });

  tearDown(() {
    cubit.close();
  });

  group('scanOrders', () {
    test('success computes the total across every order', () async {
      final orderOne = buildOrder(orderId: 'o1');
      final orderTwo = buildOrder(
        orderId: 'o2',
        products: [productA],
        quantities: [1],
      );
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([orderOne, orderTwo]),
      );

      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      expect(cubit.state, isA<Success>());
      expect(cubit.editableOrders, hasLength(2));
      expect(cubit.total, 21.0);
      expect(cubit.listUpdated, false);
    });

    test('failure emits Failure with the repo error', () async {
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => FailureResponse<List<OrderModel>>('offline'));

      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      expect(cubit.state, isA<Failure>());
      expect((cubit.state as Failure).error, 'offline');
    });
  });

  group('editing an order', () {
    setUp(() async {
      final order = buildOrder(orderId: 'o1');
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => SuccessResponse<List<OrderModel>>([order]));
      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');
    });

    test('increaseQuantity raises the order price and the total', () {
      final order = cubit.editableOrders.single;

      cubit.increaseQuantity(order: order, productIndex: 0);

      expect(cubit.editableOrders.single.orderedQuantities[0], 3);
      expect(cubit.editableOrders.single.orderPrice, 21.0);
      expect(cubit.total, 21.0);
      expect(cubit.listUpdated, true);
    });

    test('decreaseQuantity lowers the order price and the total', () {
      final order = cubit.editableOrders.single;

      cubit.decreaseQuantity(order: order, productIndex: 1);

      expect(cubit.editableOrders.single.orderedQuantities[1], 2);
      expect(cubit.editableOrders.single.orderPrice, 14.0);
      expect(cubit.total, 14.0);
    });

    test('removeProductFromOrder removes the product and deducts its price',
            () {
          final order = cubit.editableOrders.single;

          cubit.removeProductFromOrder(
            orderId: order.orderId!,
            productToRemove: productB,
          );

          final updated = cubit.editableOrders.single;
          expect(updated.orderedProducts, [productA]);
          expect(updated.orderedQuantities, [2]);
          expect(updated.orderPrice, 10.0);
        });

    test('removeOrder drops the order and recomputes the total', () {
      final order = cubit.editableOrders.single;

      cubit.removeOrder(order: order);

      expect(cubit.editableOrders, isEmpty);
      expect(cubit.total, 0.0);
      expect(cubit.listUpdated, true);
    });

    test('resetOrder restores the original quantities for that order', () {
      final order = cubit.editableOrders.single;
      cubit.increaseQuantity(order: order, productIndex: 0);
      expect(cubit.editableOrders.single.orderedQuantities[0], 3);

      cubit.resetOrder(order.orderId!);

      expect(cubit.editableOrders.single.orderedQuantities[0], 2);
    });

    test('reset restores every order back to the scanned snapshot', () {
      final order = cubit.editableOrders.single;
      cubit.removeOrder(order: order);
      expect(cubit.editableOrders, isEmpty);

      cubit.reset();

      expect(cubit.editableOrders, hasLength(1));
      expect(cubit.listUpdated, false);
    });
  });

  group('handing off orders', () {
    test('handOneOrder returns true on success and false on failure',
            () async {
          when(
                () => repo.updateOrderInDatabase(
              order: any(named: 'order'),
              bakeryId: any(named: 'bakeryId'), branchId: '',
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final order = buildOrder(orderId: 'o1');

          final result = await cubit.handOneOrder(order: order, bakeryId: 'b1', branchId: '');

          expect(result, true);
          verify(
                () => repo.updateOrderInDatabase(order: order, bakeryId: 'b1', branchId: ''),
          ).called(1);
        });

    test('handAllOrders removes only the orders that succeeded', () async {
      final orderOne = buildOrder(orderId: 'o1');
      final orderTwo = buildOrder(orderId: 'o2');
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([orderOne, orderTwo]),
      );
      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      when(
            () => repo.updateOrderInDatabase(order: orderOne, bakeryId: 'b1', branchId: ''),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      when(
            () => repo.updateOrderInDatabase(order: orderTwo, bakeryId: 'b1', branchId: ''),
      ).thenAnswer((_) async => FailureResponse<bool>('failed'));

      final allSucceeded = await cubit.handAllOrders(
        orders: [orderOne, orderTwo],
        bakeryId: 'b1', branchId: '',
      );

      expect(allSucceeded, false);
      expect(cubit.editableOrders.map((o) => o.orderId), ['o2']);
      expect(cubit.state, isA<Success>());
    });
  });
}