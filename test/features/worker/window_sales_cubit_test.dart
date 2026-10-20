// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/models/shift_model.dart';
// import 'package:bakemart/core/shared/models/staff_model.dart';
// import 'package:bakemart/core/shared/models/user_model.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/window_sales_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
//
// class MockWorkerRepo extends Mock implements WorkerRepo {}
//
// void main() {
//   late MockWorkerRepo repo;
//   late WorkerCubit workerCubit;
//   late WindowSalesCubit cubit;
//   final product = fakeProduct().copyWith(bakeryId: 'b1', productId: 'p1');
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//     registerFallbackValue(product);
//   });
//
//   setUp(() async {
//     repo = MockWorkerRepo();
//     when(() => repo.getUserData()).thenAnswer(
//           (_) async => SuccessResponse<UserModel>(
//         UserModel(firstName: 'Mo', secondName: 'Amin', email: '', phone: ''),
//       ),
//     );
//     when(() => repo.checkStaffTable())
//         .thenAnswer((_) async => SuccessResponse<StaffModel?>(null));
//     when(() => repo.fetchMyShifts())
//         .thenAnswer((_) async => SuccessResponse<List<ShiftModel>?>([]));
//     when(() => repo.fetchProducts('b1'))
//         .thenAnswer((_) async => SuccessResponse<List<ProductModel>?>([product]));
//     workerCubit = WorkerCubit(repo);
//     await pumpEventQueue();
//
//     cubit = WindowSalesCubit(repo, workerCubit);
//   });
//
//   tearDown(() {
//     cubit.close();
//     workerCubit.close();
//   });
//
//   test('sell success refreshes the products and settles back to Initial',
//           () async {
//         when(
//               () => repo.windowSell(
//             soldQuantity: any(named: 'soldQuantity'),
//             notSoldQuantity: any(named: 'notSoldQuantity'),
//             mealWaste: any(named: 'mealWaste'),
//             product: any(named: 'product'),
//           ),
//         ).thenAnswer((_) async => SuccessResponse<bool>(true));
//
//         await cubit.sell(soldQuantity: 5, product: product);
//
//         expect(cubit.state, isA<WindowSalesInitial>());
//         verify(
//               () => repo.windowSell(
//             soldQuantity: 5,
//             notSoldQuantity: null,
//             mealWaste: null,
//             product: product,
//           ),
//         ).called(1);
//         verify(() => repo.fetchProducts('b1')).called(1);
//       });
//
//   test('sell failure settles to Initial after surfacing the error', () async {
//     when(
//           () => repo.windowSell(
//         soldQuantity: any(named: 'soldQuantity'),
//         notSoldQuantity: any(named: 'notSoldQuantity'),
//         mealWaste: any(named: 'mealWaste'),
//         product: any(named: 'product'),
//       ),
//     ).thenAnswer((_) async => FailureResponse<bool>('offline'));
//
//     final states = <WindowSalesState>[];
//     cubit.stream.listen(states.add);
//
//     await cubit.sell(notSoldQuantity: 3, product: product);
//     await pumpEventQueue();
//
//     expect(states.any((s) => s is WindowSalesFailure), true);
//     expect(cubit.state, isA<WindowSalesInitial>());
//     verifyNever(() => repo.fetchProducts('b1'));
//   });
// }