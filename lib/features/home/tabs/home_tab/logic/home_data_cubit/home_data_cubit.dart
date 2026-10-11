import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/response_result.dart';
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
  List<HomeDataBakeriesModel> bakeries = [];

  bool refreshStatus = false;
  bool firstNameChanged = false;
  bool secondNameChanged = false;
  bool isNameChanged = false;

  bool streetChanged = false;
  bool buildingChanged = false;
  bool apartmentChanged = false;
  bool isAddressChanged = false;

  void setRefresh(bool status){
    refreshStatus=status;
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
  void addressChanged({bool? street, bool? building,bool? apartment}) {
    if (street != null) {
      streetChanged = street;
    }
    if (building != null) {
      buildingChanged = building;
    }
    if (apartment != null) {
      apartmentChanged = apartment;
    }
    isAddressChanged = streetChanged || buildingChanged|| apartmentChanged;
    emit(HomeDataSuccess());
  }

  Future<void>logout()async{
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
    if (bakeriesResult is SuccessResponse<List<HomeDataBakeriesModel>>) {
      bakeries = bakeriesResult.data;
      emit(HomeDataSuccess());
    } else if (bakeriesResult is FailureResponse<List<HomeDataBakeriesModel>>) {
      if (!isRefreshing) emit(HomeDataFailure(bakeriesResult.error));
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
}
