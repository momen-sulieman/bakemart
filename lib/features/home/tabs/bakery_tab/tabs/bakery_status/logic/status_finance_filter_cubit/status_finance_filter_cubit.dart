import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';

part 'status_finance_filter_state.dart';

class StatusFinanceFilterCubit extends Cubit<StatusFinanceFilterState>
    with DatePeriodFilterMixin {
  final BakeryTabRepo _repo;
  final BakeryTabCubit _cubit;
  late final StreamSubscription _bakerySubscription;

  StatusFinanceFilterCubit(this._repo, this._cubit)
    : super(StatusFinanceFilterInitial()) {
    filterFinanceRecords();
    _bakerySubscription = _cubit.stream.listen((_) {
      filterFinanceRecords();
    });
  }

  bool isExpanded = true;
  String selectedBranchId = "";
  FinanceModel filteredFinanceRecord = FinanceModel(
    bakeryId: "",
    branchId: "",
    cleaningExpenses: 0,
    wastes: [],
  );

  List<BakeryModel> get branches => _cubit.bakeries;

  List<FinanceModel> get _branchFinance => selectedBranchId.isEmpty
      ? _cubit.finance
      : _cubit.finance
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
    filterFinanceRecords();
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
    filterFinanceRecords();
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(StatusFinanceFilterSuccess(filteredFinanceRecord));
  }

  void applyDateFilter() {
    commitPending();
    filterFinanceRecords();
  }

  void filterFinanceRecords({DateTime? selectedDate}) {
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final records = _branchFinance;
    final matched = <FinanceModel>[];
    Object? lastFailure;
    for (final date in periodDates()) {
      final result = _repo.filterFinanceRecordsByDate(
        allFinanceRecords: records,
        selectedDate: date,
      );
      if (result is SuccessResponse<FinanceModel>) {
        matched.add(result.data);
      } else {
        lastFailure = result;
      }
    }
    if (matched.isEmpty) {
      emit(StatusFinanceFilterFialure((lastFailure as FailureResponse).error));
      return;
    }
    filteredFinanceRecord = matched.length == 1 ? matched.first : _sum(matched);
    emit(StatusFinanceFilterSuccess(filteredFinanceRecord));
  }

  FinanceModel _sum(List<FinanceModel> list) {
    return FinanceModel(
      bakeryId: list.first.bakeryId,
      branchId: list.first.branchId,
      cleaningExpenses: list.fold(
        0,
        (sum, record) => sum + record.cleaningExpenses,
      ),
      wastes: list.expand((record) => record.wastes).toList(),
    );
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}
