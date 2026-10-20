import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_sales_filter_state.dart';

class StatusSalesFilterCubit extends Cubit<StatusSalesFilterState> {
  final BakeryTabRepo _repo;
  final BakeryTabCubit _cubit;
  late final StreamSubscription _bakerySubscription;

  StatusSalesFilterCubit(this._repo, this._cubit)
      : super(StatusSalesFilterInitial()) {
    filterSales();
    _bakerySubscription = _cubit.stream.listen((_) {
      filterSales();
    });
  }

  DateTime selectedDate = DateTime.now();
  bool isExpanded = true;
  String selectedBranchId = "";
  List<SalesModel> filteredSalesRecords = [];

  List<BakeryModel> get branches => _cubit.bakeries;

  List<SalesModel> get _branchSales => selectedBranchId.isEmpty
      ? _cubit.sales
      : _cubit.sales
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
    filterSales();
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
    filterSales();
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(StatusSalesFilterSuccess());
  }

  void filterSales({DateTime? selectedDate}) {
    emit(StatusSalesFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final filterResult = _repo.filterSalesByDate(
      allSales: _branchSales,
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<List<SalesModel>>) {
      filteredSalesRecords = filterResult.data;
      emit(StatusSalesFilterSuccess());
    }
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}