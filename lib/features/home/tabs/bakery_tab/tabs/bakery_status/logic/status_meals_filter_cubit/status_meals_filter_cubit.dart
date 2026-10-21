import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_meals_filter_state.dart';

class WasteSummary {
  final String productId;
  final String productName;
  num manufacturing;
  num notSold;
  num meal;

  WasteSummary({
    required this.productId,
    required this.productName,
    required this.manufacturing,
    required this.notSold,
    required this.meal,
  });
}

class StatusMealsFilterCubit extends Cubit<StatusMealsFilterState>
    with DatePeriodFilterMixin {
  final BakeryTabRepo _repo;
  final BakeryTabCubit _cubit;
  late final StreamSubscription _bakerySubscription;

  StatusMealsFilterCubit(this._repo, this._cubit)
      : super(StatusMealsFilterInitial()) {
    filterMealsRecords();
    _bakerySubscription = _cubit.stream.listen((_) {
      filterMealsRecords();
    });
  }

  bool isExpanded = true;
  String selectedBranchId = "";
  List<WasteSummary> filteredWastes = [];
  FinanceModel filteredMealsRecord = FinanceModel(
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
    filterMealsRecords();
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
    filterMealsRecords();
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(StatusMealsFilterSuccess(filteredMealsRecord));
  }

  void applyDateFilter() {
    commitPending();
    filterMealsRecords();
  }

  void filterMealsRecords({DateTime? selectedDate}) {
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final records = _branchFinance;
    final Map<String, WasteSummary> grouped = {};
    FinanceModel? firstRecord;
    Object? lastFailure;
    for (final date in periodDates()) {
      final result = _repo.filterFinanceRecordsByDate(
        allFinanceRecords: records,
        selectedDate: date,
      );
      if (result is SuccessResponse<FinanceModel>) {
        firstRecord ??= result.data;
        for (final waste in result.data.wastes) {
          final existing = grouped[waste.productId];
          if (existing == null) {
            grouped[waste.productId] = WasteSummary(
              productId: waste.productId,
              productName: waste.productName,
              manufacturing: waste.manufacturing,
              notSold: waste.notSold,
              meal: waste.meal,
            );
          } else {
            existing.manufacturing += waste.manufacturing;
            existing.notSold += waste.notSold;
            existing.meal += waste.meal;
          }
        }
      } else {
        lastFailure = result;
      }
    }
    if (firstRecord == null) {
      filteredWastes = [];
      emit(StatusMealsFilterFialure((lastFailure as FailureResponse).error));
      return;
    }
    filteredMealsRecord = firstRecord;
    filteredWastes = grouped.values.toList();
    emit(StatusMealsFilterSuccess(filteredMealsRecord));
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}