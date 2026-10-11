import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/authentication/forgot_password/data/forgot_password_repo.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPasswordRepo _repo;

  ForgotPasswordCubit(this._repo) : super(ForgotPasswordInitial());
  TextEditingController emailController = TextEditingController();

  Future<void> resetPassword() async {
    emit(ForgotPasswordLoading());
    final ResponseResult<bool> resetResponse = await _repo.resetPassword(
      emailController.text,
    );
    if (resetResponse is SuccessResponse) {
      emit(ForgotPasswordSuccess());
    } else {
      emit(ForgotPasswordFailure((resetResponse as FailureResponse).error));
    }
  }
}
