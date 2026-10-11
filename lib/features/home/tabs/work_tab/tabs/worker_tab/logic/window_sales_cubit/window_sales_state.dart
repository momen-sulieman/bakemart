part of 'window_sales_cubit.dart';

abstract class WindowSalesState {}

final class WindowSalesInitial extends WindowSalesState {}
final class WindowSalesLoading extends WindowSalesState {}
final class WindowSalesSuccess extends WindowSalesState {}
final class WindowSalesFailure extends WindowSalesState {
  final String error;
  WindowSalesFailure(this.error);
}
