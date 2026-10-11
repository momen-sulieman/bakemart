import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/widgets/table_cells/worker_cell.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/staff_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/ignore_overflow.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class RecordingSettingsRepo extends SettingsRepo {
  final List<BakeryModel> changedBakeries = [];
  final List<StaffModel> deletedWorkers = [];
  final List<Map<String, String?>> addedWorkers = [];
  Completer<void>? deleteGate;
  ResponseResult<bool> addResult = SuccessResponse<bool>(true);

  @override
  Future<ResponseResult<bool>> changeBakeryData({
    required BakeryModel updatedBakery,
  }) async {
    changedBakeries.add(updatedBakery);
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> deleteWorker({
    required StaffModel worker,
  }) async {
    deletedWorkers.add(worker);
    if (deleteGate != null) await deleteGate!.future;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> addWorker({
    String? workerId,
    String? workerName,
  }) async {
    addedWorkers.add({'workerId': workerId, 'workerName': workerName});
    return addResult;
  }
}

final Finder supervisorStar = find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.star && w.size == 22,
);
final Finder plainStar = find.byWidgetPredicate(
      (w) => w is Icon && w.icon == Icons.star_border && w.size == 22,
);
final Finder dialogFields = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byType(TextFormField),
);
final Finder dialogDone = find.descendant(
  of: find.byType(AlertDialog),
  matching: find.byIcon(Icons.done),
);
final Finder anySpinner = loadingDots;

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late RecordingSettingsRepo settingsRepo;
  late SettingsCubit settingsCubit;
  late SettingsUpdateCubit settingsUpdateCubit;

  final alice = StaffModel(workerId: 'w1', workerName: 'Alice', bakeryId: 'b');
  final bob = StaffModel(workerId: 'w2', workerName: 'Bob', bakeryId: 'b');
  final carol = StaffModel(workerId: 'w3', workerName: 'Carol', bakeryId: 'b');

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    bakeryRepo = MockBakeryTabRepo();
    locationCubit = MockLocationCubit();
    when(() => locationCubit.state)
        .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
    when(() => locationCubit.stream)
        .thenAnswer((_) => const Stream<LocationState>.empty());

    final bakery = fakeBakery('owner-1', 30, 31);
    when(() => bakeryRepo.fetchBakery())
        .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
    when(() => bakeryRepo.fetchStorage()).thenAnswer(
          (_) async =>
          SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1')),
    );
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(bakeryId: 'owner-1', payrollMethod: true),
      ),
    );
    when(() => bakeryRepo.fetchProducts()).thenAnswer(
          (_) async => SuccessResponse<List<ProductModel>>([
        fakeProduct(id: 'p1', bakeryId: 'owner-1'),
      ]),
    );
    when(() => bakeryRepo.fetchSales())
        .thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
    when(() => bakeryRepo.fetchFinance())
        .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
    when(() => bakeryRepo.fetchShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(() => bakeryRepo.fetchStaff())
        .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));

    bakeryTabCubit = BakeryTabCubit(
      bakeryRepo,
      locationCubit,
      currentUserId: () => 'owner-1',
    );
    await pumpEventQueue();
    bakeryTabCubit.staff = [alice, bob];

    settingsRepo = RecordingSettingsRepo();
    settingsCubit = SettingsCubit(settingsRepo, bakeryTabCubit);
    settingsUpdateCubit = SettingsUpdateCubit(settingsCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    settingsCubit.close();
    settingsUpdateCubit.close();
  });

  void setSupervisors(List<String> ids) {
    settingsCubit.bakery = settingsCubit.bakery!.copyWith(supervisorId: ids);
  }

  Future<void> pumpTile(
      WidgetTester tester, {
        List<StaffModel>? staff,
      }) async {
    useTallSurface(tester, size: const Size(800, 2400));
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<SettingsCubit>.value(value: settingsCubit),
              BlocProvider<SettingsUpdateCubit>.value(
                value: settingsUpdateCubit,
              ),
            ],
            child: BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) =>
                  StaffSettingsTile(staff: staff ?? settingsCubit.staff),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> addVirtualWorker(WidgetTester tester, String name) async {
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.enterText(dialogFields.first, name);
    await tester.pump();
    await tester.tap(dialogDone);
    await tester.pumpAndSettle();
  }

  group('rendering', () {
    testWidgets('renders one row per worker', (tester) async {
      await pumpTile(tester);

      expect(find.byType(WorkerCell), findsNWidgets(2));
      expect(find.text('No data'), findsNothing);
    });

    testWidgets('renders the placeholder cells when there is no staff',
            (tester) async {
          await pumpTile(tester, staff: const []);

          expect(find.byType(WorkerCell), findsNothing);
          expect(find.text('No data'), findsNWidgets(2));
        });

    testWidgets('marks supervisors with a filled star', (tester) async {
      setSupervisors(['w1']);
      await pumpTile(tester);

      expect(supervisorStar, findsOneWidget);
      expect(plainStar, findsOneWidget);
    });
  });

  group('supervisor toggling', () {
    testWidgets('tapping an empty star promotes the worker', (tester) async {
      setSupervisors(['w1']);
      await pumpTile(tester);

      await tester.tap(plainStar);
      await tester.pumpAndSettle();

      expect(settingsRepo.changedBakeries, hasLength(1));
      expect(
        settingsRepo.changedBakeries.single.supervisorId,
        containsAll(['w1', 'w2']),
      );
    });

    testWidgets('tapping a filled star demotes the worker', (tester) async {
      setSupervisors(['w1']);
      await pumpTile(tester);

      await tester.tap(supervisorStar);
      await tester.pumpAndSettle();

      expect(settingsRepo.changedBakeries, hasLength(1));
      expect(settingsRepo.changedBakeries.single.supervisorId, isEmpty);
    });

    testWidgets('a third supervisor is rejected with a snackbar',
            (tester) async {
          setSupervisors(['w1', 'w2']);
          await pumpTile(tester, staff: [alice, bob, carol]);

          await tester.tap(plainStar);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.byType(SnackBar), findsOneWidget);
          expect(settingsRepo.changedBakeries, isEmpty);
        });
  });

  group('editing and deleting', () {
    testWidgets('the trash icon enters editing mode and reveals row deletes',
            (tester) async {
          await pumpTile(tester);
          expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);

          await tester.tap(find.byIcon(Icons.delete_forever_outlined));
          await tester.pumpAndSettle();

          expect(settingsCubit.isStaffEditing, true);
          expect(find.byIcon(Icons.done), findsOneWidget);
          expect(find.byIcon(Icons.delete_forever_outlined), findsNWidgets(2));
        });

    testWidgets('the done icon leaves editing mode', (tester) async {
      await pumpTile(tester);
      await tester.tap(find.byIcon(Icons.delete_forever_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      expect(settingsCubit.isStaffEditing, false);
      expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
    });

    testWidgets('tapping a row delete removes that worker', (tester) async {
      await pumpTile(tester);
      await tester.tap(find.byIcon(Icons.delete_forever_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_forever_outlined).first);
      await tester.pumpAndSettle();

      expect(settingsRepo.deletedWorkers, hasLength(1));
      expect(settingsRepo.deletedWorkers.single.workerId, 'w1');
    });

    testWidgets('only the row being deleted shows a spinner', (tester) async {
      settingsRepo.deleteGate = Completer<void>();
      await pumpTile(tester);
      await tester.tap(find.byIcon(Icons.delete_forever_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_forever_outlined).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(anySpinner, findsOneWidget);
      expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);

      settingsRepo.deleteGate!.complete();
      await tester.pumpAndSettle();

      expect(anySpinner, findsNothing);
    });

    testWidgets('collapsing the tile updates the cubit and hides the trash',
            (tester) async {
          await pumpTile(tester);

          await tester.tap(find.byType(ListTile).first);
          await tester.pumpAndSettle();

          expect(settingsCubit.isStaffExpanded, false);
          expect(find.byIcon(Icons.delete_forever_outlined), findsNothing);
        });
  });

  group('add worker menu', () {
    testWidgetsIgnoringOverflow(
        'the add button opens the popup menu with both options',
            (tester) async {
          await pumpTile(tester);

          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.edit), findsOneWidget);
          expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
        });

    testWidgetsIgnoringOverflow('the virtual option opens the name dialog',
            (tester) async {
          await pumpTile(tester);

          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.edit));
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsOneWidget);
          expect(dialogFields, findsOneWidget);
        });

    testWidgetsIgnoringOverflow('confirming an empty name does not add a worker',
            (tester) async {
          await pumpTile(tester);
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.edit));
          await tester.pumpAndSettle();

          await tester.tap(dialogDone);
          await tester.pumpAndSettle();

          expect(settingsRepo.addedWorkers, isEmpty);
          expect(find.byType(AlertDialog), findsOneWidget);
        });

    testWidgetsIgnoringOverflow(
        'confirming a name adds a virtual worker and closes the dialog',
            (tester) async {
          await pumpTile(tester);

          await addVirtualWorker(tester, 'Dave');

          expect(settingsRepo.addedWorkers, hasLength(1));
          expect(settingsRepo.addedWorkers.single['workerName'], 'Dave');
          expect(settingsRepo.addedWorkers.single['workerId'], isNull);
          expect(find.byType(AlertDialog), findsNothing);
        });

    testWidgetsIgnoringOverflow('the back arrow closes the dialog without adding',
            (tester) async {
          await pumpTile(tester);
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.edit));
          await tester.pumpAndSettle();

          await tester.tap(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.byIcon(Icons.arrow_back),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
          expect(settingsRepo.addedWorkers, isEmpty);
        });

    testWidgetsIgnoringOverflow('a failed add surfaces the error snackbar',
            (tester) async {
          settingsRepo.addResult = FailureResponse<bool>('failed');
          await pumpTile(tester);

          await addVirtualWorker(tester, 'Dave');
          await tester.pump(const Duration(milliseconds: 300));

          expect(find.byType(SnackBar), findsOneWidget);
        });
  });
}