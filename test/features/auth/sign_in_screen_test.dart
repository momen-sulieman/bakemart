import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/features/authentication/sign_in/data/sign__in_repo.dart';
import 'package:bakemart/features/authentication/sign_in/logic/sgin_in_cubit/sign_in_cubit.dart';
import 'package:bakemart/features/authentication/sign_in/ui/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockSignInRepo extends Mock implements SignInRepo {}

class MockSupabaseUser extends Mock implements User {}

void main() {
  late MockSignInRepo repo;
  late SignInCubit signInCubit;
  late ObscurityCubit obscurityCubit;

  // The InkWell wrapping the "Login" submit button — the heading above it
  // is also literally the text "Login", so every tap/verify on the button
  // must be scoped to this InkWell, never to find.text('Login') alone.
  final loginButtonFinder = find.widgetWithText(InkWell, 'Login');

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockSignInRepo();
    signInCubit = SignInCubit(repo);
    obscurityCubit = ObscurityCubit();
  });

  tearDown(() {
    signInCubit.close();
    obscurityCubit.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await pumpLocalizedWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<SignInCubit>.value(value: signInCubit),
          BlocProvider<ObscurityCubit>.value(value: obscurityCubit),
        ],
        child: const SignInScreen(),
      ),
    );
    // Make sure the frame (and easy_localization's async asset load) has
    // fully settled before any test starts interacting with widgets.
    await tester.pumpAndSettle();
  }

  Future<void> enterCredentials(WidgetTester tester) async {
    final emailField = find.byType(TextFormField).at(0);
    final passwordField = find.byType(TextFormField).at(1);

    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'mo@bakemart.com');
    await tester.pump();

    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, 'secret123');
    await tester.pump();
  }

  testWidgets('renders the email and password fields and the Login button',
          (tester) async {
        await pumpScreen(tester);

        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        // "Login" appears twice on this screen: the heading and the button label.
        expect(find.text('Login'), findsNWidgets(2));
        expect(loginButtonFinder, findsOneWidget);
      });

  testWidgets('shows a validation error when submitting empty fields',
          (tester) async {
        await pumpScreen(tester);

        await tester.ensureVisible(loginButtonFinder);
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Cannot be empty'), findsNWidgets(2));
        verifyNever(() => repo.signInWithEmail(any(), any()));
      });

  testWidgets('obscurity icon toggles password visibility', (tester) async {
    await pumpScreen(tester);

    expect(obscurityCubit.state, true);
    // obscurityState == true renders Icons.remove_red_eye (not _outlined).
    expect(find.byIcon(Icons.remove_red_eye), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_red_eye));
    await tester.pumpAndSettle();

    expect(obscurityCubit.state, false);
    expect(find.byIcon(Icons.remove_red_eye_outlined), findsOneWidget);
  });

  testWidgets('signs in with the typed credentials on valid submit',
          (tester) async {
        final user = MockSupabaseUser();
        when(() => user.emailConfirmedAt).thenReturn('2026-01-01');
        when(
              () => repo.signInWithEmail(any(), any()),
        ).thenAnswer((_) async => SuccessResponse<User>(user));

        await pumpScreen(tester);
        await enterCredentials(tester);

        await tester.ensureVisible(loginButtonFinder);
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle();

        verify(() => repo.signInWithEmail('mo@bakemart.com', 'secret123'))
            .called(1);
      });

  testWidgets('shows the repo error in a snackbar on sign-in failure',
          (tester) async {
        when(
              () => repo.signInWithEmail(any(), any()),
        ).thenAnswer((_) async => FailureResponse<User>('Invalid credentials'));

        await pumpScreen(tester);
        await enterCredentials(tester);

        await tester.ensureVisible(loginButtonFinder);
        await tester.tap(loginButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Invalid credentials'), findsOneWidget);
      });
}