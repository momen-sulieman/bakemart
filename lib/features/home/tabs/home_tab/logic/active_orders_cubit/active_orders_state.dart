part of 'active_orders_cubit.dart';

abstract class ActiveOrdersState {}

final class NoActiveOrders extends ActiveOrdersState {}

final class ActiveOrders extends ActiveOrdersState {
  final List<OrderModel> orders;

  ActiveOrders(this.orders);
}

final class ActiveOrdersFailure extends ActiveOrdersState {
  final String error;

  ActiveOrdersFailure(this.error);
}
