import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepo {
  final SupabaseClient _supabase;

  SignUpRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;
  Future<ResponseResult<String>> signUpWithEmail(
      UserModel user,
      String password,
      ) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signUp(
        password: password.trim(),
        email: user.email.trim(),
        data: {
          UsersTableColumns.firstName: user.firstName,
          UsersTableColumns.secondName: user.secondName,
          UsersTableColumns.phone: user.phone,
          UsersTableColumns.street: user.street,
          UsersTableColumns.building: user.building,
          UsersTableColumns.apartment: user.apartment,
        },
      );
      final User? created = authResponse.user;
      if (created == null) {
        return FailureResponse("Sign up faild!");
      }
      return SuccessResponse(created.id);
    } on AuthException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }

  Future<ResponseResult<bool>> markProfileImageUploaded(String userId) async {
    try {
      await _supabase
          .from(Tables.users)
          .update({UsersTableColumns.hasProfileImage: true})
          .eq(UsersTableColumns.id, userId);
      return SuccessResponse(true);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}