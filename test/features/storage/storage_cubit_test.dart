import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/logic/storage_cubit/storage_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockStorageRepo extends Mock implements StorageRepo {}

class MockBakeryTabCubit extends Mock implements BakeryTabCubit {}

void main() {
  late MockStorageRepo repo;
  late MockBakeryTabCubit bakeryTabCubit;

  setUpAll(() async {
    registerFallbackValue(fakeStorage());
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockStorageRepo();
    bakeryTabCubit = MockBakeryTabCubit();
    when(() => bakeryTabCubit.storage).thenAnswer((_) => fakeStorage());
    when(() => bakeryTabCubit.loadStorage()).thenAnswer((_) async {});
  });

  StorageCubit build() {
    final cubit = StorageCubit(repo, bakeryTabCubit);
    addTearDown(cubit.close);
    return cubit;
  }

  test('getStorage loads the bakery tab cubit storage on creation', () async {
    final cubit = build();
    await pumpEventQueue();

    expect(cubit.state, isA<StorageSucces>());
    expect(cubit.storage.bakeryId, 'b1');
    expect((cubit.state as StorageSucces).inputValidity, false);
  });

  test('inputValidityTrue and inputValidityFalse toggle the flag', () async {
    final cubit = build();
    await pumpEventQueue();

    cubit.inputValidityTrue();
    expect(cubit.inputValidity, true);
    expect((cubit.state as StorageSucces).inputValidity, true);

    cubit.inputValidityFalse();
    expect(cubit.inputValidity, false);
  });

  test('addToStorage saves then reloads from the bakery tab cubit', () async {
    when(
          () => repo.updateStorage(any()),
    ).thenAnswer((_) async => SuccessResponse<bool>(true));
    final cubit = build();
    await pumpEventQueue();
    cubit.inputValidityTrue();
    final reloaded = fakeStorage(bakeryId: 'b1');
    when(() => bakeryTabCubit.storage).thenAnswer((_) => reloaded);

    await cubit.addToStorage(fakeStorage());
    await pumpEventQueue();

    expect(cubit.inputValidity, false);
    expect(cubit.storage, reloaded);
    verify(() => bakeryTabCubit.loadStorage()).called(1);
  });

  test('addToStorage emits a failure without reloading', () async {
    when(
          () => repo.updateStorage(any()),
    ).thenAnswer((_) async => FailureResponse<bool>('denied'));
    final cubit = build();
    await pumpEventQueue();

    await cubit.addToStorage(fakeStorage());
    await pumpEventQueue();

    expect(cubit.state, isA<StorageFailure>());
    expect((cubit.state as StorageFailure).error, 'denied');
    verifyNever(() => bakeryTabCubit.loadStorage());
  });
}