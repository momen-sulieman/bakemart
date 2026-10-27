import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/response_result.dart';
import '../../../../../../core/shared/models/bakery_model.dart';
import '../../../../../../core/shared/models/product_model.dart';
import '../../../../../../core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../../data/home_repo.dart';
import '../active_orders_cubit/active_orders_cubit.dart';

part 'home_data_state.dart';

class HomeDataCubit extends Cubit<HomeDataState> {
  final HomeRepo _repo;
  final ActiveOrdersCubit _activeOrdersCubit;
  final CartCubit _cartCubit;

  HomeDataCubit(this._repo, this._activeOrdersCubit, this._cartCubit)
    : super(HomeDataInitial()) {
    getHomeData();
  }

  UserModel user = UserModel(
    firstName: "",
    secondName: "",
    email: "",
    phone: "",
  );
  List<HomeDataBakeriesModel> nearbyBakeries = [];
  List<BakeryModel> allBakeries = [];

  bool refreshStatus = false;
  bool firstNameChanged = false;
  bool secondNameChanged = false;
  bool isNameChanged = false;

  bool streetChanged = false;
  bool buildingChanged = false;
  bool apartmentChanged = false;
  bool isAddressChanged = false;
  bool searchingMode = false;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  bool isSearchFocused = false;
  final Map<String, HomeDataBakeriesModel> _fetchedBranches = {};
  String? loadingBranchId;

  List<BakeryModel> branchesOf(String bakeryId) {
    final List<BakeryModel> branches = allBakeries
        .where((bakery) => bakery.bakeryId == bakeryId)
        .toList();
    branches.sort((a, b) => a.branchNumber.compareTo(b.branchNumber));
    return branches;
  }

  Future<HomeDataBakeriesModel?> getBranchDetails(BakeryModel branch) async {
    if (loadingBranchId != null) return null;

    for (final item in nearbyBakeries) {
      if (item.bakeryModel.bakeryId == branch.bakeryId &&
          item.bakeryModel.branchId == branch.branchId) {
        return item;
      }
    }

    final HomeDataBakeriesModel? cached = _fetchedBranches[branch.branchId];
    if (cached != null) return cached;

    loadingBranchId = branch.branchId;
    emit(HomeDataSuccess());

    final result = await _repo.getBranchProducts(
      bakeryId: branch.bakeryId,
      branchId: branch.branchId,
    );

    loadingBranchId = null;
    HomeDataBakeriesModel? details;
    if (result is SuccessResponse<List<ProductModel>>) {
      details = HomeDataBakeriesModel(
        bakeryModel: branch,
        productModelList: result.data,
      );
      _fetchedBranches[branch.branchId] = details;
    }
    emit(HomeDataSuccess());
    return details;
  }

  List<HomeDataBakeriesModel> get searchResults {
    final String query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return [];
    final Set<String> matchedIds = allBakeries
        .where((bakery) => bakery.bakeryName.toLowerCase().contains(query))
        .map((bakery) => bakery.bakeryId)
        .toSet();
    return matchedIds.map((bakeryId) {
      for (final item in nearbyBakeries) {
        if (item.bakeryModel.bakeryId == bakeryId) return item;
      }
      return HomeDataBakeriesModel(
        bakeryModel: branchesOf(bakeryId).first,
        productModelList: [],
      );
    }).toList();
  }

  int branchesCount(String bakeryId) {
    return allBakeries.where((bakery) => bakery.bakeryId == bakeryId).length;
  }

  void setSearchingMode(bool status) {
    searchingMode = status;
    isSearchFocused = status;
    if (!status) {
      searchController.clear();
      searchQuery = "";
      isSearchFocused = false;
    }
    emit(HomeDataSuccess());
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    emit(HomeDataSuccess());
  }

  void setSearchFocus(bool focused) {
    if (isSearchFocused == focused) return;
    isSearchFocused = focused;
    emit(HomeDataSuccess());
  }

  void setRefresh(bool status) {
    refreshStatus = status;
    emit(HomeDataSuccess());
  }

  Future<void> updateProfileImageStatus(bool hasImage) async {
    final result = await _repo.setProfileImageStatus(
      userId: user.id!,
      hasImage: hasImage,
    );
    if (result is SuccessResponse<bool>) {
      user = user.copyWith(hasProfileImage: hasImage);
      emit(HomeDataSuccess());
    }
  }

  Future<bool> removeProfileImage() async {
    final result = await _repo.removeProfileImage(userId: user.id!);
    if (result is SuccessResponse<bool>) {
      user = user.copyWith(hasProfileImage: false);
      emit(HomeDataSuccess());
      return true;
    }
    return false;
  }

  void nameChanged({bool? firstName, bool? secondName}) {
    if (firstName != null) {
      firstNameChanged = firstName;
    }
    if (secondName != null) {
      secondNameChanged = secondName;
    }
    isNameChanged = firstNameChanged || secondNameChanged;
    emit(HomeDataSuccess());
  }

  void addressChanged({bool? street, bool? building, bool? apartment}) {
    if (street != null) {
      streetChanged = street;
    }
    if (building != null) {
      buildingChanged = building;
    }
    if (apartment != null) {
      apartmentChanged = apartment;
    }
    isAddressChanged = streetChanged || buildingChanged || apartmentChanged;
    emit(HomeDataSuccess());
  }

  Future<void> logout() async {
    await _repo.logout();
  }

  Future<void> getHomeData({bool isRefreshing = false}) async {
    if (!isRefreshing) emit(HomeDataLoading());
    _activeOrdersCubit.checkActiveOrders();

    final userDataResult = await _repo.getUserData();
    if (userDataResult is FailureResponse<UserModel>) {
      if (!isRefreshing) emit(HomeDataFailure(userDataResult.error));
      return;
    }
    user = (userDataResult as SuccessResponse<UserModel>).data;
    _cartCubit.initAddress(
      street: user.street,
      building: user.building,
      apartment: user.apartment,
    );

    final bakeriesResult = await _repo.getBakeries();
    if (bakeriesResult
        is SuccessResponse<
          ({
            List<HomeDataBakeriesModel> homeData,
            List<BakeryModel> allBakeries,
          })
        >) {
      nearbyBakeries = bakeriesResult.data.homeData;
      allBakeries=bakeriesResult.data.allBakeries;
      emit(HomeDataSuccess());
    } else if (bakeriesResult is FailureResponse) {
      if (!isRefreshing) {
        emit(HomeDataFailure((bakeriesResult as FailureResponse).error));
      }
    }
  }

  Future<void> changeUserData({required UserModel updatedUserData}) async {
    final changeResult = await _repo.changeUserData(
      updatedUserData: updatedUserData,
    );
    if (changeResult is SuccessResponse<bool>) {
      final userDataResult = await _repo.getUserData();
      if (userDataResult is FailureResponse<UserModel>) {
        emit(HomeDataFailure(userDataResult.error));
        return;
      }
      user = (userDataResult as SuccessResponse<UserModel>).data;
      emit(HomeDataSuccess());
    } else if (changeResult is FailureResponse) {
      emit(HomeDataFailure((changeResult as FailureResponse).error));
    }
  }
  @override
  Future<void> close() {
    searchController.dispose();
    return super.close();
  }
}
