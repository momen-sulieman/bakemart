// import 'dart:async';
//
// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/models/bakery_model.dart';
// import 'package:bakemart/core/shared/models/finance_model.dart';
// import 'package:bakemart/core/shared/models/payroll_model.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/models/shift_model.dart';
// import 'package:bakemart/core/shared/models/staff_model.dart';
// import 'package:bakemart/core/shared/models/storage_model.dart';
// import 'package:bakemart/core/shared/models/user_model.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_cubit/expenses_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/expenses_filter_cubit/expenses_filter_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/history_filter_cubit/history_filter_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_cubit/shifts_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/shifts_filter_cubit/shifts_filter_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/worker_tab_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
// import '../../helpers/widget_test_helpers.dart';
//
// class TestWorkerRepo extends WorkerRepo {
//   Completer<ResponseResult<UserModel>>? pendingUserData;
//   String? userId;
//
//   @override
//   Future<ResponseResult<UserModel>> getUserData() async {
//     if (pendingUserData != null) return pendingUserData!.future;
//     return SuccessResponse<UserModel>(
//       UserModel(
//         id: userId,
//         firstName: 'Mo',
//         secondName: 'Amin',
//         email: '',
//         phone: '',
//       ),
//     );
//   }
//
//   StaffModel? staffRow;
//   @override
//   Future<ResponseResult<StaffModel?>> checkStaffTable() async {
//     return SuccessResponse<StaffModel?>(staffRow);
//   }
//
//   @override
//   Future<ResponseResult<List<ShiftModel>?>> fetchMyShifts() async {
//     return SuccessResponse<List<ShiftModel>?>([]);
//   }
//
//   BakeryModel? bakeryRow;
//   @override
//   Future<ResponseResult<BakeryModel>> getBakeryData(String employerId,String branchId) async {
//     return SuccessResponse<BakeryModel>(bakeryRow!);
//   }
//
//   PayrollModel? payrollRow;
//   @override
//   Future<ResponseResult<PayrollModel?>> fetchPayroll(String id) async {
//     return SuccessResponse<PayrollModel?>(payrollRow);
//   }
//
//   List<ProductModel> productsRow = [];
//   @override
//   Future<ResponseResult<List<ProductModel>?>> fetchProducts(String id) async {
//     return SuccessResponse<List<ProductModel>?>(productsRow);
//   }
//
//   List<StaffModel> staffListRow = [];
//   @override
//   Future<ResponseResult<List<StaffModel>?>> fetchStaff(String id) async {
//     return SuccessResponse<List<StaffModel>?>(staffListRow);
//   }
//
//   List<ShiftModel> shiftsRow = [];
//   @override
//   Future<ResponseResult<List<ShiftModel>?>> fetchShifts(String id) async {
//     return SuccessResponse<List<ShiftModel>?>(shiftsRow);
//   }
//
//   List<FinanceModel> financeRow = [];
//   @override
//   Future<ResponseResult<List<FinanceModel>?>> fetchFinance(String id) async {
//     return SuccessResponse<List<FinanceModel>?>(financeRow);
//   }
//
//   @override
//   Future<ResponseResult<StorageModel?>> fetchStorage(String id) async {
//     return SuccessResponse<StorageModel?>(StorageModel(bakeryId: id, branchId: ''));
//   }
// }
//
// void main() {
//   late TestWorkerRepo repo;
//   late WorkerCubit workerCubit;
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//   });
//
//   setUp(() {
//     repo = TestWorkerRepo();
//   });
//
//   tearDown(() {
//     workerCubit.close();
//     if (GetIt.instance.isRegistered<HistoryFilterCubit>()) {
//       GetIt.instance.unregister<HistoryFilterCubit>();
//     }
//   });
//
//   Future<void> pumpScreen(
//       WidgetTester tester, {
//         List<Widget> extraProviders = const [],
//         bool settle = true,
//       }) async {
//     if (GetIt.instance.isRegistered<HistoryFilterCubit>()) {
//       GetIt.instance.unregister<HistoryFilterCubit>();
//     }
//     GetIt.instance.registerFactory<HistoryFilterCubit>(
//           () => HistoryFilterCubit(repo),
//     );
//     useTallSurface(tester, size: const Size(800, 3000));
//     await pumpLocalizedWidget(
//       tester,
//       MultiBlocProvider(
//         providers: [
//           BlocProvider<WorkerCubit>.value(value: workerCubit),
//           ...extraProviders.cast(),
//         ],
//         child: const WorkerTabScreen(),
//       ),
//       settle: false,
//     );
//     for (var i = 0; i < 20 && workerCubit.state is WorkerLoading; i++) {
//       await tester.pump(const Duration(milliseconds: 50));
//     }
//     if (settle) {
//       await tester.pumpAndSettle();
//     } else {
//       await tester.pump(const Duration(milliseconds: 50));
//     }
//   }
//
//   testWidgets('shows a loading indicator while the first frame loads',
//           (tester) async {
//         repo.pendingUserData = Completer<ResponseResult<UserModel>>();
//         workerCubit = WorkerCubit(repo);
//
//         await pumpScreen(tester, settle: false);
//         await tester.pump(const Duration(milliseconds: 50));
//
//         expect(loadingDots, findsWidgets);
//         repo.pendingUserData!.complete(FailureResponse<UserModel>('cancelled'));
//       });
//
//   testWidgets('UnEmployed shows the join-a-bakery prompt', (tester) async {
//     repo.staffRow = null;
//     workerCubit = WorkerCubit(repo);
//
//     await pumpScreen(tester);
//
//     expect(workerCubit.state, isA<UnEmployed>());
//     expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
//   });
//
//   testWidgets('Employed shows the bakery name in the app bar', (tester) async {
//     final bakery = fakeBakery('b1', 0, 0);
//     repo.staffRow =
//         fakeStaff(workerId: 'w1', workerName: 'Mo', bakeryId: 'b1');
//     repo.bakeryRow = bakery;
//     workerCubit = WorkerCubit(repo);
//
//     await pumpScreen(tester);
//
//     expect(workerCubit.state, isA<Employed>());
//     expect(find.text(bakery.bakeryName), findsOneWidget);
//   });
//
//   testWidgets(
//       'Supervisor renders the product list plus the embedded worksheet and expenses tiles',
//           (tester) async {
//         final bakery = fakeBakery('b1', 0, 0).copyWith(supervisorId: ['w1']);
//         final product = fakeProduct().copyWith(
//           productId: 'p1',
//           productName: 'Croissant',
//           bakeryId: 'b1',
//         );
//         final today = DateTime.now();
//         repo.userId = 'w1';
//         repo.staffRow =
//             fakeStaff(workerId: 'w1', workerName: 'Mo', bakeryId: 'b1');
//         repo.bakeryRow = bakery;
//         repo.payrollRow =
//             PayrollModel(bakeryId: 'b1', payrollMethod: false, chef: 50, branchId: '');
//         repo.productsRow = [product];
//         repo.staffListRow = [
//           fakeStaff(workerId: 'w2', workerName: 'Alice', bakeryId: 'b1'),
//         ];
//         repo.shiftsRow = [
//           ShiftModel(
//             bakeryId: 'b1',
//             workerId: 'w2',
//             workerName: 'Alice',
//             wage: 150,
//             role: const ['chef'],
//             numberOfBatches: const [3],
//             date: today, branchId: '',
//           ),
//         ];
//         repo.financeRow = [
//           FinanceModel(
//             bakeryId: 'b1',
//             date: today,
//             cleaningExpenses: 10,
//             wastes: const [], branchId: '',
//           ),
//         ];
//         await tester.runAsync(() async {
//           workerCubit = WorkerCubit(repo);
//           await pumpEventQueue();
//         });
//         final productionCubit = ProductionCubit(repo, workerCubit);
//         final shiftsFilterCubit = ShiftsFilterCubit(repo, workerCubit);
//         final shiftsCubit = ShiftsCubit(repo, workerCubit);
//         final expensesFilterCubit = ExpensesFilterCubit(repo, workerCubit);
//         final expensesCubit = ExpensesCubit(repo, workerCubit);
//         addTearDown(productionCubit.close);
//         addTearDown(shiftsFilterCubit.close);
//         addTearDown(shiftsCubit.close);
//         addTearDown(expensesFilterCubit.close);
//         addTearDown(expensesCubit.close);
//
//         await pumpScreen(
//           tester,
//           extraProviders: [
//             BlocProvider<ProductionCubit>.value(value: productionCubit),
//             BlocProvider<ShiftsFilterCubit>.value(value: shiftsFilterCubit),
//             BlocProvider<ShiftsCubit>.value(value: shiftsCubit),
//             BlocProvider<ExpensesFilterCubit>.value(value: expensesFilterCubit),
//             BlocProvider<ExpensesCubit>.value(value: expensesCubit),
//           ],
//         );
//
//         expect(workerCubit.state, isA<Supervisor>());
//         expect(find.text('Croissant'), findsOneWidget);
//         expect(find.textContaining('Alice'), findsOneWidget);
//         expect(find.text('10.00'), findsOneWidget);
//       });
// }