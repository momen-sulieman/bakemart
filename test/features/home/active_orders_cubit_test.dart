import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

void main() {
  late MockHomeRepo repo;
  late ActiveOrdersCubit cubit;

  setUp(() {
    repo = MockHomeRepo();
    cubit = ActiveOrdersCubit(repo);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('starts with no active orders', () {
    expect(cubit.state, isA<NoActiveOrders>());
    expect(cubit.liveActiveOrders, isNull);
    expect(cubit.cancellingOrderIds, isEmpty);
  });

  test('checkActiveOrders exposes the repo stream', () {
    final stream = Stream<List<OrderModel>>.value(const []);
    when(() => repo.streamActiveOrders()).thenAnswer((_) => stream);

    cubit.checkActiveOrders();

    expect(cubit.liveActiveOrders, same(stream));
    verify(() => repo.streamActiveOrders()).called(1);
  });

  test('cancelOrder publishes the cancelling ids then clears them', () async {
    when(
          () => repo.cancelOrder(orderId: 'o1'),
    ).thenAnswer((_) async => SuccessResponse<void>(null));
    final emitted = <Set<String>>[];
    final subscription = cubit.cancellingOrderIdsStream.listen(emitted.add);

    await cubit.cancelOrder(orderId: 'o1');
    await pumpEventQueue();

    expect(emitted, [
      {'o1'},
      <String>{},
    ]);
    expect(cubit.cancellingOrderIds, isEmpty);
    verify(() => repo.cancelOrder(orderId: 'o1')).called(1);
    await subscription.cancel();
  });

  test('cancelOrder clears the id even when the repo fails', () async {
    when(
          () => repo.cancelOrder(orderId: 'o1'),
    ).thenAnswer((_) async => FailureResponse<void>('locked'));
    final emitted = <Set<String>>[];
    final subscription = cubit.cancellingOrderIdsStream.listen(emitted.add);

    await cubit.cancelOrder(orderId: 'o1');
    await pumpEventQueue();

    expect(emitted.last, isEmpty);
    expect(cubit.cancellingOrderIds, isEmpty);
    await subscription.cancel();
  });

  test('tracks several orders being cancelled at once', () async {
    when(() => repo.cancelOrder(orderId: any(named: 'orderId'))).thenAnswer(
          (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return SuccessResponse<void>(null);
      },
    );
    final emitted = <Set<String>>[];
    final subscription = cubit.cancellingOrderIdsStream.listen(emitted.add);

    final first = cubit.cancelOrder(orderId: 'o1');
    final second = cubit.cancelOrder(orderId: 'o2');
    await Future.wait([first, second]);
    await pumpEventQueue();

    expect(emitted.first, {'o1'});
    expect(emitted[1], {'o1', 'o2'});
    expect(emitted.last, isEmpty);
    await subscription.cancel();
  });
}