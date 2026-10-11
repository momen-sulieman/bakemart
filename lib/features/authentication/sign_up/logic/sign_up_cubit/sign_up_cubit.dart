import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/features/authentication/sign_up/data/sign_up_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final SignUpRepo _repo;
  final SupabaseImageCubit _imageCubit;

  SignUpCubit(this._repo, this._imageCubit) : super(SignUpInitial());
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final TextEditingController streetController = TextEditingController();
  final TextEditingController buildingController = TextEditingController();
  final TextEditingController apartmentController = TextEditingController();
  String phoneNumber = "";
  String countryCode = '+20';

  void updateCountryCode(String newCode) {
    countryCode = newCode;
    emit(SignUpInitial());
  }

  String formatPhoneNumber({
    required String countryCode,
    required String? phoneNumber,
  }) {
    if (phoneNumber == null) {
      return "";
    }
    final cleanNumber = phoneNumber.trim().replaceAll(RegExp(r'\D'), '');
    final normalizedNumber = cleanNumber.startsWith('0')
        ? cleanNumber.substring(1)
        : cleanNumber;

    return '$countryCode$normalizedNumber';
  }

  @override
  Future<void> close() {
    firstNameController.dispose();
    secondNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    return super.close();
  }

  Future<void> signUp() async {
    emit(SignUpLoading());
    phoneNumber = formatPhoneNumber(
      countryCode: countryCode,
      phoneNumber: phoneController.text,
    );
    final ResponseResult<String> signUpResponse = await _repo.signUpWithEmail(
      UserModel(
        firstName: firstNameController.text.trim().capitalize(),
        secondName: secondNameController.text.trim().capitalize(),
        email: emailController.text.trim(),
        phone: phoneNumber,
        street: streetController.text,
        building: buildingController.text,
        apartment: apartmentController.text,
      ),
      passwordController.text,
    );
    if (signUpResponse is SuccessResponse<String>) {
      final newUserId = signUpResponse.data;
      final imageState = _imageCubit.state;
      if (imageState is ImagePicked) {
        final uploadResponse = await _imageCubit.uploadImage(
          imageState.imageFile,
          id: newUserId,
        );
        if (uploadResponse is SuccessResponse<bool>) {
          await _repo.markProfileImageUploaded(newUserId);
        }
      }
      emit(SignUpSuccess());
    } else {
      emit(SignUpFailure((signUpResponse as FailureResponse).error));
    }
  }
}