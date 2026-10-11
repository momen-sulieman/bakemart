part of 'expenses_cubit.dart';

enum ExpensesAction { save, deleteProduct }

abstract class ExpensesState {}

final class ExpensesInitial extends ExpensesState {}

final class ExpensesLoading extends ExpensesState {
  final String? productId;
  final ExpensesAction action;

  ExpensesLoading({this.productId, this.action = ExpensesAction.save});
}

final class ExpensesSuccess extends ExpensesState {}

final class ExpensesFailure extends ExpensesState {
  final String error;

  ExpensesFailure(this.error);
}
