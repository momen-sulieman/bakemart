import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/utils/enums/storages_table_columns.dart';
import 'package:bakemart/core/utils/enums/tables.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/supabase_fakes.dart';
import '../../helpers/test_setup.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockSupabaseQueryBuilder query;
  late StorageRepo repo;

  setUpAll(() async {
    registerFallbackValue(<dynamic, dynamic>{});
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    query = MockSupabaseQueryBuilder();
    when(() => supabase.from(Tables.storages)).thenAnswer((_) => query);
    repo = StorageRepo(supabase: supabase);
  });

  test('updateStorage sends the storage json keyed by bakery id', () async {
    when(() => query.update(any())).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.value(null),
    );
    final storage = fakeStorage(bakeryId: 'b1');

    final result = await repo.updateStorage(storage);

    expect(result, isA<SuccessResponse<bool>>());
    final sent = Map<String, dynamic>.from(
      verify(() => query.update(captureAny())).captured.single as Map,
    );
    expect(sent[StoragesTableColumns.bakeryId], 'b1');
  });

  test('returns a failure when the update throws', () async {
    when(() => query.update(any())).thenAnswer(
          (_) => FakePostgrestBuilder<dynamic>.error(Exception('offline')),
    );

    final result = await repo.updateStorage(fakeStorage());

    expect(result, isA<FailureResponse<bool>>());
  });
}