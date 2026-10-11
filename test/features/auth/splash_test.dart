import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/routing/app_routes.dart';
import 'package:bakemart/features/splash/data/splash_repo.dart';
import 'package:bakemart/features/splash/logic/splash_cubit/splash_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/supabase_fakes.dart';

class FailingSplashRepo extends SplashRepo {
  @override
  Future<ResponseResult<bool>> getUserData(User? user) async {
    return FailureResponse<bool>('boom');
  }
}

void main() {
  SplashCubit build({
    SplashRepo? repo,
    User? user,
    required bool seenOnboarding,
  }) {
    final cubit = SplashCubit(
      repo ?? SplashRepo(),
      currentUser: () => user,
      seenOnboarding: () => seenOnboarding,
      delay: Duration.zero,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  group('SplashRepo', () {
    test('reports false without a user', () async {
      final result = await SplashRepo().getUserData(null);

      expect((result as SuccessResponse<bool>).data, false);
    });

    test('reports true with a user', () async {
      final result = await SplashRepo().getUserData(MockUser());

      expect((result as SuccessResponse<bool>).data, true);
    });
  });

  group('SplashCubit', () {
    test('starts loading', () {
      final cubit = build(seenOnboarding: true);

      expect(cubit.state, isA<SplashLoading>());
    });

    test('goes to onboarding when it was not seen, even with a user',
            () async {
          final cubit = build(user: MockUser(), seenOnboarding: false);

          await pumpEventQueue();

          expect(
            (cubit.state as SplashSuccess).route,
            AppRoutes.onBoarding.route,
          );
        });

    test('goes home for a signed in user', () async {
      final cubit = build(user: MockUser(), seenOnboarding: true);

      await pumpEventQueue();

      expect((cubit.state as SplashSuccess).route, AppRoutes.home.route);
    });

    test('goes to sign in without a user', () async {
      final cubit = build(seenOnboarding: true);

      await pumpEventQueue();

      expect((cubit.state as SplashSuccess).route, AppRoutes.signIn.route);
    });

    test('fails when the repo fails after onboarding', () async {
      final cubit = build(repo: FailingSplashRepo(), seenOnboarding: true);

      await pumpEventQueue();

      expect(cubit.state, isA<SplashFailure>());
    });

    test('still shows onboarding when the repo fails before it', () async {
      final cubit = build(repo: FailingSplashRepo(), seenOnboarding: false);

      await pumpEventQueue();

      expect(
        (cubit.state as SplashSuccess).route,
        AppRoutes.onBoarding.route,
      );
    });

    test('does not emit after being closed', () async {
      final cubit = build(user: MockUser(), seenOnboarding: true);

      await cubit.close();
      await pumpEventQueue();

      expect(cubit.state, isA<SplashLoading>());
    });
  });
}