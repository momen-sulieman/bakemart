import 'package:bakemart/core/network/response_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashRepo {

  Future<ResponseResult<bool>> getUserData(User? user) async {
    try {
      if (user != null) {
        return SuccessResponse(true);
      } else {
        return SuccessResponse(false);
      }
    } catch (error) {
      return FailureResponse(error.toString());
    }
  }
}
