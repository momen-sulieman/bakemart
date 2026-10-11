import 'dart:async';

import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../../../core/network/response_result.dart';
import '../../../../data/bakery_tab_repo.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'status_shifts_filter_state.dart';

class StatusShiftsFilterCubit extends Cubit<StatusShiftsFilterState> {
  final BakeryTabRepo _repo;
  final BakeryTabCubit _cubit;
  late final StreamSubscription _bakerySubscription;

  StatusShiftsFilterCubit(this._repo, this._cubit)
      : super(StatusShiftsFilterInitial()){
    filterShifts();
    _bakerySubscription = _cubit.stream.listen((_) {
      filterShifts();
    });
  }

  DateTime selectedDate = DateTime.now();
  bool isExpanded = true;
  List<ShiftModel>filteredShifts=[];

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
    filterShifts();
  }

  void updateTileExpansion(bool expanded) {
    isExpanded = expanded;
    emit(StatusShiftsFilterSuccess(filteredShifts));
  }

  void filterShifts({DateTime? selectedDate}) {
    emit(StatusShiftsFilterLoading());
    this.selectedDate = selectedDate ?? this.selectedDate;
    final filterResult = _repo.filterShiftsByDate(
      allShifts: _cubit.shifts,
      selectedDate: this.selectedDate,
    );
    if (filterResult is SuccessResponse<List<ShiftModel>>) {
      filteredShifts=filterResult.data;
      emit(StatusShiftsFilterSuccess(filteredShifts));
    }
  }

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}