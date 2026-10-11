part of 'status_sales_filter_cubit.dart';

abstract class StatusSalesFilterState {}

final class StatusSalesFilterInitial extends StatusSalesFilterState {}
final class StatusSalesFilterLoading extends StatusSalesFilterState {}
final class StatusSalesFilterSuccess extends StatusSalesFilterState {}
final class StatusSalesFilterFialure extends StatusSalesFilterState {
  final String error;
  StatusSalesFilterFialure(this.error);
}


