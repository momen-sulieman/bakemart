import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/authentication/forgot_password/data/forgot_password_repo.dart';
import 'package:bakemart/features/authentication/forgot_password/logic/forgot_password_cubit/forgot_password_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/supabase_fakes.dart';

class MockForgotPasswordRepo extends Mock implements ForgotPasswordRepo {}

void main() {
  group('ForgotPasswordRepo', () {
    late MockGoTrueClient auth;
    late ForgotPasswordRepo repo;

    setUp(() {
      final supabase = MockSupabaseClient();
      auth = MockGoTrueClient();
      when(() => supabase.auth).thenAnswer((_) => auth);
      repo = ForgotPasswordRepo(supabase: supabase);
    });

    test('sends the reset email', () async {
      when(() => auth.resetPasswordForEmail(any())).thenAnswer((_) async {});

      final result = await repo.resetPassword('a@b.c');

      expect((result as SuccessResponse<bool>).data, true);
      verify(() => auth.resetPasswordForEmail('a@b.c')).called(1);
    });

    test('returns the auth error message', () async {
      when(
            () => auth.resetPasswordForEmail(any()),
      ).thenThrow(AuthException('rate limited'));

      final result = await repo.resetPassword('a@b.c');

      expect(result, isA<FailureResponse<bool>>());
      expect((result as FailureResponse<bool>).error, 'rate limited');
    });

    test('returns a failure for any other error', () async {
      when(
            () => auth.resetPasswordForEmail(any()),
      ).thenThrow(Exception('offline'));

      final result = await repo.resetPassword('a@b.c');

      expect(result, isA<FailureResponse<bool>>());
    });
  });

  group('ForgotPasswordCubit', () {
    late MockForgotPasswordRepo repo;
    late ForgotPasswordCubit cubit;
    late List<ForgotPasswordState> states;

    setUp(() {
      repo = MockForgotPasswordRepo();
      cubit = ForgotPasswordCubit(repo);
      states = [];
      cubit.stream.listen(states.add);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('starts initial', () {
      expect(cubit.state, isA<ForgotPasswordInitial>());
    });

    test('emits loading then success and sends the typed email', () async {
      when(
            () => repo.resetPassword(any()),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit.emailController.text = 'a@b.c';

      await cubit.resetPassword();
      await pumpEventQueue();

      expect(states, [
        isA<ForgotPasswordLoading>(),
        isA<ForgotPasswordSuccess>(),
      ]);
      verify(() => repo.resetPassword('a@b.c')).called(1);
    });

    test('emits loading then failure with the error', () async {
      when(
            () => repo.resetPassword(any()),
      ).thenAnswer((_) async => FailureResponse<bool>('no such user'));

      await cubit.resetPassword();
      await pumpEventQueue();

      expect(states, [
        isA<ForgotPasswordLoading>(),
        isA<ForgotPasswordFailure>(),
      ]);
      expect((states.last as ForgotPasswordFailure).error, 'no such user');
    });
  });
}