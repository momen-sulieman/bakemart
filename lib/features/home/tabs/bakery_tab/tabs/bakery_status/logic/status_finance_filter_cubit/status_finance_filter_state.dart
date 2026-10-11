part of 'status_finance_filter_cubit.dart';

abstract class StatusFinanceFilterState {}

final class StatusFinanceFilterInitial extends StatusFinanceFilterState {}
final class StatusFinanceFilterLoading extends StatusFinanceFilterState {}
final class StatusFinanceFilterSuccess extends StatusFinanceFilterState {
  final FinanceModel financeRecord;
  StatusFinanceFilterSuccess(this.financeRecord);
}
final class StatusFinanceFilterFialure extends StatusFinanceFilterState {
  final String error;
  StatusFinanceFilterFialure(this.error);
}
