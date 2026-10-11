import 'package:bakemart/core/network/response_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignInRepo {
  final SupabaseClient _supabase;

  SignInRepo({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<ResponseResult<User>> signInWithEmail(
      String email,
      String password,
      ) async {
    try {
      final AuthResponse authResponse = await _supabase.auth.signInWithPassword(
        password: password.trim(),
        email: email.trim(),
      );
      if (authResponse.user != null) {
        return SuccessResponse(authResponse.user!);
      }
      return FailureResponse("Something went wrong!");
    } on AuthException catch (error) {
      return FailureResponse(error.message);
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}