import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/supabase_fakes.dart';
import '../helpers/test_setup.dart';

void main() {
  late MockSupabaseClient supabase;
  late MockSupabaseStorageClient storage;
  late MockStorageFileApi fileApi;

  setUpAll(() async {
    registerFallbackValue(File('fallback.jpg'));
    registerFallbackValue(const FileOptions());
    await setupTestEnvironment();
  });

  setUp(() {
    supabase = MockSupabaseClient();
    storage = MockSupabaseStorageClient();
    fileApi = MockStorageFileApi();
    when(() => supabase.storage).thenReturn(storage);
    when(() => storage.from(any())).thenReturn(fileApi);
    when(() => fileApi.getPublicUrl(any())).thenAnswer(
          (invocation) =>
      'https://cdn.test/${invocation.positionalArguments.first}',
    );
  });

  SupabaseImageCubit build(
      String bucket,
      String? name, {
        bool skipInitialFetch = false,
      }) {
    final cubit = SupabaseImageCubit(
      bucket,
      name,
      skipInitialFetch: skipInitialFetch,
      supabase: supabase,
    );
    addTearDown(cubit.close);
    return cubit;
  }

  test('is empty when there is no file name', () async {
    final cubit = build('bucket_null', null);

    expect(cubit.state, isA<ImageEmpty>());
    await cubit.loadImage();
    expect(cubit.state, isA<ImageEmpty>());
    verifyNever(() => fileApi.getPublicUrl(any()));
  });

  test('is empty and does not fetch when skipInitialFetch is set', () {
    final cubit = build('bucket_skip', 'file', skipInitialFetch: true);

    expect(cubit.state, isA<ImageEmpty>());
    verifyNever(() => fileApi.getPublicUrl(any()));
  });

  test('loads the public url on creation', () {
    final cubit = build('bucket_load', 'file');

    expect(cubit.state, isA<ImageLoaded>());
    expect(
      (cubit.state as ImageLoaded).imageUrl,
      'https://cdn.test/file.jpg',
    );
  });

  test('reuses the cached url for the same bucket and file', () {
    build('bucket_cache', 'file');
    final second = build('bucket_cache', 'file');

    expect(second.state, isA<ImageLoaded>());
    verify(() => fileApi.getPublicUrl('file.jpg')).called(1);
  });

  test('bustCache appends a timestamp and refreshes the cache', () async {
    final cubit = build('bucket_bust', 'file');

    await cubit.loadImage(bustCache: true);

    expect(
      (cubit.state as ImageLoaded).imageUrl,
      startsWith('https://cdn.test/file.jpg?t='),
    );
  });

  test('clear empties the state and invalidates the cache', () {
    final cubit = build('bucket_clear', 'file');

    cubit.clear();

    expect(cubit.state, isA<ImageEmpty>());
    build('bucket_clear', 'file');
    verify(() => fileApi.getPublicUrl('file.jpg')).called(2);
  });

  test('showLoading emits loading', () {
    final cubit = build('bucket_loading', 'file');

    cubit.showLoading();

    expect(cubit.state, isA<ImageLoading>());
  });

  group('uploadImage', () {
    test('fails without any id', () async {
      final cubit = build('bucket_up_null', null);

      final result = await cubit.uploadImage(File('x.jpg'));

      expect(result, isA<FailureResponse<bool>>());
      expect((result as FailureResponse<bool>).error, 'No id provided!');
    });

    test('uploads under the file name', () async {
      when(
            () => fileApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'path');
      final cubit = build('bucket_up', 'file');

      final result = await cubit.uploadImage(File('x.jpg'));

      expect(result, isA<SuccessResponse<bool>>());
      verify(
            () => fileApi.upload(
          'file.jpg',
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).called(1);
    });

    test('uploads under an explicit id', () async {
      when(
            () => fileApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'path');
      final cubit = build('bucket_up_id', 'file');

      await cubit.uploadImage(File('x.jpg'), id: 'other');

      verify(
            () => fileApi.upload(
          'other.jpg',
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).called(1);
    });

    test('returns a failure when the upload throws', () async {
      when(
            () => fileApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenThrow(StorageException('quota'));
      final cubit = build('bucket_up_fail', 'file');

      final result = await cubit.uploadImage(File('x.jpg'));

      expect(result, isA<FailureResponse<bool>>());
    });
  });
}