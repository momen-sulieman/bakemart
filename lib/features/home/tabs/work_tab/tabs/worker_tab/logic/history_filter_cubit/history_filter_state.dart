part of 'history_filter_cubit.dart';

abstract class HistoryFilterState {}

final class HistoryFilterInitial extends HistoryFilterState {}

final class HistoryFilterLoading extends HistoryFilterState {}

final class HistoryFilterSuccess extends HistoryFilterState {
  final List<ShiftModel> filteredShifts;
  HistoryFilterSuccess(this.filteredShifts);
}

final class HistoryFilterFailure extends HistoryFilterState {
  final String error;
  HistoryFilterFailure(this.error);
}