import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';
part 'status_meals_filter_state.dart';

class StatusMealsFilterCubit extends Cubit<StatusMealsFilterState> {
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

  DateTime selectedDate = DateTime.now();
  bool isExpanded = true;
  String selectedBranchId = "";
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

  void filterMealsRecords({DateTime? selectedDate}) {
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final filterResult = _repo.filterFinanceRecordsByDate(
      allFinanceRecords: _branchFinance,
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<FinanceModel>) {
      filteredMealsRecord = filterResult.data;
      emit(StatusMealsFilterSuccess(filteredMealsRecord));
    } else {
      emit(StatusMealsFilterFialure((filterResult as FailureResponse).error));
    }
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}