import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/storage_model.dart';
import '../../../../../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import '../../data/settings_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepo _repo;
  final BakeryTabCubit _bakeryTabCubit;
  final SupabaseImageCubit Function(String bucket) _imageCubitFactory;

  SettingsCubit(
    this._repo,
    this._bakeryTabCubit, {
    SupabaseImageCubit Function(String bucket)? imageCubitFactory,
  }) : _imageCubitFactory =
           imageCubitFactory ?? ((bucket) => SupabaseImageCubit(bucket, null)),
       super(SettingsLoading()) {
    getSettings();
  }

  String productsViewedBranch = "";
  String payrollsViewedBranch = "";
  String staffsViewedBranch = "";
  List<BakeryModel> bakeries = [];
  List<PayrollModel> payrolls = [];
  List<PayrollModel> editablePayrolls = [];
  List<StaffModel> staff = [];
  List<ProductModel> products = [];
  List<ProductModel> editableProducts = [];
  bool isLocationEditing = false;
  bool isNameChanged = false;
  bool isStaffExpanded = true;
  bool isStaffEditing = false;
  bool isPayrollExpanded = true;
  bool isPayrollEditing = false;
  bool isPayrollChanged = false;
  bool isPayrollRateChanged = false;
  bool isProductsExpanded = true;
  bool isBranchesExpanded = true;
  bool isProductsEditing = false;
  bool isBranchesEditing = false;
  bool isProductsChanged = false;
  bool isBranchesChanged = false;
  bool isOneProductChanged = false;
  bool isProductDataChanged = false;
  bool newBranchFormValidity = false;
  bool isCreatingBranch = false;
  bool isDeletingBranch = false;
  bool branchNameExists=false;
  double newBranchLat = 0;
  double newBranchLng = 0;

  List<String> getBranchNames() {
    return bakeries.map((bakery) => bakery.branchName).toList();
  }
  void setbranchNameExists(bool status){
    branchNameExists=status;
    _emitSuccess();
  }
  void setNewBranchLocation({required double lat, required double lng}) {
    newBranchLat = lat;
    newBranchLng = lng;
  }

  final Set<String> changedProductPictures = {};
  bool newProductFormValidity = false;
  bool isLocationChanged = false;
  final Map<String, File> pendingProductImages = {};
  final Map<String, int> productImageVersion = {};

  PayrollModel? get payroll => payrolls.firstWhereOrNull(
    (item) => item.branchId == payrollsViewedBranch,
  );

  PayrollModel? get editablePayroll => editablePayrolls.firstWhereOrNull(
    (item) => item.branchId == payrollsViewedBranch,
  );

  String _validBranch(String current) {
    if (bakeries.any((branch) => branch.branchId == current)) return current;
    return bakeries.isNotEmpty ? bakeries.first.branchId : "";
  }

  void productsBranchChanged(String branchId) {
    productsViewedBranch = branchId;
    _emitSuccess();
  }

  void payrollsBranchChanged(String branchId) {
    payrollsViewedBranch = branchId;
    _emitSuccess();
  }

  void staffBranchChanged(String branchId) {
    staffsViewedBranch = branchId;
    _emitSuccess();
  }

  void bumpProductImageVersion(String productId) {
    productImageVersion[productId] = (productImageVersion[productId] ?? 0) + 1;
    _emitSuccess();
  }

  void setProductImage(String productId, File image) {
    pendingProductImages[productId] = image;
    _emitSuccess();
  }

  void locationCancelEditing() {
    isLocationEditing = false;
    _emitSuccess();
  }

  void setProductPictureChanged(String productId, bool status) {
    if (status) {
      changedProductPictures.add(productId);
    } else {
      changedProductPictures.remove(productId);
    }
    _emitSuccess();
  }

  Future<void> deleteProduct({
    required String productId,
    required String branchId,
  }) async {
    final deleteResult = await _repo.deleteProduct(
      productId: productId,
      branchId: branchId,
    );
    if (deleteResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadProducts();
      if (_bakeryTabCubit.products.isEmpty) emit(SettingsFailure("error"));
      products = _bakeryTabCubit.products;
      editableProducts = products;
      _emitSuccess();
    }
  }

  void setValidity({
    bool? newProductFormValidityState,
    bool? newBranchFormValidityState,
  }) {
    if (newProductFormValidityState != null) {
      newProductFormValidity = newProductFormValidityState;
    }
    if (newBranchFormValidityState != null) {
      newBranchFormValidity = newBranchFormValidityState;
    }
    _emitSuccess();
  }

  void addProduct(ProductModel product, {File? image}) {
    editableProducts = [...editableProducts, product];
    if (image != null && product.productId != null) {
      pendingProductImages[product.productId!] = image;
    }
    isProductsChanged = true;
    _emitSuccess();
  }

  void updatePayrollTileExpansion(bool expanded) {
    isPayrollExpanded = expanded;
    _emitSuccess();
  }

  void updateProductsTileExpansion(bool expanded) {
    isProductsExpanded = expanded;
    _emitSuccess();
  }

  void updateBranchesTileExpansion(bool expanded) {
    isBranchesExpanded = expanded;
    _emitSuccess();
  }

  void updateStaffTileExpansion(bool expanded) {
    isStaffExpanded = expanded;
    _emitSuccess();
  }

  void locationEditingMode(bool editing) {
    isLocationEditing = editing;
    _emitSuccess();
  }

  void payrollEditingMode(bool editing) {
    isPayrollEditing = editing;
    _emitSuccess();
  }

  void staffEditingMode(bool editing) {
    isStaffEditing = editing;
    _emitSuccess();
  }

  void productsEditingMode(bool editing) {
    isProductsEditing = editing;
    _emitSuccess();
  }

  void branchesEditingMode(bool editing) {
    isBranchesEditing = editing;
    _emitSuccess();
  }

  void payrollCancelEditing() {
    editablePayrolls = payrolls;
    isPayrollChanged = false;
    isPayrollEditing = false;
    _emitSuccess();
  }

  void productsCancelEditing() {
    editableProducts = products;
    pendingProductImages.clear();
    isProductsChanged = false;
    isProductsEditing = false;
    changedProductPictures.clear();
    _emitSuccess();
  }

  void branchesCancelEditing() {
    isBranchesChanged = false;
    isBranchesEditing = false;
    _emitSuccess();
  }

  void nameChanged(bool changed) {
    isNameChanged = changed;
    _emitSuccess();
  }

  void payrollSomethingChanged(bool changed) {
    isPayrollChanged = changed;
    _emitSuccess();
  }

  void productsSomethingChanged(bool changed) {
    isProductsChanged = changed;
    isOneProductChanged = changed;
    _emitSuccess();
  }

  void payrollRateChanged(bool changed) {
    isPayrollRateChanged = changed;
    _emitSuccess();
  }

  void productDataChanged(bool changed) {
    isProductDataChanged = changed;
    _emitSuccess();
  }

  void oneProductChanged(bool changed) {
    isOneProductChanged = changed;
    _emitSuccess();
  }

  void updatePayrollMethod(PayrollModel payroll) {
    editablePayrolls = editablePayrolls.map((item) {
      return item.branchId == payroll.branchId ? payroll : item;
    }).toList();
    isPayrollChanged = true;
    isPayrollRateChanged = false;
    _emitSuccess();
  }

  void postNewRate({
    required String role,
    required double newRate,
    required String branchId,
  }) {
    editablePayrolls = editablePayrolls.map((payroll) {
      if (payroll.branchId != branchId) return payroll;

      switch (role) {
        case PayrollsTableColumns.ajan:
          return payroll.copyWith(ajan: newRate);
        case PayrollsTableColumns.faran:
          return payroll.copyWith(faran: newRate);
        case PayrollsTableColumns.tawlaji:
          return payroll.copyWith(tawlaji: newRate);
        case PayrollsTableColumns.chef:
          return payroll.copyWith(chef: newRate);
        case PayrollsTableColumns.coChef:
          return payroll.copyWith(coChef: newRate);
        case PayrollsTableColumns.bagger:
          return payroll.copyWith(bagger: newRate);
        case PayrollsTableColumns.supervisor:
          return payroll.copyWith(supervisor: newRate);
        default:
          return payroll;
      }
    }).toList();

    isPayrollChanged = true;
    isPayrollRateChanged = false;
    _emitSuccess();
  }

  void _emitSuccess() {
    productsViewedBranch = _validBranch(productsViewedBranch);
    payrollsViewedBranch = _validBranch(payrollsViewedBranch);
    staffsViewedBranch = _validBranch(staffsViewedBranch);
    emit(
      SettingsSuccess(
        bakeries: bakeries,
        payrolls: editablePayrolls,
        staff: staff,
        products: editableProducts,
      ),
    );
  }

  Future<bool> createNewBranch({
    required BakeryModel bakeryData,
    required List<ProductModel> products,
    required PayrollModel payroll,
    required StorageModel storage,
  }) async {
    isCreatingBranch = true;
    _emitSuccess();
    final result = await _repo.createNewBranch(
      bakeryData: bakeryData,
      products: products,
      payroll: payroll,
      storage: storage,
    );
    if (result is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData(withEmit: false);
      await _bakeryTabCubit.loadAll();
      await getSettings();
      isCreatingBranch = false;
      newBranchFormValidity = false;
      _emitSuccess();
      return true;
    }
    isCreatingBranch = false;
    _emitSuccess();
    return false;
  }

  Future<bool> deleteBranch({required String branchId}) async {
    if (isDeletingBranch) return false;
    final BakeryModel? branch = bakeries.firstWhereOrNull(
          (item) => item.branchId == branchId,
    );
    if (branch == null || bakeries.length <= 1) return false;
    final bool wasEditing = isBranchesEditing;
    isDeletingBranch = true;
    _emitSuccess();
    final result = await _repo.deleteBranch(
      bakeryId: branch.bakeryId,
      branchId: branchId,
    );
    if (result is! SuccessResponse<bool>) {
      isDeletingBranch = false;
      _emitSuccess();
      return false;
    }
    await _bakeryTabCubit.loadBakeryData(withEmit: false);
    await _bakeryTabCubit.loadAll();
    await getSettings();
    isBranchesEditing = wasEditing;
    isDeletingBranch = false;
    _emitSuccess();
    return true;
  }

  Future<void> changeBranchLocation({
    required String branchId,
    required double lat,
    required double lng,
  }) async {
    final result = await _repo.changeBranchLocation(
      branchId: branchId,
      lat: lat,
      lng: lng,
    );
    if (result is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakeries = _bakeryTabCubit.bakeries;
      _emitSuccess();
    } else if (result is FailureResponse) {
      emit(SettingsFailure((result as FailureResponse).error));
    }
  }

  Future<void> getSettings() async {
    bakeries = _bakeryTabCubit.bakeries;
    payrolls = _bakeryTabCubit.payrolls;
    editablePayrolls = _bakeryTabCubit.payrolls;
    staff = _bakeryTabCubit.staff;
    products = _bakeryTabCubit.products;
    editableProducts = _bakeryTabCubit.products;
    _emitSuccess();
  }

  Future<void> updateBakeryData(BakeryModel updatedBakeryData) async {
    final updateResponse = await _repo.updateBakeryData(updatedBakeryData);
    if (updateResponse is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakeries = _bakeryTabCubit.bakeries;
      _emitSuccess();
    }
  }

  Future<void> updatePayroll(PayrollModel updatedPayroll) async {
    final updateResponse = await _repo.updatePayroll(updatedPayroll);
    if (updateResponse is SuccessResponse<bool>) {
      isPayrollChanged = false;
      isPayrollEditing = false;
      await _bakeryTabCubit.loadPayroll();
      payrolls = _bakeryTabCubit.payrolls;
      editablePayrolls = payrolls;
      _emitSuccess();
    }
  }

  void editProduct(ProductModel updatedProduct) {
    editableProducts = editableProducts.map((product) {
      if (product.productId == updatedProduct.productId &&
          product.branchId == updatedProduct.branchId) {
        return updatedProduct;
      }
      return product;
    }).toList();
    _emitSuccess();
  }

  Future<void> updateProducts(List<ProductModel> updatedProducts) async {
    final updateResponse = await _repo.updateProducts(updatedProducts);
    if (updateResponse is SuccessResponse<bool>) {
      if (pendingProductImages.isNotEmpty) {
        final imageCubit = _imageCubitFactory(Buckets.productsImages);
        for (final entry in pendingProductImages.entries) {
          final uploadResult = await imageCubit.uploadImage(
            entry.value,
            id: entry.key,
          );
          if (uploadResult is SuccessResponse<bool>) {
            SupabaseImageCubit.invalidate(Buckets.productsImages, entry.key);
            bumpProductImageVersion(entry.key);
          }
        }
        await imageCubit.close();
        pendingProductImages.clear();
      }
      isProductsChanged = false;
      isProductsEditing = false;
      changedProductPictures.clear();
      await _bakeryTabCubit.loadProducts();
      if (_bakeryTabCubit.products.isEmpty) emit(SettingsFailure("error"));
      products = _bakeryTabCubit.products;
      editableProducts = products;
      _emitSuccess();
    }
  }

  Future<void> changeBakeryName({required String name}) async {
    final changeNameResult = await _repo.changeBakeryName(name: name);
    if (changeNameResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakeries = _bakeryTabCubit.bakeries;
      _emitSuccess();
    } else if (changeNameResult is FailureResponse) {
      emit(SettingsFailure((changeNameResult as FailureResponse).error));
    }
  }

  Future<void> changeBakerySupervisor({
    required BakeryModel updatedBakery,
  }) async {
    final changeSupervisorResult = await _repo.changeBakerySupervisor(
      updatedBakery: updatedBakery,
    );
    if (changeSupervisorResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakeries = _bakeryTabCubit.bakeries;
      _emitSuccess();
    } else if (changeSupervisorResult is FailureResponse) {
      emit(SettingsFailure((changeSupervisorResult as FailureResponse).error));
    }
  }

  Future<void> deleteWorker({required StaffModel worker}) async {
    final deleteResult = await _repo.deleteWorker(worker: worker);
    if (deleteResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadStaff();
      staff = _bakeryTabCubit.staff;
      _emitSuccess();
    } else if (deleteResult is FailureResponse) {
      emit(SettingsFailure((deleteResult as FailureResponse).error));
    }
  }

  Future<ResponseResult<bool>> addWorker({
    required String branchId,
    String? workerId,
    String? workerName,
  }) async {
    final addingResult = await _repo.addWorker(
      branchId: branchId,
      workerId: workerId,
      workerName: workerName,
    );
    if (addingResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadStaff();
      staff = _bakeryTabCubit.staff;
      _emitSuccess();
    }
    return addingResult;
  }
}
