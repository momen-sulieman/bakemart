import 'dart:async';
import 'dart:io';

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
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/data/bakery_tab_repo.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/test_setup.dart';

class MockBakeryTabRepo extends Mock implements BakeryTabRepo {}

class MockLocationCubit extends Mock implements LocationCubit {}

class MockSupabaseImageCubit extends Mock implements SupabaseImageCubit {}

void main() {
  late MockBakeryTabRepo repo;
  late MockLocationCubit locationCubit;
  late StreamController<LocationState> locationStates;
  late LocationState currentLocation;

  final bakery = fakeBakery('owner-1', 30, 31);

  setUpAll(() async {
    registerFallbackValue(bakery);
    registerFallbackValue(<ProductModel>[]);
    registerFallbackValue(PayrollModel(bakeryId: '', payrollMethod: true));
    registerFallbackValue(StorageModel(bakeryId: ''));
    registerFallbackValue(File('fallback.jpg'));
    await setupTestEnvironment();
  });

  setUp(() {
    repo = MockBakeryTabRepo();
    locationCubit = MockLocationCubit();
    locationStates = StreamController<LocationState>.broadcast();
    currentLocation = LocationUpdated(lat: 30, lng: 31);

    when(() => locationCubit.state).thenAnswer((_) => currentLocation);
    when(() => locationCubit.stream).thenAnswer((_) => locationStates.stream);
    when(
          () => repo.fetchBakery(),
    ).thenAnswer((_) async => SuccessResponse<BakeryModel?>(null));
    when(
          () => repo.fetchStorage(),
    ).thenAnswer((_) async => SuccessResponse<StorageModel?>(null));
    when(
          () => repo.fetchPayroll(),
    ).thenAnswer((_) async => SuccessResponse<PayrollModel?>(null));
    when(
          () => repo.fetchProducts(),
    ).thenAnswer((_) async => SuccessResponse<List<ProductModel>>([]));
    when(
          () => repo.fetchSales(),
    ).thenAnswer((_) async => SuccessResponse<List<SalesModel>>([]));
    when(
          () => repo.fetchFinance(),
    ).thenAnswer((_) async => SuccessResponse<List<FinanceModel>>([]));
    when(
          () => repo.fetchShifts(),
    ).thenAnswer((_) async => SuccessResponse<List<ShiftModel>>([]));
    when(
          () => repo.fetchStaff(),
    ).thenAnswer((_) async => SuccessResponse<List<StaffModel>>([]));
  });

  tearDown(() async {
    await locationStates.close();
  });

  Future<BakeryTabCubit> build({
    String? Function()? currentUserId,
    SupabaseImageCubit Function(String bucket)? imageCubitFactory,
  }) async {
    final cubit = BakeryTabCubit(
      repo,
      locationCubit,
      currentUserId: currentUserId ?? () => 'owner-1',
      imageCubitFactory: imageCubitFactory,
    );
    addTearDown(cubit.close);
    await pumpEventQueue();
    return cubit;
  }

  List<BakeryTabState> collect(BakeryTabCubit cubit) {
    final states = <BakeryTabState>[];
    cubit.stream.listen(states.add);
    return states;
  }

  group('check', () {
    test('starts loading', () async {
      final cubit = BakeryTabCubit(
        repo,
        locationCubit,
        currentUserId: () => 'owner-1',
      );
      addTearDown(cubit.close);

      expect(cubit.state, isA<BakeryTabLoading>());
      await pumpEventQueue();
    });

    test('has no bakery when the owner has none', () async {
      final cubit = await build();

      expect(cubit.state, isA<HasNoBakery>());
      verifyNever(() => repo.fetchStorage());
    });

    test('loads everything when the owner has a bakery', () async {
      final product = fakeProduct(id: 'p1', bakeryId: 'owner-1');
      when(
            () => repo.fetchBakery(),
      ).thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
      when(() => repo.fetchProducts()).thenAnswer(
            (_) async => SuccessResponse<List<ProductModel>>([product]),
      );
      final cubit = BakeryTabCubit(
        repo,
        locationCubit,
        currentUserId: () => 'owner-1',
      );
      addTearDown(cubit.close);
      final states = collect(cubit);

      await pumpEventQueue();

      expect(states, [isA<HasBakery>(), isA<HasBakery>()]);
      expect(cubit.bakery, bakery);
      expect(cubit.products, [product]);
      verify(() => repo.fetchStorage()).called(1);
      verify(() => repo.fetchPayroll()).called(1);
      verify(() => repo.fetchSales()).called(1);
      verify(() => repo.fetchFinance()).called(1);
      verify(() => repo.fetchShifts()).called(1);
      verify(() => repo.fetchStaff()).called(1);
    });

    test('fails when the bakery cannot be fetched', () async {
      when(() => repo.fetchBakery()).thenAnswer(
            (_) async => FailureResponse<BakeryModel?>('offline'),
      );

      final cubit = await build();

      expect(cubit.state, isA<BakeryTabFailure>());
      expect((cubit.state as BakeryTabFailure).error, 'offline');
    });
  });

  group('location', () {
    test('takes the current location on creation', () async {
      final cubit = await build();

      expect(cubit.bakeryLat, 30);
      expect(cubit.bakeryLng, 31);
    });

    test('follows the location stream and refreshes the onboarding', () async {
      final cubit = await build();
      final states = collect(cubit);

      locationStates.add(LocationUpdated(lat: 40, lng: 41));
      await pumpEventQueue();

      expect(cubit.bakeryLat, 40);
      expect(cubit.bakeryLng, 41);
      expect(states, [isA<HasNoBakery>()]);
    });

    test('ignores the stream after a manual location', () async {
      final cubit = await build();

      cubit.updatePendingLocation(lat: 1, lng: 2);
      locationStates.add(LocationUpdated(lat: 40, lng: 41));
      await pumpEventQueue();

      expect(cubit.hasManualLocation, true);
      expect(cubit.bakeryLat, 1);
      expect(cubit.bakeryLng, 2);
    });

    test('setLocation copies the latest known location', () async {
      final cubit = await build();
      cubit.updatePendingLocation(lat: 1, lng: 2);
      currentLocation = LocationUpdated(lat: 5, lng: 6);

      cubit.setLocation();

      expect(cubit.bakeryLat, 5);
      expect(cubit.bakeryLng, 6);
    });

    test('locationEditingMode stores the flag and emits', () async {
      final cubit = await build();
      final states = collect(cubit);

      cubit.locationEditingMode(true);
      await pumpEventQueue();

      expect(cubit.isLocationEditing, true);
      expect(states, [isA<HasNoBakery>()]);
    });
  });

  group('form validity', () {
    test('formValidity needs name, products, payroll, storage and a certificate photo',
            () async {
          final cubit = await build();

          cubit.setValidity(
            nameValidityState: true,
            payrollValidityState: true,
            storageValidityState: true,
          );
          expect(cubit.formValidity, false);

          cubit.addProduct(fakeProduct());
          cubit.setValidity();
          expect(
            cubit.formValidity,
            false,
            reason: 'still missing the certificate photo',
          );

          cubit.setCertificateImage(File('cert.jpg'));
          expect(cubit.formValidity, true);

          cubit.onNameChanged('');
          expect(cubit.nameValidity, false);
          expect(cubit.formValidity, false);
        });

    test('storage is valid with one positive amount', () async {
      final cubit = await build();
      final field = cubit.storageFields.first.$2;

      expect(cubit.checkStorageValidity(), false);
      field.text = '0';
      expect(cubit.checkStorageValidity(), false);
      field.text = 'abc';
      expect(cubit.checkStorageValidity(), false);
      field.text = '5';
      expect(cubit.checkStorageValidity(), true);
      field.text = '٥';
      expect(cubit.checkStorageValidity(), true);
    });

    test('onStorageFieldChanged updates the validity', () async {
      final cubit = await build();
      cubit.storageFields.first.$2.text = '5';

      cubit.onStorageFieldChanged();

      expect(cubit.storageValidity, true);
    });

    test('payroll needs a supervisor and one other salary', () async {
      final cubit = await build();
      final supervisor = cubit.payrollFields
          .firstWhere((field) => field.$1 == PayrollsTableColumns.supervisor)
          .$2;
      final other = cubit.payrollFields
          .firstWhere((field) => field.$1 == PayrollsTableColumns.chef)
          .$2;

      cubit.validatePayrollInputs();
      expect(cubit.payrollValidity, false);

      supervisor.text = '100';
      cubit.validatePayrollInputs();
      expect(cubit.payrollValidity, false);

      other.text = '80';
      cubit.validatePayrollInputs();
      expect(cubit.payrollValidity, true);

      supervisor.text = '0';
      cubit.validatePayrollInputs();
      expect(cubit.payrollValidity, false);
    });

    test('setPayrollMethod stores the method', () async {
      final cubit = await build();

      cubit.setPayrollMethod(false);

      expect(cubit.selectedPayrollMethod, false);
    });
  });

  group('products', () {
    test('addProduct appends and remembers its image', () async {
      final cubit = await build();
      final photo = File('p1.jpg');

      cubit.addProduct(fakeProduct(id: 'p1'), image: photo);
      cubit.addProduct(fakeProduct(id: 'p2'));

      expect(cubit.editableProducts.map((p) => p.productId), ['p1', 'p2']);
      expect(cubit.pendingProductImages, {'p1': photo});
    });

    test('setProductImage stores the image and emits', () async {
      final cubit = await build();
      final states = collect(cubit);
      final photo = File('p1.jpg');

      cubit.setProductImage('p1', photo);
      await pumpEventQueue();

      expect(cubit.pendingProductImages['p1'], photo);
      expect(states, [isA<HasNoBakery>()]);
    });

    test('editProduct replaces the product at the index', () async {
      final cubit = await build();
      cubit.addProduct(fakeProduct(id: 'p1'));

      cubit.editProduct(
        updatedProduct: fakeProduct(id: 'p1').copyWith(productName: 'New'),
        index: 0,
      );

      expect(cubit.editableProducts.single.productName, 'New');
    });

    test('removeProduct removes the product at the index', () async {
      final cubit = await build();
      cubit.addProduct(fakeProduct(id: 'p1'));
      cubit.addProduct(fakeProduct(id: 'p2'));

      cubit.removeProduct(index: 0);

      expect(cubit.editableProducts.map((p) => p.productId), ['p2']);
    });
  });

  test('onboardingPageChanged stores the page and emits', () async {
    final cubit = await build();
    final states = collect(cubit);

    cubit.onboardingPageChanged(2);
    await pumpEventQueue();

    expect(cubit.currentOnboardingPage, 2);
    expect(states, [isA<HasNoBakery>()]);
  });

  group('createBakery', () {
    Future<void> create(BakeryTabCubit cubit) {
      return cubit.createBakery(
        bakeryData: fakeBakery('', 30, 31),
        products: [fakeProduct(id: 'p1')],
        payroll: PayrollModel(bakeryId: '', payrollMethod: true),
        storage: StorageModel(bakeryId: ''),
      );
    }

    setUp(() {
      when(
            () => repo.createBakery(
          bakeryData: any(named: 'bakeryData'),
          products: any(named: 'products'),
          payroll: any(named: 'payroll'),
          storage: any(named: 'storage'),
        ),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
    });

    test('shows loading then reloads the created bakery', () async {
      final cubit = await build();
      when(
            () => repo.fetchBakery(),
      ).thenAnswer((_) async => SuccessResponse<BakeryModel?>(bakery));
      final states = collect(cubit);

      await create(cubit);
      await pumpEventQueue();

      expect(states, [
        isA<BakeryTabLoading>(),
        isA<HasBakery>(),
        isA<HasBakery>(),
      ]);
      expect(cubit.bakery, bakery);
    });

    test('uploads the pending images under the right ids', () async {
      final imageCubit = MockSupabaseImageCubit();
      final buckets = <String>[];
      when(
            () => imageCubit.uploadImage(any(), id: any(named: 'id')),
      ).thenAnswer((_) async => SuccessResponse<bool>(true));
      when(() => imageCubit.close()).thenAnswer((_) async {});
      final cubit = await build(
        imageCubitFactory: (bucket) {
          buckets.add(bucket);
          return imageCubit;
        },
      );
      final bakeryPhoto = File('bakery.jpg');
      final productPhoto = File('product.jpg');
      cubit.setBakeryImage(bakeryPhoto);
      cubit.addProduct(fakeProduct(id: 'p1'), image: productPhoto);

      await create(cubit);
      await pumpEventQueue();

      expect(buckets, [Buckets.bakeriesImages, Buckets.productsImages]);
      verify(() => imageCubit.uploadImage(bakeryPhoto, id: 'owner-1')).called(1);
      verify(() => imageCubit.uploadImage(productPhoto, id: 'p1')).called(1);
      verify(() => imageCubit.close()).called(2);
      expect(cubit.pendingBakeryImage, isNull);
      expect(cubit.pendingProductImages, isEmpty);
    });

    test('skips the bakery image when nobody is signed in', () async {
      final imageCubit = MockSupabaseImageCubit();
      final buckets = <String>[];
      final cubit = await build(
        currentUserId: () => null,
        imageCubitFactory: (bucket) {
          buckets.add(bucket);
          return imageCubit;
        },
      );
      cubit.setBakeryImage(File('bakery.jpg'));

      await create(cubit);
      await pumpEventQueue();

      expect(buckets, isEmpty);
    });

    test('emits the error and uploads nothing when creation fails', () async {
      when(
            () => repo.createBakery(
          bakeryData: any(named: 'bakeryData'),
          products: any(named: 'products'),
          payroll: any(named: 'payroll'),
          storage: any(named: 'storage'),
        ),
      ).thenAnswer((_) async => FailureResponse<bool>('duplicate key'));
      final imageCubit = MockSupabaseImageCubit();
      final buckets = <String>[];
      final cubit = await build(
        imageCubitFactory: (bucket) {
          buckets.add(bucket);
          return imageCubit;
        },
      );
      cubit.setBakeryImage(File('bakery.jpg'));
      final states = collect(cubit);

      await create(cubit);
      await pumpEventQueue();

      expect(states, [isA<BakeryTabLoading>(), isA<BakeryTabFailure>()]);
      expect((states.last as BakeryTabFailure).error, 'duplicate key');
      expect(buckets, isEmpty);
    });
  });
}