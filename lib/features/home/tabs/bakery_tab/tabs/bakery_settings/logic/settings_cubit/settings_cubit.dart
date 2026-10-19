import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  BakeryModel? bakery;
  PayrollModel? payroll;
  PayrollModel? editablePayroll;
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
  bool isProductsEditing = false;
  bool isProductsChanged = false;
  bool isOneProductChanged = false;
  bool isProductDataChanged = false;

  final Set<String> changedProductPictures = {};
  bool newProductFormValidity = false;
  bool isLocationChanged = false;
  final Map<String, File> pendingProductImages = {};
  final Map<String, int> productImageVersion = {};

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

  Future<void> deleteProduct({required String productId}) async {
    final deleteResult = await _repo.deleteProduct(productId: productId);
    if (deleteResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadProducts();
      if (_bakeryTabCubit.products.isEmpty) emit(SettingsFailure("error"));
      products = _bakeryTabCubit.products;
      editableProducts = products;
      _emitSuccess();
    }
  }

  void setValidity({required bool newProductFormValidityState}) {
    newProductFormValidity = newProductFormValidityState;
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

  void payrollCancelEditing() {
    editablePayroll = payroll;
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

  void updatePayrollMethod(bool method) {
    editablePayroll = editablePayroll!.copyWith(payrollMethod: method);
    isPayrollChanged = true;
    isPayrollRateChanged = false;
    _emitSuccess();
  }

  void postNewRate({required String role, required double newRate}) {
    switch (role) {
      case PayrollsTableColumns.ajan:
        editablePayroll = editablePayroll!.copyWith(ajan: newRate);
        break;
      case PayrollsTableColumns.faran:
        editablePayroll = editablePayroll!.copyWith(faran: newRate);
        break;
      case PayrollsTableColumns.tawlaji:
        editablePayroll = editablePayroll!.copyWith(tawlaji: newRate);
        break;
      case PayrollsTableColumns.chef:
        editablePayroll = editablePayroll!.copyWith(chef: newRate);
        break;
      case PayrollsTableColumns.coChef:
        editablePayroll = editablePayroll!.copyWith(coChef: newRate);
        break;
      case PayrollsTableColumns.bagger:
        editablePayroll = editablePayroll!.copyWith(bagger: newRate);
        break;
      case PayrollsTableColumns.supervisor:
        editablePayroll = editablePayroll!.copyWith(supervisor: newRate);
        break;
    }
    isPayrollChanged = true;
    isPayrollRateChanged = false;
    _emitSuccess();
  }

  void _emitSuccess() {
    emit(
      SettingsSuccess(
        bakery: bakery!,
        payroll: editablePayroll!,
        staff: staff,
        products: editableProducts,
      ),
    );
  }

  Future<void> getSettings() async {
    bakery = _bakeryTabCubit.bakery;
    payroll = _bakeryTabCubit.payroll;
    editablePayroll = _bakeryTabCubit.payroll;
    staff = _bakeryTabCubit.staff;
    products = _bakeryTabCubit.products;
    editableProducts = _bakeryTabCubit.products;
    _emitSuccess();
  }

  Future<void> updateBakeryData(BakeryModel updatedBakeryData) async {
    final updateResponse = await _repo.updateBakeryData(updatedBakeryData);
    if (updateResponse is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakery = _bakeryTabCubit.bakery;
      _emitSuccess();
    }
  }

  Future<void> updatePayroll(PayrollModel updatedPayroll) async {
    final updateResponse = await _repo.updatePayroll(updatedPayroll);
    if (updateResponse is SuccessResponse<bool>) {
      isPayrollChanged = false;
      isPayrollEditing = false;
      await _bakeryTabCubit.loadPayroll();
      payroll = _bakeryTabCubit.payroll;
      _emitSuccess();
    }
  }

  void editProduct(ProductModel updatedProduct) {
    editableProducts = editableProducts.map((product) {
      if (product.productId == updatedProduct.productId) {
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
        final imageCubit = _imageCubitFactory(Buckets.productsImages);        for (final entry in pendingProductImages.entries) {
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

  Future<void> changeBakeryData({required BakeryModel updatedBakery}) async {
    final changeSupervisorResult = await _repo.changeBakeryData(
      updatedBakery: updatedBakery,
    );
    if (changeSupervisorResult is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadBakeryData();
      bakery = _bakeryTabCubit.bakery;
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