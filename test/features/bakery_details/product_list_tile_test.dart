import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/bakery_details/logic/quantity_counter_cubit/quantity_counter_cubit.dart';
import 'package:bakemart/features/bakery_details/ui/widgets/product_counter.dart';
import 'package:bakemart/features/bakery_details/ui/widgets/product_list_tile.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockLocationCubit extends Mock implements LocationCubit {}

// CartRepo's only network call is makeOrder — everything else
// (calculateOrderPrice, calculateDeliveryFee, addItemToCart, cartToOrder)
// is pure logic worth exercising for real, so this only overrides the
// network method rather than mocking the whole class.
class TestCartRepo extends CartRepo {
  @override
  Future<ResponseResult<OrderModel>> makeOrder(OrderModel order) async {
    return SuccessResponse<OrderModel>(order);
  }
}

void main() {
  late MockLocationCubit locationCubit;
  late CartCubit cartCubit;

  // The add-to-cart button is the InkWell whose direct child is a Text —
  // every other InkWell on this sheet is inside a TransparentButton, whose
  // child is a ClipRRect, not a Text.
  final addToCartFinder =
  find.byWidgetPredicate((widget) => widget is InkWell && widget.child is Text);

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    cartCubit = CartCubit(TestCartRepo(), locationCubit);

    if (GetIt.instance.isRegistered<CartCubit>()) {
      GetIt.instance.unregister<CartCubit>();
    }
    if (GetIt.instance.isRegistered<QuantityCounterCubit>()) {
      GetIt.instance.unregister<QuantityCounterCubit>();
    }
    // ProductListTile reaches for CartCubit via
    // DependencyInjection.getIt<CartCubit>() inside the bottom sheet,
    // bypassing the ambient BlocProvider — register the SAME instance so
    // the icon's isInCart check and the sheet agree on cart state.
    GetIt.instance.registerLazySingleton<CartCubit>(() => cartCubit);
    GetIt.instance.registerFactory<QuantityCounterCubit>(
          () => QuantityCounterCubit(),
    );
  });

  tearDown(() {
    cartCubit.close();
    GetIt.instance.unregister<CartCubit>();
    GetIt.instance.unregister<QuantityCounterCubit>();
  });

  HomeDataBakeriesModel buildBakery({ProductModel? product}) {
    return HomeDataBakeriesModel(
      bakeryModel: fakeBakery('b1', 30.001, 31.001),
      productModelList: [product ?? fakeProduct(id: 'p1', bakeryId: 'b1')],
    );
  }

  Future<void> pumpTile(
      WidgetTester tester,
      HomeDataBakeriesModel bakery,
      ) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<CartCubit>.value(
          value: cartCubit,
          child: ProductListTile(bakery: bakery, index: 0),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the product name, price and rating', (tester) async {
    final product = fakeProduct(id: 'p1', bakeryId: 'b1')
        .copyWith(productName: 'Croissant', productPrice: 3.5);
    final bakery = buildBakery(product: product);

    await pumpTile(tester, bakery);

    expect(find.text('Croissant'), findsOneWidget);
    expect(find.text('3.5'), findsOneWidget);
  });

  testWidgets('tapping the row opens the product details dialog',
          (tester) async {
        final bakery = buildBakery();
        await pumpTile(tester, bakery);

        expect(find.byType(ProductDetailsScreen), findsNothing);

        await tester.tap(find.byType(ProductListTile));
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailsScreen), findsOneWidget);
      });

  testWidgets(
      'tapping the cart icon opens the counter, and confirming adds the typed quantity',
          (tester) async {
        final product = fakeProduct(id: 'p1', bakeryId: 'b1');
        final bakery = buildBakery(product: product);
        await pumpTile(tester, bakery);

        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(ProductCounter), findsOneWidget);

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();
        expect(find.text('1'), findsOneWidget);

        await tester.tap(addToCartFinder);
        await tester.pumpAndSettle();

        expect(find.byType(ProductCounter), findsNothing);
        expect(cartCubit.cart.quantities[product.productId], 1);
        expect(cartCubit.cart.bakeries.containsKey('b1'), true);
      });

  testWidgets(
      'shows an already-in-cart snackbar instead of the counter when already added',
          (tester) async {
        final product = fakeProduct(id: 'p1', bakeryId: 'b1');
        final bakery = buildBakery(product: product);
        cartCubit.addToCart(
          bakery: bakery.bakeryModel,
          product: product,
          quantity: 2,
        );
        await pumpTile(tester, bakery);

        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(ProductCounter), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        // Quantity untouched by the tap itself — only the snackbar fired.
        expect(cartCubit.cart.quantities[product.productId], 2);
      });
}