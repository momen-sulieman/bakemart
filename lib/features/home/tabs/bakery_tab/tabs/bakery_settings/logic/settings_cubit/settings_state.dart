part of 'settings_cubit.dart';

abstract class SettingsState {}


final class SettingsLoading extends SettingsState {}

final class SettingsSuccess extends SettingsState {
  final List<BakeryModel> bakeries;
  final List<PayrollModel> payrolls;
  final List<StaffModel> staff;
  final List<ProductModel> products;

  SettingsSuccess({
    required this.bakeries,
    required this.payrolls,
    required this.staff,
    required this.products,
  });
}

final class SettingsFailure extends SettingsState {
  final String error;

  SettingsFailure(this.error);
}
