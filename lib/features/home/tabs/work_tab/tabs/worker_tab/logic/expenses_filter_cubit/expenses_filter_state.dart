part of 'expenses_filter_cubit.dart';

abstract class ExpensesFilterState {}

final class ExpensesFilterInitial extends ExpensesFilterState {}

final class ExpensesFilterLoading extends ExpensesFilterState {}

final class ExpensesFilterSuccess extends ExpensesFilterState {}

final class ExpensesFilterFailure extends ExpensesFilterState {
  final String error;

  ExpensesFilterFailure(this.error);
}
