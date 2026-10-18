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
import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/sales_status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

void main() {
  late MockBakeryTabRepo bakeryRepo;
  late MockLocationCubit locationCubit;
  late BakeryTabCubit bakeryTabCubit;
  late StatusSalesFilterCubit filterCubit;

  setUpAll(() async {
    await setupTestEnvironment();
  });

  Future<void> setUpWith(
      WidgetTester tester,
      List<SalesModel> sales,
      List<ProductModel> products,
      ) async {
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
          SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1', branchId: '')),
    );
    when(() => bakeryRepo.fetchPayroll()).thenAnswer(
          (_) async => SuccessResponse<PayrollModel?>(
        PayrollModel(bakeryId: 'owner-1', payrollMethod: true, branchId: ''),
      ),
    );
    when(() => bakeryRepo.fetchProducts())
        .thenAnswer((_) async => SuccessResponse<List<ProductModel>>(products));
    when(() => bakeryRepo.fetchSales())
        .thenAnswer((_) async => SuccessResponse<List<SalesModel>>(sales));
    when(() => bakeryRepo.fetchFinance())
        .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
    when(() => bakeryRepo.fetchShifts())
        .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(() => bakeryRepo.fetchStaff())
        .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));
    when(() => bakeryRepo.filterSalesByDate(
      allSales: any(named: 'allSales'),
      selectedDate: any(named: 'selectedDate'),
    )).thenAnswer((invocation) {
      final records = invocation.namedArguments[#allSales] as List<SalesModel>;
      final date = invocation.namedArguments[#selectedDate] as DateTime;
      final matches = records
          .where((r) =>
      r.date?.year == date.year &&
          r.date?.month == date.month &&
          r.date?.day == date.day)
          .toList();
      return SuccessResponse<List<SalesModel>>(matches);
    });

    await tester.runAsync(() async {
      bakeryTabCubit = BakeryTabCubit(
        bakeryRepo,
        locationCubit,
        currentUserId: () => 'owner-1',
      );
      await pumpEventQueue();
    });

    filterCubit = StatusSalesFilterCubit(bakeryRepo, bakeryTabCubit);
  }

  tearDown(() {
    bakeryTabCubit.close();
    filterCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
    useTallSurface(tester);
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<StatusSalesFilterCubit>.value(value: filterCubit),
            BlocProvider<BakeryTabCubit>.value(value: bakeryTabCubit),
          ],
          child: const SalesStatusTile(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows produced and sold for a product sold today',
          (tester) async {
        final today = DateTime.now();
        final product = fakeProduct(id: 'p1', bakeryId: 'owner-1')
            .copyWith(productName: 'Croissant');
        await setUpWith(tester, [
          SalesModel(
            productName: 'Croissant',
            bakeryId: 'owner-1',
            productId: 'p1',
            productPrice: 3.5,
            date: today,
            produced: 40,
            sold: 25, branchId: '',
          ),
        ], [product]);
        await pumpTile(tester);

        expect(find.text('40'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
      });

  testWidgets('tapping a row opens the product details dialog',
          (tester) async {
        final today = DateTime.now();
        final product = fakeProduct(id: 'p1', bakeryId: 'owner-1')
            .copyWith(productName: 'Croissant');
        await setUpWith(tester, [
          SalesModel(
            productName: 'Croissant',
            bakeryId: 'owner-1',
            productId: 'p1',
            productPrice: 3.5,
            date: today,
            produced: 40,
            sold: 25, branchId: '',
          ),
        ], [product]);
        await pumpTile(tester);

        await tester.tap(find.text('Croissant'));
        await tester.pumpAndSettle();

        expect(find.byType(ProductDetailsScreen), findsOneWidget);
      });

  testWidgets('shows nothing sold when no record matches today',
          (tester) async {
        await setUpWith(tester, [
          SalesModel(
            productName: 'Croissant',
            bakeryId: 'owner-1',
            productId: 'p1',
            productPrice: 3.5,
            date: DateTime.now().subtract(const Duration(days: 3)),
            produced: 40,
            sold: 25, branchId: '',
          ),
        ], []);
        await pumpTile(tester);

        expect(find.text('40'), findsNothing);
        expect(find.text('25'), findsNothing);
      });
}