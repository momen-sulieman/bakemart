import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/staffs_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
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
  late MockSupabaseQueryBuilder bakeriesQuery;
  late MockSupabaseQueryBuilder payrollsQuery;
  late MockSupabaseQueryBuilder productsQuery;
  late MockSupabaseQueryBuilder staffsQuery;
  late MockSupabaseQueryBuilder usersQuery;
  late SettingsRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(<Map<String, dynamic>>[]);
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    authUser = MockUser();
    bakeriesQuery = MockSupabaseQueryBuilder();
    payrollsQuery = MockSupabaseQueryBuilder();
    productsQuery = MockSupabaseQueryBuilder();
    staffsQuery = MockSupabaseQueryBuilder();
    usersQuery = MockSupabaseQueryBuilder();
    when(() => supabase.auth).thenAnswer((_) => auth);
    when(() => auth.currentUser).thenAnswer((_) => authUser);
    when(() => authUser.id).thenAnswer((_) => 'owner-1');
    when(() => supabase.from(Tables.bakeries)).thenAnswer((_) => bakeriesQuery);
    when(() => supabase.from(Tables.payrolls)).thenAnswer((_) => payrollsQuery);
    when(() => supabase.from(Tables.products)).thenAnswer((_) => productsQuery);
    when(() => supabase.from(Tables.staffs)).thenAnswer((_) => staffsQuery);
    when(() => supabase.from(Tables.users)).thenAnswer((_) => usersQuery);
    repo = SettingsRepo(supabase: supabase);
  });

  test('updateBakeryData updates by bakery id', () async {
    when(() => bakeriesQuery.update(any())).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );
    final bakery = fakeBakery('b1', 1, 2);

    final result = await repo.updateBakeryData(bakery);

    expect(result, isA<SuccessResponse<bool>>());
    verify(() => bakeriesQuery.update(bakery.toJson())).called(1);
  });

  test('updatePayroll updates by bakery id', () async {
    when(() => payrollsQuery.update(any())).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );

    final result = await repo.updatePayroll(fakePayroll(bakeryId: 'b1'));

    expect(result, isA<SuccessResponse<bool>>());
    verify(() => payrollsQuery.update(any())).called(1);
  });

  test('updateProducts upserts on product id conflict', () async {
    when(() => productsQuery.upsert(any(), onConflict: any(named: 'onConflict')))
        .thenAnswer((_) => FakePostgrestBuilder<dynamic>.value(null));
    final products = [fakeProduct(id: 'p1'), fakeProduct(id: 'p2')];

    final result = await repo.updateProducts(products);

    expect(result, isA<SuccessResponse<bool>>());
    verify(
          () => productsQuery.upsert(
        any(),
        onConflict: ProductsTableColumns.productId,
      ),
    ).called(1);
  });

  test('deleteWorker deletes by bakery and worker id', () async {
    when(() => staffsQuery.delete()).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );

    final result = await repo.deleteWorker(worker: fakeStaff());

    expect(result, isA<SuccessResponse<bool>>());
    verify(() => staffsQuery.delete()).called(1);
  });

  test('deleteProduct deletes by product id', () async {
    when(() => productsQuery.delete()).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );

    final result = await repo.deleteProduct(productId: 'p1');

    expect(result, isA<SuccessResponse<bool>>());
  });

  test('getUserData returns the parsed user', () async {
    when(() => usersQuery.select()).thenAnswer(
          (_) => FakePostgrestBuilder<PostgrestList>.value(
        const <Map<String, dynamic>>[],
        single: UserModel(
          id: 'u1',
          firstName: 'A',
          secondName: 'B',
          email: 'a@b.c',
          phone: '1',
        ).toJson(),
      ),
    );

    final result = await repo.getUserData('u1');

    expect((result as SuccessResponse<UserModel>).data.id, 'u1');
  });

  group('addWorker', () {
    test('adds a worker by scanned QR id, using their real name', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          const <Map<String, dynamic>>[],
          single: UserModel(
            id: 'w1',
            firstName: 'Mo',
            secondName: 'Men',
            email: 'mo@test.com',
            phone: '1',
          ).toJson(),
        ),
      );
      when(() => staffsQuery.insert(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.addWorker(workerId: 'w1');

      expect(result, isA<SuccessResponse<bool>>());
      final sent = Map<String, dynamic>.from(
        verify(() => staffsQuery.insert(captureAny())).captured.single
        as Map,
      );
      expect(sent[StaffsTableColumns.workerName], 'Mo Men');
      expect(sent[StaffsTableColumns.workerId], 'w1');
      expect(sent[StaffsTableColumns.bakeryId], 'owner-1');
    });

    test('fails on a QR code with no matching user', () async {
      when(() => usersQuery.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.error(
          Exception('not found'),
        ),
      );

      final result = await repo.addWorker(workerId: 'unknown');

      expect(result, isA<FailureResponse<bool>>());
      expect((result as FailureResponse<bool>).error, 'Wrong QR code');
      verifyNever(() => staffsQuery.insert(any()));
    });

    test('adds a virtual worker with a generated id', () async {
      when(() => staffsQuery.insert(any())).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.value(null),
      );

      final result = await repo.addWorker(workerName: 'Sam');

      expect(result, isA<SuccessResponse<bool>>());
      final sent = Map<String, dynamic>.from(
        verify(() => staffsQuery.insert(captureAny())).captured.single
        as Map,
      );
      expect(sent[StaffsTableColumns.workerName], 'Sam');
      expect(sent[StaffsTableColumns.workerId], isNotEmpty);
      expect(sent[StaffsTableColumns.bakeryId], 'owner-1');
    });
  });
}