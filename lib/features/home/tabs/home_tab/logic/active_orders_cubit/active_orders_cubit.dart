import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/shared/models/order_model.dart';
import '../../data/home_repo.dart';

part 'active_orders_state.dart';

class ActiveOrdersCubit extends Cubit<ActiveOrdersState> {
  final HomeRepo _repo;

  ActiveOrdersCubit(this._repo) : super(NoActiveOrders());

  Stream<List<OrderModel>>? liveActiveOrders;

  final Set<String> cancellingOrderIds = {};
  final StreamController<Set<String>> _cancellingController =
  StreamController<Set<String>>.broadcast();

  Stream<Set<String>> get cancellingOrderIdsStream =>
      _cancellingController.stream;

  void checkActiveOrders() {
    liveActiveOrders = _repo.streamActiveOrders();
  }

  Future<void> cancelOrder({required String orderId}) async {
    cancellingOrderIds.add(orderId);
    _cancellingController.add(Set<String>.from(cancellingOrderIds));
    await _repo.cancelOrder(orderId: orderId);
    cancellingOrderIds.remove(orderId);
    _cancellingController.add(Set<String>.from(cancellingOrderIds));
  }

  @override
  Future<void> close() {
    _cancellingController.close();
    return super.close();
  }
}