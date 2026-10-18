import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/authentication/sign_in/data/sign__in_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/dependency_injection/dependency_injection.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final SignInRepo _repo;

  SignInCubit(this._repo) : super(SignInInitial());
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> signIn() async {
    emit(SignInLoading());
    await DependencyInjection.resetUserSession();
    final ResponseResult<User> signInResponse = await _repo.signInWithEmail(
      emailController.text,
      passwordController.text,
    );
    if (signInResponse is SuccessResponse<User>) {
      if (signInResponse.data.emailConfirmedAt != null) {
        emit(SignInSuccess());
      } else {
        emit(SignInFailure("Email was not verified!"));
      }
    } else {
      emit(SignInFailure((signInResponse as FailureResponse<User>).error));
    }
  }
}
