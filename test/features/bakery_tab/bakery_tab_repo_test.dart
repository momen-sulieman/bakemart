import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/bakeries_table_columns.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/core/utils/enums/products_table_columns.dart';
import 'package:bakemart/core/utils/enums/recipes_table_columns.dart';
import 'package:bakemart/core/utils/enums/storages_table_columns.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

class FakeSales extends Fake implements SalesModel {
  @override
  final DateTime? date;

  FakeSales(this.date);
}

class FakeFinance extends Fake implements FinanceModel {
  @override
  final DateTime? date;

  FakeFinance(this.date);
}

class FakeShift extends Fake implements ShiftModel {
  @override
  final DateTime? date;

  FakeShift(this.date);
}

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late MockUser authUser;
  late BakeryTabRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    registerFallbackValue(<String, dynamic>{});
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    authUser = MockUser();
    when(() => supabase.auth).thenAnswer((_) => auth);
    when(() => auth.currentUser).thenAnswer((_) => authUser);
    when(() => authUser.id).thenAnswer((_) => 'owner-1');
    repo = BakeryTabRepo(supabase: supabase);
  });

  group('fetching', () {
    late MockSupabaseQueryBuilder query;

    final allFetches = <String, Future<ResponseResult<dynamic>> Function()>{
      'fetchBakery': () => repo.fetchBakery(),
      'fetchStorage': () => repo.fetchStorage(),
      'fetchPayroll': () => repo.fetchPayroll(),
      'fetchProducts': () => repo.fetchProducts(),
      'fetchSales': () => repo.fetchSales(),
      'fetchFinance': () => repo.fetchFinance(),
      'fetchShifts': () => repo.fetchShifts(),
      'fetchStaff': () => repo.fetchStaff(),
    };
    final singleFetches = <String, Future<ResponseResult<dynamic>> Function()>{
      'fetchBakery': () => repo.fetchBakery(),
      'fetchStorage': () => repo.fetchStorage(),
      'fetchPayroll': () => repo.fetchPayroll(),
    };
    final listFetches = <String, Future<ResponseResult<dynamic>> Function()>{
      'fetchProducts': () => repo.fetchProducts(),
      'fetchSales': () => repo.fetchSales(),
      'fetchFinance': () => repo.fetchFinance(),
      'fetchShifts': () => repo.fetchShifts(),
      'fetchStaff': () => repo.fetchStaff(),
    };

    setUp(() {
      query = MockSupabaseQueryBuilder();
      when(() => supabase.from(any())).thenAnswer((_) => query);
    });

    for (final entry in allFetches.entries) {
      test('${entry.key} fails when nobody is signed in', () async {
        when(() => auth.currentUser).thenAnswer((_) => null);

        final result = await entry.value();

        expect(result, isA<FailureResponse>());
        expect((result as FailureResponse).error, 'User is not authenticated.');
      });

      test('${entry.key} fails when the query throws', () async {
        when(() => query.select()).thenAnswer(
              (_) => FakePostgrestBuilder<PostgrestList>.error(
            Exception('offline'),
          ),
        );

        final result = await entry.value();

        expect(result, isA<FailureResponse>());
      });
    }

    for (final entry in singleFetches.entries) {
      test('${entry.key} returns null when there is no row', () async {
        when(() => query.select()).thenAnswer(
              (_) => FakePostgrestBuilder<PostgrestList>.value(
            <Map<String, dynamic>>[],
            single: null,
          ),
        );

        final result = await entry.value();

        expect(result, isA<SuccessResponse>());
        expect((result as SuccessResponse).data, isNull);
      });
    }

    for (final entry in listFetches.entries) {
      test('${entry.key} returns an empty list for no rows', () async {
        when(() => query.select()).thenAnswer(
              (_) => FakePostgrestBuilder<PostgrestList>.value(
            <Map<String, dynamic>>[],
          ),
        );

        final result = await entry.value();

        expect(result, isA<SuccessResponse>());
        expect((result as SuccessResponse).data, isEmpty);
      });
    }

    test('fetchBakery parses the owner bakery', () async {
      when(() => query.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value(
          <Map<String, dynamic>>[],
          single: fakeBakery('owner-1', 30, 31).toJson(),
        ),
      );

      final result = await repo.fetchBakery();

      final bakery = (result as SuccessResponse).data;
      expect(bakery.bakeryId, 'owner-1');
      expect(bakery.bakeryLat, 30);
    });

    test('fetchProducts parses every row', () async {
      when(() => query.select()).thenAnswer(
            (_) => FakePostgrestBuilder<PostgrestList>.value([
          fakeProduct(id: 'p1', bakeryId: 'owner-1').toJson(),
          fakeProduct(id: 'p2', bakeryId: 'owner-1').toJson(),
        ]),
      );

      final result = await repo.fetchProducts();

      final products = (result as SuccessResponse<List<ProductModel>>).data;
      expect(products.map((p) => p.productId), ['p1', 'p2']);
    });
  });

  group('createBakery', () {
    setUp(() {
      when(
            () => supabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer((_) => FakePostgrestBuilder<dynamic>.value(null));
    });

    Future<ResponseResult<bool>> create({List<ProductModel>? products}) {
      return repo.createBakery(
        bakeryData: fakeBakery('', 30, 31),
        products: products ?? [fakeProduct(id: ''), fakeProduct(id: 'p2')],
        payroll: PayrollModel(bakeryId: '', payrollMethod: true),
        storage: StorageModel(bakeryId: ''),
      );
    }

    Map<String, dynamic> sentParams() {
      return verify(
            () => supabase.rpc<dynamic>(
          'create_bakery',
          params: captureAny(named: 'params'),
        ),
      ).captured.single
      as Map<String, dynamic>;
    }

    test('sends everything to the create_bakery function in one call',
            () async {
          final result = await create();

          expect((result as SuccessResponse<bool>).data, true);
          final params = sentParams();
          expect(
            params.keys,
            containsAll(['p_bakery', 'p_products', 'p_payroll', 'p_storage']),
          );
        });

    test('stamps the owner id on the bakery, payroll and storage', () async {
      await create();

      final params = sentParams();
      expect(
        (params['p_bakery'] as Map)[BakeriesTableColumns.bakeryId],
        'owner-1',
      );
      expect(
        (params['p_payroll'] as Map)[PayrollsTableColumns.bakeryId],
        'owner-1',
      );
      expect(
        (params['p_storage'] as Map)[StoragesTableColumns.bakeryId],
        'owner-1',
      );
    });

    test('generates ids only for products without one', () async {
      await create();

      final rows = (sentParams()['p_products'] as List)
          .cast<Map<String, dynamic>>();
      expect(rows[0][ProductsTableColumns.productId], isNotEmpty);
      expect(rows[1][ProductsTableColumns.productId], 'p2');
      expect(
        rows.map((row) => row[ProductsTableColumns.bakeryId]),
        everyElement('owner-1'),
      );
    });

    test('copies the product and bakery ids into each embedded recipe',
            () async {
          await create();

          final rows = (sentParams()['p_products'] as List)
              .cast<Map<String, dynamic>>();
          for (final row in rows) {
            final recipe =
            row[ProductsTableColumns.productRecipe] as Map<String, dynamic>;
            expect(recipe[RecipesTableColumns.bakeryId], 'owner-1');
            expect(
              recipe[RecipesTableColumns.productId],
              row[ProductsTableColumns.productId],
            );
          }
        });

    test('sends an empty product list when there are none', () async {
      final result = await create(products: []);

      expect(result, isA<SuccessResponse<bool>>());
      expect(sentParams()['p_products'], isEmpty);
    });

    test('fails without calling the function when nobody is signed in',
            () async {
          when(() => auth.currentUser).thenAnswer((_) => null);

          final result = await create();

          expect(
            (result as FailureResponse<bool>).error,
            'Failed to assign Bakery ID.',
          );
          verifyNever(
                () => supabase.rpc<dynamic>(any(), params: any(named: 'params')),
          );
        });

    test('returns the database message when the function fails', () async {
      when(
            () => supabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(
          PostgrestException(message: 'duplicate key'),
        ),
      );

      final result = await create();

      expect((result as FailureResponse<bool>).error, 'duplicate key');
    });

    test('returns a failure for any other error', () async {
      when(
            () => supabase.rpc<dynamic>(any(), params: any(named: 'params')),
      ).thenAnswer(
            (_) => FakePostgrestBuilder<dynamic>.error(Exception('offline')),
      );

      final result = await create();

      expect(result, isA<FailureResponse<bool>>());
    });
  });

  group('date filters', () {
    final day = DateTime(2026, 9, 21, 8);
    final sameDayLater = DateTime(2026, 9, 21, 23);
    final otherDay = DateTime(2026, 9, 22, 8);

    test('filterSalesByDate keeps only the selected day', () {
      final matching = FakeSales(day);
      final laterSameDay = FakeSales(sameDayLater);

      final result = repo.filterSalesByDate(
        allSales: [matching, FakeSales(otherDay), FakeSales(null), laterSameDay],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect((result as SuccessResponse<List<SalesModel>>).data, [
        matching,
        laterSameDay,
      ]);
    });

    test('filterShiftsByDate keeps only the selected day', () {
      final matching = FakeShift(day);

      final result = repo.filterShiftsByDate(
        allShifts: [FakeShift(otherDay), matching, FakeShift(null)],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect((result as SuccessResponse<List<ShiftModel>>).data, [matching]);
    });

    test('filterFinanceRecordsByDate returns the first matching record', () {
      final matching = FakeFinance(day);

      final result = repo.filterFinanceRecordsByDate(
        allFinanceRecords: [FakeFinance(otherDay), matching, FakeFinance(day)],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect((result as SuccessResponse<FinanceModel>).data, same(matching));
    });

    test('filterFinanceRecordsByDate fails when the day has no record', () {
      final result = repo.filterFinanceRecordsByDate(
        allFinanceRecords: [FakeFinance(otherDay), FakeFinance(null)],
        selectedDate: DateTime(2026, 9, 21),
      );

      expect(result, isA<FailureResponse<FinanceModel>>());
      expect(
        (result as FailureResponse<FinanceModel>).error,
        'No financial records found for the selected date.',
      );
    });
  });
}