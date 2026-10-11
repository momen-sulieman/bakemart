import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/services/location_services.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/core/utils/enums/users_table_columns.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late MockUser authUser;
  late MockSupabaseQueryBuilder usersQuery;
  late MockSupabaseQueryBuilder ordersQuery;
  late MockSupabaseQueryBuilder bakeriesQuery;
  late MockSupabaseQueryBuilder productsQuery;
  late MockSupabaseStorageClient storage;
  late MockStorageFileApi fileApi;
  late MockLocationServices locationServices;
  late HomeRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(<String>[]);
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    authUser = MockUser();
    usersQuery = MockSupabaseQueryBuilder();
    ordersQuery = MockSupabaseQueryBuilder();
    bakeriesQuery = MockSupabaseQueryBuilder();
    productsQuery = MockSupabaseQueryBuilder();
    storage = MockSupabaseStorageClient();
    fileApi = MockStorageFileApi();
    locationServices = MockLocationServices();

    when(() => supabase.auth).thenAnswer((_) => auth);
    when(() => auth.currentUser).thenAnswer((_) => authUser);
    when(() => authUser.id).thenAnswer((_) => 'user-1');
    when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
    when(() => supabase.from(Tables.orders)).thenAnswer((_) => ordersQuery);
    when(() => supabase.from(Tables.bakeries)).thenAnswer((_) => bakeriesQuery);
    when(() => supabase.from(Tables.products)).thenAnswer((_) => productsQuery);
    when(() => supabase.storage).thenAnswer((_) => storage);
    when(() => storage.from(any())).thenAnswer((_) => fileApi);

    repo = HomeRepo(supabase: supabase, locationServices: locationServices);
  });

  group('getUserData', () {
    test('fails when nobody is signed in', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      final result = await repo.getUserData();

      expect(result, isA<FailureResponse<UserModel>>());
      expect(
        (result as FailureResponse<UserModel>).error,
        'User is not authenticated',
      );
    });

    test('returns the parsed user', () async {
      final json = UserModel(
        id: 'user-1',
        firstName: 'Mo',
        secondName: 'Men',
        email: 'mo@test.com',
        phone: '123',
        hasProfileImage: true,
      ).toJson();
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: json,
        ),
      );

      final result = await repo.getUserData();

      expect(result, isA<SuccessResponse<UserModel>>());
      final user = (result as SuccessResponse<UserModel>).data;
      expect(user.id, 'user-1');
      expect(user.firstName, 'Mo');
      expect(user.hasProfileImage, true);
    });

    test('returns a failure when the query throws', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.error(
          PostgrestException(message: 'row not found'),
        ),
      );

      final result = await repo.getUserData();

      expect(result, isA<FailureResponse<UserModel>>());
    });
  });

  group('setProfileImageStatus', () {
    test('updates the has_profile_image column', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.setProfileImageStatus(
        userId: 'user-1',
        hasImage: true,
      );

      expect(result, isA<SuccessResponse<bool>>());
      verify(
            () => usersQuery.update({UsersTableColumns.hasProfileImage: true}),
      ).called(1);
    });

    test('returns the postgrest error message on failure', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(
          PostgrestException(message: 'denied'),
        ),
      );

      final result = await repo.setProfileImageStatus(
        userId: 'user-1',
        hasImage: true,
      );

      expect(result, isA<FailureResponse<bool>>());
      expect((result as FailureResponse<bool>).error, 'denied');
    });
  });

  group('removeProfileImage', () {
    test('deletes the file then sets the flag to false', () async {
      when(
            () => fileApi.remove(any()),
      ).thenAnswer((_) async => <FileObject>[]);
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.removeProfileImage(userId: 'user-1');

      expect(result, isA<SuccessResponse<bool>>());
      verify(() => storage.from(Buckets.usersImages)).called(1);
      verify(() => fileApi.remove(['user-1.jpg'])).called(1);
      verify(
            () => usersQuery.update({UsersTableColumns.hasProfileImage: false}),
      ).called(1);
    });

    test('does not touch the table when storage fails', () async {
      when(() => fileApi.remove(any())).thenThrow(StorageException('nope'));

      final result = await repo.removeProfileImage(userId: 'user-1');

      expect(result, isA<FailureResponse<bool>>());
      expect((result as FailureResponse<bool>).error, 'nope');
      verifyNever(() => usersQuery.update(any()));
    });
  });

  group('cancelOrder', () {
    test('succeeds when the delete goes through', () async {
      when(() => ordersQuery.delete()).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.cancelOrder(orderId: 'o1');

      expect(result, isA<SuccessResponse<void>>());
    });

    test('returns the postgrest error message on failure', () async {
      when(() => ordersQuery.delete()).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(
          PostgrestException(message: 'locked'),
        ),
      );

      final result = await repo.cancelOrder(orderId: 'o1');

      expect(result, isA<FailureResponse<void>>());
      expect((result as FailureResponse<void>).error, 'locked');
    });
  });

  group('logout', () {
    test('signs out', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await repo.logout();

      verify(() => auth.signOut()).called(1);
    });

    test('throws an Exception when sign out fails', () async {
      when(() => auth.signOut()).thenThrow(AuthException('bad session'));

      expect(repo.logout(), throwsA(isA<Exception>()));
    });
  });

  group('changeUserData', () {
    final updated = UserModel(
      id: 'user-1',
      firstName: 'A',
      secondName: 'B',
      email: 'a@b.c',
      phone: '1',
    );

    test('updates the user row', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.changeUserData(updatedUserData: updated);

      expect(result, isA<SuccessResponse<bool>>());
      verify(() => usersQuery.update(updated.toJson())).called(1);
    });

    test('returns a failure when the update throws', () async {
      when(() => usersQuery.update(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(Exception('offline')),
      );

      final result = await repo.changeUserData(updatedUserData: updated);

      expect(result, isA<FailureResponse<bool>>());
    });
  });

  group('streamActiveOrders', () {
    test('is empty when nobody is signed in', () async {
      when(() => auth.currentUser).thenAnswer((_) => null);

      expect(await repo.streamActiveOrders().toList(), isEmpty);
    });
  });

  group('getBakeries', () {
    final near = fakeBakery('b2', 30.01, 31.0);
    final mid = fakeBakery('b1', 30.02, 31.0);
    final far = fakeBakery('b3', 31.0, 31.0);

    setUp(() {
      when(
            () => locationServices.getCurrentLocation(),
      ).thenAnswer((_) async => fakePosition(30.0, 31.0));
    });

    test('keeps bakeries within 10 km sorted by distance and groups products',
            () async {
          when(() => bakeriesQuery.select()).thenAnswer(
                (_) => FakePostgrestBuilder<PostgrestList>.value([
              mid.toJson(),
              far.toJson(),
              near.toJson(),
            ]),
          );
          when(() => productsQuery.select()).thenAnswer(
                (_) => FakePostgrestBuilder<PostgrestList>.value([
              {
                ProductsTableColumns.productId: 'p1',
                ProductsTableColumns.bakeryId: 'b1',
              },
              {
                ProductsTableColumns.productId: 'p2',
                ProductsTableColumns.bakeryId: 'b2',
              },
              {
                ProductsTableColumns.productId: 'p3',
                ProductsTableColumns.bakeryId: 'b3',
              },
            ]),
          );

          final result = await repo.getBakeries();

          expect(
            result,
            isA<SuccessResponse<List<HomeDataBakeriesModel>>>(),
          );
          final data =
              (result as SuccessResponse<List<HomeDataBakeriesModel>>).data;
          expect(data.map((e) => e.bakeryModel.bakeryId), ['b2', 'b1']);
          expect(data[0].productModelList.map((p) => p.productId), ['p2']);
          expect(data[1].productModelList.map((p) => p.productId), ['p1']);
        });

    test('returns an empty list and skips products when nothing is nearby',
            () async {
          when(() => bakeriesQuery.select()).thenAnswer(
                (_) => FakePostgrestBuilder<PostgrestList>.value([far.toJson()]),
          );

          final result = await repo.getBakeries();

          final data =
              (result as SuccessResponse<List<HomeDataBakeriesModel>>).data;
          expect(data, isEmpty);
          verifyNever(() => supabase.from(Tables.products));
        });

    test('returns a failure when location fails', () async {
      when(() => locationServices.getCurrentLocation()).thenThrow(
        LocationServiceException(
          'Location services are disabled.',
          LocationFailureReason.serviceDisabled,
        ),
      );

      final result = await repo.getBakeries();

      expect(result, isA<FailureResponse<List<HomeDataBakeriesModel>>>());
      expect(
        (result as FailureResponse<List<HomeDataBakeriesModel>>).error,
        'Location services are disabled.',
      );
    });

    test('returns a failure when the bakeries query throws', () async {
      when(() => bakeriesQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.error(Exception('offline')),
      );

      final result = await repo.getBakeries();

      expect(result, isA<FailureResponse<List<HomeDataBakeriesModel>>>());
    });
  });
}