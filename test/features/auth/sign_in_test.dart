import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/authentication/sign_in/data/sign__in_repo.dart';
import 'package:bakemart/features/authentication/sign_in/logic/sgin_in_cubit/sign_in_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/supabase_fakes.dart';

class MockSignInRepo extends Mock implements SignInRepo {}

void main() {
  group('SignInRepo', () {
    late MockGoTrueClient auth;
    late MockUser user;
    late SignInRepo repo;

    setUp(() {
      final supabase = MockSupabaseClient();
      auth = MockGoTrueClient();
      user = MockUser();
      when(() => supabase.auth).thenAnswer((_) => auth);
      repo = SignInRepo(supabase: supabase);
    });

    void stubSignIn(Future<AuthResponse> Function() answer) {
      when(
            () => auth.signInWithPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => answer());
    }

    test('returns the user and trims the credentials', () async {
      stubSignIn(() async => AuthResponse(user: user));

      final result = await repo.signInWithEmail('  a@b.c ', ' secret ');

      expect((result as SuccessResponse<User>).data, same(user));
      verify(
            () => auth.signInWithPassword(email: 'a@b.c', password: 'secret'),
      ).called(1);
    });

    test('fails when the response has no user', () async {
      stubSignIn(() async => AuthResponse());

      final result = await repo.signInWithEmail('a@b.c', 'secret');

      expect(result, isA<FailureResponse<User>>());
      expect((result as FailureResponse<User>).error, 'Something went wrong!');
    });

    test('returns the auth error message for a wrong password', () async {
      stubSignIn(() async => throw AuthException('Invalid login credentials'));

      final result = await repo.signInWithEmail('a@b.c', 'wrong');

      expect(result, isA<FailureResponse<User>>());
      expect(
        (result as FailureResponse<User>).error,
        'Invalid login credentials',
      );
    });

    test('returns a failure for any other error', () async {
      stubSignIn(() async => throw Exception('offline'));

      final result = await repo.signInWithEmail('a@b.c', 'secret');

      expect(result, isA<FailureResponse<User>>());
    });
  });

  group('SignInCubit', () {
    late MockSignInRepo repo;
    late MockUser user;
    late SignInCubit cubit;
    late List<SignInState> states;

    setUp(() {
      repo = MockSignInRepo();
      user = MockUser();
      cubit = SignInCubit(repo);
      states = [];
      cubit.stream.listen(states.add);
      cubit.emailController.text = 'a@b.c';
      cubit.passwordController.text = 'secret';
    });

    tearDown(() async {
      await cubit.close();
    });

    test('emits loading then success for a verified user', () async {
      when(() => user.emailConfirmedAt).thenAnswer((_) => '2026-01-01');
      when(
            () => repo.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => SuccessResponse<User>(user));

      await cubit.signIn();
      await pumpEventQueue();

      expect(states, [isA<SignInLoading>(), isA<SignInSuccess>()]);
      verify(() => repo.signInWithEmail('a@b.c', 'secret')).called(1);
    });

    test('rejects a user whose email is not verified', () async {
      when(() => user.emailConfirmedAt).thenAnswer((_) => null);
      when(
            () => repo.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => SuccessResponse<User>(user));

      await cubit.signIn();
      await pumpEventQueue();

      expect(states, [isA<SignInLoading>(), isA<SignInFailure>()]);
      expect((states.last as SignInFailure).error, 'Email was not verified!');
    });

    test('emits the repo error when sign in fails', () async {
      when(
            () => repo.signInWithEmail(any(), any()),
      ).thenAnswer((_) async => FailureResponse<User>('Invalid credentials'));

      await cubit.signIn();
      await pumpEventQueue();

      expect(states, [isA<SignInLoading>(), isA<SignInFailure>()]);
      expect((states.last as SignInFailure).error, 'Invalid credentials');
    });
  });
}