import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'shifts_state.dart';

class ShiftsCubit extends Cubit<ShiftsState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;

  ShiftsCubit(this._repo, this._workerCubit) : super(ShiftsInitial());

  Future<void> save({
    required List<ShiftModel> shiftTable,
    required DateTime date,
  }) async {
    emit(ShiftsLoading(action: ShiftsAction.save));
    final bakeryId = _workerCubit.bakery!.bakeryId;
    final branchId = _workerCubit.bakery!.branchId;
    final result = await _repo.upsertShiftsTable(shiftTable: shiftTable);
    if (result is SuccessResponse<bool>) {
      await _workerCubit.updateShifts(bakeryId, branchId);
      final double payrollExpenses = shiftTable.fold(
        0.0,
        (sum, shift) => sum + shift.wage,
      );
      final payrollExpensesPostingResult = await _repo.postPayrollExpenses(
        bakeryId: bakeryId,
        branchId: branchId,
        payrollExpenses: payrollExpenses,
        date: date,
      );
      if (payrollExpensesPostingResult is SuccessResponse<bool>) {
        await _workerCubit.updateFinance(bakeryId, branchId);
        emit(ShiftsSuccess());
        emit(ShiftsInitial());
      } else {
        final errorMsg =
            (payrollExpensesPostingResult as FailureResponse).error;
        emit(ShiftsFailure("Expenses error: $errorMsg"));
        emit(ShiftsInitial());
      }
    } else {
      emit(ShiftsFailure((result as FailureResponse).error));
      emit(ShiftsInitial());
    }
  }

  Future<void> deleteWorker({required ShiftModel worker}) async {
    emit(
      ShiftsLoading(
        targetId: worker.workerId,
        action: ShiftsAction.deleteWorker,
      ),
    );
    final bakeryId = _workerCubit.bakery!.bakeryId;
    final branchId = _workerCubit.bakery!.branchId;
    final result = await _repo.deleteShift(worker: worker);
    if (result is SuccessResponse<bool>) {
      await _workerCubit.updateShifts(bakeryId, branchId);
      emit(ShiftsSuccess());
      emit(ShiftsInitial());
    } else {
      emit(ShiftsFailure((result as FailureResponse).error));
      emit(ShiftsInitial());
    }
  }
}
