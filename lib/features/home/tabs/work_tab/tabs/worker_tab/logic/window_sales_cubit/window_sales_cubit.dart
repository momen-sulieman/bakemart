import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/worker_repo.dart';
import '../worker_cubit/worker_cubit.dart';

part 'window_sales_state.dart';

class WindowSalesCubit extends Cubit<WindowSalesState> {
  final WorkerRepo _repo;
  final WorkerCubit _workerCubit;

  WindowSalesCubit(this._repo, this._workerCubit) : super(WindowSalesInitial());

  Future<void> sell({
    int? soldQuantity,
    int? notSoldQuantity,
    int? mealWaste,
    required ProductModel product,
  }) async {
    emit(WindowSalesLoading());
    final result = await _repo.windowSell(
      soldQuantity: soldQuantity,
      notSoldQuantity: notSoldQuantity,
      mealWaste: mealWaste,
      product: product,
    );
    if(result is SuccessResponse<bool>){
      await _workerCubit.updateProducts(product.bakeryId,product.branchId);
      emit(WindowSalesSuccess());
      emit(WindowSalesInitial());
    }else{
      emit(WindowSalesFailure((result as FailureResponse).error));
      emit(WindowSalesInitial());
    }
  }
}
