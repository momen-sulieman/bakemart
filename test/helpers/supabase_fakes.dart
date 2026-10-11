import 'dart:async';

import 'package:bakemart/core/services/location_services.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockUser extends Mock implements User {}

class MockLocationServices extends Mock implements LocationServices {}

class FakePostgrestBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {
  final Future<T> Function() _run;
  final Object? _singleValue;

  FakePostgrestBuilder.value(T value, {Object? single})
      : _run = (() async => value),
        _singleValue = single;

  FakePostgrestBuilder.error(Object error)
      : _run = (() async => throw error),
        _singleValue = null;

  FakePostgrestBuilder._(this._run, [this._singleValue]);

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestFilterBuilder<T> inFilter(String column, List values) => this;

  @override
  PostgrestTransformBuilder<T> order(
      String column, {
        bool ascending = false,
        bool nullsFirst = false,
        String? referencedTable,
      }) => this;

  @override
  PostgrestTransformBuilder<PostgrestList> select([String columns = '*']) {
    return FakePostgrestBuilder<PostgrestList>._(() async {
      await _run();
      return <Map<String, dynamic>>[];
    }, _singleValue);
  }

  @override
  PostgrestTransformBuilder<PostgrestMap> single() {
    return FakePostgrestBuilder<PostgrestMap>._(() async {
      await _run();
      return _singleValue as PostgrestMap;
    });
  }

  @override
  PostgrestTransformBuilder<PostgrestMap?> maybeSingle() {
    return FakePostgrestBuilder<PostgrestMap?>._(() async {
      await _run();
      return _singleValue as PostgrestMap?;
    });
  }

  @override
  Future<R> then<R>(
      FutureOr<R> Function(T value) onValue, {
        Function? onError,
      }) {
    return _run().then(onValue, onError: onError);
  }
}