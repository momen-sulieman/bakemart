import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/features/authentication/sign_up/data/sign_up_repo.dart';
import 'package:bakemart/features/authentication/sign_up/logic/sign_up_cubit/sign_up_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

class MockSignUpRepo extends Mock implements SignUpRepo {}

class MockSupabaseImageCubit extends Mock implements SupabaseImageCubit {}

void main() {
  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(
      UserModel(firstName: '', secondName: '', email: '', phone: ''),
    );
    await setupTestEnvironment();
  });

  group('SignUpRepo', () {
    late MockGoTrueClient auth;
    late MockUser authUser;
    late MockSupabaseQueryBuilder usersQuery;
    late SignUpRepo repo;

    final user = UserModel(
      firstName: 'Mo',
      secondName: 'Men',
      email: ' a@b.c ',
      phone: '+201012345678',
      street: 'Main',
    );

    setUp(() {
      final supabase = MockSupabaseClient();
      auth = MockGoTrueClient();
      authUser = MockUser();
      usersQuery = MockSupabaseQueryBuilder();
      when(() => supabase.auth).thenAnswer((_) => auth);
      when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
      when(() => authUser.id).thenAnswer((_) => 'auth-1');
      repo = SignUpRepo(supabase: supabase);
    });

    void stubSignUp(Future<AuthResponse> Function() answer) {
      when(
            () => auth.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) => answer());
    }

    test('creates the account with the profile as metadata', () async {
      stubSignUp(() async => AuthResponse(user: authUser));

      final result = await repo.signUpWithEmail(user, ' secret ');

      expect((result as SuccessResponse<String>).data, 'auth-1');
      final data =
      verify(
            () => auth.signUp(
          email: 'a@b.c',
          password: 'secret',
          data: captureAny(named: 'data'),
        ),
      ).captured.single
      as Map<String, dynamic>;
      expect(data[UsersTableColumns.firstName], 'Mo');
      expect(data[UsersTableColumns.secondName], 'Men');
      expect(data[UsersTableColumns.phone], '+201012345678');
      expect(data[UsersTableColumns.street], 'Main');
    });

    test('never writes the users table itself', () async {
      stubSignUp(() async => AuthResponse(user: authUser));

      await repo.signUpWithEmail(user, 'secret');

      verifyNever(() => usersQuery.insert(any()));
    });

    test('fails when auth returns no user', () async {
      stubSignUp(() async => AuthResponse());

      final result = await repo.signUpWithEmail(user, 'secret');

      expect(result, isA<FailureResponse<String>>());
    });

    test('returns the auth error message', () async {
      stubSignUp(() async => throw AuthException('already registered'));

      final result = await repo.signUpWithEmail(user, 'secret');

      expect((result as FailureResponse<String>).error, 'already registered');
    });

    test('markProfileImageUploaded sets the flag for the user', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.markProfileImageUploaded('auth-1');

      expect((result as SuccessResponse<bool>).data, true);
      verify(
            () => usersQuery.update({UsersTableColumns.hasProfileImage: true}),
      ).called(1);
    });

    test('markProfileImageUploaded returns a failure on error', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(Exception('offline')),
      );

      final result = await repo.markProfileImageUploaded('auth-1');

      expect(result, isA<FailureResponse<bool>>());
    });
  });

  group('SignUpCubit', () {
    late MockSignUpRepo repo;
    late MockSupabaseImageCubit imageCubit;
    late SignUpCubit cubit;
    late List<SignUpState> states;

    void fillForm() {
      cubit.firstNameController.text = '  mo ';
      cubit.secondNameController.text = ' men';
      cubit.emailController.text = ' a@b.c ';
      cubit.passwordController.text = 'secret';
      cubit.phoneController.text = '010 1234-5678';
      cubit.streetController.text = 'Main';
      cubit.buildingController.text = '12';
      cubit.apartmentController.text = '3';
    }

    setUp(() {
      repo = MockSignUpRepo();
      imageCubit = MockSupabaseImageCubit();
      when(() => imageCubit.state).thenAnswer((_) => ImageEmpty());
      when(
            () => repo.signUpWithEmail(any(), any()),
      ).thenAnswer((_) async => SuccessResponse<String>('new-id'));
      when(
            () => repo.markProfileImageUploaded(any()),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      when(
            () => imageCubit.uploadImage(any(), id: any(named: 'id')),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit = SignUpCubit(repo, imageCubit);
      states = [];
      cubit.stream.listen(states.add);
    });

    tearDown(() async {
      await cubit.close();
    });

    group('formatPhoneNumber', () {
      test('drops the leading zero and non digits', () {
        expect(
          cubit.formatPhoneNumber(
            countryCode: '+20',
            phoneNumber: '010 1234-5678',
          ),
          '+201012345678',
        );
      });

      test('keeps a number without a leading zero', () {
        expect(
          cubit.formatPhoneNumber(countryCode: '+20', phoneNumber: '1012345678'),
          '+201012345678',
        );
      });

      test('is empty for a null number', () {
        expect(
          cubit.formatPhoneNumber(countryCode: '+20', phoneNumber: null),
          '',
        );
      });
    });

    test('updateCountryCode stores the code and emits initial', () async {
      cubit.updateCountryCode('+966');
      await pumpEventQueue();

      expect(cubit.countryCode, '+966');
      expect(states, [isA<SignUpInitial>()]);
    });

    test('sends a cleaned user and succeeds without a picked image',
            () async {
          fillForm();

          await cubit.signUp();
          await pumpEventQueue();

          expect(states, [isA<SignUpLoading>(), isA<SignUpSuccess>()]);
          final captured = verify(
                () => repo.signUpWithEmail(captureAny(), 'secret'),
          ).captured;
          final sent = captured.single as UserModel;
          expect(sent.firstName, 'mo'.capitalize());
          expect(sent.secondName, 'men'.capitalize());
          expect(sent.email, 'a@b.c');
          expect(sent.phone, '+201012345678');
          expect(sent.street, 'Main');
          expect(sent.building, '12');
          expect(sent.apartment, '3');
          expect(cubit.phoneNumber, '+201012345678');
          verifyNever(() => imageCubit.uploadImage(any(), id: any(named: 'id')));
          verifyNever(() => repo.markProfileImageUploaded(any()));
        });

    test('uploads the picked image and marks the profile', () async {
      fillForm();
      final photo = File('photo.jpg');
      when(() => imageCubit.state).thenAnswer((_) => ImagePicked(photo));

      await cubit.signUp();
      await pumpEventQueue();

      expect(states, [isA<SignUpLoading>(), isA<SignUpSuccess>()]);
      verify(() => imageCubit.uploadImage(photo, id: 'new-id')).called(1);
      verify(() => repo.markProfileImageUploaded('new-id')).called(1);
    });

    test('still succeeds but skips the flag when the upload fails', () async {
      fillForm();
      when(
            () => imageCubit.state,
      ).thenAnswer((_) => ImagePicked(File('photo.jpg')));
      when(
            () => imageCubit.uploadImage(any(), id: any(named: 'id')),
      ).thenAnswer((_) async => FailureResponse<bool>('quota'));

      await cubit.signUp();
      await pumpEventQueue();

      expect(states, [isA<SignUpLoading>(), isA<SignUpSuccess>()]);
      verifyNever(() => repo.markProfileImageUploaded(any()));
    });

    test('emits the error and skips the upload when sign up fails', () async {
      fillForm();
      when(
            () => repo.signUpWithEmail(any(), any()),
      ).thenAnswer((_) async => FailureResponse<String>('already registered'));
      when(
            () => imageCubit.state,
      ).thenAnswer((_) => ImagePicked(File('photo.jpg')));

      await cubit.signUp();
      await pumpEventQueue();

      expect(states, [isA<SignUpLoading>(), isA<SignUpFailure>()]);
      expect((states.last as SignUpFailure).error, 'already registered');
      verifyNever(() => imageCubit.uploadImage(any(), id: any(named: 'id')));
    });
  });
}