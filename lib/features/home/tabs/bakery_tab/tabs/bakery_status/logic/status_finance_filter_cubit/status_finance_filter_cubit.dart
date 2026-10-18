import 'dart:async';

import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_finance_filter_state.dart';

class StatusFinanceFilterCubit extends Cubit<StatusFinanceFilterState> {
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

  DateTime selectedDate = DateTime.now();
  bool isExpanded = true;
  FinanceModel filteredFinanceRecord = FinanceModel(
    bakeryId: "",
    branchId: "",
    cleaningExpenses: 0,
    wastes: [],
  );

  List<int> get dynamicDaysList {
    final int daysInTargetMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    return List.generate(daysInTargetMonth, (index) => index + 1);
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

  void filterFinanceRecords({DateTime? selectedDate}) {
    this.selectedDate = selectedDate ?? this.selectedDate;
    final filterResult = _repo.filterFinanceRecordsByDate(
      allFinanceRecords: _cubit.finance,
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<FinanceModel>) {
      filteredFinanceRecord = filterResult.data;
      emit(StatusFinanceFilterSuccess(filteredFinanceRecord));
    } else {
      emit(StatusFinanceFilterFialure((filterResult as FailureResponse).error));
    }
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}