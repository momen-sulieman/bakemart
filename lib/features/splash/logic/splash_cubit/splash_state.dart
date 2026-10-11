part of 'splash_cubit.dart';

abstract class SplashState {}

final class SplashLoading extends SplashState {}
final class SplashSuccess extends SplashState {
  final String route;
  SplashSuccess(this.route);
}
final class SplashFailure extends SplashState {
  final String error;
  SplashFailure(this.error);
}
