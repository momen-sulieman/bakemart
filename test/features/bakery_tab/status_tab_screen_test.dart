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
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/status_tab_screen.dart';
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

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late StatusFinanceFilterCubit financeCubit;
  late StatusSalesFilterCubit salesCubit;
  late StatusMealsFilterCubit mealsCubit;
  late StatusShiftsFilterCubit shiftsCubit;

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

    final today = DateTime.now();
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
    when(() => bakeryRepo.fetchSales()).thenAnswer(
          (_) async => SuccessResponse<List<SalesModel>>([
        SalesModel(
          productName: 'Croissant',
          bakeryId: 'owner-1',
          productId: 'p1',
          productPrice: 3.5,
          date: today,
          produced: 40,
          sold: 25,
        ),
      ]),
    );
    when(() => bakeryRepo.fetchFinance()).thenAnswer(
          (_) async => SuccessResponse<List<FinanceModel>>([
        FinanceModel(
          bakeryId: 'owner-1',
          date: today,
          cleaningExpenses: 10,
          payrollExpenses: 5,
          profit: 100,
          wastes: const [],
        ),
      ]),
    );
    when(() => bakeryRepo.fetchShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(() => bakeryRepo.fetchStaff())
        .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));

    when(() => bakeryRepo.filterFinanceRecordsByDate(
      allFinanceRecords: any(named: 'allFinanceRecords'),
      selectedDate: any(named: 'selectedDate'),
    )).thenAnswer((invocation) {
      final records = invocation.namedArguments[#allFinanceRecords]
      as List<FinanceModel>;
      final date = invocation.namedArguments[#selectedDate] as DateTime;
      final match = records.where(
            (r) =>
        r.date?.year == date.year &&
            r.date?.month == date.month &&
            r.date?.day == date.day,
      );
      if (match.isEmpty) return FailureResponse<FinanceModel>('No records');
      return SuccessResponse<FinanceModel>(match.first);
    });
    when(() => bakeryRepo.filterSalesByDate(
      allSales: any(named: 'allSales'),
      selectedDate: any(named: 'selectedDate'),
    )).thenAnswer((invocation) {
      final records =
      invocation.namedArguments[#allSales] as List<SalesModel>;
      final date = invocation.namedArguments[#selectedDate] as DateTime;
      final matches = records
          .where((r) =>
      r.date?.year == date.year &&
          r.date?.month == date.month &&
          r.date?.day == date.day)
          .toList();
      return SuccessResponse<List<SalesModel>>(matches);
    });
    when(() => bakeryRepo.filterShiftsByDate(
      allShifts: any(named: 'allShifts'),
      selectedDate: any(named: 'selectedDate'),
    )).thenAnswer((_) => SuccessResponse<List<ShiftModel>>([]));

    bakeryTabCubit = BakeryTabCubit(
      bakeryRepo,
      locationCubit,
      currentUserId: () => 'owner-1',
    );
    await pumpEventQueue();

    financeCubit = StatusFinanceFilterCubit(bakeryRepo, bakeryTabCubit);
    salesCubit = StatusSalesFilterCubit(bakeryRepo, bakeryTabCubit);
    mealsCubit = StatusMealsFilterCubit(bakeryRepo, bakeryTabCubit);
    shiftsCubit = StatusShiftsFilterCubit(bakeryRepo, bakeryTabCubit);

    if (GetIt.instance.isRegistered<StatusFinanceFilterCubit>()) {
      GetIt.instance.unregister<StatusFinanceFilterCubit>();
    }
    if (GetIt.instance.isRegistered<StatusSalesFilterCubit>()) {
      GetIt.instance.unregister<StatusSalesFilterCubit>();
    }
    if (GetIt.instance.isRegistered<StatusMealsFilterCubit>()) {
      GetIt.instance.unregister<StatusMealsFilterCubit>();
    }
    if (GetIt.instance.isRegistered<StatusShiftsFilterCubit>()) {
      GetIt.instance.unregister<StatusShiftsFilterCubit>();
    }
    GetIt.instance.registerLazySingleton<StatusFinanceFilterCubit>(
          () => financeCubit,
    );
    GetIt.instance
        .registerLazySingleton<StatusSalesFilterCubit>(() => salesCubit);
    GetIt.instance
        .registerLazySingleton<StatusMealsFilterCubit>(() => mealsCubit);
    GetIt.instance
        .registerLazySingleton<StatusShiftsFilterCubit>(() => shiftsCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    financeCubit.close();
    salesCubit.close();
    mealsCubit.close();
    shiftsCubit.close();
    GetIt.instance.unregister<StatusFinanceFilterCubit>();
    GetIt.instance.unregister<StatusSalesFilterCubit>();
    GetIt.instance.unregister<StatusMealsFilterCubit>();
    GetIt.instance.unregister<StatusShiftsFilterCubit>();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 3600));
    await pumpLocalizedWidget(
      tester,
      BlocProvider<BakeryTabCubit>.value(
        value: bakeryTabCubit,
        child: const StatusTabScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all four sections, each expanded by default',
          (tester) async {
        await pumpScreen(tester);

        expect(find.byType(ExpansionTile), findsNWidgets(4));
      });

  testWidgets('shows today\'s finance and sales figures together on one screen',
          (tester) async {
        await pumpScreen(tester);

        expect(find.text('100.00'), findsWidgets); // profit
        expect(find.text('40'), findsOneWidget); // produced
        expect(find.text('25'), findsOneWidget); // sold
      });
}