import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/worker_repo.dart';

part 'history_filter_state.dart';

class HistoryFilterCubit extends Cubit<HistoryFilterState> {
  final WorkerRepo _repo;

  HistoryFilterCubit(this._repo) : super(HistoryFilterInitial()) {
    _fetchAndFilter();
  }

  List<ShiftModel> allShifts = [];
  List<ShiftModel> filteredShifts = [];
  bool isExpanded = true;
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year.clamp(2026, 2035);

  Future<void> _fetchAndFilter() async {
    if (isClosed) return;
    emit(HistoryFilterLoading());

    final result = await _repo.fetchMyShifts();

    if (isClosed) return; // <-- guards the race: cubit may have closed during the await
    if (result is SuccessResponse<List<ShiftModel>?>) {
      allShifts = result.data ?? [];
      _filter();
    } else {
      emit(HistoryFilterFailure((result as FailureResponse).error));
    }
  }

  void _filter() {
    if (isClosed) return;
    filteredShifts = allShifts
        .where(
          (shift) =>
      shift.date?.month == selectedMonth &&
          shift.date?.year == selectedYear,
    )
        .toList();
    emit(HistoryFilterSuccess(filteredShifts));
  }

  void filterByMonth(int month) {
    if (isClosed) return;
    selectedMonth = month;
    _filter();
  }

  void filterByYear(int year) {
    if (isClosed) return;
    selectedYear = year;
    _filter();
  }

  void updateTileExpansion(bool expanded) {
    if (isClosed) return;
    isExpanded = expanded;
    emit(HistoryFilterSuccess(filteredShifts));
  }
}