import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/obscurity_cubit/obscurity_cubit.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/features/authentication/sign_up/data/sign_up_repo.dart';
import 'package:bakemart/features/authentication/sign_up/logic/sign_up_cubit/sign_up_cubit.dart';
import 'package:bakemart/features/authentication/sign_up/ui/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockSignUpRepo extends Mock implements SignUpRepo {}

void main() {
  late MockSignUpRepo repo;
  late SignUpCubit cubit;
  late ObscurityCubit obscurityCubit;
  late SupabaseImageCubit imageCubit;

  final signUpButtonFinder = find.widgetWithText(InkWell, 'Sign up');

  setUpAll(() async {
    await setupTestEnvironment();
    registerFallbackValue(
      UserModel(firstName: '', secondName: '', email: '', phone: ''),
    );
  });

  setUp(() {
    repo = MockSignUpRepo();
    imageCubit = SupabaseImageCubit(Buckets.usersImages, null);
    obscurityCubit = ObscurityCubit();
    cubit = SignUpCubit(repo, imageCubit);
  });

  tearDown(() {
    cubit.close();
    obscurityCubit.close();
    imageCubit.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 2400));
    await pumpLocalizedWidget(
      tester,
      MultiBlocProvider(
        providers: [
          BlocProvider<SignUpCubit>.value(value: cubit),
          BlocProvider<ObscurityCubit>.value(value: obscurityCubit),
          BlocProvider<SupabaseImageCubit>.value(value: imageCubit),
        ],
        child: const SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterRequiredFields(
      WidgetTester tester, {
        String firstName = 'Mo',
        String secondName = 'Amin',
        String phone = '01012345678',
        String email = 'mo@bakemart.com',
        String password = 'secret123',
        String? confirmPassword,
      }) async {
    final fields = find.byType(TextFormField);
    Future<void> enter(int index, String value) async {
      final field = fields.at(index);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pump();
    }

    await enter(0, firstName);
    await enter(1, secondName);
    await enter(2, phone);
    await enter(3, email);
    await enter(4, password);
    await enter(5, confirmPassword ?? password);
  }

  testWidgets('renders the required fields and the Sign up button',
          (tester) async {
        await pumpScreen(tester);

        expect(find.byType(TextFormField), findsNWidgets(9));
        expect(find.text('First name'), findsOneWidget);
        expect(find.text('Second name'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Confirm password'), findsOneWidget);
        expect(find.text('Street name'), findsOneWidget);
        expect(find.text('Building no.'), findsOneWidget);
        expect(find.text('Apartment no.'), findsOneWidget);
        expect(signUpButtonFinder, findsOneWidget);
      });

  testWidgets(
      'shows a validation error on every required field and does not call the repo on empty submit',
          (tester) async {
        await pumpScreen(tester);

        await tester.ensureVisible(signUpButtonFinder);
        await tester.tap(signUpButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Cannot be empty'), findsNWidgets(6));
        verifyNever(() => repo.signUpWithEmail(any(), any()));
      });

  testWidgets('does not call the repo when the passwords do not match',
          (tester) async {
        await pumpScreen(tester);
        await enterRequiredFields(tester, confirmPassword: 'different1');

        await tester.ensureVisible(signUpButtonFinder);
        await tester.tap(signUpButtonFinder);
        await tester.pumpAndSettle();

        verifyNever(() => repo.signUpWithEmail(any(), any()));
      });

  testWidgets(
      'formats the phone number, signs up with the typed data and ends in success',
          (tester) async {
        when(() => repo.signUpWithEmail(any(), 'secret123'))
            .thenAnswer((_) async => SuccessResponse<String>('new-user-id'));
        when(() => repo.markProfileImageUploaded(any()))
            .thenAnswer((_) async => SuccessResponse<bool>(true));

        await pumpScreen(tester);
        await enterRequiredFields(tester);

        await tester.ensureVisible(signUpButtonFinder);
        await tester.tap(signUpButtonFinder);
        await tester.pumpAndSettle();

        final captured = verify(
              () => repo.signUpWithEmail(captureAny(), 'secret123'),
        ).captured;
        final submittedUser = captured.single;
        expect(submittedUser.email, 'mo@bakemart.com');
        expect(submittedUser.phone, '+201012345678');

        expect(cubit.state, isA<SignUpSuccess>());
        verifyNever(() => repo.markProfileImageUploaded(any()));
      });

  testWidgets('shows the repo error in a snackbar on sign-up failure',
          (tester) async {
        when(() => repo.signUpWithEmail(any(), any()))
            .thenAnswer((_) async => FailureResponse<String>('Email already used'));

        await pumpScreen(tester);
        await enterRequiredFields(tester);

        await tester.ensureVisible(signUpButtonFinder);
        await tester.tap(signUpButtonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Email already used'), findsOneWidget);
        expect(cubit.state, isA<SignUpFailure>());
      });
}