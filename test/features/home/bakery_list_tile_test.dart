import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/widgets/bakery_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockLocationCubit locationCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());
  });

  HomeDataBakeriesModel buildBakery() {
    return HomeDataBakeriesModel(
      bakeryModel: fakeBakery('b1', 30, 31),
      productModelList: [
        fakeProduct(id: 'p1', bakeryId: 'b1'),
        fakeProduct(id: 'p2', bakeryId: 'b1'),
      ],
    );
  }

  Future<RouteRecorder> pumpTile(
      WidgetTester tester,
      HomeDataBakeriesModel bakery,
      ) async {
    useTallSurface(tester);
    final observer = RouteRecorder();
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<LocationCubit>.value(
          value: locationCubit,
          child: BakeryListTile(bakery: bakery),
        ),
      ),
      observers: [observer],
    );
    await tester.pumpAndSettle();
    return observer;
  }

  testWidgets('renders the bakery name and its computed rating',
          (tester) async {
        final bakery = buildBakery();
        await pumpTile(tester, bakery);

        expect(find.text(bakery.bakeryModel.bakeryName), findsOneWidget);
        expect(find.text(bakery.bakeryRate.toString()), findsOneWidget);
      });

  testWidgets('tapping the tile pushes a route carrying the bakery as an argument',
          (tester) async {
        final bakery = buildBakery();
        final observer = await pumpTile(tester, bakery);

        await tester.tap(find.text(bakery.bakeryModel.bakeryName));
        await tester.pumpAndSettle();

        expect(observer.pushed, hasLength(1));
        expect(observer.pushed.single.arguments, same(bakery));
      });

  testWidgets('does not navigate when the location pin is tapped instead',
          (tester) async {
        final bakery = buildBakery();
        final observer = await pumpTile(tester, bakery);

        await tester.tap(find.byIcon(Icons.location_pin));
        await tester.pump();

        expect(observer.pushed.where((route) => route.arguments != null), isEmpty);
      });
}