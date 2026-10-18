import 'dart:async';
import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/sales_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/utils/enums/payrolls_table_columns.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../core/shared/models/product_model.dart';
import '../../../../../../core/shared/models/shift_model.dart';
import '../../../../../../core/shared/models/staff_model.dart';
import '../../../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../core/utils/extensions/string_extension.dart';
import '../../data/bakery_tab_repo.dart';

part 'bakery_tab_state.dart';

typedef StorageFieldDescriptor = (
  String label,
  TextEditingController controller,
  String unit,
);
typedef PayrollFieldDescriptor = (
  String label,
  TextEditingController controller,
  bool isRequired,
);

class BakeryTabCubit extends Cubit<BakeryTabState> {
  final BakeryTabRepo _repo;
  final LocationCubit _locationCubit;
  final String? Function() _currentUserId;
  final SupabaseImageCubit Function(String bucket) _imageCubitFactory;

  BakeryTabCubit(
    this._repo,
    this._locationCubit, {
    String? Function()? currentUserId,
    SupabaseImageCubit Function(String bucket)? imageCubitFactory,
  }) : _currentUserId =
           currentUserId ??
           (() => Supabase.instance.client.auth.currentUser?.id),
       _imageCubitFactory =
           imageCubitFactory ?? ((bucket) => SupabaseImageCubit(bucket, null)),
       super(BakeryTabLoading()) {
    storageFields = [
      (StorageItems.fineWheat, TextEditingController(), "gram"),
      (StorageItems.wholeWheat, TextEditingController(), "gram"),
      (StorageItems.corn, TextEditingController(), "gram"),
      (StorageItems.oats, TextEditingController(), "gram"),
      (StorageItems.barley, TextEditingController(), "gram"),
      (StorageItems.semolina, TextEditingController(), "gram"),
      (StorageItems.phyllo, TextEditingController(), "gram"),
      (StorageItems.yeast, TextEditingController(), "gram"),
      (StorageItems.salt, TextEditingController(), "gram"),
      (StorageItems.sugar, TextEditingController(), "gram"),
      (StorageItems.eggs, TextEditingController(), "egg"),
      (StorageItems.ghee, TextEditingController(), "gram"),
      (StorageItems.oil, TextEditingController(), "gram"),
      (StorageItems.butter, TextEditingController(), "gram"),
      (StorageItems.sesame, TextEditingController(), "gram"),
      (StorageItems.blackSeeds, TextEditingController(), "gram"),
      (StorageItems.fennel, TextEditingController(), "gram"),
      (StorageItems.anise, TextEditingController(), "gram"),
      (StorageItems.mahlab, TextEditingController(), "gram"),
      (StorageItems.cinnamon, TextEditingController(), "gram"),
      (StorageItems.bakingPowder, TextEditingController(), "gram"),
      (StorageItems.bakingSoda, TextEditingController(), "gram"),
      (StorageItems.conditioner, TextEditingController(), "gram"),
      (StorageItems.vanilla, TextEditingController(), "gram"),
      (StorageItems.milk, TextEditingController(), "gram"),
      (StorageItems.milkPowder, TextEditingController(), "gram"),
      (StorageItems.whippingCream, TextEditingController(), "gram"),
      (StorageItems.condensedMilk, TextEditingController(), "gram"),
      (StorageItems.chocolate, TextEditingController(), "gram"),
      (StorageItems.datePaste, TextEditingController(), "gram"),
      (StorageItems.malban, TextEditingController(), "gram"),
      (StorageItems.custard, TextEditingController(), "gram"),
      (StorageItems.cocoa, TextEditingController(), "gram"),
      (StorageItems.coconutPowder, TextEditingController(), "gram"),
      (StorageItems.blackMolasses, TextEditingController(), "gram"),
      (StorageItems.whiteCheese, TextEditingController(), "gram"),
      (StorageItems.roumyCheese, TextEditingController(), "gram"),
      (StorageItems.istanbouliCheese, TextEditingController(), "gram"),
      (StorageItems.mozzarella, TextEditingController(), "gram"),
      (StorageItems.olives, TextEditingController(), "gram"),
      (StorageItems.peanut, TextEditingController(), "gram"),
      (StorageItems.cashew, TextEditingController(), "gram"),
      (StorageItems.almond, TextEditingController(), "gram"),
      (StorageItems.pistachio, TextEditingController(), "gram"),
    ];

    payrollFields = [
      (PayrollsTableColumns.supervisor, TextEditingController(), true),
      (PayrollsTableColumns.chef, TextEditingController(), false),
      (PayrollsTableColumns.coChef, TextEditingController(), false),
      (PayrollsTableColumns.ajan, TextEditingController(), false),
      (PayrollsTableColumns.faran, TextEditingController(), false),
      (PayrollsTableColumns.tawlaji, TextEditingController(), false),
      (PayrollsTableColumns.bagger, TextEditingController(), false),
    ];

    final currentLocationState = _locationCubit.state;
    if (currentLocationState is LocationUpdated) {
      bakeryLat = currentLocationState.lat;
      bakeryLng = currentLocationState.lng;
    }
    _locationSubscription = _locationCubit.stream.listen((locationState) {
      if (locationState is LocationUpdated && !hasManualLocation) {
        bakeryLat = locationState.lat;
        bakeryLng = locationState.lng;
        if (state is HasNoBakery) {
          emit(HasNoBakery());
        }
      }
    });
    check();
  }

  StreamSubscription? _locationSubscription;
  bool hasManualLocation = false;

  List<ProductModel> products = [];
  List<ProductModel> editableProducts = [];
  List<SalesModel> sales = [];
  List<FinanceModel> finance = [];
  List<ShiftModel> shifts = [];
  List<StaffModel> staff = [];
  StorageModel storage = StorageModel(bakeryId: "", branchId: "");
  BakeryModel bakery = BakeryModel(
    bakeryName: "",
    bakeryLat: 0,
    bakeryLng: 0,
    supervisorId: [],
    bakeryId: "",
    branchId: "",
    branchName: "",
    branchNumber: 1,
  );
  PayrollModel payroll = PayrollModel(
    bakeryId: "",
    payrollMethod: true,
    branchId: "",
  );

  final TextEditingController nameController = TextEditingController();
  final TextEditingController branchNameController = TextEditingController();
  late final List<StorageFieldDescriptor> storageFields;
  late final List<PayrollFieldDescriptor> payrollFields;
  bool selectedPayrollMethod = true;

  bool newProductFormValidity = false;
  bool payrollValidity = false;
  bool storageValidity = false;
  bool nameValidity = false;
  bool branchNameValidity = false;
  bool formValidity = false;
  bool isLocationEditing = false;
  double bakeryLat = 0;
  double bakeryLng = 0;
  File? pendingBakeryImage;
  File? pendingCertificateImage;
  final Map<String, File> pendingProductImages = {};

  final PageController pageController = PageController();
  int currentOnboardingPage = 0;

  void onboardingPageChanged(int index) {
    currentOnboardingPage = index;
    emit(HasNoBakery());
  }

  void nextOnboardingPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void previousOnboardingPage() {
    pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void setBakeryImage(File? image) {
    pendingBakeryImage = image;
  }

  void setCertificateImage(File? image) {
    pendingCertificateImage = image;
    setValidity();
  }

  void setLocation() {
    final locationState = _locationCubit.state;
    if (locationState is LocationUpdated) {
      bakeryLat = locationState.lat;
      bakeryLng = locationState.lng;
    }
  }

  void updatePendingLocation({required double lat, required double lng}) {
    bakeryLat = lat;
    bakeryLng = lng;
    hasManualLocation = true;
    emit(HasNoBakery());
  }

  void locationEditingMode(bool editing) {
    isLocationEditing = editing;
    emit(HasNoBakery());
  }

  void setValidity({
    bool? nameValidityState,
    bool? branchNameValidityState,
    bool? payrollValidityState,
    bool? newProductFormValidityState,
    bool? storageValidityState,
  }) {
    if (nameValidityState != null) {
      nameValidity = nameValidityState;
    }
    if (branchNameValidityState != null) {
      branchNameValidity = branchNameValidityState;
    }
    if (newProductFormValidityState != null) {
      newProductFormValidity = newProductFormValidityState;
    }
    if (payrollValidityState != null) {
      payrollValidity = payrollValidityState;
    }
    if (storageValidityState != null) {
      storageValidity = storageValidityState;
    }
    formValidity =
        nameValidity &&
        branchNameValidity &&
        editableProducts.isNotEmpty &&
        payrollValidity &&
        storageValidity &&
        pendingCertificateImage != null;
    emit(HasNoBakery());
  }

  void onNameSet(String text) {
    setValidity(nameValidityState: text.isNotEmpty);
  }

  void onBranchNameSet(String text) {
    setValidity(branchNameValidityState: text.isNotEmpty);
  }

  bool checkStorageValidity() {
    return storageFields.any((field) {
      final text = field.$2.text.trim();
      if (text.isEmpty) return false;
      final val = double.tryParse(text.toEnglishDigits());
      return val != null && val > 0;
    });
  }

  void onStorageFieldChanged() {
    setValidity(storageValidityState: checkStorageValidity());
  }

  void setPayrollMethod(bool isDaily) {
    selectedPayrollMethod = isDaily;
  }

  void validatePayrollInputs() {
    final supervisorField = payrollFields.firstWhere(
      (field) => field.$1 == PayrollsTableColumns.supervisor,
    );
    final supervisorValue = double.tryParse(
      supervisorField.$2.text.toEnglishDigits(),
    );
    final isSupervisorValid = supervisorValue != null && supervisorValue > 0;

    final isAtLeastOneOtherValid = payrollFields
        .where((field) => field.$1 != PayrollsTableColumns.supervisor)
        .any((field) {
          final value = double.tryParse(field.$2.text.toEnglishDigits());
          return value != null && value > 0;
        });

    setValidity(
      payrollValidityState: isSupervisorValid && isAtLeastOneOtherValid,
    );
  }

  void addProduct(ProductModel product, {File? image}) {
    editableProducts = [...editableProducts, product];
    if (image != null && product.productId != null) {
      pendingProductImages[product.productId!] = image;
    }
    emit(HasNoBakery());
  }

  void setProductImage(String productId, File image) {
    pendingProductImages[productId] = image;
    emit(HasNoBakery());
  }

  void editProduct({required ProductModel updatedProduct, required int index}) {
    editableProducts[index] = updatedProduct;
    emit(HasNoBakery());
  }

  void removeProduct({required int index}) {
    editableProducts.removeAt(index);
    emit(HasNoBakery());
  }

  Future<void> check() async {
    final bakeryResponse = await _repo.fetchBakery();
    if (bakeryResponse is SuccessResponse<BakeryModel?> &&
        bakeryResponse.data != null) {
      bakery = bakeryResponse.data!;
      emit(HasBakery());
      await loadAll();
    } else if (bakeryResponse is SuccessResponse<BakeryModel?> &&
        bakeryResponse.data == null) {
      emit(HasNoBakery());
    } else {
      emit(BakeryTabFailure((bakeryResponse as FailureResponse).error));
    }
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadStorage(withEmit: false),
      loadPayroll(withEmit: false),
      loadProducts(withEmit: false),
      loadSales(withEmit: false),
      loadFinance(withEmit: false),
      loadShifts(withEmit: false),
      loadStaff(withEmit: false),
    ]);
    emit(HasBakery());
  }

  Future<void> loadBakeryData({bool withEmit = true}) async {
    final bakeryResponse = await _repo.fetchBakery();
    if (bakeryResponse is SuccessResponse<BakeryModel?> &&
        bakeryResponse.data != null) {
      bakery = bakeryResponse.data!;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadStorage({bool withEmit = true}) async {
    final storageResponse = await _repo.fetchStorage();
    if (storageResponse is SuccessResponse<StorageModel?> &&
        storageResponse.data != null) {
      storage = storageResponse.data!;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadPayroll({bool withEmit = true}) async {
    final payrollResponse = await _repo.fetchPayroll();
    if (payrollResponse is SuccessResponse<PayrollModel?> &&
        payrollResponse.data != null) {
      payroll = payrollResponse.data!;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadProducts({bool withEmit = true}) async {
    final productsResponse = await _repo.fetchProducts();
    if (productsResponse is SuccessResponse<List<ProductModel>> &&
        productsResponse.data.isNotEmpty) {
      products = productsResponse.data;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadSales({bool withEmit = true}) async {
    final salesResponse = await _repo.fetchSales();
    if (salesResponse is SuccessResponse<List<SalesModel>> &&
        salesResponse.data.isNotEmpty) {
      sales = salesResponse.data;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadFinance({bool withEmit = true}) async {
    final financeResponse = await _repo.fetchFinance();
    if (financeResponse is SuccessResponse<List<FinanceModel>> &&
        financeResponse.data.isNotEmpty) {
      finance = financeResponse.data;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadShifts({bool withEmit = true}) async {
    final shiftsResponse = await _repo.fetchShifts();
    if (shiftsResponse is SuccessResponse<List<ShiftModel>> &&
        shiftsResponse.data.isNotEmpty) {
      shifts = shiftsResponse.data;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> loadStaff({bool withEmit = true}) async {
    final staffResponse = await _repo.fetchStaff();
    if (staffResponse is SuccessResponse<List<StaffModel>> &&
        staffResponse.data.isNotEmpty) {
      staff = staffResponse.data;
      if (withEmit) emit(HasBakery());
    }
  }

  Future<void> createBakery({
    required BakeryModel bakeryData,
    required List<ProductModel> products,
    required PayrollModel payroll,
    required StorageModel storage,
  }) async {
    emit(BakeryTabLoading());
    final creationResult = await _repo.createBakery(
      bakeryData: bakeryData,
      products: products,
      payroll: payroll,
      storage: storage,
    );
    if (creationResult is SuccessResponse<bool>) {
      final ownerId = _currentUserId();
      if (pendingBakeryImage != null && ownerId != null) {
        final bakeryImageCubit = _imageCubitFactory(Buckets.bakeriesImages);
        await bakeryImageCubit.uploadImage(pendingBakeryImage!, id: ownerId);
        await bakeryImageCubit.close();
        pendingBakeryImage = null;
      }
      if (pendingCertificateImage != null && ownerId != null) {
        final certificateImageCubit = _imageCubitFactory(
          Buckets.bakeryCertificateImages,
        );
        await certificateImageCubit.uploadImage(
          pendingCertificateImage!,
          id: ownerId,
        );
        await certificateImageCubit.close();
        pendingCertificateImage = null;
      }
      if (pendingProductImages.isNotEmpty) {
        final productImageCubit = _imageCubitFactory(Buckets.productsImages);
        for (final entry in pendingProductImages.entries) {
          await productImageCubit.uploadImage(entry.value, id: entry.key);
        }
        await productImageCubit.close();
        pendingProductImages.clear();
      }
      check();
    } else if (creationResult is FailureResponse) {
      final failure = creationResult as FailureResponse;
      emit(BakeryTabFailure(failure.error));
    }
  }

  @override
  Future<void> close() async {
    if (isClosed) return;
    nameController.dispose();
    branchNameController.dispose();
    pageController.dispose();
    for (final field in storageFields) {
      field.$2.dispose();
    }
    for (final field in payrollFields) {
      field.$2.dispose();
    }
    await _locationSubscription?.cancel();
    if (DependencyInjection.getIt.isRegistered<BakeryTabCubit>(
      instance: this,
    )) {
      await DependencyInjection.getIt.resetLazySingleton<BakeryTabCubit>(
        instance: this,
      );
    }
    return super.close();
  }
}
