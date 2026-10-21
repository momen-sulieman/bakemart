import 'dart:async';

import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_sales_filter_state.dart';

class SalesSummary {
  final String bakeryId;
  final String branchId;
  final String productId;
  final String productName;
  final double productPrice;
  int produced;
  int sold;

  SalesSummary({
    required this.bakeryId,
    required this.branchId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.produced,
    required this.sold,
  });
}

class StatusSalesFilterCubit extends Cubit<StatusSalesFilterState>
    with DatePeriodFilterMixin {
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

  bool isExpanded = true;
  String selectedBranchId = "";
  List<SalesSummary> filteredSalesRecords = [];

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

  void applyDateFilter() {
    commitPending();
    filterSales();
  }

  void filterSales({DateTime? selectedDate}) {
    emit(StatusSalesFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    _syncBranch();
    final sales = _branchSales;
    final Map<String, SalesSummary> grouped = {};
    for (final date in periodDates()) {
      final result = _repo.filterSalesByDate(
        allSales: sales,
        selectedDate: date,
      );
      if (result is SuccessResponse<List<SalesModel>>) {
        for (final record in result.data) {
          final existing = grouped[record.productId];
          if (existing == null) {
            grouped[record.productId] = SalesSummary(
              bakeryId: record.bakeryId,
              branchId: record.branchId,
              productId: record.productId,
              productName: record.productName,
              productPrice: record.productPrice,
              produced: record.produced,
              sold: record.sold,
            );
          } else {
            existing.produced += record.produced;
            existing.sold += record.sold;
          }
        }
      }
    }
    filteredSalesRecords = grouped.values.toList();
    emit(StatusSalesFilterSuccess());
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}