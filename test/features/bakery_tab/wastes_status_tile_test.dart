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
import 'package:bakemart/core/shared/models/waste_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/wastes_status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late StatusMealsFilterCubit filterCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  Future<void> setUpWith(
      WidgetTester tester,
      List<FinanceModel> finance,
      ) async {
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
          SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1')),
    );
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(bakeryId: 'owner-1', payrollMethod: true),
      ),
    );
    when(() => bakeryRepo.fetchProducts())
        .thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
    when(() => bakeryRepo.fetchSales())
        .thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
    when(() => bakeryRepo.fetchFinance())
        .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>(finance));
    when(() => bakeryRepo.fetchShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(() => bakeryRepo.fetchStaff())
        .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));
    when(() => bakeryRepo.filterFinanceRecordsByDate(
      allFinanceRecords: any(named: 'allFinanceRecords'),
      selectedDate: any(named: 'selectedDate'),
    )).thenAnswer((invocation) {
      final records =
      invocation.namedArguments[#allFinanceRecords] as List<FinanceModel>;
      final date = invocation.namedArguments[#selectedDate] as DateTime;
      final match = records.where(
            (r) =>
        r.date?.year == date.year &&
            r.date?.month == date.month &&
            r.date?.day == date.day,
      );
      if (match.isEmpty) {
        return FailureResponse<FinanceModel>('No records');
      }
      return SuccessResponse<FinanceModel>(match.first);
    });

    await tester.runAsync(() async {
      bakeryTabCubit = BakeryTabCubit(
        bakeryRepo,
        locationCubit,
        currentUserId: () => 'owner-1',
      );
      await pumpEventQueue();
    });

    filterCubit = StatusMealsFilterCubit(bakeryRepo, bakeryTabCubit);
  }

  tearDown(() {
    bakeryTabCubit.close();
    filterCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: BlocProvider<StatusMealsFilterCubit>.value(
          value: filterCubit,
          child: const WastesStatusTile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows manufacturing, not-sold and meal counts for today',
          (tester) async {
        final today = DateTime.now();
        await setUpWith(tester, [
          FinanceModel(
            bakeryId: 'owner-1',
            date: today,
            cleaningExpenses: 0,
            payrollExpenses: 0,
            profit: 0,
            wastes: [
              WasteModel(
                productId: 'p1',
                productName: 'Croissant',
                meal: 3,
                notSold: 7,
                manufacturing: 2,
                productPrice: 3.5,
                date: today,
              ),
            ],
          ),
        ]);
        await pumpTile(tester);

        expect(find.textContaining('Croissant'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

  testWidgets('shows nothing when there is no record for today',
          (tester) async {
        await setUpWith(tester, [
          FinanceModel(
            bakeryId: 'owner-1',
            date: DateTime.now().subtract(const Duration(days: 2)),
            cleaningExpenses: 0,
            payrollExpenses: 0,
            profit: 0,
            wastes: [
              WasteModel(
                productId: 'p1',
                productName: 'Croissant',
                meal: 3,
                notSold: 7,
                manufacturing: 2,
                productPrice: 3.5,
                date: DateTime.now().subtract(const Duration(days: 2)),
              ),
            ],
          ),
        ]);
        await pumpTile(tester);

        expect(find.textContaining('Croissant'), findsNothing);
      });
}