import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/models/waste_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

void main() {
  late MockWorkerRepo repo;
  late WorkerCubit workerCubit;
  late ExpensesCubit cubit;
  final product = fakeProduct().copyWith(bakeryId: 'b1', productId: 'p1');
  final waste = WasteModel(
    productId: 'p1',
    productName: product.productName,
    meal: 1,
    notSold: 2,
    manufacturing: 0,
    productPrice: product.productPrice,
    date: DateTime.now(),
  );

  setUpAll(() async {
    await setupTestEnvironment();
    registerFallbackValue(
      FinanceModel(
        bakeryId: 'b1',
        date: DateTime.now(),
        cleaningExpenses: 0,
        wastes: const [], branchId: '',
      ),
    );
    registerFallbackValue(waste);
    registerFallbackValue(<WasteModel>[]);
    registerFallbackValue(<ProductModel>[]);
  });

  setUp(() async {
    repo = MockWorkerRepo();
    when(() => repo.getUserData()).thenAnswer(
          (_) async => SuccessResponse<UserModel>(
        UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
      ),
    );
    when(() => repo.checkStaffTable())
        .thenAnswer((_) async => SuccessResponse<StaffModel?>(null));
    when(() => repo.fetchMyShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>?>([]));
    when(() => repo.fetchFinance('b1'))
        .thenAnswer((_) async => SuccessResponse<List<FinanceModel>?>([]));
    when(() => repo.fetchProducts('b1'))
        .thenAnswer((_) async => SuccessResponse<List<ProductModel>?>([product]));
    workerCubit = WorkerCubit(repo);
    await pumpEventQueue();
    workerCubit.products = [product];

    cubit = ExpensesCubit(repo, workerCubit);
  });

  tearDown(() {
    cubit.close();
    workerCubit.close();
  });

  group('save', () {
    test(
        'for a record dated today, adjusts product availability and refreshes both finance and products',
            () async {
          when(
                () => repo.upsertFinancerecord(
              financeRecord: any(named: 'financeRecord'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          when(
                () => repo.adjustAvailabilityForWasteChanges(
              oldWastes: any(named: 'oldWastes'),
              newWastes: any(named: 'newWastes'),
              products: any(named: 'products'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final record = FinanceModel(
            bakeryId: 'b1',
            date: DateTime.now(),
            cleaningExpenses: 0,
            wastes: [waste], branchId: '',
          );
          final baseline = FinanceModel(
            bakeryId: 'b1',
            date: DateTime.now(),
            cleaningExpenses: 0,
            wastes: const [], branchId: '',
          );

          await cubit.save(
            financeRecord: record,
            baselineRecord: baseline,
            bakeryId: 'b1',
          );

          expect(cubit.state, isA<ExpensesInitial>());
          verify(
                () => repo.adjustAvailabilityForWasteChanges(
              oldWastes: const [],
              newWastes: [waste],
              products: [product],
              bakeryId: 'b1',
            ),
          ).called(1);
          verify(() => repo.fetchFinance('b1')).called(1);
          verify(() => repo.fetchProducts('b1')).called(1);
        });

    test(
        'for a record dated in the past, skips availability adjustment and the products refresh',
            () async {
          when(
                () => repo.upsertFinancerecord(
              financeRecord: any(named: 'financeRecord'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final pastDate = DateTime.now().subtract(const Duration(days: 3));
          final record = FinanceModel(
            bakeryId: 'b1',
            date: pastDate,
            cleaningExpenses: 0,
            wastes: [waste], branchId: '',
          );

          await cubit.save(
            financeRecord: record,
            baselineRecord: record,
            bakeryId: 'b1',
          );

          expect(cubit.state, isA<ExpensesInitial>());
          verifyNever(
                () => repo.adjustAvailabilityForWasteChanges(
              oldWastes: any(named: 'oldWastes'),
              newWastes: any(named: 'newWastes'),
              products: any(named: 'products'),
              bakeryId: any(named: 'bakeryId'),
            ),
          );
          verify(() => repo.fetchFinance('b1')).called(1);
          verifyNever(() => repo.fetchProducts('b1'));
        });

    test('surfaces a failure and still settles back to Initial', () async {
      when(
            () => repo.upsertFinancerecord(
          financeRecord: any(named: 'financeRecord'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => FailureResponse<bool>('offline'));
      final record = FinanceModel(
        bakeryId: 'b1',
        date: DateTime.now(),
        cleaningExpenses: 0,
        wastes: const [], branchId: '',
      );
      final states = <ExpensesState>[];
      cubit.stream.listen(states.add);

      await cubit.save(
        financeRecord: record,
        baselineRecord: record,
        bakeryId: 'b1',
      );
      await pumpEventQueue();

      expect(
        states.any((s) => s is ExpensesFailure && s.error == 'offline'),
        true,
      );
      expect(cubit.state, isA<ExpensesInitial>());
    });
  });

  group('deleteMealFromDatabase', () {
    test('success refreshes finance and settles back to Initial', () async {
      when(
            () => repo.deleteMealFromDatabase(
          financeRecord: any(named: 'financeRecord'),
          product: any(named: 'product'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      final record = FinanceModel(
        bakeryId: 'b1',
        date: DateTime.now(),
        cleaningExpenses: 0,
        wastes: [waste], branchId: '',
      );

      await cubit.deleteMealFromDatabase(
        financeRecord: record,
        product: waste,
        bakeryId: 'b1',
      );

      expect(cubit.state, isA<ExpensesInitial>());
      verify(() => repo.fetchFinance('b1')).called(1);
    });

    test('failure surfaces the error and settles back to Initial', () async {
      when(
            () => repo.deleteMealFromDatabase(
          financeRecord: any(named: 'financeRecord'),
          product: any(named: 'product'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => FailureResponse<bool>('offline'));
      final record = FinanceModel(
        bakeryId: 'b1',
        date: DateTime.now(),
        cleaningExpenses: 0,
        wastes: [waste], branchId: '',
      );
      final states = <ExpensesState>[];
      cubit.stream.listen(states.add);

      await cubit.deleteMealFromDatabase(
        financeRecord: record,
        product: waste,
        bakeryId: 'b1',
      );
      await pumpEventQueue();

      expect(
        states.any((s) => s is ExpensesFailure && s.error == 'offline'),
        true,
      );
      expect(cubit.state, isA<ExpensesInitial>());
    });
  });
}