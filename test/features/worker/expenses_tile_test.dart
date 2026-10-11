import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:bakemart/core/shared/models/waste_model.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/expenses_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';
import '../../helpers/widget_test_helpers.dart';

class TestWorkerRepo extends WorkerRepo {
  FinanceModel? lastUpsertedFinance;
  WasteModel? lastDeletedWaste;
  List<FinanceModel> financeAfter = [];
  List<ProductModel> productsAfter = [];

  @override
  Future<ResponseResult<UserModel>> getUserData() async {
    return SuccessResponse<UserModel>(
      UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
    );
  }

  @override
  Future<ResponseResult<StaffModel?>> checkStaffTable() async {
    return SuccessResponse<StaffModel?>(null);
  }

  @override
  Future<ResponseResult<List<ShiftModel>?>> fetchMyShifts() async {
    return SuccessResponse<List<ShiftModel>?>([]);
  }

  @override
  Future<ResponseResult<bool>> upsertFinancerecord({
    required FinanceModel financeRecord,
    required String bakeryId,
  }) async {
    lastUpsertedFinance = financeRecord;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> adjustAvailabilityForWasteChanges({
    required List<WasteModel> oldWastes,
    required List<WasteModel> newWastes,
    required List<ProductModel> products,
    required String bakeryId,
  }) async {
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<bool>> deleteMealFromDatabase({
    required FinanceModel financeRecord,
    required WasteModel product,
    required String bakeryId,
  }) async {
    lastDeletedWaste = product;
    return SuccessResponse<bool>(true);
  }

  @override
  Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id) async {
    return SuccessResponse<List<FinanceModel>?>(financeAfter);
  }

  @override
  Future<ResponseResult<List<ProductModel>?>> fetchProducts(String id) async {
    return SuccessResponse<List<ProductModel>?>(productsAfter);
  }
}

void main() {
  late TestWorkerRepo repo;
  late WorkerCubit workerCubit;
  late ExpensesFilterCubit filterCubit;
  late ExpensesCubit expensesCubit;
  final today = DateTime.now();
  final productA = fakeProduct()
      .copyWith(productId: 'p1', productName: 'Croissant', productPrice: 3.5);
  final productB = fakeProduct()
      .copyWith(productId: 'p2', productName: 'Baguette', productPrice: 2.5);
  final wasteA = WasteModel(
    productId: 'p1',
    productName: 'Croissant',
    meal: 1,
    notSold: 2,
    manufacturing: 3,
    productPrice: 3.5,
    date: today,
  );

  setUpAll(() async {
    await setupTestEnvironment();
  });

  setUp(() async {
    repo = TestWorkerRepo();
    workerCubit = WorkerCubit(repo);
    await pumpEventQueue();
    workerCubit.bakery = fakeBakery('b1', 0, 0);
    workerCubit.products = [productA, productB];
    workerCubit.finance = [
      FinanceModel(
        bakeryId: 'b1',
        date: today,
        cleaningExpenses: 10,
        wastes: [wasteA],
      ),
    ];
    repo.financeAfter = workerCubit.finance!;
    repo.productsAfter = workerCubit.products!;

    filterCubit = ExpensesFilterCubit(repo, workerCubit);
    expensesCubit = ExpensesCubit(repo, workerCubit);
  });

  tearDown(() {
    filterCubit.close();
    expensesCubit.close();
    workerCubit.close();
  });

  Future<void> pumpTile(WidgetTester tester) async {
    useTallSurface(tester, size: const Size(800, 2200));
    await pumpLocalizedWidget(
      tester,
      Scaffold(
        body: SingleChildScrollView(
          child: MultiBlocProvider(
            providers: [
              BlocProvider<WorkerCubit>.value(value: workerCubit),
              BlocProvider<ExpensesFilterCubit>.value(value: filterCubit),
              BlocProvider<ExpensesCubit>.value(value: expensesCubit),
            ],
            child: ExpensesTile(workerState: workerCubit.state),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the side expenses and the waste row', (tester) async {
    await pumpTile(tester);

    expect(find.text('10.00'), findsOneWidget);
    expect(find.text('Croissant'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsNWidgets(2));
  });

  testWidgets('the edit icon enters edit mode', (tester) async {
    await pumpTile(tester);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(filterCubit.editMode, true);
    expect(find.byIcon(Icons.delete_forever_outlined), findsOneWidget);
  });

  testWidgets('editing the side expenses value calls changeSideExpenses',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.text('10.00'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '25');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(filterCubit.editableCurrentFilteredExpenses.cleaningExpenses, 25);
        expect(filterCubit.updated, true);
      });

  testWidgets('deleting a waste row while editing calls the repo and refreshes',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_forever_outlined));
        await tester.pumpAndSettle();

        expect(repo.lastDeletedWaste?.productId, 'p1');
      });

  testWidgets('adding a product opens the dialog and calls addAProduct',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        expect(find.text('Baguette'), findsWidgets);

        final fields = find.byType(TextFormField);
        expect(fields, findsNWidgets(3));
        await tester.enterText(fields.at(2), '4');
        await tester.pump();

        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        expect(
          filterCubit.editableCurrentFilteredExpenses.wastes
              .any((w) => w.productId == 'p2' && w.meal == 4),
          true,
        );
      });

  testWidgets('saving persists the edited record and leaves edit mode',
          (tester) async {
        await pumpTile(tester);
        await tester.tap(find.byIcon(Icons.edit));
        await tester.pumpAndSettle();
        await tester.tap(find.text('10.00'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextFormField), '25');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.done));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.done).first);
        await tester.pumpAndSettle();

        expect(repo.lastUpsertedFinance?.cleaningExpenses, 25);
        expect(filterCubit.editMode, false);
      });
}