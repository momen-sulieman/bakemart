import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/cart/data/cart_repo.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/home_tab_screen.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/widgets/bakery_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

class MockCartRepo extends Mock implements CartRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockHomeRepo repo;
  late MockLocationCubit locationCubit;
  late CartCubit cartCubit;
  late ActiveOrdersCubit activeOrdersCubit;

  final user = UserModel(
    firstName: 'Mo',
    secondName: 'Amin',
    email: 'mo@bakemart.com',
    phone: '+201012345678',
  );

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockHomeRepo();
    locationCubit = MockLocationCubit();
    // LocationInitial (not LocationUpdated) so CartCubit's constructor skips
    // its price recalculation, which would call the mocked CartRepo.
    when(() => locationCubit.state).thenAnswer((_) => LocationInitial());
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
    when(() => repo.streamActiveOrders())
        .thenAnswer((_) => const Stream<List<OrderModel>>.empty());

    cartCubit = CartCubit(MockCartRepo(), locationCubit);
    activeOrdersCubit = ActiveOrdersCubit(repo);

    // HomeTabScreen fetches ActiveOrdersCubit straight from GetIt.
    if (GetIt.instance.isRegistered<ActiveOrdersCubit>()) {
      GetIt.instance.unregister<ActiveOrdersCubit>();
    }
    GetIt.instance
        .registerLazySingleton<ActiveOrdersCubit>(() => activeOrdersCubit);
  });

  tearDown(() {
    cartCubit.close();
    activeOrdersCubit.close();
    GetIt.instance.unregister<ActiveOrdersCubit>();
  });

  void stubUser() {
    when(() => repo.getUserData())
        .thenAnswer((_) async => SuccessResponse<UserModel>(user));
  }

  void stubBakeries(List<HomeDataBakeriesModel> bakeries) {
    when(() => repo.getBakeries()).thenAnswer(
          (_) async => SuccessResponse<List<HomeDataBakeriesModel>>(bakeries),
    );
  }

  HomeDataBakeriesModel buildBakery(String id) {
    return HomeDataBakeriesModel(
      bakeryModel: fakeBakery(id, 30, 31),
      productModelList: [fakeProduct(id: 'p-$id', bakeryId: id)],
    );
  }

  HomeDataCubit buildCubit() {
    final cubit = HomeDataCubit(repo, activeOrdersCubit, cartCubit);
    addTearDown(cubit.close);
    return cubit;
  }

  // While loading, the screen shows an infinitely-repeating spinner, so
  // pumpAndSettle can't be used until the cubit leaves HomeDataLoading.
  Future<void> waitForLoad(WidgetTester tester, HomeDataCubit cubit) async {
    for (var i = 0; i < 20 && cubit.state is HomeDataLoading; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> pumpScreen(WidgetTester tester, HomeDataCubit cubit) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<HomeDataCubit>.value(value: cubit),
          BlocProvider<CartCubit>.value(value: cartCubit),
          BlocProvider<LocationCubit>.value(value: locationCubit),
        ],
        child: const HomeTabScreen(),
      ),
      settle: false,
    );
  }

  testWidgets('stays in the loading state while the user data is pending',
          (tester) async {
        final pending = Completer<ResponseResult<UserModel>>();
        when(() => repo.getUserData()).thenAnswer((_) => pending.future);
        final cubit = buildCubit();

        await pumpScreen(tester, cubit);
        await tester.pump(const Duration(milliseconds: 100));

        expect(cubit.state, isA<HomeDataLoading>());
        expect(find.byType(BakeryListTile), findsNothing);
        expect(find.byIcon(Icons.cell_tower), findsNothing);
      });

  testWidgets('lists every nearby bakery once the data loads', (tester) async {
    stubUser();
    stubBakeries([buildBakery('b1'), buildBakery('b2')]);
    final cubit = buildCubit();

    await pumpScreen(tester, cubit);
    await waitForLoad(tester, cubit);
    await tester.pumpAndSettle();

    expect(cubit.state, isA<HomeDataSuccess>());
    expect(find.byType(BakeryListTile), findsNWidgets(2));
    expect(find.text('Bakery b1'), findsOneWidget);
    expect(find.text('Bakery b2'), findsOneWidget);
    verify(() => repo.getBakeries()).called(1);
  });

  testWidgets('shows the empty state with no bakery tiles when none are nearby',
          (tester) async {
        stubUser();
        stubBakeries([]);
        final cubit = buildCubit();

        await pumpScreen(tester, cubit);
        await waitForLoad(tester, cubit);
        await tester.pumpAndSettle();

        expect(find.byType(BakeryListTile), findsNothing);
        expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
      });

  testWidgets('shows the offline state on failure and retries when tapped',
          (tester) async {
        when(() => repo.getUserData())
            .thenAnswer((_) async => FailureResponse<UserModel>('offline'));
        final cubit = buildCubit();

        await pumpScreen(tester, cubit);
        await waitForLoad(tester, cubit);
        await tester.pumpAndSettle();

        expect(cubit.state, isA<HomeDataFailure>());
        expect(find.byIcon(Icons.cell_tower), findsOneWidget);

        stubUser();
        stubBakeries([buildBakery('b1')]);
        await tester.tap(find.byIcon(Icons.cell_tower));
        await waitForLoad(tester, cubit);
        await tester.pumpAndSettle();

        expect(cubit.state, isA<HomeDataSuccess>());
        expect(find.byType(BakeryListTile), findsOneWidget);
        expect(find.byIcon(Icons.cell_tower), findsNothing);
      });
}