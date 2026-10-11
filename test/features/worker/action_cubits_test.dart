import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/window_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

class MockWorkerCubit extends Mock implements WorkerCubit {}

void main() {
  setUpAll(() async {
    registerFallbackValue(fakeOrder());
    registerFallbackValue(fakeFinance());
    registerFallbackValue(fakeWaste());
    registerFallbackValue(<ShiftModel>[]);
    registerFallbackValue(fakeShift());
    registerFallbackValue(fakeProduct());
    registerFallbackValue(<ProductModel>[]);
    registerFallbackValue(StorageModel(bakeryId: 'fallback'));
    registerFallbackValue(fakePayroll());
    registerFallbackValue(DateTime(2026, 1, 1));
    await setupTestEnvironment();
  });

  group('DeliverySalesCubit', () {
    late MockWorkerRepo repo;

    setUp(() => repo = MockWorkerRepo());

    DeliverySalesCubit build() {
      final cubit = DeliverySalesCubit(repo);
      addTearDown(cubit.close);
      return cubit;
    }

    OrderModel orderWith(String id, {int qty = 2, double price = 10}) {
      return fakeOrder().copyWith(
        orderId: id,
        orderedProducts: [
          fakeProduct(
            id: '$id-p',
            overrides: {ProductsTableColumns.productPrice: price},
          ),
        ],
        orderedQuantities: [qty],
      );
    }

    test('scanOrders loads and totals the orders', () async {
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([
          orderWith('o1'),
          orderWith('o2', qty: 1, price: 5),
        ]),
      );
      final cubit = build();

      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      expect(cubit.state, isA<Success>());
      expect(cubit.total, 25);
      expect(cubit.editableOrders, hasLength(2));
    });

    test('removeOrder drops the order and recalculates the total', () async {
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([
          orderWith('o1'),
          orderWith('o2', qty: 1, price: 5),
        ]),
      );
      final cubit = build();
      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      cubit.removeOrder(order: orderWith('o1'));

      expect(cubit.editableOrders.map((o) => o.orderId), ['o2']);
      expect(cubit.total, 5);
      expect(cubit.listUpdated, true);
    });

    test('increaseQuantity and decreaseQuantity adjust the total', () async {
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([orderWith('o1')]),
      );
      final cubit = build();
      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

      cubit.increaseQuantity(order: orderWith('o1'), productIndex: 0);
      expect(cubit.total, 30);

      cubit.decreaseQuantity(order: orderWith('o1'), productIndex: 0);
      expect(cubit.total, 20);
    });

    test('reset restores the scanned list and clears listUpdated', () async {
      when(
            () => repo.fetchAllOrdersOfThisDeliveryMan(
          deliveryManId: any(named: 'deliveryManId'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer(
            (_) async => SuccessResponse<List<OrderModel>>([orderWith('o1')]),
      );
      final cubit = build();
      await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');
      cubit.removeOrder(order: orderWith('o1'));

      cubit.reset();

      expect(cubit.editableOrders, hasLength(1));
      expect(cubit.listUpdated, false);
    });

    test('handAllOrders hands off each order and removes the successful ones',
            () async {
          when(
                () => repo.fetchAllOrdersOfThisDeliveryMan(
              deliveryManId: any(named: 'deliveryManId'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer(
                (_) async => SuccessResponse<List<OrderModel>>([
              orderWith('o1'),
              orderWith('o2'),
            ]),
          );
          when(
                () => repo.updateOrderInDatabase(
              order: any(named: 'order'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((invocation) async {
            final order = invocation.namedArguments[#order] as OrderModel;
            return order.orderId == 'o1'
                ? SuccessResponse<bool>(true)
                : FailureResponse<bool>('failed');
          });
          final cubit = build();
          await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');

          final allSucceeded = await cubit.handAllOrders(
            orders: [orderWith('o1'), orderWith('o2')],
            bakeryId: 'b1',
          );

          expect(allSucceeded, false);
          expect(cubit.editableOrders.map((o) => o.orderId), ['o2']);
        });
  });

  group('ExpensesCubit', () {
    late MockWorkerRepo repo;
    late MockWorkerCubit workerCubit;

    setUp(() {
      repo = MockWorkerRepo();
      workerCubit = MockWorkerCubit();
      when(() => workerCubit.updateFinance(any())).thenAnswer((_) async {});
      when(() => workerCubit.updateProducts(any())).thenAnswer((_) async {});
      when(() => workerCubit.products).thenAnswer((_) => [fakeProduct(id: 'p1')]);
    });

    test('save adjusts availability for today and updates finance', () async {
      final today = fakeFinance(date: DateTime.now());
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
      final cubit = ExpensesCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <ExpensesState>[];
      cubit.stream.listen(states.add);

      await cubit.save(
        financeRecord: today,
        baselineRecord: fakeFinance(),
        bakeryId: 'b1',
      );
      await pumpEventQueue();

      expect(states, [isA<ExpensesLoading>(), isA<ExpensesSuccess>(), isA<ExpensesInitial>()]);
      verify(
            () => repo.adjustAvailabilityForWasteChanges(
          oldWastes: any(named: 'oldWastes'),
          newWastes: any(named: 'newWastes'),
          products: any(named: 'products'),
          bakeryId: 'b1',
        ),
      ).called(1);
    });

    test('save skips the availability adjustment for a non-today record',
            () async {
          when(
                () => repo.upsertFinancerecord(
              financeRecord: any(named: 'financeRecord'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final cubit = ExpensesCubit(repo, workerCubit);
          addTearDown(cubit.close);

          await cubit.save(
            financeRecord: fakeFinance(date: DateTime(2020, 1, 1)),
            baselineRecord: fakeFinance(),
            bakeryId: 'b1',
          );

          verifyNever(
                () => repo.adjustAvailabilityForWasteChanges(
              oldWastes: any(named: 'oldWastes'),
              newWastes: any(named: 'newWastes'),
              products: any(named: 'products'),
              bakeryId: any(named: 'bakeryId'),
            ),
          );
        });

    test('save emits a failure on repo error', () async {
      when(
            () => repo.upsertFinancerecord(
          financeRecord: any(named: 'financeRecord'),
          bakeryId: any(named: 'bakeryId'),
        ),
      ).thenAnswer((_) async => FailureResponse<bool>('denied'));
      final cubit = ExpensesCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <ExpensesState>[];
      cubit.stream.listen(states.add);

      await cubit.save(
        financeRecord: fakeFinance(),
        baselineRecord: fakeFinance(),
        bakeryId: 'b1',
      );
      await pumpEventQueue();

      expect(states, [isA<ExpensesLoading>(), isA<ExpensesFailure>(), isA<ExpensesInitial>()]);
    });

    test('deleteMealFromDatabase reports success then failure paths',
            () async {
          when(
                () => repo.deleteMealFromDatabase(
              financeRecord: any(named: 'financeRecord'),
              product: any(named: 'product'),
              bakeryId: any(named: 'bakeryId'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final cubit = ExpensesCubit(repo, workerCubit);
          addTearDown(cubit.close);
          final states = <ExpensesState>[];
          cubit.stream.listen(states.add);

          await cubit.deleteMealFromDatabase(
            financeRecord: fakeFinance(),
            product: fakeWaste(),
            bakeryId: 'b1',
          );
          await pumpEventQueue();

          expect(states, [isA<ExpensesLoading>(), isA<ExpensesSuccess>(), isA<ExpensesInitial>()]);
        });
  });

  group('ProductionCubit', () {
    late MockWorkerRepo repo;
    late MockWorkerCubit workerCubit;

    setUp(() {
      repo = MockWorkerRepo();
      workerCubit = MockWorkerCubit();
      when(() => workerCubit.updateProducts(any())).thenAnswer((_) async {});
      when(() => workerCubit.updateShifts(any())).thenAnswer((_) async {});
      when(() => workerCubit.updateFinance(any())).thenAnswer((_) async {});
      when(() => workerCubit.payrollMethod).thenAnswer((_) => true);
    });

    test('addWorkerToWorkersSheet updates form validity with daily payroll',
            () async {
          final cubit = ProductionCubit(repo, workerCubit);
          addTearDown(cubit.close);
          cubit.setInputValidity(true);

          cubit.addWorkerToWorkersSheet(newWorker: fakeShift());

          expect(cubit.formValidity, true);
        });

    test('postProduction fails cleanly when the sales update fails',
            () async {
          when(
                () => repo.produce(
              batchCounter: any(named: 'batchCounter'),
              manufacturingWasteCounter: any(named: 'manufacturingWasteCounter'),
              product: any(named: 'product'),
              currentStorage: any(named: 'currentStorage'),
            ),
          ).thenAnswer((_) async => FailureResponse<bool>('storage error'));
          final cubit = ProductionCubit(repo, workerCubit);
          addTearDown(cubit.close);

          await cubit.postProduction(
            batchCounter: 2,
            manufacturingWasteCounter: 0,
            product: fakeProduct(),
            currentStorage: StorageModel(bakeryId: 'b1'),
          );

          expect(cubit.state, isA<ProductionInitial>());
          verifyNever(() => workerCubit.updateProducts(any()));
        });

    test('postProduction with hourly payroll skips shifts and expenses',
            () async {
          when(() => workerCubit.payrollMethod).thenAnswer((_) => true);
          when(
                () => repo.produce(
              batchCounter: any(named: 'batchCounter'),
              manufacturingWasteCounter: any(named: 'manufacturingWasteCounter'),
              product: any(named: 'product'),
              currentStorage: any(named: 'currentStorage'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final cubit = ProductionCubit(repo, workerCubit);
          addTearDown(cubit.close);

          await cubit.postProduction(
            batchCounter: 2,
            manufacturingWasteCounter: 0,
            product: fakeProduct(),
            currentStorage: StorageModel(bakeryId: 'b1'),
          );

          verify(() => workerCubit.updateProducts(any())).called(1);
          verifyNever(() => repo.upsertShiftsTable(shiftTable: any(named: 'shiftTable')));
        });

    test('postProduction with daily payroll posts shifts and expenses',
            () async {
          when(() => workerCubit.payrollMethod).thenAnswer((_) => false);
          when(() => workerCubit.shifts).thenAnswer((_) => []);
          when(() => workerCubit.payroll).thenAnswer((_) => fakePayroll());
          when(
                () => repo.produce(
              batchCounter: any(named: 'batchCounter'),
              manufacturingWasteCounter: any(named: 'manufacturingWasteCounter'),
              product: any(named: 'product'),
              currentStorage: any(named: 'currentStorage'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          when(
                () => repo.mergeShifts(
              existingShifts: any(named: 'existingShifts'),
              newBatchShift: any(named: 'newBatchShift'),
              payroll: any(named: 'payroll'),
            ),
          ).thenReturn([fakeShift(wage: 20)]);
          when(
                () => repo.upsertShiftsTable(shiftTable: any(named: 'shiftTable')),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          when(
                () => repo.postPayrollExpenses(
              bakeryId: any(named: 'bakeryId'),
              payrollExpenses: any(named: 'payrollExpenses'),
              date: any(named: 'date'),
            ),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final cubit = ProductionCubit(repo, workerCubit);
          addTearDown(cubit.close);

          await cubit.postProduction(
            batchCounter: 2,
            manufacturingWasteCounter: 0,
            product: fakeProduct(),
            currentStorage: StorageModel(bakeryId: 'b1'),
          );

          verify(() => repo.upsertShiftsTable(shiftTable: any(named: 'shiftTable'))).called(1);
          verify(
                () => repo.postPayrollExpenses(
              bakeryId: any(named: 'bakeryId'),
              payrollExpenses: 20,
              date: any(named: 'date'),
            ),
          ).called(1);
          verify(() => workerCubit.updateFinance(any())).called(1);
        });
  });

  group('ShiftsCubit', () {
    late MockWorkerRepo repo;
    late MockWorkerCubit workerCubit;

    setUp(() {
      repo = MockWorkerRepo();
      workerCubit = MockWorkerCubit();
      when(() => workerCubit.bakery).thenAnswer((_) => fakeBakery('b1', 0, 0));
      when(() => workerCubit.updateShifts(any())).thenAnswer((_) async {});
      when(() => workerCubit.updateFinance(any())).thenAnswer((_) async {});
    });

    test('save posts shifts then payroll expenses', () async {
      when(
            () => repo.upsertShiftsTable(shiftTable: any(named: 'shiftTable')),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      when(
            () => repo.postPayrollExpenses(
          bakeryId: any(named: 'bakeryId'),
          payrollExpenses: any(named: 'payrollExpenses'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      final cubit = ShiftsCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <ShiftsState>[];
      cubit.stream.listen(states.add);

      await cubit.save(
        shiftTable: [fakeShift(wage: 20), fakeShift(workerId: 'w2', wage: 10)],
        date: DateTime.now(),
      );
      await pumpEventQueue();

      expect(states, [isA<ShiftsLoading>(), isA<ShiftsSuccess>(), isA<ShiftsInitial>()]);
      verify(
            () => repo.postPayrollExpenses(
          bakeryId: 'b1',
          payrollExpenses: 30,
          date: any(named: 'date'),
        ),
      ).called(1);
    });

    test('save reports a shifts error without posting expenses', () async {
      when(
            () => repo.upsertShiftsTable(shiftTable: any(named: 'shiftTable')),
      ).thenAnswer((_) async => FailureResponse<bool>('denied'));
      final cubit = ShiftsCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <ShiftsState>[];
      cubit.stream.listen(states.add);

      await cubit.save(shiftTable: [fakeShift()], date: DateTime.now());
      await pumpEventQueue();

      expect(states, [isA<ShiftsLoading>(), isA<ShiftsFailure>(), isA<ShiftsInitial>()]);
      verifyNever(
            () => repo.postPayrollExpenses(
          bakeryId: any(named: 'bakeryId'),
          payrollExpenses: any(named: 'payrollExpenses'),
          date: any(named: 'date'),
        ),
      );
    });

    test('deleteWorker tags the loading state and reloads on success',
            () async {
          when(
                () => repo.deleteShift(worker: any(named: 'worker')),
          ).thenAnswer((_) async => SuccessResponse<bool>(true));
          final cubit = ShiftsCubit(repo, workerCubit);
          addTearDown(cubit.close);
          final states = <ShiftsState>[];
          cubit.stream.listen(states.add);

          await cubit.deleteWorker(worker: fakeShift(workerId: 'w1'));
          await pumpEventQueue();

          final loading = states.first as ShiftsLoading;
          expect(loading.targetId, 'w1');
          expect(loading.action, ShiftsAction.deleteWorker);
          verify(() => workerCubit.updateShifts('b1')).called(1);
        });
  });

  group('WindowSalesCubit', () {
    test('sell reloads products on success', () async {
      final repo = MockWorkerRepo();
      final workerCubit = MockWorkerCubit();
      when(() => workerCubit.updateProducts(any())).thenAnswer((_) async {});
      when(
            () => repo.windowSell(
          soldQuantity: any(named: 'soldQuantity'),
          notSoldQuantity: any(named: 'notSoldQuantity'),
          mealWaste: any(named: 'mealWaste'),
          product: any(named: 'product'),
        ),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      final cubit = WindowSalesCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <WindowSalesState>[];
      cubit.stream.listen(states.add);

      await cubit.sell(soldQuantity: 3, product: fakeProduct(bakeryId: 'b1'));
      await pumpEventQueue();

      expect(states, [isA<WindowSalesLoading>(), isA<WindowSalesSuccess>(), isA<WindowSalesInitial>()]);
      verify(() => workerCubit.updateProducts('b1')).called(1);
    });

    test('sell emits a failure on repo error', () async {
      final repo = MockWorkerRepo();
      final workerCubit = MockWorkerCubit();
      when(
            () => repo.windowSell(
          soldQuantity: any(named: 'soldQuantity'),
          notSoldQuantity: any(named: 'notSoldQuantity'),
          mealWaste: any(named: 'mealWaste'),
          product: any(named: 'product'),
        ),
      ).thenAnswer((_) async => FailureResponse<bool>('denied'));
      final cubit = WindowSalesCubit(repo, workerCubit);
      addTearDown(cubit.close);
      final states = <WindowSalesState>[];
      cubit.stream.listen(states.add);

      await cubit.sell(soldQuantity: 3, product: fakeProduct());
      await pumpEventQueue();

      expect(states, [isA<WindowSalesLoading>(), isA<WindowSalesFailure>(), isA<WindowSalesInitial>()]);
      verifyNever(() => workerCubit.updateProducts(any()));
    });
  });
}