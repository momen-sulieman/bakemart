part of 'shifts_cubit.dart';

enum ShiftsAction { save, deleteWorker }

abstract class ShiftsState {}

final class ShiftsInitial extends ShiftsState {}

final class ShiftsLoading extends ShiftsState {
  final String? targetId;
  final ShiftsAction action;

  ShiftsLoading({this.targetId, this.action = ShiftsAction.save});
}

final class ShiftsSuccess extends ShiftsState {}

final class ShiftsFailure extends ShiftsState {
  final String error;
  ShiftsFailure(this.error);
}