import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/bakery_model.dart';
import '../settings_cubit/settings_cubit.dart';

part 'settings_update_state.dart';

class SettingsUpdateCubit extends Cubit<SettingsUpdateState> {
  final SettingsCubit _settingsCubit;

  SettingsUpdateCubit(this._settingsCubit) : super(SettingsUpdateInitial());

  final StreamController<String> _errorController =
  StreamController<String>.broadcast();

  Stream<String> get errorMessages => _errorController.stream;

  void updateBakeryData(BakeryModel updatedBakeryData) async {
    emit(SettingsUpdateLoading());
    await _settingsCubit.updateBakeryData(updatedBakeryData);
    emit(SettingsUpdateInitial());
  }

  Future<void> updatePayroll(PayrollModel updatedPayroll) async {
    emit(SettingsUpdateLoading());
    await _settingsCubit.updatePayroll(updatedPayroll);
    emit(SettingsUpdateInitial());
  }

  Future<void> updateProducts(List<ProductModel> updatedProducts) async {
    emit(SettingsUpdateLoading());
    await _settingsCubit.updateProducts(updatedProducts);
    emit(SettingsUpdateInitial());
  }

  Future<void> changeBakeryData({
    required BakeryModel updatedBakery,
    String? targetId,
  }) async {
    emit(
      SettingsUpdateLoading(
        targetId: targetId,
        action: SettingsUpdateAction.supervisor,
      ),
    );
    await _settingsCubit.changeBakeryData(updatedBakery: updatedBakery);
    emit(SettingsUpdateInitial());
  }

  Future<void> deleteWorker({required StaffModel worker}) async {
    emit(
      SettingsUpdateLoading(
        targetId: worker.workerId,
        action: SettingsUpdateAction.deleteWorker,
      ),
    );
    await _settingsCubit.deleteWorker(worker: worker);
    emit(SettingsUpdateInitial());
  }

  Future<void> addWorker({String? workerId, String? workerName}) async {
    emit(SettingsUpdateLoading(action: SettingsUpdateAction.addWorker));
    final result = await _settingsCubit.addWorker(
      workerName: workerName,
      workerId: workerId,
    );
    emit(SettingsUpdateInitial());
    if (result is FailureResponse) {
      _errorController.add((result as FailureResponse).error);
    }
  }

  @override
  Future<void> close() {
    _errorController.close();
    return super.close();
  }
}