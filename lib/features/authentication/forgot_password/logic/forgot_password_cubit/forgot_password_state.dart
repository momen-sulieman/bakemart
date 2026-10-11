part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState {}

final class ForgotPasswordInitial extends ForgotPasswordState {}

final class ForgotPasswordLoading extends ForgotPasswordState {}

final class ForgotPasswordSuccess extends ForgotPasswordState {}

final class ForgotPasswordFailure extends ForgotPasswordState {
  String error;

  ForgotPasswordFailure(this.error);
}
