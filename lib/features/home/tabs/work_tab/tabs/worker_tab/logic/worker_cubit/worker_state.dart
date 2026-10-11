part of 'worker_cubit.dart';

abstract class WorkerState {}

final class WorkerLoading extends WorkerState {}

final class WorkerFailure extends WorkerState {
  final String error;

  WorkerFailure(this.error);
}

final class Supervisor extends WorkerState {
  final UserModel? user;
  final BakeryModel? bakery;
  final PayrollModel? payroll;
  final List<ProductModel>? products;
  final List<StaffModel>? staff;
  final List<ShiftModel>? shifts;
  final List<FinanceModel>? finance;

  Supervisor({
    required this.user,
    required this.bakery,
    required this.payroll,
    required this.products,
    required this.staff,
    required this.shifts,
    required this.finance,
  });
}

final class Employed extends WorkerState {
  final UserModel user;
  final BakeryModel bakery;

  Employed(this.user, this.bakery);
}

final class UnEmployed extends WorkerState {
  final UserModel user;

  UnEmployed(this.user);
}
