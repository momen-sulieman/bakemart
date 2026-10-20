// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/models/finance_model.dart';
// import 'package:bakemart/core/shared/models/order_model.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/models/staff_model.dart';
// import 'package:bakemart/core/shared/models/shift_model.dart';
// import 'package:bakemart/core/shared/models/user_model.dart';
// import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/data/worker_repo.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/delivery_man_orders_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
// import '../../helpers/widget_test_helpers.dart';
//
// class MockWorkerRepo extends Mock implements WorkerRepo {}
//
// void main() {
//   late MockWorkerRepo repo;
//   late WorkerCubit workerCubit;
//   late DeliverySalesCubit cubit;
//
//   final productA = fakeProduct().copyWith(
//     productId: 'p1',
//     productName: 'Croissant',
//     productPrice: 5.0,
//   );
//   final order = fakeOrder(bakeries: [fakeBakery('b1', 0, 0)]).copyWith(
//     orderId: 'o1',
//     customerName: 'Sam',
//     customerId: 'c1',
//     deliveryManName: 'Driver',
//     deliveryManId: 'd1',
//     orderedProducts: [productA],
//     orderedQuantities: [2],
//     received: [false],
//   );
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//     registerFallbackValue(order);
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
//     workerCubit = WorkerCubit(repo);
//     await pumpEventQueue();
//     workerCubit.bakery = fakeBakery('b1', 0, 0);
//
//     cubit = DeliverySalesCubit(repo);
//   });
//
//   tearDown(() {
//     cubit.close();
//     workerCubit.close();
//   });
//
//   Future<void> pumpScreen(WidgetTester tester) async {
//     useTallSurface(tester, size: const Size(800, 2200));
//     await pumpLocalizedWidget(
//       tester,
//       MultiBlocProvider(
//         providers: [
//           BlocProvider<DeliverySalesCubit>.value(value: cubit),
//           BlocProvider<WorkerCubit>.value(value: workerCubit),
//         ],
//         child: const DeliveryManOrdersScreen(),
//       ),
//     );
//     await tester.pumpAndSettle();
//   }
//
//   testWidgets('shows the empty state when there are no orders',
//           (tester) async {
//         when(
//               () => repo.fetchAllOrdersOfThisDeliveryMan(
//             deliveryManId: any(named: 'deliveryManId'),
//             bakeryId: any(named: 'bakeryId'),
//           ),
//         ).thenAnswer((_) async => SuccessResponse<List<OrderModel>>([]));
//         await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');
//
//         await pumpScreen(tester);
//
//         expect(find.text('No orders found'), findsOneWidget);
//       });
//
//   testWidgets('shows the failure state on a failed scan', (tester) async {
//     when(
//           () => repo.fetchAllOrdersOfThisDeliveryMan(
//         deliveryManId: any(named: 'deliveryManId'),
//         bakeryId: any(named: 'bakeryId'),
//       ),
//     ).thenAnswer((_) async => FailureResponse<List<OrderModel>>('offline'));
//     await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');
//
//     await pumpScreen(tester);
//
//     expect(find.text('Try again'), findsOneWidget);
//   });
//
//   group('with a scanned order', () {
//     setUp(() async {
//       when(
//             () => repo.fetchAllOrdersOfThisDeliveryMan(
//           deliveryManId: any(named: 'deliveryManId'),
//           bakeryId: any(named: 'bakeryId'),
//         ),
//       ).thenAnswer((_) async => SuccessResponse<List<OrderModel>>([order]));
//       await cubit.scanOrders(deliveryManId: 'd1', bakeryId: 'b1');
//     });
//
//     testWidgets('renders the driver name, the total and the order',
//             (tester) async {
//           await pumpScreen(tester);
//
//           expect(find.textContaining('Driver'), findsWidgets);
//           expect(find.text('10.00'), findsWidgets);
//           expect(find.textContaining('Sam'), findsWidgets);
//           expect(find.text('Croissant'), findsOneWidget);
//         });
//
//     testWidgets('tapping a product opens its details dialog', (tester) async {
//       await pumpScreen(tester);
//
//       await tester.tap(find.text('Croissant'));
//       await tester.pumpAndSettle();
//
//       expect(find.byType(ProductDetailsScreen), findsOneWidget);
//     });
//
//     testWidgets('decreasing the quantity lowers the subtotal and the total',
//             (tester) async {
//           await pumpScreen(tester);
//
//           await tester.tap(find.byIcon(Icons.remove));
//           await tester.pumpAndSettle();
//
//           expect(cubit.editableOrders.single.orderedQuantities[0], 1);
//           expect(find.text('5.00'), findsWidgets);
//         });
//
//     testWidgets(
//         'increasing the quantity back toward the original is allowed, past it is not',
//             (tester) async {
//           await pumpScreen(tester);
//           await tester.tap(find.byIcon(Icons.remove));
//           await tester.pumpAndSettle();
//           expect(cubit.editableOrders.single.orderedQuantities[0], 1);
//
//           await tester.tap(find.byIcon(Icons.add));
//           await tester.pumpAndSettle();
//
//           expect(cubit.editableOrders.single.orderedQuantities[0], 2);
//         });
//
//     testWidgets('a reduced order shows a refresh icon that resets it',
//             (tester) async {
//           await pumpScreen(tester);
//           await tester.tap(find.byIcon(Icons.remove));
//           await tester.pumpAndSettle();
//           expect(find.byIcon(Icons.refresh), findsOneWidget);
//
//           await tester.tap(find.byIcon(Icons.refresh));
//           await tester.pumpAndSettle();
//
//           expect(cubit.editableOrders.single.orderedQuantities[0], 2);
//           expect(find.byIcon(Icons.refresh), findsNothing);
//         });
//
//     testWidgets('tapping "all" hands off every order and updates the worker',
//             (tester) async {
//           when(
//                 () => repo.updateOrderInDatabase(
//               order: any(named: 'order'),
//               bakeryId: any(named: 'bakeryId'), branchId: '',
//             ),
//           ).thenAnswer((_) async => SuccessResponse<bool>(true));
//           when(() => repo.fetchProducts('b1'))
//               .thenAnswer((_) async => SuccessResponse<List<ProductModel>?>([]));
//           when(() => repo.fetchFinance('b1')).thenAnswer(
//                 (_) async => SuccessResponse<List<FinanceModel>?>([]),
//           );
//
//           await pumpScreen(tester);
//
//           await tester.tap(find.text('all'));
//           await tester.pumpAndSettle();
//
//           verify(
//                 () => repo.updateOrderInDatabase(order: order, bakeryId: 'b1', branchId: ''),
//           ).called(1);
//           verify(() => repo.fetchProducts('b1')).called(1);
//           verify(() => repo.fetchFinance('b1')).called(1);
//         });
//   });
// }