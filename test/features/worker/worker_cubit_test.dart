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
// import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:mocktail/mocktail.dart';
//
// import '../../helpers/fixtures.dart';
// import '../../helpers/test_setup.dart';
//
// class MockWorkerRepo extends Mock implements WorkerRepo {}
//
// class FakeBarcodeCapture extends Fake implements BarcodeCapture {}
//
// void main() {
//   late MockWorkerRepo repo;
//
//   setUpAll(() async {
//     registerFallbackValue(FakeBarcodeCapture());
//     await setupTestEnvironment();
//   });
//
//   final user = UserModel(
//     id: 'w1',
//     firstName: 'Mo',
//     secondName: 'Men',
//     email: 'a@b.c',
//     phone: '1',
//   );
//   final bakery = fakeBakery('b1', 0, 0);
//
//   WorkerCubit build() {
//     final cubit = WorkerCubit(repo);
//     addTearDown(cubit.close);
//     return cubit;
//   }
//
//   setUp(() {
//     repo = MockWorkerRepo();
//     when(
//           () => repo.getUserData(),
//     ).thenAnswer((_) async => SuccessResponse<UserModel>(user));
//   });
//
//   test('emits UnEmployed when not in the staff table', () async {
//     when(() => repo.checkStaffTable()).thenAnswer(
//           (_) async => SuccessResponse<StaffModel?>(null),
//     );
//     when(() => repo.fetchMyShifts()).thenAnswer(
//           (_) async => SuccessResponse<List<ShiftModel>?>([fakeShift()]),
//     );
//
//     final cubit = build();
//     await pumpEventQueue();
//
//     expect(cubit.state, isA<UnEmployed>());
//     expect(cubit.shifts, hasLength(1));
//   });
//
//   test('emits Employed for staff who is not a supervisor', () async {
//     when(() => repo.checkStaffTable()).thenAnswer(
//           (_) async => SuccessResponse<StaffModel?>(fakeStaff(bakeryId: 'b1')),
//     );
//     when(
//           () => repo.getBakeryData('b1',""),
//     ).thenAnswer((_) async => SuccessResponse<BakeryModel>(bakery));
//     when(() => repo.fetchMyShifts()).thenAnswer(
//           (_) async => SuccessResponse<List<ShiftModel>?>([]),
//     );
//
//     final cubit = build();
//     await pumpEventQueue();
//
//     expect(cubit.state, isA<Employed>());
//   });
//
//   test('emits Supervisor and loads every dataset for a bakery supervisor',
//           () async {
//         final supervisorBakery = bakery.copyWith(supervisorId: ['w1']);
//         when(() => repo.checkStaffTable()).thenAnswer(
//               (_) async => SuccessResponse<StaffModel?>(fakeStaff(bakeryId: 'b1')),
//         );
//         when(() => repo.getBakeryData('b1',"")).thenAnswer(
//               (_) async => SuccessResponse<BakeryModel>(supervisorBakery),
//         );
//         when(() => repo.fetchPayroll('b1')).thenAnswer(
//               (_) async => SuccessResponse<PayrollModel?>(fakePayroll()),
//         );
//         when(() => repo.fetchProducts('b1')).thenAnswer(
//               (_) async => SuccessResponse<List<ProductModel>?>([fakeProduct()]),
//         );
//         when(() => repo.fetchStaff('b1')).thenAnswer(
//               (_) async => SuccessResponse<List<StaffModel>?>([fakeStaff()]),
//         );
//         when(() => repo.fetchShifts('b1')).thenAnswer(
//               (_) async => SuccessResponse<List<ShiftModel>?>([fakeShift()]),
//         );
//         when(() => repo.fetchFinance('b1')).thenAnswer(
//               (_) async => SuccessResponse<List<FinanceModel>?>([fakeFinance()]),
//         );
//         when(() => repo.fetchStorage('b1')).thenAnswer(
//               (_) async => SuccessResponse<StorageModel?>(fakeStorage()),
//         );
//
//         final cubit = build();
//         await pumpEventQueue();
//
//         expect(cubit.state, isA<Supervisor>());
//         expect(cubit.payrollMethod, true);
//         expect(cubit.products, hasLength(1));
//         expect(cubit.staff, hasLength(1));
//         expect(cubit.shifts, hasLength(1));
//         expect(cubit.finance, hasLength(1));
//         expect(cubit.storage, isNotNull);
//       });
//
//   test('emits WorkerFailure when the user cannot be loaded', () async {
//     when(() => repo.getUserData()).thenAnswer(
//           (_) async => FailureResponse<UserModel>('offline'),
//     );
//
//     final cubit = build();
//     await pumpEventQueue();
//
//     expect(cubit.state, isA<WorkerFailure>());
//   });
//
//   test('quit reloads to the post-quit state', () async {
//     when(() => repo.checkStaffTable()).thenAnswer(
//           (_) async => SuccessResponse<StaffModel?>(fakeStaff(bakeryId: 'b1')),
//     );
//     when(
//           () => repo.getBakeryData('b1',""),
//     ).thenAnswer((_) async => SuccessResponse<BakeryModel>(bakery));
//     when(() => repo.fetchMyShifts()).thenAnswer(
//           (_) async => SuccessResponse<List<ShiftModel>?>([]),
//     );
//     when(() => repo.quit()).thenAnswer((_) async => SuccessResponse<bool>(true));
//     final cubit = build();
//     await pumpEventQueue();
//
//     await cubit.quit();
//     await pumpEventQueue();
//
//     verify(() => repo.quit()).called(1);
//     expect(cubit.state, isA<Employed>());
//   });
//
//   test('join reloads the frame on success and fails visibly on error',
//           () async {
//         when(() => repo.checkStaffTable()).thenAnswer(
//               (_) async => SuccessResponse<StaffModel?>(null),
//         );
//         when(() => repo.fetchMyShifts()).thenAnswer(
//               (_) async => SuccessResponse<List<ShiftModel>?>([]),
//         );
//         final cubit = build();
//         await pumpEventQueue();
//         when(
//               () => repo.join(any()),
//         ).thenAnswer((_) async => FailureResponse<bool>('Bakery not found!'));
//
//         await cubit.join(BarcodeCapture(barcodes: const []));
//         await pumpEventQueue();
//
//         expect(cubit.state, isA<WorkerFailure>());
//       });
// }