import 'dart:async';

import 'package:bakemart/core/network/response_result.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_storage/data/storage_repo.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../logic/bakery_tab_cubit/bakery_tab_cubit.dart';

part 'storage_state.dart';

class StorageCubit extends Cubit<StorageState> {
  final StorageRepo _repo;
  final BakeryTabCubit _bakeryTabCubit;
  late final StreamSubscription _bakerySubscription;

  StorageCubit(this._repo, this._bakeryTabCubit) : super(StorageLoading()) {
    getStorage();
    _bakerySubscription = _bakeryTabCubit.stream.listen((_) {
      if (!isClosed) getStorage();
    });
  }

  bool inputValidity = false;
  String storageViewedBranch = "";
  StorageModel storage = StorageModel(
    bakeryId: "",
    branchId: "",
    fineWheat: 0,
    wholeWheat: 0,
    corn: 0,
    oats: 0,
    barley: 0,
    yeast: 0,
    salt: 0,
    sugar: 0,
  );

  List<BakeryModel> get branches => _bakeryTabCubit.bakeries;

  Future<void> getStorage() async {
    final List<BakeryModel> allBranches = _bakeryTabCubit.bakeries;
    final List<StorageModel> allStorages = _bakeryTabCubit.storages;
    if (!allBranches.any((branch) => branch.branchId == storageViewedBranch)) {
      storageViewedBranch = allBranches.isNotEmpty
          ? allBranches.first.branchId
          : "";
    }
    final StorageModel? viewedStorage = allStorages.firstWhereOrNull(
          (item) => item.branchId == storageViewedBranch,
    );
    if (viewedStorage != null) storage = viewedStorage;
    emit(StorageSucces(storage, inputValidity: inputValidity));
  }

  void storageBranchChanged(String branchId) {
    storageViewedBranch = branchId;
    inputValidity = false;
    getStorage();
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

  @override
  Future<void> close() {
    _bakerySubscription.cancel();
    return super.close();
  }
}