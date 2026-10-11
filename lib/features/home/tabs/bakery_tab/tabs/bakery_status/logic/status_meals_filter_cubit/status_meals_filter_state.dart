part of 'status_meals_filter_cubit.dart';


abstract class StatusMealsFilterState {}

final class StatusMealsFilterInitial extends StatusMealsFilterState {}
final class StatusMealsFilterLoading extends StatusMealsFilterState {}
final class StatusMealsFilterSuccess extends StatusMealsFilterState {
  final FinanceModel mealsRecord;
  StatusMealsFilterSuccess(this.mealsRecord);
}
final class StatusMealsFilterFialure extends StatusMealsFilterState {
  final String error;
  StatusMealsFilterFialure(this.error);
}

