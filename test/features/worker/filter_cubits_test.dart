import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/history_filter_cubit/history_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockBakeryTabCubit extends Mock implements BakeryTabCubit {}

class MockWorkerRepo extends Mock implements WorkerRepo {}

class MockWorkerCubit extends Mock implements WorkerCubit {}

void main() {
  setUpAll(() async {
    registerFallbackValue(fakePayroll());
    registerFallbackValue(<String>['fallback']);
    registerFallbackValue(<int>[0]);
    await setupTestEnvironment();
  });
  group('StatusFinanceFilterCubit', () {
    late MockBakeryTabRepo repo;
    late MockBakeryTabCubit bakeryTabCubit;
    late StreamController<BakeryTabState> bakeryStream;

    setUp(() {
      repo = MockBakeryTabRepo();
      bakeryTabCubit = MockBakeryTabCubit();
      bakeryStream = StreamController<BakeryTabState>.broadcast();
      when(() => bakeryTabCubit.stream).thenAnswer((_) => bakeryStream.stream);
      when(() => bakeryTabCubit.finance).thenAnswer((_) => [fakeFinance()]);
    });

    tearDown(() => bakeryStream.close());

    test('filters on creation using the current bakery finance', () async {
      when(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel>(fakeFinance(bakeryId: 'match')));
      final cubit = StatusFinanceFilterCubit(repo, bakeryTabCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state, isA<StatusFinanceFilterSuccess>());
      expect(cubit.filteredFinanceRecord.bakeryId, 'match');
    });

    test('refilters whenever the bakery tab cubit emits', () async {
      when(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel>(fakeFinance()));
      final cubit = StatusFinanceFilterCubit(repo, bakeryTabCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      bakeryStream.add(HasBakery());
      await pumpEventQueue();

      verify(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).called(2);
    });

    test('changeSelectedDate clamps to the last day of a shorter month', () {
      when(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel>(fakeFinance()));
      final cubit = StatusFinanceFilterCubit(repo, bakeryTabCubit);
      addTearDown(cubit.close);

      cubit.changeSelectedDate(month: 2, day: 31);

      expect(cubit.selectedDate.month, 2);
      expect(cubit.selectedDate.day, lessThanOrEqualTo(29));
    });

    test('emits failure when the repo fails', () async {
      when(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(FailureResponse<FinanceModel>('none'));
      final cubit = StatusFinanceFilterCubit(repo, bakeryTabCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state, isA<StatusFinanceFilterFialure>());
    });
  });

  group('StatusMealsFilterCubit', () {
    test('mirrors StatusFinanceFilterCubit behavior', () async {
      final repo = MockBakeryTabRepo();
      final bakeryTabCubit = MockBakeryTabCubit();
      final bakeryStream = StreamController<BakeryTabState>.broadcast();
      when(() => bakeryTabCubit.stream).thenAnswer((_) => bakeryStream.stream);
      when(() => bakeryTabCubit.finance).thenAnswer((_) => [fakeFinance()]);
      when(
            () => repo.filterFinanceRecordsByDate(
          allFinanceRecords: any(named: 'allFinanceRecords'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel>(fakeFinance()));

      final cubit = StatusMealsFilterCubit(repo, bakeryTabCubit);
      addTearDown(() {
        cubit.close();
        bakeryStream.close();
      });
      await pumpEventQueue();

      expect(cubit.state, isA<StatusMealsFilterSuccess>());
    });
  });

  group('StatusSalesFilterCubit', () {
    test('filters sales for the bakery on creation', () async {
      final repo = MockBakeryTabRepo();
      final bakeryTabCubit = MockBakeryTabCubit();
      final bakeryStream = StreamController<BakeryTabState>.broadcast();
      when(() => bakeryTabCubit.stream).thenAnswer((_) => bakeryStream.stream);
      when(() => bakeryTabCubit.sales).thenAnswer((_) => []);
      when(
            () => repo.filterSalesByDate(
          allSales: any(named: 'allSales'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<List<SalesModel>>([]));

      final cubit = StatusSalesFilterCubit(repo, bakeryTabCubit);
      addTearDown(() {
        cubit.close();
        bakeryStream.close();
      });
      await pumpEventQueue();

      expect(cubit.state, isA<StatusSalesFilterSuccess>());
    });
  });

  group('StatusShiftsFilterCubit', () {
    test('filters shifts for the bakery on creation', () async {
      final repo = MockBakeryTabRepo();
      final bakeryTabCubit = MockBakeryTabCubit();
      final bakeryStream = StreamController<BakeryTabState>.broadcast();
      when(() => bakeryTabCubit.stream).thenAnswer((_) => bakeryStream.stream);
      when(() => bakeryTabCubit.shifts).thenAnswer((_) => [fakeShift()]);
      when(
            () => repo.filterShiftsByDate(
          allShifts: any(named: 'allShifts'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<List<ShiftModel>>([fakeShift()]));

      final cubit = StatusShiftsFilterCubit(repo, bakeryTabCubit);
      addTearDown(() {
        cubit.close();
        bakeryStream.close();
      });
      await pumpEventQueue();

      expect(cubit.state, isA<StatusShiftsFilterSuccess>());
      expect(cubit.filteredShifts, hasLength(1));
    });
  });

  group('ExpensesFilterCubit', () {
    late MockWorkerRepo repo;
    late MockWorkerCubit workerCubit;
    late StreamController<WorkerState> workerStream;

    setUp(() {
      repo = MockWorkerRepo();
      workerCubit = MockWorkerCubit();
      workerStream = StreamController<WorkerState>.broadcast();
      when(() => workerCubit.stream).thenAnswer((_) => workerStream.stream);
      when(() => workerCubit.finance).thenAnswer((_) => [fakeFinance()]);
    });

    tearDown(() => workerStream.close());

    test('starts with the filtered expenses for today', () async {
      when(
            () => repo.filterExpensesByDate(
          allExpenses: any(named: 'allExpenses'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel?>(fakeFinance(bakeryId: 'x')));
      final cubit = ExpensesFilterCubit(repo, workerCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.currentFilteredExpenses.bakeryId, 'x');
    });

    test('falls back to an empty record for the day when nothing matches',
            () async {
          when(
                () => repo.filterExpensesByDate(
              allExpenses: any(named: 'allExpenses'),
              selectedDate: any(named: 'selectedDate'),
            ),
          ).thenReturn(FailureResponse<FinanceModel?>('none'));
          final cubit = ExpensesFilterCubit(repo, workerCubit);
          addTearDown(cubit.close);
          await pumpEventQueue();

          expect(cubit.currentFilteredExpenses.wastes, isEmpty);
          expect(cubit.currentFilteredExpenses.cleaningExpenses, 0);
        });

    test('does not refilter while in edit mode', () async {
      when(
            () => repo.filterExpensesByDate(
          allExpenses: any(named: 'allExpenses'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<FinanceModel?>(fakeFinance()));
      final cubit = ExpensesFilterCubit(repo, workerCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();
      cubit.changeEditMode();

      workerStream.add(WorkerLoading());
      await pumpEventQueue();

      verify(
            () => repo.filterExpensesByDate(
          allExpenses: any(named: 'allExpenses'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).called(1);
    });

    test('changeSideExpenses updates the editable copy and marks a change',
            () async {
          when(
                () => repo.filterExpensesByDate(
              allExpenses: any(named: 'allExpenses'),
              selectedDate: any(named: 'selectedDate'),
            ),
          ).thenReturn(SuccessResponse<FinanceModel?>(fakeFinance()));
          final cubit = ExpensesFilterCubit(repo, workerCubit);
          addTearDown(cubit.close);
          await pumpEventQueue();

          cubit.changeSideExpenses(15);

          expect(cubit.editableCurrentFilteredExpenses.cleaningExpenses, 15);
          expect(cubit.updated, true);
        });

    test('addAProduct then removeAProduct keeps the update flag correct',
            () async {
          when(
                () => repo.filterExpensesByDate(
              allExpenses: any(named: 'allExpenses'),
              selectedDate: any(named: 'selectedDate'),
            ),
          ).thenReturn(SuccessResponse<FinanceModel?>(fakeFinance()));
          final cubit = ExpensesFilterCubit(repo, workerCubit);
          addTearDown(cubit.close);
          await pumpEventQueue();

          cubit.addAProduct(
            product: fakeProduct(id: 'p1'),
            mealQuantity: 1,
            notSoldQuantity: 0,
            manufacturingQuantity: 0,
          );
          expect(cubit.editableCurrentFilteredExpenses.wastes, hasLength(1));
          expect(cubit.updated, true);

          cubit.removeAProduct(targetProductId: 'p1');
          expect(cubit.editableCurrentFilteredExpenses.wastes, isEmpty);
        });

    test('editMealQuantity updates the matching waste entry', () async {
      when(
            () => repo.filterExpensesByDate(
          allExpenses: any(named: 'allExpenses'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(
        SuccessResponse<FinanceModel?>(
          fakeFinance(wastes: [fakeWaste(productId: 'p1', meal: 2)]),
        ),
      );
      final cubit = ExpensesFilterCubit(repo, workerCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.editMealQuantity(productId: 'p1', newQuantity: 9);

      expect(cubit.editableCurrentFilteredExpenses.wastes.single.meal, 9);
    });
  });

  group('ShiftsFilterCubit', () {
    late MockWorkerRepo repo;
    late MockWorkerCubit workerCubit;
    late StreamController<WorkerState> workerStream;

    setUp(() {
      repo = MockWorkerRepo();
      workerCubit = MockWorkerCubit();
      workerStream = StreamController<WorkerState>.broadcast();
      when(() => workerCubit.stream).thenAnswer((_) => workerStream.stream);
      when(() => workerCubit.state).thenAnswer((_) => WorkerLoading());
      when(() => workerCubit.shifts).thenAnswer((_) => [fakeShift()]);
      when(() => workerCubit.payroll).thenAnswer((_) => fakePayroll(chef: 10));
      when(() => workerCubit.payrollMethod).thenAnswer((_) => true);
      when(
            () => repo.filterShiftsByDate(
          allShifts: any(named: 'allShifts'),
          selectedDate: any(named: 'selectedDate'),
        ),
      ).thenReturn(SuccessResponse<List<ShiftModel>>([fakeShift(workerId: 'w1')]));
    });

    tearDown(() => workerStream.close());

    test('filters on creation', () async {
      final cubit = ShiftsFilterCubit(repo, workerCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.currentFilteredShifts, hasLength(1));
    });

    test('removeWorker drops the matching shift', () async {
      final cubit = ShiftsFilterCubit(repo, workerCubit);
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.removeWorker(targetWorkerId: 'w1');

      expect(cubit.editableCurrentFilteredShifts, isEmpty);
      expect(cubit.updated, true);
    });

    test('addRoleToWorker recalculates the wage for the combined roles',
            () async {
          final cubit = ShiftsFilterCubit(repo, workerCubit);
          addTearDown(cubit.close);
          await pumpEventQueue();
          when(
                () => repo.calculateWage(
              roles: any(named: 'roles'),
              numberOfBatches: any(named: 'numberOfBatches'),
              payroll: any(named: 'payroll'),
            ),
          ).thenReturn(999);

          cubit.addRoleToWorker(
            targetWorkerId: 'w1',
            newRole: 'faran',
            newNumberOfBatches: 2,
            payroll: fakePayroll(chef: 10),
          );

          final updated = cubit.editableCurrentFilteredShifts.first;
          expect(updated.role, contains('faran'));
          expect(updated.wage, 999);
        });

    test('editShiftOfDailyPayment sets the wage from the payroll rate',
            () async {
          final cubit = ShiftsFilterCubit(repo, workerCubit);
          addTearDown(cubit.close);
          await pumpEventQueue();

          cubit.editShiftOfDailyPayment(index: 0, role: 'chef', rate: 2);

          expect(cubit.wage, 20);
          expect(cubit.editableCurrentFilteredShifts[0].wage, 20);
          expect(cubit.editableCurrentFilteredShifts[0].rate, 2);
        });
  });

  group('HistoryFilterCubit', () {
    test('filters the current worker shifts by month and year', () async {
      final repo = MockWorkerRepo();
      final now = DateTime.now();
      final match = fakeShift(date: DateTime(now.year, now.month, 5));
      final other = fakeShift(date: DateTime(now.year, now.month == 1 ? 2 : 1, 5));
      when(() => repo.fetchMyShifts()).thenAnswer(
            (_) async => SuccessResponse<List<ShiftModel>?>([match, other]),
      );

      final cubit = HistoryFilterCubit(repo);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state, isA<HistoryFilterSuccess>());
      expect(cubit.filteredShifts, [match]);
    });

    test('emits a failure when the fetch fails', () async {
      final repo = MockWorkerRepo();
      when(() => repo.fetchMyShifts()).thenAnswer(
            (_) async => FailureResponse<List<ShiftModel>?>('offline'),
      );

      final cubit = HistoryFilterCubit(repo);
      addTearDown(cubit.close);
      await pumpEventQueue();

      expect(cubit.state, isA<HistoryFilterFailure>());
    });
  });
}