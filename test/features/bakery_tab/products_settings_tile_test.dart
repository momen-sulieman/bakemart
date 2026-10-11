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
import 'package:bakemart/core/shared/widgets/dialogs/add_product_dialog/ui/add_product_dialog.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/products_settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class TestSettingsRepo extends SettingsRepo {
  List<ProductModel>? lastUpdatedProducts;

  @override
  Future<ResponseResult<bool>> updateProducts(
      List<ProductModel> updatedProducts,
      ) async {
    lastUpdatedProducts = updatedProducts;
    return SuccessResponse<bool>(true);
  }
}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late TestSettingsRepo settingsRepo;
  late SettingsCubit settingsCubit;
  late SettingsUpdateCubit settingsUpdateCubit;

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
        fakeProduct(id: 'p1', bakeryId: 'owner-1')
            .copyWith(productName: 'Croissant', productPrice: 3.5, productWeight: 80),
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

    settingsRepo = TestSettingsRepo();
    settingsCubit = SettingsCubit(settingsRepo, bakeryTabCubit);
    settingsUpdateCubit = SettingsUpdateCubit(settingsCubit);
  });

  tearDown(() {
    bakeryTabCubit.close();
    settingsCubit.close();
    settingsUpdateCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
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
            child: ProductsSettingsTile(products: settingsCubit.products),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the product row with its weight and price',
          (tester) async {
        await pumpTile(tester);

        expect(find.text('Croissant'), findsOneWidget);
        expect(find.text('80'), findsOneWidget);
        expect(find.text('3.50'), findsOneWidget);
      });

  testWidgets('the edit icon enters editing mode, revealing the add button',
          (tester) async {
        await pumpTile(tester);

        expect(find.byType(AddProductDialog), findsNothing);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        expect(settingsCubit.isProductsEditing, true);
      });

  testWidgets('adding a product through the dialog calls addProduct',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        expect(find.byType(AddProductDialog), findsOneWidget);

        // Field order inside AddProductDialog: name, price, weight, quantity,
        // then each recipe field — filling name/price/weight/quantity plus one
        // recipe field (index 4, "yeast") is enough to satisfy validity.
        final fields = find.byType(TextFormField);
        await tester.enterText(fields.at(0), 'Baguette');
        await tester.enterText(fields.at(1), '2.5');
        await tester.enterText(fields.at(2), '200');
        await tester.enterText(fields.at(3), '10');
        await tester.enterText(fields.at(4), '50');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(find.byType(AddProductDialog), findsNothing);
        expect(
          settingsCubit.editableProducts.any((p) => p.productName == 'Baguette'),
          true,
        );
      });
}