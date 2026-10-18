import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class TestWorkerRepo extends WorkerRepo {
  ResponseResult<bool> Function()? onProduce;
  List<ShiftModel> upsertedShifts = [];
  double? postedPayrollExpenses;
  bool upsertShiftsCalled = false;
  bool fetchFinanceCalled = false;

  @override
  Future<ResponseResult<UserModel>> getUserData() async {
    return SuccessResponse<UserModel>(
      UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
    );
  }

  @override
  Future<ResponseResult<StaffModel?>> checkStaffTable() async {
    return SuccessResponse<StaffModel?>(null);
  }

  @override
  Future<ResponseResult<List<ShiftModel>?>> fetchMyShifts() async {
    return SuccessResponse<List<ShiftModel>?>([]);
  }

  @override
  Future<ResponseResult<bool>> produce({
    required int batchCounter,
    required int manufacturingWasteCounter,
    required ProductModel product,
    required StorageModel currentStorage,
  }) async {
    return onProduce?.call() ?? SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<ProductModel>?>> fetchProducts(String id) async {
    return SuccessResponse<List<ProductModel>?>([]);
  }

  @override
  Future<ResponseResult<bool>> upsertShiftsTable({
    required List<ShiftModel> shiftTable,
  }) async {
    upsertShiftsCalled = true;
    upsertedShifts = shiftTable;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<ShiftModel>?>> fetchShifts(String id) async {
    return SuccessResponse<List<ShiftModel>?>(upsertedShifts);
  }

  @override
  Future<ResponseResult<bool>> postPayrollExpenses({
    required String bakeryId,
    required String branchId,
    required double payrollExpenses,
    required DateTime date,
  }) async {
    postedPayrollExpenses = payrollExpenses;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id) async {
    fetchFinanceCalled = true;
    return SuccessResponse<List<FinanceModel>?>([]);
  }
}

void main() {
  late WorkerCubit workerCubit;
  late TestWorkerRepo testRepo;
  late ProductionCubit cubit;
  final product = fakeProduct().copyWith(bakeryId: 'b1', productId: 'p1');
  final storage = fakeStorage();

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    testRepo = TestWorkerRepo();
    workerCubit = WorkerCubit(testRepo);
    await pumpEventQueue();
    workerCubit.bakery = fakeBakery('b1', 0, 0);
  });

  tearDown(() {
    cubit.close();
    workerCubit.close();
  });

  group('form validity', () {
    test('for daily payment, validity follows the quantity field alone', () {
      workerCubit.payrollMethod = true;
      cubit = ProductionCubit(testRepo, workerCubit);

      cubit.setInputValidity(true);
      expect(cubit.formValidity, true);

      cubit.setInputValidity(false);
      expect(cubit.formValidity, false);
    });

    test('for batch payment, validity also needs at least one worker', () {
      workerCubit.payrollMethod = false;
      cubit = ProductionCubit(testRepo, workerCubit);

      cubit.setInputValidity(true);
      expect(cubit.formValidity, false, reason: 'no workers added yet');

      cubit.addWorkerToWorkersSheet(
        newWorker: ShiftModel(
          bakeryId: 'b1',
          workerId: 'w1',
          workerName: 'Alice',
          wage: 0,
          role: const ['chef'],
          numberOfBatches: const [2], branchId: '',
        ),
      );
      cubit.setInputValidity(true);
      expect(cubit.formValidity, true);
    });

    test('removeWorkerFromWorkersSheet and emptyWorkersSheet clear the sheet',
            () {
          workerCubit.payrollMethod = false;
          cubit = ProductionCubit(testRepo, workerCubit);
          cubit.addWorkerToWorkersSheet(
            newWorker: ShiftModel(
              bakeryId: 'b1',
              workerId: 'w1',
              workerName: 'Alice',
              wage: 0,
              role: const ['chef'],
              numberOfBatches: const [2], branchId: '',
            ),
          );

          cubit.removeWorkerFromWorkersSheet(0);
          expect(cubit.workersSheet, isEmpty);

          cubit.addWorkerToWorkersSheet(
            newWorker: ShiftModel(
              bakeryId: 'b1',
              workerId: 'w2',
              workerName: 'Bob',
              wage: 0,
              role: const ['chef'],
              numberOfBatches: const [1], branchId: '',
            ),
          );
          cubit.emptyWorkersSheet();
          expect(cubit.workersSheet, isEmpty);
        });
  });

  group('postProduction with daily payment', () {
    setUp(() {
      workerCubit.payrollMethod = true;
      cubit = ProductionCubit(testRepo, workerCubit);
    });

    test('success updates products and never touches shifts or finance',
            () async {
          await cubit.postProduction(
            batchCounter: 2,
            manufacturingWasteCounter: 0,
            product: product,
            currentStorage: storage,
          );

          expect(cubit.state, isA<ProductionInitial>());
          expect(testRepo.upsertShiftsCalled, false);
          expect(testRepo.fetchFinanceCalled, false);
        });

    test('failure emits ProductionFailure then settles to Initial', () async {
      testRepo.onProduce = () => FailureResponse<bool>('offline');
      final states = <ProductionState>[];
      cubit.stream.listen(states.add);

      await cubit.postProduction(
        batchCounter: 1,
        manufacturingWasteCounter: 0,
        product: product,
        currentStorage: storage,
      );
      await pumpEventQueue();

      expect(states.any((s) => s is ProductionFailure), true);
      expect(cubit.state, isA<ProductionInitial>());
      expect(testRepo.upsertShiftsCalled, false);
    });
  });

  group('postProduction with batch payment', () {
    setUp(() {
      workerCubit.payrollMethod = false;
      workerCubit.payroll = PayrollModel(
        bakeryId: 'b1',
        payrollMethod: false,
        chef: 50, branchId: '',
      );
      workerCubit.shifts = [];
      cubit = ProductionCubit(testRepo, workerCubit);
      cubit.addWorkerToWorkersSheet(
        newWorker: ShiftModel(
          bakeryId: 'b1',
          workerId: 'w1',
          workerName: 'Alice',
          wage: 0,
          role: const ['chef'],
          numberOfBatches: const [3], branchId: '',
        ),
      );
    });

    test('success merges the shift, upserts it and posts payroll expenses',
            () async {
          await cubit.postProduction(
            batchCounter: 3,
            manufacturingWasteCounter: 0,
            product: product,
            currentStorage: storage,
          );

          expect(cubit.state, isA<ProductionInitial>());
          expect(testRepo.upsertShiftsCalled, true);
          expect(testRepo.upsertedShifts.single.wage, 150);
          expect(testRepo.postedPayrollExpenses, 150);
          expect(testRepo.fetchFinanceCalled, true);
        });
  });
}