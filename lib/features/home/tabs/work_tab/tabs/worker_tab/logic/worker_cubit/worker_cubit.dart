import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/finance_model.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/bakery_model.dart';
import '../../data/worker_repo.dart';

part 'worker_state.dart';

class WorkerCubit extends Cubit<WorkerState> {
  final WorkerRepo _repo;

  WorkerCubit(this._repo) : super(WorkerLoading()) {
    frame();
  }

  UserModel? user;
  BakeryModel? bakery;
  PayrollModel? payroll;
  StorageModel? storage;
  bool payrollMethod = true;
  List<ProductModel>? products;
  List<StaffModel>? staff;
  List<ShiftModel>? shifts;
  List<FinanceModel>? finance;

  Future<void> quit() async {
    emit(WorkerLoading());
    await _repo.quit();
    frame();
  }

  Future<void> frame({bool withLoading = true}) async {
    if (withLoading) emit(WorkerLoading());
    final userResponse = await _repo.getUserData();
    if (userResponse is! SuccessResponse<UserModel>) {
      emit(
        WorkerFailure(
          "User data error: ${(userResponse as FailureResponse).error}",
        ),
      );
      return;
    }

    final userModel = userResponse.data;
    user = userModel;

    final checkResponse = await _repo.checkStaffTable();
    if (checkResponse is! SuccessResponse<StaffModel?>) {
      emit(
        WorkerFailure(
          "Staff table error: ${(checkResponse as FailureResponse).error}",
        ),
      );
      return;
    }

    final staffData = checkResponse.data;

    if (staffData == null) {
      final shiftsResult = await _repo.fetchMyShifts();
      if (shiftsResult is SuccessResponse<List<ShiftModel>?>) {
        shifts = shiftsResult.data;
      }
      emit(UnEmployed(userModel));
      return;
    }

    final bakeryId = staffData.bakeryId;
    final branchId = staffData.branchId;

    final bakeryResponse = await _repo.getBakeryData(bakeryId, branchId);
    if (bakeryResponse is! SuccessResponse<BakeryModel>) {
      emit(
        WorkerFailure(
          "Bakery fetching error: ${(bakeryResponse as FailureResponse).error}",
        ),
      );
      return;
    }

    final bakeryModel = bakeryResponse.data;
    bakery = bakeryModel;

    if (userModel.id != null &&
        bakeryModel.supervisorId.contains(userModel.id)) {
      final results = await Future.wait([
        _repo.fetchPayroll(bakeryModel.bakeryId, bakeryModel.branchId),
        _repo.fetchProducts(bakeryModel.bakeryId, bakeryModel.branchId),
        _repo.fetchStaff(bakeryModel.bakeryId, bakeryModel.branchId),
        _repo.fetchShifts(bakeryModel.bakeryId, bakeryModel.branchId),
        _repo.fetchFinance(bakeryModel.bakeryId, bakeryModel.branchId),
        _repo.fetchStorage(bakeryModel.bakeryId, bakeryModel.branchId),
      ]);

      final payrollResponse = results[0] as ResponseResult<PayrollModel?>;
      final productsResponse =
          results[1] as ResponseResult<List<ProductModel>?>;
      final staffResponse = results[2] as ResponseResult<List<StaffModel>?>;
      final shiftsResponse = results[3] as ResponseResult<List<ShiftModel>?>;
      final financeResponse = results[4] as ResponseResult<List<FinanceModel>?>;
      final storageResponse = results[5] as ResponseResult<StorageModel?>;

      if (payrollResponse is SuccessResponse<PayrollModel?>) {
        payroll = payrollResponse.data;
        if (payroll != null) {
          payrollMethod = payroll!.payrollMethod;
        }
      }
      if (storageResponse is SuccessResponse<StorageModel?>) {
        storage = storageResponse.data;
      }
      if (productsResponse is SuccessResponse<List<ProductModel>?>) {
        products = productsResponse.data;
      }
      if (staffResponse is SuccessResponse<List<StaffModel>?>) {
        staff = staffResponse.data;
      }
      if (shiftsResponse is SuccessResponse<List<ShiftModel>?>) {
        shifts = shiftsResponse.data;
      }
      if (financeResponse is SuccessResponse<List<FinanceModel>?>) {
        finance = financeResponse.data;
      }

      emit(
        Supervisor(
          user: user,
          bakery: bakery,
          products: products,
          payroll: payroll,
          staff: staff,
          shifts: shifts,
          finance: finance,
        ),
      );
    } else {
      final shiftsResult = await _repo.fetchMyShifts();
      if (shiftsResult is SuccessResponse<List<ShiftModel>?>) {
        shifts = shiftsResult.data;
      }
      emit(Employed(userModel, bakeryModel));
    }
  }

  Future<void> updateShifts(String bakeryId, String branchId) async {
    final shiftsResponse = await _repo.fetchShifts(bakeryId, branchId);
    if (shiftsResponse is SuccessResponse<List<ShiftModel>?>) {
      shifts = shiftsResponse.data;
      emit(
        Supervisor(
          user: user,
          bakery: bakery,
          payroll: payroll,
          products: products,
          staff: staff,
          shifts: shifts,
          finance: finance,
        ),
      );
    }
  }

  Future<void> updateProducts(String bakeryId, String branchId) async {
    final productsResponse = await _repo.fetchProducts(bakeryId, branchId);
    if (productsResponse is SuccessResponse<List<ProductModel>?>) {
      products = productsResponse.data;
      emit(
        Supervisor(
          user: user,
          bakery: bakery,
          payroll: payroll,
          products: products,
          staff: staff,
          shifts: shifts,
          finance: finance,
        ),
      );
    }
  }

  Future<void> updateFinance(String bakeryId, String branchId) async {
    final financeResponse = await _repo.fetchFinance(bakeryId, branchId);
    if (financeResponse is SuccessResponse<List<FinanceModel>?>) {
      finance = financeResponse.data;
      emit(
        Supervisor(
          user: user,
          bakery: bakery,
          payroll: payroll,
          products: products,
          staff: staff,
          shifts: shifts,
          finance: finance,
        ),
      );
    }
  }
}
