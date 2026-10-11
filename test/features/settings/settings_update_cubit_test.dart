import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockSettingsCubit settingsCubit;
  late SettingsUpdateCubit cubit;

  setUpAll(() async {
    registerFallbackValue(fakeBakery('b1', 0, 0));
    registerFallbackValue(fakePayroll());
    registerFallbackValue(<dynamic>[]);
    registerFallbackValue(fakeStaff());
    await setupTestEnvironment();
  });

  setUp(() {
    settingsCubit = MockSettingsCubit();
    when(
          () => settingsCubit.updateBakeryData(any()),
    ).thenAnswer((_) async {});
    when(() => settingsCubit.updatePayroll(any())).thenAnswer((_) async {});
    when(() => settingsCubit.updateProducts(any())).thenAnswer((_) async {});
    when(
          () => settingsCubit.changeBakeryData(updatedBakery: any(named: 'updatedBakery')),
    ).thenAnswer((_) async {});
    when(
          () => settingsCubit.deleteWorker(worker: any(named: 'worker')),
    ).thenAnswer((_) async {});
    cubit = SettingsUpdateCubit(settingsCubit);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('updateBakeryData bounces through loading back to initial', () async {
    final states = <SettingsUpdateState>[];
    cubit.stream.listen(states.add);

    cubit.updateBakeryData(fakeBakery('b1', 1, 2));
    await pumpEventQueue();

    expect(states, [isA<SettingsUpdateLoading>(), isA<SettingsUpdateInitial>()]);
  });

  test('changeBakeryData tags the loading state as supervisor for the target',
          () async {
        final states = <SettingsUpdateState>[];
        cubit.stream.listen(states.add);

        await cubit.changeBakeryData(
          updatedBakery: fakeBakery('b1', 1, 2),
          targetId: 'w1',
        );

        final loading = states.first as SettingsUpdateLoading;
        expect(loading.targetId, 'w1');
        expect(loading.action, SettingsUpdateAction.supervisor);
      });

  test('deleteWorker tags the loading state with the worker id', () async {
    final states = <SettingsUpdateState>[];
    cubit.stream.listen(states.add);

    await cubit.deleteWorker(worker: fakeStaff(workerId: 'w1'));

    final loading = states.first as SettingsUpdateLoading;
    expect(loading.targetId, 'w1');
    expect(loading.action, SettingsUpdateAction.deleteWorker);
  });

  test('addWorker publishes the repo error on the error stream', () async {
    when(
          () => settingsCubit.addWorker(
        workerId: any(named: 'workerId'),
        workerName: any(named: 'workerName'),
      ),
    ).thenAnswer((_) async => FailureResponse<bool>('Wrong QR code'));
    final errors = <String>[];
    cubit.errorMessages.listen(errors.add);

    await cubit.addWorker(workerId: 'bad');
    await pumpEventQueue();

    expect(errors, ['Wrong QR code']);
  });

  test('addWorker stays silent on success', () async {
    when(
          () => settingsCubit.addWorker(
        workerId: any(named: 'workerId'),
        workerName: any(named: 'workerName'),
      ),
    ).thenAnswer((_) async => SuccessResponse<bool>(true));
    final errors = <String>[];
    cubit.errorMessages.listen(errors.add);

    await cubit.addWorker(workerId: 'w1');
    await pumpEventQueue();

    expect(errors, isEmpty);
  });
}