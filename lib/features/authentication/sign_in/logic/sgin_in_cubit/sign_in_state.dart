part of 'sign_in_cubit.dart';

abstract class SignInState {}

final class SignInInitial extends SignInState {}

final class SignInLoading extends SignInState {}

final class SignInSuccess extends SignInState {}

final class SignInFailure extends SignInState {
  String error;

  SignInFailure(this.error);
}
