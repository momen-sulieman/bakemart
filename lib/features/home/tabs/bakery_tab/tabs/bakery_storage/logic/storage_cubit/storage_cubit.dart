import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  final StorageRepo _repo;
  final BakeryTabCubit _bakeryTabCubit;

  StorageCubit(this._repo, this._bakeryTabCubit) : super(StorageLoading()) {
    getStorage();
  }

  bool inputValidity = false;
  StorageModel storage = StorageModel(
    bakeryId: "",
    fineWheat: 0,
    wholeWheat: 0,
    corn: 0,
    oats: 0,
    barley: 0,
    yeast: 0,
    salt: 0,
    sugar: 0,
  );

  Future<void> getStorage() async {
    storage = _bakeryTabCubit.storage;
    emit(StorageSucces(storage, inputValidity: inputValidity));
    }

  void inputValidityTrue() {
    inputValidity = true;
    emit(StorageSucces(storage, inputValidity: inputValidity));
  }

  void inputValidityFalse() {
    inputValidity = false;
    emit(StorageSucces(storage, inputValidity: inputValidity));
  }

  Future<void> addToStorage(StorageModel updatedStorage) async {
    final updateResponse = await _repo.updateStorage(updatedStorage);
    if (updateResponse is SuccessResponse<bool>) {
      await _bakeryTabCubit.loadStorage();
      inputValidity = false;
      getStorage();
    } else {
      emit(StorageFailure((updateResponse as FailureResponse).error));
    }
  }
}
