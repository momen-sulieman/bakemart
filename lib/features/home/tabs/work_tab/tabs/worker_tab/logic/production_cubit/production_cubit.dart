import 'package:bakemart/core/network/response_result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/product_model.dart';
import '../../../../../../../../core/shared/models/shift_model.dart';
import '../../../../../../../../core/shared/models/storage_model.dart';
import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'production_state.dart';

class ProductionCubit extends Cubit<ProductionState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;

  ProductionCubit(this._repo, this._workerCubit) : super(ProductionInitial());
  List<ShiftModel> workersSheet = [];
  bool addingWorker = false;
  bool formInputValidity = false;
  bool workerInputValidity = false;
  bool formValidity = false;

  void emptyWorkersSheet() {
    workersSheet = [];
    emit(ProductionInitial());
  }

  void removeWorkerFromWorkersSheet(int index) {
    workersSheet = workersSheet..removeAt(index);
    emit(ProductionInitial());
  }

  void addWorkerToWorkersSheet({required ShiftModel newWorker}) {
    final updatedWorkersSheet = [...workersSheet, newWorker];
    workersSheet = updatedWorkersSheet;
    formValidity = formInputValidity && workersSheet.isNotEmpty;
    emit(ProductionInitial());
  }

  void setAddingWorker(bool status) {
    addingWorker = status;
    emit(ProductionInitial());
  }

  void setInputValidity(bool status) {
    formInputValidity = status;
    if (!_workerCubit.payrollMethod) {
      formValidity = formInputValidity && workersSheet.isNotEmpty;
    } else {
      formValidity = formInputValidity;
    }
    emit(ProductionInitial());
  }

  void setWorkerInputValidity(bool status) {
    workerInputValidity = status;
    emit(ProductionInitial());
  }

  Future<void> postProduction({
    required int batchCounter,
    required int manufacturingWasteCounter,
    required ProductModel product,
    required StorageModel currentStorage,
  }) async {
    emit(ProductionLoading());
    final salesUpdateResult = await _repo.produce(
      batchCounter: batchCounter,
      manufacturingWasteCounter: manufacturingWasteCounter,
      product: product,
      currentStorage: currentStorage
    );
    if (salesUpdateResult is FailureResponse) {
      emit(ProductionFailure("Sales error: ${salesUpdateResult.toString()}"));
      emit(ProductionInitial());
      return;
    }
    await _workerCubit.updateProducts(product.bakeryId);
    final payrollMethod = _workerCubit.payrollMethod;
    if (!payrollMethod) {
      final now = DateTime.now();

      final List<ShiftModel> existingShifts =
          _workerCubit.shifts?.where((shift) {
            if (shift.date == null) return false;
            return shift.date!.year == now.year &&
                shift.date!.month == now.month &&
                shift.date!.day == now.day;
          }).toList() ??
          [];
      final updatedShiftTable = _repo.mergeShifts(
        existingShifts: existingShifts,
        newBatchShift: workersSheet,
        payroll: _workerCubit.payroll!,
      );
      final shiftsUpdateResult = await _repo.upsertShiftsTable(
        shiftTable: updatedShiftTable,
      );
      if (shiftsUpdateResult is FailureResponse) {
        emit(
          ProductionFailure("Shifts error: ${shiftsUpdateResult.toString()}"),
        );
        emit(ProductionInitial());
        return;
      }
      await _workerCubit.updateShifts(product.bakeryId);
      final double payrollExpenses = updatedShiftTable.fold(
        0.0,
        (sum, shift) => sum + shift.wage,
      );
      final DateTime date=DateTime.now();
      final payrollExpensesPostingResult = await _repo.postPayrollExpenses(
        bakeryId: product.bakeryId,
        branchId: product.branchId,
        payrollExpenses: payrollExpenses,
        date: date
      );
      if (payrollExpensesPostingResult is! SuccessResponse<bool>) {
        final errorMsg =
            (payrollExpensesPostingResult as FailureResponse).error;
        emit(ProductionFailure("Expenses error: $errorMsg"));
        ProductionInitial();
      } else {
        await _workerCubit.updateFinance(product.bakeryId);
      }
    }
    emit(ProductionSuccess());
    emit(ProductionInitial());
  }
}
