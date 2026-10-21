import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/shared/models/finance_model.dart';
import '../../../../../../../../core/shared/models/waste_model.dart';
import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'expenses_state.dart';

class ExpensesCubit extends Cubit<ExpensesState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;

  ExpensesCubit(this._repo, this._workerCubit) : super(ExpensesInitial());

  Future<void> save({
    required FinanceModel financeRecord,
    required FinanceModel baselineRecord,
    required String bakeryId,
    required String branchId,
  }) async {
    emit(ExpensesLoading(action: ExpensesAction.save));
    final result = await _repo.upsertFinancerecord(
      financeRecord: financeRecord,
      bakeryId: bakeryId,
      branchId: branchId
    );
    if (result is SuccessResponse<bool>) {
      final DateTime? recordDate = financeRecord.date;
      final DateTime now = DateTime.now();
      final bool isToday =
          recordDate != null &&
              recordDate.year == now.year &&
              recordDate.month == now.month &&
              recordDate.day == now.day;

      if (isToday && _workerCubit.products != null) {
        await _repo.adjustAvailabilityForWasteChanges(
          oldWastes: baselineRecord.wastes,
          newWastes: financeRecord.wastes,
          products: _workerCubit.products!,
          bakeryId: bakeryId,
        );
      }

      await _workerCubit.updateFinance(bakeryId,branchId);
      if (isToday) {
        await _workerCubit.updateProducts(bakeryId,branchId);
      }
      emit(ExpensesSuccess());
      emit(ExpensesInitial());
    } else {
      emit(ExpensesFailure((result as FailureResponse).error));
      emit(ExpensesInitial());
    }
  }

  Future<void> deleteMealFromDatabase({
    required FinanceModel financeRecord,
    required WasteModel product,
    required String bakeryId,
    required String branchId,
  }) async {
    emit(
      ExpensesLoading(
        productId: product.productId,
        action: ExpensesAction.deleteProduct,
      ),
    );
    final result = await _repo.deleteMealFromDatabase(
      financeRecord: financeRecord,
      bakeryId: bakeryId,
      product: product,
    );
    if (result is SuccessResponse<bool>) {
      await _workerCubit.updateFinance(bakeryId,branchId);
      emit(ExpensesSuccess());
      emit(ExpensesInitial());
    } else {
      emit(ExpensesFailure((result as FailureResponse).error));
      emit(ExpensesInitial());
    }
  }
}