// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
// import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
// import 'package:bakemart/core/shared/models/bakery_model.dart';
// import 'package:bakemart/core/shared/models/finance_model.dart';
// import 'package:bakemart/core/shared/models/payroll_model.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/models/sales_model.dart';
// import 'package:bakemart/core/shared/models/shift_model.dart';
// import 'package:bakemart/core/shared/models/staff_model.dart';
// import 'package:bakemart/core/shared/models/storage_model.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/ui/widgets/shifts_status_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
// import '../../helpers/widget_test_helpers.dart';
//
// class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}
//
// class MockLocationCubit extends Mock implements LocationCubit {}
//
// void main() {
//   late MockBakeryTabRepo bakeryRepo;
//   late MockLocationCubit locationCubit;
//   late BakeryTabCubit bakeryTabCubit;
//   late StatusShiftsFilterCubit filterCubit;
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//   });
//
//   Future<void> setUpWith(
//       WidgetTester tester,
//       List<ShiftModel> shifts, {
//         bool payrollMethod = true,
//       }) async {
//     bakeryRepo = MockBakeryTabRepo();
//     locationCubit = MockLocationCubit();
//     when(() => locationCubit.state)
//         .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
//     when(() => locationCubit.stream)
//         .thenAnswer((_) => const Stream<LocationState>.empty());
//
//     final bakery = fakeBakery('owner-1', 30, 31);
//     when(() => bakeryRepo.fetchBakery())
//         .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
//     when(() => bakeryRepo.fetchStorage()).thenAnswer(
//           (_) async =>
//           SuccessResponse<StorageModel?>(StorageModel(bakeryId: 'owner-1', branchId: '')),
//     );
//     when(() => bakeryRepo.fetchPayroll()).thenAnswer(
//           (_) async => SuccessResponse<PayrollModel?>(
//         PayrollModel(
//           bakeryId: 'owner-1',
//           payrollMethod: payrollMethod,
//           chef: 50, branchId: '',
//         ),
//       ),
//     );
//     when(() => bakeryRepo.fetchProducts())
//         .thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
//     when(() => bakeryRepo.fetchSales())
//         .thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
//     when(() => bakeryRepo.fetchFinance())
//         .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
//     when(() => bakeryRepo.fetchShifts())
//         .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>(shifts));
//     when(() => bakeryRepo.fetchStaff())
//         .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));
//     when(() => bakeryRepo.filterShiftsByDate(
//       allShifts: any(named: 'allShifts'),
//       selectedDate: any(named: 'selectedDate'),
//     )).thenAnswer((invocation) {
//       final records = invocation.namedArguments[#allShifts] as List<ShiftModel>;
//       final date = invocation.namedArguments[#selectedDate] as DateTime;
//       final matches = records
//           .where((s) =>
//       s.date?.year == date.year &&
//           s.date?.month == date.month &&
//           s.date?.day == date.day)
//           .toList();
//       return SuccessResponse<List<ShiftModel>>(matches);
//     });
//
//     await tester.runAsync(() async {
//       bakeryTabCubit = BakeryTabCubit(
//         bakeryRepo,
//         locationCubit,
//         currentUserId: () => 'owner-1',
//       );
//       await pumpEventQueue();
//     });
//
//     filterCubit = StatusShiftsFilterCubit(bakeryRepo, bakeryTabCubit);
//   }
//
//   tearDown(() {
//     bakeryTabCubit.close();
//     filterCubit.close();
//   });
//
//   Future<void> pumpTile(WidgetTester tester) async {
//     useTallSurface(tester);
//     await pumpLocalizedWidget(
//       tester,
//       Scaffold(
//         body: MultiBlocProvider(
//           providers: [
//             BlocProvider<StatusShiftsFilterCubit>.value(value: filterCubit),
//             BlocProvider<BakeryTabCubit>.value(value: bakeryTabCubit),
//           ],
//           child: const ShiftsStatusTile(),
//         ),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }
//
//   ShiftModel todayShift({
//     List<int> batches = const [3],
//     double wage = 150,
//     double? rate,
//   }) {
//     return ShiftModel(
//       bakeryId: 'owner-1',
//       workerId: 'w1',
//       workerName: 'Alice',
//       wage: wage,
//       role: const ['chef'],
//       numberOfBatches: batches,
//       date: DateTime.now(),
//       rate: rate, branchId: '',
//     );
//   }
//
//   testWidgets('shows the worker, batch count and wage for a shift today',
//           (tester) async {
//         await setUpWith(tester, [todayShift()], payrollMethod: false);
//         await pumpTile(tester);
//
//         expect(find.textContaining('Alice'), findsOneWidget);
//         expect(find.text('3'), findsWidgets);
//         expect(find.text('150.00'), findsOneWidget);
//       });
//
//   testWidgets('shows the rate percentage instead of batches on daily payroll',
//           (tester) async {
//         await setUpWith(
//           tester,
//           [todayShift(batches: const [], wage: 50, rate: 0.5)],
//           payrollMethod: true,
//         );
//         await pumpTile(tester);
//
//         expect(find.text('50%'), findsOneWidget);
//       });
//
//   testWidgets('shows no row when there is no shift for today', (tester) async {
//     await setUpWith(tester, [
//       ShiftModel(
//         bakeryId: 'owner-1',
//         workerId: 'w1',
//         workerName: 'Alice',
//         wage: 150,
//         role: const ['chef'],
//         numberOfBatches: const [3],
//         date: DateTime.now().subtract(const Duration(days: 1)), branchId: '',
//       ),
//     ]);
//     await pumpTile(tester);
//
//     expect(find.textContaining('Alice'), findsNothing);
//   });
//
//   testWidgets('tapping a shift opens its detail dialog with the batch breakdown',
//           (tester) async {
//         await setUpWith(tester, [todayShift()], payrollMethod: false);
//         await pumpTile(tester);
//
//         await tester.tap(find.textContaining('Alice'));
//         await tester.pumpAndSettle();
//
//         expect(find.byType(AlertDialog), findsOneWidget);
//         expect(find.text('150.0'), findsWidgets);
//       });
// }