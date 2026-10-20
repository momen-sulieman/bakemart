// import 'dart:io';
//
// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/cubits/location_cubit/location_cubit.dart';
// import 'package:bakemart/core/shared/cubits/location_cubit/location_state.dart';
// import 'package:bakemart/core/shared/models/bakery_model.dart';
// import 'package:bakemart/core/shared/models/payroll_model.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/models/storage_model.dart';
// import 'package:bakemart/core/shared/widgets/dialogs/add_product_dialog/ui/add_product_dialog.dart';
// import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/ui/widgets/creation_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/di_overrides.dart';
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
// import '../../helpers/widget_test_helpers.dart';
//
// class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}
//
// class MockLocationCubit extends Mock implements LocationCubit {}
//
// class MockImageCubit extends Mock implements SupabaseImageCubit {}
//
// void main() {
//   late MockBakeryTabRepo bakeryRepo;
//   late MockLocationCubit locationCubit;
//   late MockImageCubit imageCubit;
//   late BakeryTabCubit bakeryCubit;
//
//   setUpAll(() async {
//     await setupTestEnvironment();
//     registerFallbackValue(File('fallback.png'));
//     registerFallbackValue(fakeBakery('', 0, 0));
//     registerFallbackValue(PayrollModel(bakeryId: '', payrollMethod: true, branchId: ''));
//     registerFallbackValue(StorageModel(bakeryId: '', branchId: ''));
//     registerFallbackValue(<ProductModel>[]);
//   });
//
//   setUp(() async {
//     ensureImageCubitFactory();
//     bakeryRepo = MockBakeryTabRepo();
//     locationCubit = MockLocationCubit();
//     imageCubit = MockImageCubit();
//
//     when(() => locationCubit.state)
//         .thenAnswer((_) => LocationUpdated(lat: 30, lng: 31));
//     when(() => locationCubit.stream)
//         .thenAnswer((_) => const Stream<LocationState>.empty());
//     when(() => bakeryRepo.fetchBakery())
//         .thenAnswer((_) async => SuccessResponse<BakeryModel?>(null));
//     when(
//           () => bakeryRepo.createBakery(
//         bakeryData: any(named: 'bakeryData'),
//         products: any(named: 'products'),
//         payroll: any(named: 'payroll'),
//         storage: any(named: 'storage'),
//       ),
//     ).thenAnswer((_) async => SuccessResponse<bool>(true));
//     when(
//           () => imageCubit.uploadImage(any(), id: any(named: 'id')),
//     ).thenAnswer((_) async => SuccessResponse<bool>(true));
//     when(() => imageCubit.close()).thenAnswer((_) async {});
//
//     bakeryCubit = BakeryTabCubit(
//       bakeryRepo,
//       locationCubit,
//       currentUserId: () => 'owner-1',
//       imageCubitFactory: (_) => imageCubit,
//     );
//     await pumpEventQueue();
//   });
//
//   tearDown(() async {
//     await bakeryCubit.close();
//   });
//
//   Future<void> openCreation(WidgetTester tester) async {
//     useTallSurface(tester, size: const Size(900, 6000));
//     await pumpLocalizedWidget(
//       tester,
//       Builder(
//         builder: (context) => Scaffold(
//           body: Center(
//             child: ElevatedButton(
//               onPressed: () => showDialog(
//                 context: context,
//                 barrierColor: Colors.transparent,
//                 builder: (_) => MultiBlocProvider(
//                   providers: [
//                     BlocProvider<BakeryTabCubit>.value(value: bakeryCubit),
//                     BlocProvider<LocationCubit>.value(value: locationCubit),
//                   ],
//                   child: const CreationScreen(),
//                 ),
//               ),
//               child: const Text('open'),
//             ),
//           ),
//         ),
//       ),
//     );
//     await tester.tap(find.text('open'));
//     await tester.pumpAndSettle();
//   }
//
//   ProductModel croissant() => fakeProduct(id: 'p1', bakeryId: '').copyWith(
//     productName: 'Croissant',
//     productPrice: 3.5,
//     productWeight: 80,
//   );
//
//   Future<void> makeFormValid(WidgetTester tester) async {
//     bakeryCubit.addProduct(croissant());
//     bakeryCubit.setCertificateImage(File('cert.jpg'));
//     await tester.pump();
//     final fields = find.byType(TextFormField);
//     await tester.enterText(fields.at(0), 'golden');
//     await tester.enterText(fields.at(1), '100');
//     await tester.enterText(fields.at(2), '50');
//     await tester.enterText(fields.at(8), '500');
//     await tester.pumpAndSettle();
//   }
//
//   group('products section', () {
//     testWidgets('starts without a products table', (tester) async {
//       await openCreation(tester);
//
//       expect(find.byType(Table), findsNothing);
//       expect(bakeryCubit.editableProducts, isEmpty);
//     });
//
//     testWidgets('a product added to the cubit renders as a row',
//             (tester) async {
//           await openCreation(tester);
//
//           bakeryCubit.addProduct(croissant());
//           await tester.pumpAndSettle();
//
//           expect(find.byType(Table), findsOneWidget);
//           expect(find.text('Croissant'), findsOneWidget);
//           expect(find.text('80'), findsOneWidget);
//           expect(find.text('3.50'), findsOneWidget);
//         });
//
//     testWidgets('the row delete icon removes the product', (tester) async {
//       await openCreation(tester);
//       bakeryCubit.addProduct(croissant());
//       await tester.pumpAndSettle();
//
//       await tester.tap(find.byIcon(Icons.delete_forever_outlined));
//       await tester.pumpAndSettle();
//
//       expect(bakeryCubit.editableProducts, isEmpty);
//       expect(find.byType(Table), findsNothing);
//     });
//
//     testWidgets('the add button opens the dialog and saving adds a product',
//             (tester) async {
//           await openCreation(tester);
//
//           await tester.tap(find.byIcon(Icons.add).last);
//           await tester.pumpAndSettle();
//           expect(find.byType(AddProductDialog), findsOneWidget);
//
//           final fields = find.descendant(
//             of: find.byType(AddProductDialog),
//             matching: find.byType(TextFormField),
//           );
//           await tester.enterText(fields.at(0), 'baguette');
//           await tester.enterText(fields.at(1), '2.5');
//           await tester.enterText(fields.at(2), '200');
//           await tester.enterText(fields.at(3), '10');
//           await tester.enterText(fields.at(4), '50');
//           await tester.pump();
//           await tester.tap(
//             find.descendant(
//               of: find.byType(AddProductDialog),
//               matching: find.byIcon(Icons.done),
//             ),
//           );
//           await tester.pumpAndSettle();
//
//           expect(find.byType(AddProductDialog), findsNothing);
//           expect(bakeryCubit.editableProducts, hasLength(1));
//           expect(bakeryCubit.editableProducts.single.productName, 'Baguette');
//         });
//   });
//
//   group('validity', () {
//     testWidgets('typing a bakery name toggles name validity', (tester) async {
//       await openCreation(tester);
//
//       await tester.enterText(find.byType(TextFormField).at(0), 'golden');
//       await tester.pump();
//       expect(bakeryCubit.nameValidity, true);
//
//       await tester.enterText(find.byType(TextFormField).at(0), '');
//       await tester.pump();
//       expect(bakeryCubit.nameValidity, false);
//     });
//
//     testWidgets('payroll needs a supervisor rate and at least one other rate',
//             (tester) async {
//           await openCreation(tester);
//           final fields = find.byType(TextFormField);
//
//           await tester.enterText(fields.at(1), '100');
//           await tester.pump();
//           expect(bakeryCubit.payrollValidity, false);
//
//           await tester.enterText(fields.at(2), '50');
//           await tester.pump();
//           expect(bakeryCubit.payrollValidity, true);
//         });
//
//     testWidgets('a positive storage quantity makes storage valid',
//             (tester) async {
//           await openCreation(tester);
//
//           await tester.enterText(find.byType(TextFormField).at(8), '500');
//           await tester.pump();
//
//           expect(bakeryCubit.storageValidity, true);
//         });
//
//     testWidgets('the confirm button only appears once the form is valid',
//             (tester) async {
//           await openCreation(tester);
//           expect(find.byIcon(Icons.done), findsNothing);
//
//           await makeFormValid(tester);
//
//           expect(bakeryCubit.formValidity, true);
//           expect(find.byIcon(Icons.done), findsOneWidget);
//         });
//   });
//
//   group('actions', () {
//     testWidgets('confirming creates the bakery from the entered data',
//             (tester) async {
//           await openCreation(tester);
//           await makeFormValid(tester);
//
//           await tester.tap(find.byIcon(Icons.done));
//           await tester.pumpAndSettle();
//
//           final captured = verify(
//                 () => bakeryRepo.createBakery(
//               bakeryData: captureAny(named: 'bakeryData'),
//               products: captureAny(named: 'products'),
//               payroll: captureAny(named: 'payroll'),
//               storage: captureAny(named: 'storage'),
//             ),
//           ).captured;
//           final bakeryData = captured[0] as BakeryModel;
//           final products = captured[1] as List<ProductModel>;
//           final payroll = captured[2] as PayrollModel;
//           final storage = captured[3] as StorageModel;
//
//           expect(bakeryData.bakeryName, 'Golden');
//           expect(products, hasLength(1));
//           expect(payroll.supervisor, 100.0);
//           expect(payroll.chef, 50.0);
//           expect(payroll.payrollMethod, true);
//           expect(storage.fineWheat, 500);
//           expect(find.byType(CreationScreen), findsNothing);
//           verify(() => imageCubit.uploadImage(any(), id: 'owner-1')).called(1);
//         });
//
//     testWidgets('the close icon dismisses the dialog and clears the certificate',
//             (tester) async {
//           await openCreation(tester);
//           bakeryCubit.setCertificateImage(File('cert.jpg'));
//           await tester.pump();
//
//           await tester.tap(find.byIcon(Icons.close));
//           await tester.pumpAndSettle();
//
//           expect(find.byType(CreationScreen), findsNothing);
//           expect(bakeryCubit.pendingCertificateImage, isNull);
//         });
//
//     testWidgets('the back arrow dismisses the dialog without creating',
//             (tester) async {
//           await openCreation(tester);
//
//           await tester.tap(find.byIcon(Icons.arrow_back));
//           await tester.pumpAndSettle();
//
//           expect(find.byType(CreationScreen), findsNothing);
//           verifyNever(
//                 () => bakeryRepo.createBakery(
//               bakeryData: any(named: 'bakeryData'),
//               products: any(named: 'products'),
//               payroll: any(named: 'payroll'),
//               storage: any(named: 'storage'),
//             ),
//           );
//         });
//   });
// }