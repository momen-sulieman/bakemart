import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/bakery_details/ui/bakery_details_screen.dart';
import 'package:bakemart/features/bakery_details/ui/widgets/product_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockCartRepo extends Mock implements CartRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockLocationCubit locationCubit;
  late CartCubit cartCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    locationCubit = MockLocationCubit();
    // LocationInitial so CartCubit's constructor skips its price
    // recalculation (which would call the mocked CartRepo).
    when(() => locationCubit.state).thenAnswer((_) => LocationInitial());
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    cartCubit = CartCubit(MockCartRepo(), locationCubit);
  });

  tearDown(() {
    cartCubit.close();
  });

  HomeDataBakeriesModel buildBakery({int productCount = 3}) {
    return HomeDataBakeriesModel(
      bakeryModel: fakeBakery('b1', 30, 31),
      productModelList: [
        for (var i = 1; i <= productCount; i++)
          fakeProduct(id: 'p$i', bakeryId: 'b1')
              .copyWith(productName: 'Item $i', productPrice: i * 2.0),
      ],
    );
  }

  // Opened through a real route so the back button has something to pop.
  Future<void> openScreen(
      WidgetTester tester,
      HomeDataBakeriesModel bakery,
      ) async {
    useTallSurface(tester, size: const Size(800, 2400));
    await pumpLocalizedWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<CartCubit>.value(value: cartCubit),
          BlocProvider<LocationCubit>.value(value: locationCubit),
        ],
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider<CartCubit>.value(value: cartCubit),
                        BlocProvider<LocationCubit>.value(value: locationCubit),
                      ],
                      child: BakeryDetailsScreen(bakery: bakery),
                    ),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders the bakery name and one tile per product',
          (tester) async {
        final bakery = buildBakery(productCount: 3);

        await openScreen(tester, bakery);

        expect(find.text('Bakery b1'), findsOneWidget);
        expect(find.byType(ProductListTile), findsNWidgets(3));
        expect(find.text('Item 1'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(find.text('Item 3'), findsOneWidget);
      });

  testWidgets('renders no product tiles for a bakery without products',
          (tester) async {
        final bakery = HomeDataBakeriesModel(
          bakeryModel: fakeBakery('b1', 30, 31),
          productModelList: const [],
        );

        await openScreen(tester, bakery);

        expect(find.text('Bakery b1'), findsOneWidget);
        expect(find.byType(ProductListTile), findsNothing);
      });

  testWidgets('the back button pops the screen', (tester) async {
    final bakery = buildBakery();
    await openScreen(tester, bakery);
    expect(find.byType(BakeryDetailsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();

    expect(find.byType(BakeryDetailsScreen), findsNothing);
  });

  // Deliberately not tapped: the location button opens a dialog containing
  // LocationPickerMap, which wraps FlutterMap and fetches map tiles over the
  // network. The cart button (opens CartScreen) is covered by
  // test/core/cart/cart_screen_test.dart.
}