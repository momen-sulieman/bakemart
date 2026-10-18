import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/models/waste_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

void main() {
  late MockWorkerRepo mockRepo;
  late WorkerCubit workerCubit;
  // filterExpensesByDate, used throughout this cubit, is pure logic with no
  // network call — a real WorkerRepo is simpler and more faithful here than
  // re-stubbing the matching logic on a mock.
  late WorkerRepo realRepo;
  late ExpensesFilterCubit cubit;
  final product = fakeProduct().copyWith(bakeryId: 'b1', productId: 'p1');
  final today = DateTime.now();

  FinanceModel financeFor(DateTime date, {List<WasteModel> wastes = const []}) {
    return FinanceModel(
      bakeryId: 'b1',
      date: date,
      cleaningExpenses: 10,
      wastes: wastes, branchId: '',
    );
  }

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    mockRepo = MockWorkerRepo();
    when(() => mockRepo.getUserData()).thenAnswer(
          (_) async => SuccessResponse<UserModel>(
        UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
      ),
    );
    when(() => mockRepo.checkStaffTable())
        .thenAnswer((_) async => SuccessResponse<StaffModel?>(null));
    when(() => mockRepo.fetchMyShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>?>([]));
    workerCubit = WorkerCubit(mockRepo);
    await pumpEventQueue();

    realRepo = WorkerRepo();
  });

  tearDown(() {
    cubit.close();
    workerCubit.close();
  });

  ExpensesFilterCubit build() {
    final c = ExpensesFilterCubit(realRepo, workerCubit);
    return c;
  }

  test('filter() picks out today\'s record by default', () {
    workerCubit.finance = [
      financeFor(today.subtract(const Duration(days: 1))),
      financeFor(today, wastes: const []).copyWith(cleaningExpenses: 25),
    ];
    cubit = build();

    expect(cubit.currentFilteredExpenses.cleaningExpenses, 25);
  });

  test('falls back to an empty record for the date when none matches', () {
    workerCubit.finance = [financeFor(today.subtract(const Duration(days: 2)))];
    cubit = build();

    expect(cubit.currentFilteredExpenses.cleaningExpenses, 0);
    expect(cubit.currentFilteredExpenses.wastes, isEmpty);
  });

  test('filterByDay re-filters against the new date', () {
    final otherDay = today.subtract(const Duration(days: 1));
    workerCubit.finance = [
      financeFor(today).copyWith(cleaningExpenses: 10),
      financeFor(otherDay).copyWith(cleaningExpenses: 99),
    ];
    cubit = build();

    cubit.filterByDay(otherDay.day);

    expect(cubit.currentFilteredExpenses.cleaningExpenses, 99);
  });

  test('changeSideExpenses updates the editable copy and marks a change', () {
    workerCubit.finance = [financeFor(today)];
    cubit = build();

    cubit.changeSideExpenses(50);

    expect(cubit.editableCurrentFilteredExpenses.cleaningExpenses, 50);
    expect(cubit.updated, true);
    // The baseline is untouched until save() actually persists it.
    expect(cubit.currentFilteredExpenses.cleaningExpenses, 10);
  });

  test('addAProduct appends a waste entry and marks a change', () {
    workerCubit.finance = [financeFor(today)];
    cubit = build();

    cubit.addAProduct(
      product: product,
      mealQuantity: 1,
      notSoldQuantity: 2,
      manufacturingQuantity: 3,
    );

    expect(cubit.editableCurrentFilteredExpenses.wastes, hasLength(1));
    final added = cubit.editableCurrentFilteredExpenses.wastes.single;
    expect(added.productId, 'p1');
    expect(added.meal, 1);
    expect(added.notSold, 2);
    expect(added.manufacturing, 3);
    expect(cubit.updated, true);
  });

  test('editMealQuantity, editNotSoldQuantity and editManufacturingQuantity update the right waste',
          () {
        final waste = WasteModel(
          productId: 'p1',
          productName: product.productName,
          meal: 1,
          notSold: 1,
          manufacturing: 1,
          productPrice: product.productPrice,
          date: today,
        );
        workerCubit.finance = [financeFor(today, wastes: [waste])];
        cubit = build();

        cubit.editMealQuantity(productId: 'p1', newQuantity: 9);
        cubit.editNotSoldQuantity(productId: 'p1', newQuantity: 8);
        cubit.editManufacturingQuantity(productId: 'p1', newQuantity: 7);

        final updated = cubit.editableCurrentFilteredExpenses.wastes.single;
        expect(updated.meal, 9);
        expect(updated.notSold, 8);
        expect(updated.manufacturing, 7);
      });

  test('cancelChanges reverts the editable copy and clears edit mode', () {
    workerCubit.finance = [financeFor(today)];
    cubit = build();
    cubit.changeEditMode();
    cubit.changeSideExpenses(999);
    expect(cubit.editableCurrentFilteredExpenses.cleaningExpenses, 999);

    cubit.cancelChanges();

    expect(cubit.editableCurrentFilteredExpenses.cleaningExpenses, 10);
    expect(cubit.editMode, false);
    expect(cubit.updated, false);
  });
}