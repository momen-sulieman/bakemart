// import 'dart:async';
//
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
// import 'package:bakemart/features/home/tabs/bakery_tab/ui/bakery_tab_screen.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_onboarding_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
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
//   late MockBakeryTabRepo repo;
//   late MockLocationCubit locationCubit;
//   late BakeryTabCubit cubit;
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//   });
//
//   setUp(() {
//     repo = MockBakeryTabRepo();
//     locationCubit = MockLocationCubit();
//     when(() => locationCubit.state)
//         .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
//     when(() => locationCubit.stream)
//         .thenAnswer((_) => const Stream<LocationState>.empty());
//     when(() => repo.fetchStorage()).thenAnswer(
//           (_) async => SuccessResponse<StorageModel?>(StorageModel(bakeryId: '', branchId: '')),
//     );
//     when(() => repo.fetchPayroll()).thenAnswer(
//           (_) async => SuccessResponse<PayrollModel?>(
//         PayrollModel(bakeryId: '', payrollMethod: true, branchId: ''),
//       ),
//     );
//     when(() => repo.fetchProducts())
//         .thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
//     when(() => repo.fetchSales())
//         .thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
//     when(() => repo.fetchFinance())
//         .thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
//     when(() => repo.fetchShifts())
//         .thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
//     when(() => repo.fetchStaff())
//         .thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));
//   });
//
//   tearDown(() {
//     cubit.close();
//     if (GetIt.instance.isRegistered<BakeryTabCubit>()) {
//       GetIt.instance.unregister<BakeryTabCubit>();
//     }
//   });
//
//   BakeryTabCubit build() {
//     final c =
//     BakeryTabCubit(repo, locationCubit, currentUserId: () => 'owner-1');
//     if (GetIt.instance.isRegistered<BakeryTabCubit>()) {
//       GetIt.instance.unregister<BakeryTabCubit>();
//     }
//     GetIt.instance.registerLazySingleton<BakeryTabCubit>(() => c);
//     return c;
//   }
//
//   Future<void> buildReady(WidgetTester tester) async {
//     await tester.runAsync(() async {
//       cubit = build();
//       await pumpEventQueue();
//     });
//   }
//
//   Future<void> pumpScreen(WidgetTester tester) async {
//     useTallSurface(tester, size: const Size(800, 2200));
//     await pumpLocalizedWidget(
//       tester,
//       MultiBlocProvider(
//         providers: [
//           BlocProvider<BakeryTabCubit>.value(value: cubit),
//           BlocProvider<LocationCubit>.value(value: locationCubit),
//         ],
//         child: const BakeryTabScreen(),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }
//
//   testWidgets('shows the creation onboarding flow when the owner has no bakery',
//           (tester) async {
//         when(() => repo.fetchBakery())
//             .thenAnswer((_) async => SuccessResponse<BakeryModel?>(null));
//         await buildReady(tester);
//
//         await pumpScreen(tester);
//
//         expect(cubit.state, isA<HasNoBakery>());
//         expect(find.byType(CreationOnboardingScreen), findsOneWidget);
//       });
//
//   testWidgets('shows the pending notice for an unverified bakery',
//           (tester) async {
//         final bakery = fakeBakery('owner-1', 30, 31);
//         when(() => repo.fetchBakery())
//             .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
//         await buildReady(tester);
//
//         await pumpScreen(tester);
//
//         expect(cubit.state, isA<HasBakery>());
//         expect(cubit.bakery.verified, false);
//         expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
//       });
//
//   testWidgets('shows the offline retry screen on a fetch failure and retries on tap',
//           (tester) async {
//         when(() => repo.fetchBakery())
//             .thenAnswer((_) async => FailureResponse<BakeryModel?>('offline'));
//         await buildReady(tester);
//
//         await pumpScreen(tester);
//
//         expect(cubit.state, isA<BakeryTabFailure>());
//         expect(find.byIcon(Icons.cell_tower), findsOneWidget);
//
//         final bakery = fakeBakery('owner-1', 30, 31);
//         when(() => repo.fetchBakery())
//             .thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
//         await tester.tap(find.byIcon(Icons.cell_tower));
//         await tester.pumpAndSettle();
//
//         expect(cubit.state, isA<HasBakery>());
//       });
//
//   testWidgets('shows a loading spinner between states', (tester) async {
//     final gate = Completer<ResponseResult<BakeryModel?>>();
//     when(() => repo.fetchBakery()).thenAnswer((_) => gate.future);
//     cubit = build();
//
//     useTallSurface(tester, size: const Size(800, 2200));
//     await pumpLocalizedWidget(
//       tester,
//       MultiBlocProvider(
//         providers: [
//           BlocProvider<BakeryTabCubit>.value(value: cubit),
//           BlocProvider<LocationCubit>.value(value: locationCubit),
//         ],
//         child: const BakeryTabScreen(),
//       ),
//       settle: false,
//     );
//
//     expect(cubit.state, isA<BakeryTabLoading>());
//     expect(loadingDots, findsWidgets);
//   });
// }