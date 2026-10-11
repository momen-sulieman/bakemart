part of 'bakery_tab_cubit.dart';

abstract class BakeryTabState {}

final class BakeryTabLoading extends BakeryTabState {}

final class HasNoBakery extends BakeryTabState {}

final class HasBakery extends BakeryTabState {}
final class HasNoStaff extends BakeryTabState {}

final class BakeryTabFailure extends BakeryTabState {
  final String error;

  BakeryTabFailure(this.error);
}
