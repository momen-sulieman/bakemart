import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class TestWorkerRepo extends WorkerRepo {
  ResponseResult<bool> Function()? onUpsertShifts;
  ResponseResult<bool> Function()? onPostPayrollExpenses;
  ResponseResult<bool> Function()? onDeleteShift;
  double? postedPayrollExpenses;
  bool fetchShiftsCalled = false;
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
  Future<ResponseResult<bool>> upsertShiftsTable({
    required List<ShiftModel> shiftTable,
  }) async {
    return onUpsertShifts?.call() ?? SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<ShiftModel>?>> fetchShifts(String id) async {
    fetchShiftsCalled = true;
    return SuccessResponse<List<ShiftModel>?>([]);
  }

  @override
  Future<ResponseResult<bool>> postPayrollExpenses({
    required String bakeryId,
    required String branchId,
    required double payrollExpenses,
    required DateTime date,
  }) async {
    postedPayrollExpenses = payrollExpenses;
    return onPostPayrollExpenses?.call() ?? SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id) async {
    fetchFinanceCalled = true;
    return SuccessResponse<List<FinanceModel>?>([]);
  }

  @override
  Future<ResponseResult<bool>> deleteShift({required ShiftModel worker}) async {
    return onDeleteShift?.call() ?? SuccessResponse<bool>(true);
  }
}

void main() {
  late WorkerCubit workerCubit;
  late TestWorkerRepo testRepo;
  late ShiftsCubit cubit;
  final bakery = fakeBakery('b1', 0, 0);
  final shift = ShiftModel(
    bakeryId: 'b1',
    workerId: 'w1',
    workerName: 'Alice',
    wage: 150,
    role: const ['chef'],
    numberOfBatches: const [3], branchId: '',
  );

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    testRepo = TestWorkerRepo();
    workerCubit = WorkerCubit(testRepo);
    await pumpEventQueue();
    workerCubit.bakery = bakery;

    cubit = ShiftsCubit(testRepo, workerCubit);
  });

  tearDown(() {
    cubit.close();
    workerCubit.close();
  });

  group('save', () {
    test('success posts the summed wage as payroll expenses', () async {
      await cubit.save(shiftTable: [shift], date: DateTime.now());

      expect(cubit.state, isA<ShiftsInitial>());
      expect(testRepo.fetchShiftsCalled, true);
      expect(testRepo.postedPayrollExpenses, 150);
      expect(testRepo.fetchFinanceCalled, true);
    });

    test('a failed upsert skips refreshing anything and surfaces the error',
            () async {
          testRepo.onUpsertShifts = () => FailureResponse<bool>('offline');
          final states = <ShiftsState>[];
          cubit.stream.listen(states.add);

          await cubit.save(shiftTable: [shift], date: DateTime.now());
          await pumpEventQueue();

          expect(
            states.any((s) => s is ShiftsFailure && s.error == 'offline'),
            true,
          );
          expect(cubit.state, isA<ShiftsInitial>());
          expect(testRepo.fetchShiftsCalled, false);
          expect(testRepo.fetchFinanceCalled, false);
        });

    test('a failed expenses post still refreshed shifts but not finance',
            () async {
          testRepo.onPostPayrollExpenses = () => FailureResponse<bool>('offline');
          final states = <ShiftsState>[];
          cubit.stream.listen(states.add);

          await cubit.save(shiftTable: [shift], date: DateTime.now());
          await pumpEventQueue();

          expect(states.any((s) => s is ShiftsFailure), true);
          expect(testRepo.fetchShiftsCalled, true);
          expect(testRepo.fetchFinanceCalled, false);
        });
  });

  group('deleteWorker', () {
    test('success refreshes shifts and settles to Initial', () async {
      await cubit.deleteWorker(worker: shift);

      expect(cubit.state, isA<ShiftsInitial>());
      expect(testRepo.fetchShiftsCalled, true);
    });

    test('failure surfaces the error and settles to Initial', () async {
      testRepo.onDeleteShift = () => FailureResponse<bool>('offline');
      final states = <ShiftsState>[];
      cubit.stream.listen(states.add);

      await cubit.deleteWorker(worker: shift);
      await pumpEventQueue();

      expect(
        states.any((s) => s is ShiftsFailure && s.error == 'offline'),
        true,
      );
      expect(cubit.state, isA<ShiftsInitial>());
      expect(testRepo.fetchShiftsCalled, false);
    });
  });
}