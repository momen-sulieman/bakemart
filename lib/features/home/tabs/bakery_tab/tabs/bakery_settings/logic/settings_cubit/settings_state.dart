part of 'settings_cubit.dart';

abstract class SettingsState {}


final class SettingsLoading extends SettingsState {}

final class SettingsSuccess extends SettingsState {
  final BakeryModel bakery;
  final PayrollModel payroll;
  final List<StaffModel> staff;
  final List<ProductModel> products;

  SettingsSuccess({
    required this.bakery,
    required this.payroll,
    required this.staff,
    required this.products,
  });
}

final class SettingsFailure extends SettingsState {
  final String error;

  SettingsFailure(this.error);
}
