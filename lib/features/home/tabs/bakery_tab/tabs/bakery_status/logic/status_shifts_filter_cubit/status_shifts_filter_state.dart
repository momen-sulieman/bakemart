part of 'status_shifts_filter_cubit.dart';

abstract class StatusShiftsFilterState {}

final class StatusShiftsFilterInitial extends StatusShiftsFilterState {}
final class StatusShiftsFilterLoading extends StatusShiftsFilterState {}
final class StatusShiftsFilterSuccess extends StatusShiftsFilterState {
  final List<ShiftModel> shifts;
  StatusShiftsFilterSuccess(this.shifts);
}
final class StatusShiftsFilterFialure extends StatusShiftsFilterState {
  final String error;
  StatusShiftsFilterFialure(this.error);
}

