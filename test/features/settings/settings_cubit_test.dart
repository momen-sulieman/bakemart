// import 'dart:io';
//
// import 'package:bakemart/core/network/response_result.dart';
// import 'package:bakemart/core/shared/models/product_model.dart';
// import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/data/settings_repo.dart';
// import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
//
// class MockSettingsRepo extends Mock implements SettingsRepo {}
//
// class MockBakeryTabCubit extends Mock implements BakeryTabCubit {}
//
// class MockSupabaseImageCubit extends Mock implements SupabaseImageCubit {}
//
// void main() {
//   late MockSettingsRepo repo;
//   late MockBakeryTabCubit bakeryTabCubit;
//
//   setUpAll(() async {
//     registerFallbackValue(fakeBakery('b1', 0, 0));
//     registerFallbackValue(<ProductModel>[]);
//     registerFallbackValue(fakeStaff());
//     registerFallbackValue(File('fallback.jpg'));
//     await setupTestEnvironment();
//   });
//
//   setUp(() {
//     repo = MockSettingsRepo();
//     bakeryTabCubit = MockBakeryTabCubit();
//     when(() => bakeryTabCubit.bakery).thenAnswer((_) => fakeBakery('b1', 1, 2));
//     when(() => bakeryTabCubit.payroll).thenAnswer((_) => fakePayroll());
//     when(() => bakeryTabCubit.staff).thenAnswer((_) => [fakeStaff()]);
//     when(() => bakeryTabCubit.products).thenAnswer((_) => [fakeProduct(id: 'p1')]);
//     when(() => bakeryTabCubit.loadBakeryData()).thenAnswer((_) async {});
//     when(() => bakeryTabCubit.loadPayroll()).thenAnswer((_) async {});
//     when(() => bakeryTabCubit.loadProducts()).thenAnswer((_) async {});
//     when(() => bakeryTabCubit.loadStaff()).thenAnswer((_) async {});
//   });
//
//   SettingsCubit build({SupabaseImageCubit Function(String bucket)? imageCubitFactory}) {
//     final cubit = SettingsCubit(
//       repo,
//       bakeryTabCubit,
//       imageCubitFactory: imageCubitFactory,
//     );
//     addTearDown(cubit.close);
//     return cubit;
//   }
//
//   test('getSettings mirrors the bakery tab cubit on creation', () async {
//     final cubit = build();
//     await pumpEventQueue();
//
//     expect(cubit.state, isA<SettingsSuccess>());
//     final state = cubit.state as SettingsSuccess;
//     expect(state.bakery.bakeryId, 'b1');
//     expect(state.staff, hasLength(1));
//     expect(state.products.single.productId, 'p1');
//   });
//
//   test('deleteProduct reloads and reports failure if everything was removed',
//           () async {
//         when(
//               () => repo.deleteProduct(productId: 'p1'),
//         ).thenAnswer((_) async => SuccessResponse<bool>(true));
//         when(() => bakeryTabCubit.products).thenAnswer((_) => []);
//         final cubit = build();
//         await pumpEventQueue();
//
//         await cubit.deleteProduct(productId: 'p1');
//         await pumpEventQueue();
//
//         expect(cubit.products, isEmpty);
//         expect(cubit.editableProducts, isEmpty);
//       });
//
//   test('addProduct appends to editable products and tracks its image',
//           () async {
//         final cubit = build();
//         await pumpEventQueue();
//         final photo = File('p2.jpg');
//
//         cubit.addProduct(fakeProduct(id: 'p2'), image: photo);
//
//         final state = cubit.state as SettingsSuccess;
//         expect(state.products.map((p) => p.productId), ['p1', 'p2']);
//         expect(cubit.pendingProductImages, {'p2': photo});
//         expect(cubit.isProductsChanged, true);
//       });
//
//   test('productsCancelEditing restores the original list and clears images',
//           () async {
//         final cubit = build();
//         await pumpEventQueue();
//         cubit.addProduct(fakeProduct(id: 'p2'), image: File('p2.jpg'));
//
//         cubit.productsCancelEditing();
//
//         expect(cubit.editableProducts, cubit.products);
//         expect(cubit.pendingProductImages, isEmpty);
//         expect(cubit.isProductsChanged, false);
//       });
//
//   test('editProduct replaces the matching product', () async {
//     final cubit = build();
//     await pumpEventQueue();
//
//     cubit.editProduct(fakeProduct(id: 'p1').copyWith(productName: 'New'));
//
//     final state = cubit.state as SettingsSuccess;
//     expect(state.products.single.productName, 'New');
//   });
//
//   test('updatePayrollMethod flips the method and marks a change', () async {
//     final cubit = build();
//     await pumpEventQueue();
//
//     cubit.updatePayrollMethod(false);
//
//     expect(cubit.editablePayroll!.payrollMethod, false);
//     expect(cubit.isPayrollChanged, true);
//   });
//
//   test('postNewRate updates the right role', () async {
//     final cubit = build();
//     await pumpEventQueue();
//
//     cubit.postNewRate(role: 'chef', newRate: 50);
//
//     expect(cubit.editablePayroll!.chef, 50);
//     expect(cubit.isPayrollChanged, true);
//   });
//
//   test('payrollCancelEditing restores the baseline payroll', () async {
//     final cubit = build();
//     await pumpEventQueue();
//     cubit.postNewRate(role: 'chef', newRate: 50);
//
//     cubit.payrollCancelEditing();
//
//     expect(cubit.editablePayroll, cubit.payroll);
//     expect(cubit.isPayrollChanged, false);
//   });
//
//   group('updateBakeryData', () {
//     test('reloads the bakery on success', () async {
//       when(
//             () => repo.updateBakeryData(any()),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       final cubit = build();
//       await pumpEventQueue();
//       final reloaded = fakeBakery('b1', 9, 9);
//       when(() => bakeryTabCubit.bakery).thenAnswer((_) => reloaded);
//
//       await cubit.updateBakeryData(reloaded);
//       await pumpEventQueue();
//
//       expect(cubit.bakery, reloaded);
//     });
//   });
//
//   group('updateProducts', () {
//     test('uploads pending images then reloads', () async {
//       when(
//             () => repo.updateProducts(any()),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       final imageCubit = MockSupabaseImageCubit();
//       when(
//             () => imageCubit.uploadImage(any(), id: any(named: 'id')),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       when(() => imageCubit.close()).thenAnswer((_) async {});
//       final cubit = build(imageCubitFactory: (_) => imageCubit);
//       await pumpEventQueue();
//       cubit.addProduct(fakeProduct(id: 'p2'), image: File('p2.jpg'));
//
//       await cubit.updateProducts([fakeProduct(id: 'p1'), fakeProduct(id: 'p2')]);
//       await pumpEventQueue();
//
//       expect(cubit.isProductsChanged, false);
//       expect(cubit.pendingProductImages, isEmpty);
//       verify(() => imageCubit.uploadImage(any(), id: 'p2')).called(1);
//       verify(() => imageCubit.close()).called(1);
//     });
//
//     test('leaves state untouched on failure', () async {
//       when(
//             () => repo.updateProducts(any()),
//       ).thenAnswer((_) async => FailureResponse<bool>('denied'));
//       final cubit = build();
//       await pumpEventQueue();
//       cubit.addProduct(fakeProduct(id: 'p2'));
//
//       await cubit.updateProducts([fakeProduct(id: 'p1'), fakeProduct(id: 'p2')]);
//       await pumpEventQueue();
//
//       expect(cubit.isProductsChanged, true);
//     });
//   });
//
//   group('changeBakeryData', () {
//     test('reloads on success', () async {
//       when(
//             () => repo.changeBakeryData(updatedBakery: any(named: 'updatedBakery')),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       final cubit = build();
//       await pumpEventQueue();
//
//       await cubit.changeBakeryData(updatedBakery: fakeBakery('b1', 1, 2));
//       await pumpEventQueue();
//
//       verify(() => bakeryTabCubit.loadBakeryData()).called(1);
//     });
//
//     test('emits a failure', () async {
//       when(
//             () => repo.changeBakeryData(updatedBakery: any(named: 'updatedBakery')),
//       ).thenAnswer((_) async => FailureResponse<bool>('denied'));
//       final cubit = build();
//       await pumpEventQueue();
//
//       await cubit.changeBakeryData(updatedBakery: fakeBakery('b1', 1, 2));
//       await pumpEventQueue();
//
//       expect(cubit.state, isA<SettingsFailure>());
//     });
//   });
//
//   group('deleteWorker', () {
//     test('reloads staff on success', () async {
//       when(
//             () => repo.deleteWorker(worker: any(named: 'worker')),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       final cubit = build();
//       await pumpEventQueue();
//       when(() => bakeryTabCubit.staff).thenAnswer((_) => []);
//
//       await cubit.deleteWorker(worker: fakeStaff());
//       await pumpEventQueue();
//
//       expect(cubit.staff, isEmpty);
//     });
//
//     test('emits a failure', () async {
//       when(
//             () => repo.deleteWorker(worker: any(named: 'worker')),
//       ).thenAnswer((_) async => FailureResponse<bool>('denied'));
//       final cubit = build();
//       await pumpEventQueue();
//
//       await cubit.deleteWorker(worker: fakeStaff());
//       await pumpEventQueue();
//
//       expect(cubit.state, isA<SettingsFailure>());
//     });
//   });
//
//   group('addWorker', () {
//     test('reloads staff and returns the result on success', () async {
//       when(
//             () => repo.addWorker(
//           workerId: any(named: 'workerId'),
//           workerName: any(named: 'workerName'),
//         ),
//       ).thenAnswer((_) async => SuccessResponse<bool>(true));
//       final cubit = build();
//       await pumpEventQueue();
//       final staffAfter = [fakeStaff(), fakeStaff(workerId: 'w2')];
//       when(() => bakeryTabCubit.staff).thenAnswer((_) => staffAfter);
//
//       final result = await cubit.addWorker(workerId: 'w2');
//
//       expect(result, isA<SuccessResponse<bool>>());
//       expect(cubit.staff, staffAfter);
//     });
//
//     test('does not reload staff on failure', () async {
//       when(
//             () => repo.addWorker(
//           workerId: any(named: 'workerId'),
//           workerName: any(named: 'workerName'),
//         ),
//       ).thenAnswer((_) async => FailureResponse<bool>('Wrong QR code'));
//       final cubit = build();
//       await pumpEventQueue();
//
//       final result = await cubit.addWorker(workerId: 'bad');
//
//       expect(result, isA<FailureResponse<bool>>());
//       verifyNever(() => bakeryTabCubit.loadStaff());
//     });
//   });
// }