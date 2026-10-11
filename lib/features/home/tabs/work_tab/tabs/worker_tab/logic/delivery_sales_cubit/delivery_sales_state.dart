part of 'delivery_sales_cubit.dart';

abstract class DeliverySalesState {}

final class Initial extends DeliverySalesState {}
final class Loading extends DeliverySalesState {}

final class ProcessingAll extends DeliverySalesState {}

final class Success extends DeliverySalesState {
  final List<OrderModel> orders;
  Success(this.orders);
}

final class Failure extends DeliverySalesState {
  final String error;
  Failure(this.error);
}