import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/core/shared/widgets/cart/ui/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockLocationCubit extends Mock implements LocationCubit {}

class TestCartRepo extends CartRepo {
  ResponseResult<OrderModel> Function(OrderModel order)? onMakeOrder;

  @override
  Future<ResponseResult<OrderModel>> makeOrder(OrderModel order) async {
    return onMakeOrder?.call(order) ?? SuccessResponse<OrderModel>(order);
  }
}

void main() {
  late MockLocationCubit locationCubit;
  late TestCartRepo repo;
  late CartCubit cartCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    repo = TestCartRepo();
    cartCubit = CartCubit(repo, locationCubit);
  });

  tearDown(() {
    cartCubit.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<CartCubit>.value(value: cartCubit),
            BlocProvider<LocationCubit>.value(value: locationCubit),
          ],
          child: const CartScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows a zeroed bill while the cart is empty', (tester) async {
    await pumpScreen(tester);

    expect(find.text('00.00'), findsNWidgets(3));
  });

  testWidgets('reflects the bill and the bakery once an item is added',
          (tester) async {
        await pumpScreen(tester);
        final bakery = fakeBakery('b1', 30.001, 31.001);
        final product = fakeProduct(id: 'p1', bakeryId: 'b1')
            .copyWith(productPrice: 5, productWeight: 999);

        cartCubit.addToCart(bakery: bakery, product: product, quantity: 2);
        await tester.pumpAndSettle();

        expect(find.text(bakery.bakeryName), findsOneWidget);
        expect(
          find.text(cartCubit.cart.orderPrice.toStringAsFixed(2)),
          findsWidgets,
        );
        expect(
          find.text(cartCubit.cart.totalBill.toStringAsFixed(2)),
          findsWidgets,
        );
      });

  testWidgets('updateQuantity is reflected in the order tile', (tester) async {
    await pumpScreen(tester);
    final bakery = fakeBakery('b1', 30.001, 31.001);
    final product = fakeProduct(id: 'p1', bakeryId: 'b1')
        .copyWith(productPrice: 5, productWeight: 999);
    cartCubit.addToCart(bakery: bakery, product: product, quantity: 1);
    await tester.pumpAndSettle();

    cartCubit.updateQuantity(productId: product.productId!, quantity: 7);
    await tester.pumpAndSettle();

    expect(find.textContaining('7'), findsWidgets);
    expect(cartCubit.cart.quantities[product.productId], 7);
  });

  testWidgets('clearCart resets the screen back to the empty bill',
          (tester) async {
        await pumpScreen(tester);
        final bakery = fakeBakery('b1', 30.001, 31.001);
        final product = fakeProduct(id: 'p1', bakeryId: 'b1');
        cartCubit.addToCart(bakery: bakery, product: product, quantity: 1);
        await tester.pumpAndSettle();

        cartCubit.clearCart();
        await tester.pumpAndSettle();

        expect(find.text('00.00'), findsNWidgets(3));
      });

  testWidgets('placeOrder failure keeps the cart', (tester) async {
    await pumpScreen(tester);
    final bakery = fakeBakery('b1', 30.001, 31.001);
    final product = fakeProduct(id: 'p1', bakeryId: 'b1');
    cartCubit.addToCart(bakery: bakery, product: product, quantity: 1);
    await tester.pumpAndSettle();
    repo.onMakeOrder = (_) => FailureResponse<OrderModel>('offline');

    cartCubit.placeOrder();
    await tester.pumpAndSettle();

    expect(cartCubit.state, isNot(isA<CartInitial>()));
    expect(cartCubit.cart.quantities[product.productId], 1);
  });

  testWidgets('placeOrder success clears the cart', (tester) async {
    await pumpScreen(tester);
    final bakery = fakeBakery('b1', 30.001, 31.001);
    final product = fakeProduct(id: 'p1', bakeryId: 'b1');
    cartCubit.addToCart(bakery: bakery, product: product, quantity: 1);
    await tester.pumpAndSettle();

    cartCubit.placeOrder();
    await tester.pumpAndSettle();

    expect(cartCubit.state, isA<CartInitial>());
  });
}