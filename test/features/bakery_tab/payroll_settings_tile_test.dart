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
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/payroll_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class TestSettingsRepo extends SettingsRepo {
  PayrollModel? lastUpdatedPayroll;

  @override
  Future<ResponseResult<bool>> updatePayroll(
      PayrollModel updatedPayroll,
      ) async {
    lastUpdatedPayroll = updatedPayroll;
    return SuccessResponse<bool>(true);
  }
}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late TestSettingsRepo settingsRepo;
  late SettingsCubit settingsCubit;
  late SettingsUpdateCubit settingsUpdateCubit;

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

    final bakery = fakeBakery('owner-1', 30, 31);
    when(() => bakeryRepo.fetchBakery())
        .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
    when(() => bakeryRepo.fetchStorage()).thenAnswer(
          (_) async =>
          SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1', branchId: '')),
    );
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(
          bakeryId: 'owner-1',
          payrollMethod: true,
          supervisor: 100,
          chef: 80, branchId: '',
        ),
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
    settingsUpdateCubit = SettingsUpdateCubit(settingsCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    settingsCubit.close();
    settingsUpdateCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 2000));
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<SettingsUpdateCubit>.value(
                value: settingsUpdateCubit,
              ),
            ],
            child: const PayrollSettingsTile(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows only the roles with a positive rate by default',
          (tester) async {
        await pumpTile(tester);

        expect(find.text('100.00'), findsOneWidget);
        expect(find.text('80.00'), findsOneWidget);
        // Roles with no rate (e.g. baker/"faran") stay hidden outside edit mode.
        expect(find.text('0.00'), findsNothing);
      });

  testWidgets('editing mode reveals every role, including zero-rate ones',
          (tester) async {
        await pumpTile(tester);

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(settingsCubit.isPayrollEditing, true);
        expect(find.text('0.00'), findsWidgets);
      });

  testWidgets('editing a rate calls postNewRate and updates the display',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.text('100.00'));
        await tester.pumpAndSettle();

        expect(find.byType(TextFormField), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), '150');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(settingsCubit.editablePayroll?.supervisor, 150);
        expect(find.text('150.00'), findsOneWidget);
      });

  testWidgets('confirming saves through the repo', (tester) async {
    await pumpTile(tester);
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('100.00'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '150');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    // The header check confirms and persists the whole edited payroll.
    await tester.tap(find.byIcon(Icons.done).first);
    await tester.pumpAndSettle();

    expect(settingsRepo.lastUpdatedPayroll?.supervisor, 150);
  });
}