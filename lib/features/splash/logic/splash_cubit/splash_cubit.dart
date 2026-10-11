import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/core/utils/enums/bingo_keys.dart';
import 'package:bakemart/features/splash/data/splash_repo.dart';
import 'package:bingo/bingo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  final SplashRepo _repo;
  final User? Function() _currentUser;
  final bool Function() _seenOnboarding;
  final Duration _delay;

  SplashCubit(
      this._repo, {
        User? Function()? currentUser,
        bool Function()? seenOnboarding,
        Duration delay = const Duration(seconds: 1),
      }) : _currentUser =
      currentUser ?? (() => Supabase.instance.client.auth.currentUser),
        _seenOnboarding =
            seenOnboarding ??
                (() => (Bingo.call(BingoKeys.seenOnboarding) as bool?) ?? false),
        _delay = delay,
        super(SplashLoading()) {
    route();
  }

  void _emitAfterDelay(SplashState state) {
    Future.delayed(_delay, () {
      if (!isClosed) emit(state);
    });
  }

  Future<void> route() async {
    final userResponse = await _repo.getUserData(_currentUser());
    final seenOnboarding = _seenOnboarding();
    if (!seenOnboarding) {
      _emitAfterDelay(SplashSuccess(AppRoutes.onBoarding.route));
    } else if (userResponse is SuccessResponse<bool>) {
      if (userResponse.data == true) {
        _emitAfterDelay(SplashSuccess(AppRoutes.home.route));
      } else {
        _emitAfterDelay(SplashSuccess(AppRoutes.signIn.route));
      }
    } else {
      _emitAfterDelay(SplashFailure("Something went wrong!"));
    }
  }
}