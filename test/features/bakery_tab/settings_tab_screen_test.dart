import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/settings_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class TestSettingsRepo extends SettingsRepo {
  BakeryModel? lastUpdatedBakery;

  @override
  Future<ResponseResult<bool>> updateBakeryData(
      BakeryModel updatedBakeryData,
      ) async {
    lastUpdatedBakery = updatedBakeryData;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> changeBakeryData({
    required BakeryModel updatedBakery,
  }) async {
    lastUpdatedBakery = updatedBakery;
    return SuccessResponse<bool>(true);
  }
}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late TestSettingsRepo settingsRepo;
  late SettingsCubit settingsCubit;
  late BakeryModel bakery;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    bakeryRepo = MockBakeryTabRepo();
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());

    bakery = fakeBakery('owner-1', 30, 31);
    when(() => bakeryRepo.fetchBakery())
        .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
    when(() => bakeryRepo.fetchStorage()).thenAnswer(
          (_) async =>
          SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1', branchId: '')),
    );
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(bakeryId: 'owner-1', payrollMethod: true, branchId: ''),
      ),
    );
    when(() => bakeryRepo.fetchProducts())
        .thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
    when(() => bakeryRepo.fetchSales())
        .thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
    when(() => bakeryRepo.fetchFinance())
        .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
    when(() => bakeryRepo.fetchShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(() => bakeryRepo.fetchStaff())
        .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));

    bakeryTabCubit = BakeryTabCubit(
      bakeryRepo,
      locationCubit,
      currentUserId: () => 'owner-1',
    );
    await pumpEventQueue();

    settingsRepo = TestSettingsRepo();
    settingsCubit = SettingsCubit(settingsRepo, bakeryTabCubit);

    if (GetIt.instance.isRegistered<SettingsCubit>()) {
      GetIt.instance.unregister<SettingsCubit>();
    }
    GetIt.instance.registerLazySingleton<SettingsCubit>(() => settingsCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    settingsCubit.close();
    GetIt.instance.unregister<SettingsCubit>();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 3000));
    await pumpLocalizedWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<BakeryTabCubit>.value(value: bakeryTabCubit),
          BlocProvider<LocationCubit>.value(value: locationCubit),
        ],
        child: const SettingsTabScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder nameEditIcon(String name) {
    final ancestors = find
        .ancestor(
      of: find.text(name),
      matching: find.byWidgetPredicate((_) => true),
    )
        .evaluate()
        .toList();
    for (final element in ancestors) {
      final icons = find.descendant(
        of: find.byElementPredicate((e) => identical(e, element)),
        matching: find.byIcon(Icons.edit),
      );
      if (icons.evaluate().isNotEmpty) return icons.first;
    }
    return find.byIcon(Icons.edit).first;
  }

  testWidgets('renders the bakery name', (tester) async {
    await pumpScreen(tester);

    expect(find.text(bakery.bakeryName), findsOneWidget);
  });

  testWidgets(
      'editing the bakery name calls the repo and reflects the new name',
          (tester) async {
        await pumpScreen(tester);

        await tester.tap(nameEditIcon(bakery.bakeryName));
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsOneWidget);

        final renamedBakery = bakery.copyWith(bakeryName: 'New Bakery Name');
        when(() => bakeryRepo.fetchBakery())
            .thenAnswer((_) async => SuccessResponse<BakeryModel?>(renamedBakery));

        await tester.enterText(find.byType(TextFormField), 'New Bakery Name');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(settingsRepo.lastUpdatedBakery?.bakeryName, 'New Bakery Name');
        expect(find.text('New Bakery Name'), findsOneWidget);
      });

  testWidgets('does not open the location map until the location button is tapped',
          (tester) async {
        await pumpScreen(tester);

        expect(find.text(bakery.bakeryName), findsOneWidget);
      });
}