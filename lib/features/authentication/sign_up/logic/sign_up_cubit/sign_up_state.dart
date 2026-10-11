part of 'sign_up_cubit.dart';
abstract class SignUpState {}

final class SignUpInitial extends SignUpState {}
final class SignUpLoading extends SignUpState {}
final class SignUpSuccess extends SignUpState {}
final class SignUpFailure extends SignUpState {
  String error;
  SignUpFailure(this.error);
}
