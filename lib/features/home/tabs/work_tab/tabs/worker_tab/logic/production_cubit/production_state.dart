part of 'production_cubit.dart';

abstract class ProductionState {}

final class ProductionInitial extends ProductionState {}

final class ProductionLoading extends ProductionState {}

final class ProductionSuccess extends ProductionState {}

final class ProductionFailure extends ProductionState {
  final String error;

  ProductionFailure(this.error);
}
