import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/data/home_repo.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockHomeRepo extends Mock implements HomeRepo {}

class MockActiveOrdersCubit extends Mock implements ActiveOrdersCubit {}

class MockCartCubit extends Mock implements CartCubit {}

void main() {
  late MockHomeRepo repo;
  late MockActiveOrdersCubit activeOrdersCubit;
  late MockCartCubit cartCubit;
  late HomeDataCubit cubit;

  final user = UserModel(
    id: 'u1',
    firstName: 'Mo',
    secondName: 'Men',
    email: 'mo@test.com',
    phone: '123',
    street: 'S',
    building: 'B',
    apartment: 'A',
  );
  final bakery = fakeBakery('b1', 30.0, 31.0);
  final homeBakery = HomeDataBakeriesModel(
    bakeryModel: bakery,
    productModelList: [fakeProduct()],
  );

  void stubSuccess() {
    when(
          () => repo.getUserData(),
    ).thenAnswer((_) async => SuccessResponse<UserModel>(user));
    when(() => repo.getBakeries()).thenAnswer(
          (_) async =>
          SuccessResponse<List<HomeDataBakeriesModel>>([homeBakery]),
    );
  }

  Future<HomeDataCubit> createCubit() async {
    final created = HomeDataCubit(repo, activeOrdersCubit, cartCubit);
    await pumpEventQueue();
    return created;
  }

  List<HomeDataState> collect(HomeDataCubit target) {
    final states = <HomeDataState>[];
    target.stream.listen(states.add);
    return states;
  }

  setUpAll(() async {
    registerFallbackValue(user);
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockHomeRepo();
    activeOrdersCubit = MockActiveOrdersCubit();
    cartCubit = MockCartCubit();
  });

  tearDown(() async {
    await cubit.close();
  });

  group('getHomeData', () {
    test('loads user and bakeries and seeds the cart address', () async {
      stubSuccess();

      cubit = await createCubit();

      expect(cubit.state, isA<HomeDataSuccess>());
      expect(cubit.user.id, 'u1');
      expect(cubit.bakeries, hasLength(1));
      verify(() => activeOrdersCubit.checkActiveOrders()).called(1);
      verify(
            () => cartCubit.initAddress(
          street: 'S',
          building: 'B',
          apartment: 'A',
        ),
      ).called(1);
    });

    test('emits loading then success on a manual reload', () async {
      stubSuccess();
      cubit = await createCubit();
      final states = collect(cubit);

      await cubit.getHomeData();
      await pumpEventQueue();

      expect(states, [isA<HomeDataLoading>(), isA<HomeDataSuccess>()]);
    });

    test('fails when the user cannot be loaded and skips bakeries', () async {
      when(() => repo.getUserData()).thenAnswer(
            (_) async => FailureResponse<UserModel>('no network'),
      );

      cubit = await createCubit();

      expect(cubit.state, isA<HomeDataFailure>());
      expect((cubit.state as HomeDataFailure).error, 'no network');
      verifyNever(() => repo.getBakeries());
    });

    test('fails when bakeries cannot be loaded', () async {
      when(
            () => repo.getUserData(),
      ).thenAnswer((_) async => SuccessResponse<UserModel>(user));
      when(() => repo.getBakeries()).thenAnswer(
            (_) async =>
            FailureResponse<List<HomeDataBakeriesModel>>('boom'),
      );

      cubit = await createCubit();

      expect(cubit.state, isA<HomeDataFailure>());
      expect((cubit.state as HomeDataFailure).error, 'boom');
    });

    test('stays silent when a refresh fails', () async {
      stubSuccess();
      cubit = await createCubit();
      when(() => repo.getUserData()).thenAnswer(
            (_) async => FailureResponse<UserModel>('no network'),
      );
      final states = collect(cubit);

      await cubit.getHomeData(isRefreshing: true);
      await pumpEventQueue();

      expect(states, isEmpty);
      expect(cubit.state, isA<HomeDataSuccess>());
    });
  });

  group('flags', () {
    setUp(() {
      stubSuccess();
    });

    test('setRefresh stores the status and emits success', () async {
      cubit = await createCubit();
      final states = collect(cubit);

      cubit.setRefresh(true);
      await pumpEventQueue();

      expect(cubit.refreshStatus, true);
      expect(states, [isA<HomeDataSuccess>()]);
    });

    test('nameChanged combines first and second name flags', () async {
      cubit = await createCubit();

      cubit.nameChanged(firstName: true);
      expect(cubit.isNameChanged, true);

      cubit.nameChanged(secondName: true);
      cubit.nameChanged(firstName: false);
      expect(cubit.isNameChanged, true);

      cubit.nameChanged(secondName: false);
      expect(cubit.isNameChanged, false);
    });

    test('addressChanged combines street, building and apartment flags',
            () async {
          cubit = await createCubit();

          cubit.addressChanged(street: true);
          expect(cubit.isAddressChanged, true);

          cubit.addressChanged(building: true, apartment: true);
          cubit.addressChanged(street: false, building: false);
          expect(cubit.isAddressChanged, true);

          cubit.addressChanged(apartment: false);
          expect(cubit.isAddressChanged, false);
        });
  });

  group('profile image', () {
    setUp(() {
      stubSuccess();
    });

    test('updateProfileImageStatus updates the user on success', () async {
      when(
            () => repo.setProfileImageStatus(userId: 'u1', hasImage: true),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit = await createCubit();
      final states = collect(cubit);

      await cubit.updateProfileImageStatus(true);
      await pumpEventQueue();

      expect(cubit.user.hasProfileImage, true);
      expect(states, [isA<HomeDataSuccess>()]);
    });

    test('updateProfileImageStatus leaves the user on failure', () async {
      when(
            () => repo.setProfileImageStatus(userId: 'u1', hasImage: true),
      ).thenAnswer((_) async => FailureResponse<bool>('denied'));
      cubit = await createCubit();
      final states = collect(cubit);

      await cubit.updateProfileImageStatus(true);
      await pumpEventQueue();

      expect(cubit.user.hasProfileImage, false);
      expect(states, isEmpty);
    });

    test('removeProfileImage returns true and clears the flag', () async {
      when(
            () => repo.removeProfileImage(userId: 'u1'),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit = await createCubit();
      cubit.user = cubit.user.copyWith(hasProfileImage: true);

      final removed = await cubit.removeProfileImage();

      expect(removed, true);
      expect(cubit.user.hasProfileImage, false);
    });

    test('removeProfileImage returns false and keeps the flag on failure',
            () async {
          when(
                () => repo.removeProfileImage(userId: 'u1'),
          ).thenAnswer((_) async => FailureResponse<bool>('nope'));
          cubit = await createCubit();
          cubit.user = cubit.user.copyWith(hasProfileImage: true);

          final removed = await cubit.removeProfileImage();

          expect(removed, false);
          expect(cubit.user.hasProfileImage, true);
        });
  });

  group('changeUserData', () {
    setUp(() {
      stubSuccess();
    });

    test('saves then reloads the user', () async {
      when(
            () => repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit = await createCubit();
      final renamed = user.copyWith(firstName: 'New');
      when(
            () => repo.getUserData(),
      ).thenAnswer((_) async => SuccessResponse<UserModel>(renamed));
      final states = collect(cubit);

      await cubit.changeUserData(updatedUserData: renamed);
      await pumpEventQueue();

      expect(cubit.user.firstName, 'New');
      expect(states, [isA<HomeDataSuccess>()]);
    });

    test('emits failure when saving fails', () async {
      when(
            () => repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
      ).thenAnswer((_) async => FailureResponse<bool>('save failed'));
      cubit = await createCubit();
      final states = collect(cubit);

      await cubit.changeUserData(updatedUserData: user);
      await pumpEventQueue();

      expect(states, [isA<HomeDataFailure>()]);
      expect((states.single as HomeDataFailure).error, 'save failed');
    });

    test('emits failure when reloading the user fails', () async {
      when(
            () => repo.changeUserData(updatedUserData: any(named: 'updatedUserData')),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      cubit = await createCubit();
      when(() => repo.getUserData()).thenAnswer(
            (_) async => FailureResponse<UserModel>('reload failed'),
      );
      final states = collect(cubit);

      await cubit.changeUserData(updatedUserData: user);
      await pumpEventQueue();

      expect(states, [isA<HomeDataFailure>()]);
    });
  });

  test('logout delegates to the repo', () async {
    stubSuccess();
    when(() => repo.logout()).thenAnswer((_) async {});
    cubit = await createCubit();

    await cubit.logout();

    verify(() => repo.logout()).called(1);
  });
}