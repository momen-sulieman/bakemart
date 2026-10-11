import 'package:bakemart/core/network/response_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordRepo {
  final SupabaseClient _supabase;

  ForgotPasswordRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<bool>> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return SuccessResponse(true);
    } on AuthException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
