part of 'delivery_cubit.dart';

abstract class DeliveryState {}

final class NotReceiving extends DeliveryState {}

final class Loading extends DeliveryState {}

final class Receiving extends DeliveryState {}

final class WaitingForLocation extends DeliveryState {
  final LocationFailureReason reason;

  WaitingForLocation(this.reason);
}

final class Failure extends DeliveryState {
  final String error;

  Failure(this.error);
}