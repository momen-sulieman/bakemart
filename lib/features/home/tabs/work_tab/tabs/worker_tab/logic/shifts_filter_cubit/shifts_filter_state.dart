part of 'shifts_filter_cubit.dart';

abstract class ShiftsFilterState {}

final class ShiftsFilterInitial extends ShiftsFilterState {}

final class ShiftsFilterLoading extends ShiftsFilterState {}

final class ShiftsFilterSuccess extends ShiftsFilterState {}

final class ShiftsFilterFailure extends ShiftsFilterState {
  String error;

  ShiftsFilterFailure(this.error);
}
