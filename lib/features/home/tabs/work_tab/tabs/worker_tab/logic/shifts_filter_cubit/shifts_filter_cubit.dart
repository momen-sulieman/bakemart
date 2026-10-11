import 'dart:async';
import 'dart:convert';

import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'shifts_filter_state.dart';

class ShiftsFilterCubit extends Cubit<ShiftsFilterState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;
  late final StreamSubscription _workerSubscription;

  ShiftsFilterCubit(this._repo, this._workerCubit)
      : super(ShiftsFilterInitial()) {
    _listenToWorkerCubit();
    filter();
  }

  List<ShiftModel> currentFilteredShifts = [];
  List<ShiftModel> editableCurrentFilteredShifts = [];
  List<StaffModel> staff = [];
  DateTime selectedDate = DateTime.now();
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  bool workerDeleted = false;
  bool isExpanded = true;
  bool editMode = false;
  bool updated = false;
  bool inputValidity = false;
  bool addingRole = false;
  bool numberOfBatchUpdated = false;
  bool dailyPaymentShiftUpdated = false;
  double wage = 0;

  DateTime _clampedDate(int year, int month, int day) {
    final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final int clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
    return DateTime(year, month, clampedDay);
  }

  void filterByDay(int day) {
    selectedDay = day;
    filter(selectedDate: _clampedDate(selectedDate.year, selectedMonth, day));
  }

  void filterByMonth(int month) {
    selectedMonth = month;
    filter(selectedDate: _clampedDate(selectedDate.year, month, selectedDay));
  }

  void _listenToWorkerCubit() {
    if (_workerCubit.state is Supervisor) {
      staff = _workerCubit.staff ?? [];
    }

    _workerSubscription = _workerCubit.stream.listen((state) {
      if (state is Supervisor) {
        staff = state.staff ?? [];
        filter();
      }
    });
  }
  void setWorkerDeleted(bool status){
    workerDeleted=status;
    emit(ShiftsFilterSuccess());
  }

  bool getPayrollMethod() {
    return _workerCubit.payrollMethod;
  }

  List<StaffModel> getStaff() {
    return _workerCubit.staff ?? [];
  }

  PayrollModel getPayroll() {
    return _workerCubit.payroll!;
  }

  double? getPayrollRate({required String role}) {
    final payroll = _workerCubit.payroll;
    if (payroll == null) return 0.0;
    switch (role) {
      case PayrollsTableColumns.ajan:
        return payroll.ajan;
      case PayrollsTableColumns.faran:
        return payroll.faran;
      case PayrollsTableColumns.tawlaji:
        return payroll.tawlaji;
      case PayrollsTableColumns.chef:
        return payroll.chef;
      case PayrollsTableColumns.coChef:
        return payroll.coChef;
      case PayrollsTableColumns.bagger:
        return payroll.bagger;
      case PayrollsTableColumns.supervisor:
        return payroll.supervisor;
      default:
        return 0.0;
    }
  }

  void filter({DateTime? selectedDate}) {
    emit(ShiftsFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    final filterResult = _repo.filterShiftsByDate(
      allShifts: _workerCubit.shifts ?? [],
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<List<ShiftModel>>) {
      currentFilteredShifts = filterResult.data;
      editableCurrentFilteredShifts = currentFilteredShifts
          .map((shift) => shift.copyWith())
          .toList();
    } else {
      currentFilteredShifts = [];
      editableCurrentFilteredShifts = [];
    }
    emit(ShiftsFilterSuccess());
  }

  void _checkUpdate() {
    updated = !ListEquality().equals(
      currentFilteredShifts,
      editableCurrentFilteredShifts,
    );
    emit(ShiftsFilterSuccess());
  }

  void changeEditMode() {
    editableCurrentFilteredShifts = currentFilteredShifts
        .map((shift) => shift.copyWith())
        .toList();
    editMode = !editMode;
    inputValidity = false;
    updated = false;
    workerDeleted=false;
    emit(ShiftsFilterSuccess());
  }

  void cancelChanges() {
    editableCurrentFilteredShifts = currentFilteredShifts
        .map((shift) => shift.copyWith())
        .toList();
    updated = false;
    editMode = false;
    inputValidity = false;
    workerDeleted=false;
    emit(ShiftsFilterSuccess());
  }

  void setInputValidity(bool validity) {
    inputValidity = validity;
    emit(ShiftsFilterSuccess());
  }

  void setAddingRole(bool status) {
    addingRole = status;
    emit(ShiftsFilterSuccess());
  }

  void setNumberOfBatchUpdated(bool status) {
    numberOfBatchUpdated = status;
    emit(ShiftsFilterSuccess());
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(ShiftsFilterSuccess());
  }

  void removeWorker({required String targetWorkerId}) {
    List<ShiftModel> updatedList = List.from(editableCurrentFilteredShifts);
    updatedList.removeWhere((shift) => shift.workerId == targetWorkerId);
    editableCurrentFilteredShifts = List.from(updatedList);
    _checkUpdate();
  }

  void addWorker({required ShiftModel newWorker}) {
    final shiftWithDate = newWorker.copyWith(
      date: selectedDate,
    );
    final updatedList = List<ShiftModel>.from(editableCurrentFilteredShifts)
      ..add(shiftWithDate);
    editableCurrentFilteredShifts = updatedList;
    inputValidity = false;
    _checkUpdate();
    print('Shifts Count: ${editableCurrentFilteredShifts.length}');
    print(jsonEncode(editableCurrentFilteredShifts.map((shift) => shift.toJson()).toList()));
    // print("${jsonEncode(newWorker.toJson())}");
  }

  void editShiftOfDailyPayment({
    required int index,
    required String role,
    required double rate,
  }) {
    final double? payrollRate = getPayrollRate(role: role);
    if (payrollRate != null) {
      wage = payrollRate * rate;
      editableCurrentFilteredShifts[index] =
          editableCurrentFilteredShifts[index].copyWith(
            wage: wage,
            rate: rate,
            role: [role],
          );
      setDailyPaymentShiftUpdated(false);
      _checkUpdate();
    }
  }

  void setDailyPaymentShiftUpdated(bool status) {
    dailyPaymentShiftUpdated = status;
    _checkUpdate();
  }

  void deleteRole({required String workerId, required int indexOfRole}) {
    editableCurrentFilteredShifts = editableCurrentFilteredShifts.map((shift) {
      if (shift.workerId == workerId) {
        final updatedRoles = List<String>.from(shift.role);
        final updatedBatches = List<int>.from(shift.numberOfBatches);
        if (indexOfRole < updatedRoles.length &&
            indexOfRole < updatedBatches.length) {
          updatedRoles.removeAt(indexOfRole);
          updatedBatches.removeAt(indexOfRole);
        }
        return shift.copyWith(
          role: updatedRoles,
          numberOfBatches: updatedBatches,
        );
      }
      return shift;
    }).toList();
    _checkUpdate();
  }

  void addRoleToWorker({
    required String targetWorkerId,
    required String newRole,
    required int newNumberOfBatches,
    required PayrollModel payroll,
  }) {
    editableCurrentFilteredShifts = editableCurrentFilteredShifts.map((shift) {
      if (shift.workerId == targetWorkerId) {
        final updatedRoles = List<String>.from(shift.role)..add(newRole);
        final updatedBatches = List<int>.from(shift.numberOfBatches)
          ..add(newNumberOfBatches);
        return shift.copyWith(
          role: updatedRoles,
          numberOfBatches: updatedBatches,
          wage: _repo.calculateWage(
            roles: updatedRoles,
            numberOfBatches: updatedBatches,
            payroll: payroll,
          ),
        );
      }
      return shift;
    }).toList();
    inputValidity = false;
    _checkUpdate();
  }

  void updateWorkerBatches({
    required String workerId,
    required List<int> updatedBatches,
    required PayrollModel payroll,
  }) {
    final int shiftIndex = editableCurrentFilteredShifts.indexWhere(
          (s) => s.workerId == workerId,
    );

    if (shiftIndex == -1) return;

    final ShiftModel shift = editableCurrentFilteredShifts[shiftIndex];

    bool changed = false;
    for (int i = 0; i < shift.numberOfBatches.length; i++) {
      if (i < updatedBatches.length &&
          shift.numberOfBatches[i] != updatedBatches[i]) {
        changed = true;
        break;
      }
    }

    if (!changed) return;

    final List<String> filteredRoles = [];
    final List<int> filteredBatches = [];

    for (int i = 0; i < updatedBatches.length; i++) {
      if (updatedBatches[i] > 0) {
        filteredBatches.add(updatedBatches[i]);
        if (i < shift.role.length) {
          filteredRoles.add(shift.role[i]);
        }
      }
    }

    final ShiftModel? baseline = currentFilteredShifts.firstWhereOrNull(
          (s) => s.workerId == workerId,
    );

    final List<ShiftModel> updatedShifts = List.from(
      editableCurrentFilteredShifts,
    );

    final bool matchesBaseline =
        baseline != null &&
            const ListEquality<String>().equals(baseline.role, filteredRoles) &&
            const ListEquality<int>().equals(
              baseline.numberOfBatches,
              filteredBatches,
            );

    if (matchesBaseline) {
      updatedShifts[shiftIndex] = baseline;
    } else {
      final double updatedWage = _repo.calculateWage(
        roles: filteredRoles,
        numberOfBatches: filteredBatches,
        payroll: payroll,
      );
      updatedShifts[shiftIndex] = shift.copyWith(
        role: filteredRoles,
        numberOfBatches: filteredBatches,
        wage: updatedWage,
      );
    }

    editableCurrentFilteredShifts = updatedShifts;
    inputValidity = false;
    _checkUpdate();
  }

  @override
  Future<void> close() {
    _workerSubscription.cancel();
    return super.close();
  }
// void updateWorkerBatches({
//   required String workerId,
//   required List<int> updatedBatches,
//   required PayrollModel payroll,
// }) {
//   final int shiftIndex = editableCurrentFilteredShifts.indexWhere(
//         (s) => s.workerId == workerId,
//   );
//
//   if (shiftIndex == -1) return;
//
//   final ShiftModel shift = editableCurrentFilteredShifts[shiftIndex];
//
//   bool changed = false;
//   for (int i = 0; i < shift.numberOfBatches.length; i++) {
//     if (i < updatedBatches.length &&
//         shift.numberOfBatches[i] != updatedBatches[i]) {
//       changed = true;
//       break;
//     }
//   }
//
//   if (!changed) return;
//   final List<String> filteredRoles = [];
//   final List<int> filteredBatches = [];
//
//   for (int i = 0; i < updatedBatches.length; i++) {
//     if (updatedBatches[i] > 0) {
//       filteredBatches.add(updatedBatches[i]);
//       if (i < shift.role.length) {
//         filteredRoles.add(shift.role[i]);
//       }
//     }
//   }
//   double updatedWage = _repo.calculateWage(
//     roles: filteredRoles,
//     numberOfBatches: filteredBatches,
//     payroll: payroll,
//   );
//
//   List<ShiftModel> updatedShifts = List.from(
//     editableCurrentFilteredShifts,
//   );
//   updatedShifts[shiftIndex] = shift.copyWith(
//     role: filteredRoles,
//     numberOfBatches: filteredBatches,
//     wage: updatedWage,
//   );
//   editableCurrentFilteredShifts = updatedShifts;
//   inputValidity = false;
//   _checkUpdate();
// }
}
