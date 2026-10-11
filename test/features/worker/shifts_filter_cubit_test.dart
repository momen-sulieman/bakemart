import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockWorkerRepo extends Mock implements WorkerRepo {}

void main() {
  late MockWorkerRepo mockRepo;
  late WorkerCubit workerCubit;
  // filterShiftsByDate and calculateWage are pure, so a real WorkerRepo
  // covers everything this cubit needs without mocking.
  late WorkerRepo realRepo;
  late ShiftsFilterCubit cubit;
  final today = DateTime.now();
  final payroll = PayrollModel(
    bakeryId: 'b1',
    payrollMethod: false,
    chef: 50,
    supervisor: 100,
  );

  ShiftModel shiftFor(
      DateTime date, {
        String workerId = 'w1',
        List<String> role = const ['chef'],
        List<int> numberOfBatches = const [2],
        double wage = 100,
        double? rate,
      }) {
    return ShiftModel(
      bakeryId: 'b1',
      workerId: workerId,
      workerName: 'Alice',
      wage: wage,
      role: role,
      numberOfBatches: numberOfBatches,
      date: date,
      rate: rate,
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
    workerCubit.payroll = payroll;
    workerCubit.payrollMethod = false;
    workerCubit.staff = [
      fakeStaff(workerId: 'w2', workerName: 'Bob', bakeryId: 'b1'),
    ];

    realRepo = WorkerRepo();
  });

  tearDown(() {
    cubit.close();
    workerCubit.close();
  });

  ShiftsFilterCubit build() => ShiftsFilterCubit(realRepo, workerCubit);

  test('filter() selects today\'s shifts by default', () {
    workerCubit.shifts = [
      shiftFor(today.subtract(const Duration(days: 1))),
      shiftFor(today, wage: 100),
    ];
    cubit = build();

    expect(cubit.currentFilteredShifts, hasLength(1));
    expect(cubit.currentFilteredShifts.single.wage, 100);
  });

  test('filterByDay re-filters against the new date', () {
    final otherDay = today.subtract(const Duration(days: 1));
    workerCubit.shifts = [
      shiftFor(today, wage: 100),
      shiftFor(otherDay, wage: 200),
    ];
    cubit = build();

    cubit.filterByDay(otherDay.day);

    expect(cubit.currentFilteredShifts.single.wage, 200);
  });

  test('getPayrollRate returns the correct role rate', () {
    workerCubit.shifts = [];
    cubit = build();

    expect(cubit.getPayrollRate(role: 'chef'), 50);
    expect(cubit.getPayrollRate(role: 'supervisor'), 100);
  });

  test('changeEditMode snapshots the editable list and resets flags', () {
    workerCubit.shifts = [shiftFor(today)];
    cubit = build();

    cubit.changeEditMode();

    expect(cubit.editMode, true);
    expect(cubit.editableCurrentFilteredShifts, hasLength(1));
    expect(cubit.updated, false);
  });

  test('removeWorker drops the worker from the editable list and marks updated',
          () {
        workerCubit.shifts = [shiftFor(today)];
        cubit = build();
        cubit.changeEditMode();

        cubit.removeWorker(targetWorkerId: 'w1');

        expect(cubit.editableCurrentFilteredShifts, isEmpty);
        expect(cubit.updated, true);
      });

  test('addWorker stamps the shift with the selected date', () {
    workerCubit.shifts = [];
    cubit = build();
    final newShift = ShiftModel(
      bakeryId: 'b1',
      workerId: 'w2',
      workerName: 'Bob',
      wage: 0,
      role: const ['chef'],
      numberOfBatches: const [],
      rate: 0.5,
    );

    cubit.addWorker(newWorker: newShift);

    expect(cubit.editableCurrentFilteredShifts, hasLength(1));
    expect(cubit.editableCurrentFilteredShifts.single.date, cubit.selectedDate);
  });

  test('editShiftOfDailyPayment recomputes the wage from the payroll rate',
          () {
        workerCubit.shifts = [shiftFor(today, role: const ['chef'], rate: 1.0)];
        cubit = build();
        cubit.changeEditMode();

        cubit.editShiftOfDailyPayment(index: 0, role: 'supervisor', rate: 0.5);

        final updated = cubit.editableCurrentFilteredShifts.single;
        expect(updated.role, ['supervisor']);
        expect(updated.rate, 0.5);
        expect(updated.wage, 50); // supervisor rate 100 * 0.5
      });

  test('deleteRole removes the role and its matching batch count', () {
    workerCubit.shifts = [
      shiftFor(
        today,
        role: const ['chef', 'supervisor'],
        numberOfBatches: const [2, 1],
      ),
    ];
    cubit = build();
    cubit.changeEditMode();

    cubit.deleteRole(workerId: 'w1', indexOfRole: 1);

    final updated = cubit.editableCurrentFilteredShifts.single;
    expect(updated.role, ['chef']);
    expect(updated.numberOfBatches, [2]);
  });

  test('addRoleToWorker appends a role and recalculates the wage', () {
    workerCubit.shifts = [
      shiftFor(today, role: const ['chef'], numberOfBatches: const [2], wage: 100),
    ];
    cubit = build();
    cubit.changeEditMode();

    cubit.addRoleToWorker(
      targetWorkerId: 'w1',
      newRole: 'supervisor',
      newNumberOfBatches: 1,
      payroll: payroll,
    );

    final updated = cubit.editableCurrentFilteredShifts.single;
    expect(updated.role, ['chef', 'supervisor']);
    expect(updated.numberOfBatches, [2, 1]);
    expect(updated.wage, 200); // 2*50 (chef) + 1*100 (supervisor)
  });

  test('updateWorkerBatches drops zeroed-out roles and recalculates the wage',
          () {
        workerCubit.shifts = [
          shiftFor(
            today,
            role: const ['chef', 'supervisor'],
            numberOfBatches: const [2, 1],
            wage: 200,
          ),
        ];
        cubit = build();
        cubit.changeEditMode();

        cubit.updateWorkerBatches(
          workerId: 'w1',
          updatedBatches: [3, 0],
          payroll: payroll,
        );

        final updated = cubit.editableCurrentFilteredShifts.single;
        expect(updated.role, ['chef']);
        expect(updated.numberOfBatches, [3]);
        expect(updated.wage, 150); // 3*50
      });

  test('updateWorkerBatches reverts to the baseline when batches match the original',
          () {
        final baseline = shiftFor(
          today,
          role: const ['chef'],
          numberOfBatches: const [2],
          wage: 100,
        );
        workerCubit.shifts = [baseline];
        cubit = build();
        cubit.changeEditMode();
        cubit.updateWorkerBatches(
          workerId: 'w1',
          updatedBatches: [5],
          payroll: payroll,
        );
        expect(cubit.editableCurrentFilteredShifts.single.numberOfBatches, [5]);

        cubit.updateWorkerBatches(
          workerId: 'w1',
          updatedBatches: [2],
          payroll: payroll,
        );

        expect(cubit.editableCurrentFilteredShifts.single, baseline);
      });
}