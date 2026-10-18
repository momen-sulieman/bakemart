import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/work_sheet_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

// Covers WorkerCubit's three constructor-time calls plus the network calls
// ShiftsCubit makes. filterShiftsByDate and calculateWage are pure and left
// real, which is what ShiftsFilterCubit relies on.
class TestWorkerRepo extends WorkerRepo {
  List<ShiftModel> shiftsAfterDelete = [];

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
  Future<ResponseResult<bool>> deleteShift({required ShiftModel worker}) async {
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<ShiftModel>?>> fetchShifts(String id) async {
    return SuccessResponse<List<ShiftModel>?>(shiftsAfterDelete);
  }

  @override
  Future<ResponseResult<bool>> upsertShiftsTable({
    required List<ShiftModel> shiftTable,
  }) async {
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> postPayrollExpenses({
    required String bakeryId,
    required String branchId,
    required double payrollExpenses,
    required DateTime date,
  }) async {
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id) async {
    return SuccessResponse<List<FinanceModel>?>([]);
  }
}

void main() {
  late TestWorkerRepo repo;
  late WorkerCubit workerCubit;
  late ShiftsFilterCubit filterCubit;
  late ShiftsCubit shiftsCubit;
  final today = DateTime.now();
  final payroll =
  PayrollModel(bakeryId: 'b1', payrollMethod: false, chef: 50, branchId: '');
  final shift = ShiftModel(
    bakeryId: 'b1',
    workerId: 'w1',
    workerName: 'Alice',
    wage: 150,
    role: const ['chef'],
    numberOfBatches: const [3],
    date: today, branchId: '',
  );

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    repo = TestWorkerRepo();
    workerCubit = WorkerCubit(repo);
    await pumpEventQueue();
    workerCubit.bakery = fakeBakery('b1', 0, 0);
    workerCubit.payroll = payroll;
    workerCubit.payrollMethod = false;
    workerCubit.staff = [
      fakeStaff(workerId: 'w2', workerName: 'Bob', bakeryId: 'b1'),
    ];
    workerCubit.shifts = [shift];
    repo.shiftsAfterDelete = [];

    filterCubit = ShiftsFilterCubit(repo, workerCubit);
    shiftsCubit = ShiftsCubit(repo, workerCubit);
  });

  tearDown(() {
    filterCubit.close();
    shiftsCubit.close();
    workerCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 2000));
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<WorkerCubit>.value(value: workerCubit),
              BlocProvider<ShiftsFilterCubit>.value(value: filterCubit),
              BlocProvider<ShiftsCubit>.value(value: shiftsCubit),
            ],
            child: WorkSheetTile(workerState: workerCubit.state),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  // Note: the add-worker dialog and the per-worker batch-edit dialog both
  // drive their inputs through WheelPicker role/rate selectors, which need
  // drag gestures rather than taps to change — not exercised here.

  testWidgets('renders the worker, the batch total and the wage',
          (tester) async {
        await pumpTile(tester);

        expect(find.textContaining('Alice'), findsOneWidget);
        expect(find.text('3'), findsOneWidget); // total batches
        expect(find.text('150.00'), findsOneWidget); // wage
      });

  testWidgets('the edit icon enters edit mode and reveals delete icons',
          (tester) async {
        await pumpTile(tester);

        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(filterCubit.editMode, true);
        expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
      });

  testWidgets('deleting a worker in edit mode calls the repo and removes the row',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_forever_outlined));
        await tester.pumpAndSettle();

        expect(
          filterCubit.editableCurrentFilteredShifts
              .any((s) => s.workerId == 'w1'),
          false,
        );
      });
}