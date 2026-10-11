import 'dart:async';
import 'dart:io';

import 'package:bakemart/core/network/response_result.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../../../../core/services/location_services.dart';
import '../../../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../../../core/shared/models/order_model.dart';
import '../../../../../../../../core/shared/models/user_model.dart';
import '../../data/delivery_repo.dart';

part 'delivery_state.dart';

enum DeliveryActionType { accept, cancel, deliver, verify }

class DeliveryActionResult {
  final DeliveryActionType type;
  final bool success;
  final String message;

  DeliveryActionResult({
    required this.type,
    required this.success,
    required this.message,
  });
}

class DeliveryCubit extends Cubit<DeliveryState> {
  final DeliveryRepo _repo;
  final LocationCubit _locationCubit;

  StreamSubscription? _locationSubscription;
  Stream<List<OrderModel>>? liveNearbyOrders;
  final StreamController<DeliveryActionResult> _actionController =
  StreamController<DeliveryActionResult>.broadcast();

  Stream<DeliveryActionResult> get actionResults => _actionController.stream;

  List<OrderModel> acceptedOrders = [];
  bool isReceiving = false;
  int range = 10;
  double? driverLat;
  double? driverLng;
  UserModel user = UserModel(
    firstName: "",
    secondName: "",
    email: "",
    phone: "",
  );

  String? loadingOrderId;
  DeliveryActionType? loadingAction;

  bool verificationSubmitting = false;

  bool isActionLoading(String orderId, DeliveryActionType action) =>
      loadingOrderId == orderId && loadingAction == action;

  DeliveryCubit(this._repo, this._locationCubit) : super(Loading()) {
    initCubit();
  }

  void initCubit({bool? loading}) async {
    if (loading != null) emit(Loading());
    final userResponse = await _repo.getUserData();
    if (isClosed) return;
    if (userResponse is SuccessResponse<UserModel>) {
      user = userResponse.data;
    }

    final currentLocationState = _locationCubit.state;
    if (currentLocationState is LocationUpdated) {
      driverLat = currentLocationState.lat;
      driverLng = currentLocationState.lng;
    }
    _locationSubscription?.cancel();
    _locationSubscription = _locationCubit.stream.listen((locationState) {
      if (locationState is LocationUpdated) {
        driverLat = locationState.lat;
        driverLng = locationState.lng;
        if (isReceiving && liveNearbyOrders == null) {
          startReceiving();
        }
      } else if (locationState is LocationFailure) {
        driverLat = null;
        driverLng = null;
        liveNearbyOrders = null;
        if (isReceiving) {
          emit(WaitingForLocation(locationState.reason));
        }
      }
    });
    fetchAcceptedOrders();
  }

  Future<void> fetchAcceptedOrders() async {
    final fetchResult = await _repo.fetchAcceptedOrders();
    if (fetchResult is SuccessResponse<List<OrderModel>>) {
      acceptedOrders = fetchResult.data;
      (state is Receiving)
          ? emit(Receiving())
          : (state is NotReceiving)
          ? emit(NotReceiving())
          : (state is Failure)
          ? emit(Failure("Error"))
          : (state is WaitingForLocation)
          ? emit(state)
          : emit(NotReceiving());
    } else {
      emit(Failure((fetchResult as FailureResponse).error));
    }
  }

  void startReceiving() {
    isReceiving = true;
    if (driverLat == null || driverLng == null) {
      final locationState = _locationCubit.state;
      if (locationState is LocationFailure) {
        emit(WaitingForLocation(locationState.reason));
      } else {
        emit(WaitingForLocation(LocationFailureReason.unknown));
      }
      return;
    }
    liveNearbyOrders = _repo.receiveOrders(
      range: range,
      driverLat: driverLat!,
      driverLng: driverLng!,
    );
    emit(Receiving());
  }

  Future<void> fixLocationIssue(LocationFailureReason reason) async {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        await Geolocator.openLocationSettings();
        break;
      case LocationFailureReason.permissionDeniedForever:
        await Geolocator.openAppSettings();
        break;
      case LocationFailureReason.permissionDenied:
      case LocationFailureReason.timedOut:
      case LocationFailureReason.unknown:
        _locationCubit.retryTracking();
        break;
    }
  }

  void updateRange(int newRange) {
    range = newRange;
    if (!isReceiving || driverLat == null || driverLng == null) return;
    liveNearbyOrders = _repo.receiveOrders(
      range: range,
      driverLat: driverLat!,
      driverLng: driverLng!,
    );
    emit(Receiving());
  }

  void _refreshState() {
    final current = state;
    if (current is Receiving) {
      emit(Receiving());
    } else if (current is NotReceiving) {
      emit(NotReceiving());
    } else if (current is WaitingForLocation) {
      emit(WaitingForLocation(current.reason));
    } else if (current is Failure) {
      emit(Failure(current.error));
    } else if (current is Loading) {
      emit(Loading());
    }
  }

  Future<void> acceptOrder({required String orderId}) async {
    if (loadingOrderId == orderId) {
      return;
    }
    loadingOrderId = orderId;
    loadingAction = DeliveryActionType.accept;
    _refreshState();

    final result = await _repo.acceptOrder(orderId);

    loadingOrderId = null;
    loadingAction = null;

    if (result is SuccessResponse) {
      _actionController.add(
        DeliveryActionResult(
          type: DeliveryActionType.accept,
          success: true,
          message: "orderAccepted".tr(),
        ),
      );
      await fetchAcceptedOrders();
    } else {
      _actionController.add(
        DeliveryActionResult(
          type: DeliveryActionType.accept,
          success: false,
          message: (result as FailureResponse).error,
        ),
      );
      _refreshState();
    }
  }

  Future<void> changeOrderStatus({
    required String orderId,
    required bool delivered,
  }) async {
    if (loadingOrderId == orderId) return;
    loadingOrderId = orderId;
    loadingAction = delivered
        ? DeliveryActionType.deliver
        : DeliveryActionType.cancel;
    _refreshState();

    final result = await _repo.changeOrderStatus(
      orderId: orderId,
      delivered: delivered,
    );

    loadingOrderId = null;
    loadingAction = null;

    final type = delivered
        ? DeliveryActionType.deliver
        : DeliveryActionType.cancel;
    if (result is SuccessResponse) {
      _actionController.add(
        DeliveryActionResult(
          type: type,
          success: true,
          message: delivered ? "orderDelivered".tr() : "orderCanceled".tr(),
        ),
      );
      await fetchAcceptedOrders();
    } else {
      _actionController.add(
        DeliveryActionResult(
          type: type,
          success: false,
          message: (result as FailureResponse).error,
        ),
      );
      _refreshState();
    }
  }

  Future<bool> submitVerification({
    required File faceImage,
    required File idImage,
  }) async {
    final userId = user.id;
    if (userId == null) {
      _actionController.add(
        DeliveryActionResult(
          type: DeliveryActionType.verify,
          success: false,
          message: "verificationFailed".tr(),
        ),
      );
      return false;
    }

    verificationSubmitting = true;
    _refreshState();

    final result = await _repo.submitVerification(
      userId: userId,
      faceImage: faceImage,
      idImage: idImage,
    );

    verificationSubmitting = false;

    if (result is SuccessResponse) {
      user = user.copyWith(pending: true);
      _actionController.add(
        DeliveryActionResult(
          type: DeliveryActionType.verify,
          success: true,
          message: "dataSent".tr(),
        ),
      );
      _refreshState();
      return true;
    } else {
      _actionController.add(
        DeliveryActionResult(
          type: DeliveryActionType.verify,
          success: false,
          message: (result as FailureResponse).error,
        ),
      );
      _refreshState();
      return false;
    }
  }

  void toggleReceiving() {
    if (isReceiving) {
      isReceiving = false;
      liveNearbyOrders = null;
      emit(NotReceiving());
    } else {
      startReceiving();
    }
  }

  @override
  Future<void> close() {
    _locationSubscription?.cancel();
    _actionController.close();
    return super.close();
  }
}