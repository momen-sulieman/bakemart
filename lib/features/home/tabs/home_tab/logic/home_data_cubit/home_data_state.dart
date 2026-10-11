part of 'home_data_cubit.dart';

abstract class HomeDataState {}

final class HomeDataInitial extends HomeDataState {}
final class HomeDataLoading extends HomeDataState {}
final class HomeDataSuccess extends HomeDataState {}
final class HomeDataFailure extends HomeDataState {
  final String error;
  HomeDataFailure(this.error);
}
