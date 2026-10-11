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
import 'package:bakemart/core/shared/models/storage_helper.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/logic/storage_cubit/storage_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/logic/unit_cubit/unit_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/ui/storage_tab_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/ui/widgets/storage_item_card.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class TestStorageRepo extends StorageRepo {
  StorageModel? lastUpdated;

  @override
  Future<ResponseResult<bool>> updateStorage(StorageModel updated) async {
    lastUpdated = updated;
    return SuccessResponse<bool>(true);
  }
}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late TestStorageRepo storageRepo;
  late StorageCubit storageCubit;
  late UnitCubit unitCubit;

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
    final storage = StorageModel(bakeryId: 'owner-1', sugar: 5000, salt: 2000);
    when(() => bakeryRepo.fetchBakery())
        .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
    when(() => bakeryRepo.fetchStorage())
        .thenAnswer((_) async => SuccessResponse<StorageModel?>(storage));
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(bakeryId: 'owner-1', payrollMethod: true),
      ),
    );
    when(() => bakeryRepo.fetchProducts())
        .thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
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

    storageRepo = TestStorageRepo();
    storageCubit = StorageCubit(storageRepo, bakeryTabCubit);
    unitCubit = UnitCubit();

    if (GetIt.instance.isRegistered<StorageCubit>()) {
      GetIt.instance.unregister<StorageCubit>();
    }
    if (GetIt.instance.isRegistered<UnitCubit>()) {
      GetIt.instance.unregister<UnitCubit>();
    }
    GetIt.instance.registerLazySingleton<StorageCubit>(() => storageCubit);
    GetIt.instance.registerLazySingleton<UnitCubit>(() => unitCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    storageCubit.close();
    unitCubit.close();
    GetIt.instance.unregister<StorageCubit>();
    GetIt.instance.unregister<UnitCubit>();
  });

  Future<void> pumpScreen(WidgetTester tester, {double height = 3000}) async {
    useTallSurface(tester, size: Size(800, height));
    await pumpLocalizedWidget(
      tester,
      BlocProvider<BakeryTabCubit>.value(
        value: bakeryTabCubit,
        child: const StorageTabScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders one card per storage item', (tester) async {
    await pumpScreen(tester, height: 20000);

    expect(
      find.byType(StorageItemCard),
      findsNWidgets(StorageHelper.allItems.length),
    );
  });

  testWidgets('shows the sugar quantity converted to kilograms by default',
          (tester) async {
        await pumpScreen(tester);

        expect(find.text('5.0'), findsOneWidget);
      });

  testWidgets('adding to an item calls the repo with the updated total',
          (tester) async {
        await pumpScreen(tester);

        final sugarCardFinder = find.byWidgetPredicate(
              (w) => w is StorageItemCard && w.itemName == StorageItems.sugar,
        );
        expect(sugarCardFinder, findsOneWidget);

        final addIconFinder = find.descendant(
          of: sugarCardFinder,
          matching: find.byIcon(Icons.add),
        );
        await tester.tap(addIconFinder);
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), '2');
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(storageRepo.lastUpdated?.sugar, 7000);
      });
}