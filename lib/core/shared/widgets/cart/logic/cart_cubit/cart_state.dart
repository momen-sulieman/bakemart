part of 'cart_cubit.dart';

abstract class CartState {}

final class CartInitial extends CartState {}
final class LocationError extends CartState {
  final String error;
  LocationError(this.error);
}
final class CartUpdated extends  CartState{
  final Cart cart;
  CartUpdated(this.cart);
}
final class OrderFailed extends CartState {
  final String error;
  OrderFailed(this.error);
}
final class PlacingOrder extends CartState {}
final class OrderPlaced extends CartState {}


