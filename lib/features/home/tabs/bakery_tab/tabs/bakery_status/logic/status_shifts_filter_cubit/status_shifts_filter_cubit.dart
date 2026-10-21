import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_shifts_filter_state.dart';

class ShiftSummary {
  final String workerId;
  final String workerName;
  final String branchId;
  final List<String> _firstRole;
  final Map<String, int> _batchesByRole = {};
  double rate = 0;
  double wage = 0;
  int count = 0;

  ShiftSummary(ShiftModel shift)
      : workerId = shift.workerId,
        workerName = shift.workerName,
        branchId = shift.branchId,
        _firstRole = List<String>.from(shift.role) {
    add(shift);
  }

  void add(ShiftModel shift) {
    count++;
    rate += (shift.rate ?? 0).toDouble();
    wage += shift.wage.toDouble();
    for (int i = 0; i < shift.numberOfBatches.length; i++) {
      final role = shift.role[i];
      _batchesByRole[role] = (_batchesByRole[role] ?? 0) + shift.numberOfBatches[i];
    }
  }

  List<String> get role =>
      _batchesByRole.isEmpty ? _firstRole : _batchesByRole.keys.toList();

  List<int> get numberOfBatches => _batchesByRole.values.toList();

  String get rateLabel {
    if (count == 1) {
      if (rate == 1) return "100%";
      if (rate == 0.5) return "50%";
      if (rate == 0.25) return "25%";
      return "--";
    }
    return rate.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}

class StatusShiftsFilterCubit extends Cubit<StatusShiftsFilterState>
    with DatePeriodFilterMixin {
  final BakeryTabRepo _repo;
  final BakeryTabCubit _cubit;
  late final StreamSubscription _bakerySubscription;

  StatusShiftsFilterCubit(this._repo, this._cubit)
      : super(StatusShiftsFilterInitial()) {
    filterShifts();
    _bakerySubscription = _cubit.stream.listen((_) {
      filterShifts();
    });
  }

  bool isExpanded = true;
  String selectedBranchId = "";
  List<ShiftModel> filteredShifts = [];
  List<ShiftSummary> filteredSummaries = [];

  List<BakeryModel> get branches => _cubit.bakeries;

  List<ShiftModel> get _branchShifts => selectedBranchId.isEmpty
      ? _cubit.shifts
      : _cubit.shifts
      .where((record) => record.branchId == selectedBranchId)
      .toList();

  void _syncBranch() {
    final ids = _cubit.bakeries.map((bakery) => bakery.branchId).toList();
    if (ids.isNotEmpty && !ids.contains(selectedBranchId)) {
      selectedBranchId = ids.first;
    }
  }

  List<int> get dynamicDaysList {
    final int daysInTargetMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    return List.generate(daysInTargetMonth, (index) => index + 1);
  }

  void changeBranch(String branchId) {
    selectedBranchId = branchId;
    filterShifts();
  }

  void changeSelectedDate({int? year, int? month, int? day}) {
    int targetYear = year ?? selectedDate.year;
    int targetMonth = month ?? selectedDate.month;
    int targetDay = day ?? selectedDate.day;
    int daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > daysInTargetMonth) {
      targetDay = daysInTargetMonth;
    }
    selectedDate = DateTime(targetYear, targetMonth, targetDay);
    filterShifts();
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(StatusShiftsFilterSuccess(filteredShifts));
  }

  void applyDateFilter() {
    commitPending();
    filterShifts();
  }

  void filterShifts({DateTime? selectedDate}) {
    emit(StatusShiftsFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final shifts = _branchShifts;
    final Map<String, ShiftSummary> grouped = {};
    final List<ShiftModel> all = [];
    int counter = 0;
    for (final date in periodDates()) {
      final result = _repo.filterShiftsByDate(
        allShifts: shifts,
        selectedDate: date,
      );
      if (result is SuccessResponse<List<ShiftModel>>) {
        for (final shift in result.data) {
          all.add(shift);
          final key = useDay ? '${counter++}' : shift.workerId;
          final existing = grouped[key];
          if (existing == null) {
            grouped[key] = ShiftSummary(shift);
          } else {
            existing.add(shift);
          }
        }
      }
    }
    filteredShifts = all;
    filteredSummaries = grouped.values.toList();
    emit(StatusShiftsFilterSuccess(filteredShifts));
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}