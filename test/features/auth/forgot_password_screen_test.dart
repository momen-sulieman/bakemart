import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/authentication/forgot_password/data/forgot_password_repo.dart';
import 'package:bakemart/features/authentication/forgot_password/logic/forgot_password_cubit/forgot_password_cubit.dart';
import 'package:bakemart/features/authentication/forgot_password/ui/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockForgotPasswordRepo extends Mock implements ForgotPasswordRepo {}

void main() {
  late MockForgotPasswordRepo repo;
  late ForgotPasswordCubit cubit;

  final sendButtonFinder = find.widgetWithText(InkWell, 'Send an e-mail');

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockForgotPasswordRepo();
    cubit = ForgotPasswordCubit(repo);
  });

  tearDown(() {
    cubit.close();
  });

  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      BlocProvider<ForgotPasswordCubit>.value(
        value: cubit,
        child: const ForgotPasswordScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the heading, email field and send button',
          (tester) async {
        await pumpScreen(tester);

        expect(find.text('Reset password'), findsOneWidget);
        expect(find.byType(TextFormField), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Send an e-mail'), findsOneWidget);
        expect(cubit.state, isA<ForgotPasswordInitial>());
      });

  testWidgets('shows a validation error and does not call the repo on empty submit',
          (tester) async {
        await pumpScreen(tester);

        await tester.ensureVisible(sendButtonFinder);
        await tester.tap(sendButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Cannot be empty'), findsOneWidget);
        verifyNever(() => repo.resetPassword(any()));
        expect(cubit.state, isA<ForgotPasswordInitial>());
      });

  testWidgets('typing in the field updates the cubit email controller',
          (tester) async {
        await pumpScreen(tester);

        await tester.enterText(find.byType(TextFormField), 'mo@bakemart.com');
        await tester.pump();

        expect(cubit.emailController.text, 'mo@bakemart.com');
      });

  testWidgets('submits the typed email and ends in success', (tester) async {
    when(() => repo.resetPassword('mo@bakemart.com'))
        .thenAnswer((_) async => SuccessResponse<bool>(true));

    await pumpScreen(tester);
    await tester.enterText(find.byType(TextFormField), 'mo@bakemart.com');
    await tester.pump();

    await tester.ensureVisible(sendButtonFinder);
    await tester.tap(sendButtonFinder);
    await tester.pumpAndSettle();

    verify(() => repo.resetPassword('mo@bakemart.com')).called(1);
    expect(cubit.state, isA<ForgotPasswordSuccess>());
  });

  testWidgets('ends in failure with the repo error when the request fails',
          (tester) async {
        when(() => repo.resetPassword('mo@bakemart.com'))
            .thenAnswer((_) async => FailureResponse<bool>('boom'));

        await pumpScreen(tester);
        await tester.enterText(find.byType(TextFormField), 'mo@bakemart.com');
        await tester.pump();

        await tester.ensureVisible(sendButtonFinder);
        await tester.tap(sendButtonFinder);
        await tester.pumpAndSettle();

        verify(() => repo.resetPassword('mo@bakemart.com')).called(1);
        expect(cubit.state, isA<ForgotPasswordFailure>());
        expect((cubit.state as ForgotPasswordFailure).error, 'boom');
      });

  testWidgets('shows the failure snackbar and keeps the button visible',
          (tester) async {
        when(() => repo.resetPassword('mo@bakemart.com'))
            .thenAnswer((_) async => FailureResponse<bool>('boom'));

        await pumpScreen(tester);
        await tester.enterText(find.byType(TextFormField), 'mo@bakemart.com');
        await tester.pump();

        await tester.ensureVisible(sendButtonFinder);
        await tester.tap(sendButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Request Failed!'), findsOneWidget);
        expect(find.text('Send an e-mail'), findsOneWidget);
      });

  testWidgets('pops the screen and shows the sent snackbar on success',
          (tester) async {
        when(() => repo.resetPassword('mo@bakemart.com'))
            .thenAnswer((_) async => SuccessResponse<bool>(true));

        useTallSurface(tester);
        await pumpLocalizedWidget(
          tester,
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider<ForgotPasswordCubit>.value(
                        value: cubit,
                        child: const ForgotPasswordScreen(),
                      ),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.byType(ForgotPasswordScreen), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), 'mo@bakemart.com');
        await tester.pump();
        await tester.ensureVisible(sendButtonFinder);
        await tester.tap(sendButtonFinder);
        await tester.pumpAndSettle();

        expect(find.byType(ForgotPasswordScreen), findsNothing);
        expect(find.text('E-mail sent!'), findsOneWidget);
      });
}