import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/network/response_result.dart';
import '../../../../../../../../core/shared/models/order_model.dart';
import '../../data/worker_repo.dart';

part 'delivery_sales_state.dart';

class DeliverySalesCubit extends Cubit<DeliverySalesState> {
  final WorkerRepo _repo;

  DeliverySalesCubit(this._repo) : super(Initial());

  List<OrderModel> scannedOrders = [];
  List<OrderModel> editableOrders = [];
  double total = 0;
  bool listUpdated = false;

  Future<void> scanOrders({
    required String deliveryManId,
    required String bakeryId,
  }) async {
    emit(Loading());
    final fetchResult = await _repo.fetchAllOrdersOfThisDeliveryMan(
      deliveryManId: deliveryManId,
      bakeryId: bakeryId,
    );
    if (fetchResult is SuccessResponse<List<OrderModel>>) {
      scannedOrders = fetchResult.data;
      editableOrders = List<OrderModel>.from(scannedOrders);
      total = getOrdersTotal(scannedOrders);
      listUpdated = false;
      emit(Success(editableOrders));
    } else {
      emit(Failure((fetchResult as FailureResponse).error));
    }
  }

  void removeOrder({required OrderModel order}) {
    final List<OrderModel> updatedEditableList = List.from(editableOrders);
    updatedEditableList.removeWhere((o) => o.orderId == order.orderId);
    editableOrders = updatedEditableList;
    total = getOrdersTotal(updatedEditableList);
    listUpdated = true;
    emit(Success(updatedEditableList));
  }

  void removeOrderWithoutChangingTotal({required OrderModel order}) {
    final List<OrderModel> updatedEditableList = List.from(editableOrders);
    updatedEditableList.removeWhere((o) => o.orderId == order.orderId);
    editableOrders = updatedEditableList;
    listUpdated = true;
    emit(Success(updatedEditableList));
  }

  Future<bool> handOneOrder({
    required OrderModel order,
    required String bakeryId,
  }) async {
    final result = await _repo.updateOrderInDatabase(
      order: order,
      bakeryId: bakeryId,
    );
    return result is SuccessResponse<bool>;
  }

  Future<bool> handAllOrders({
    required List<OrderModel> orders,
    required String bakeryId,
  }) async {
    emit(ProcessingAll());
    bool allSucceeded = true;
    final List<OrderModel> remaining = List.from(editableOrders);

    for (final order in orders) {
      final success = await handOneOrder(order: order, bakeryId: bakeryId);
      if (success) {
        remaining.removeWhere((o) => o.orderId == order.orderId);
      } else {
        allSucceeded = false;
      }
    }

    editableOrders = remaining;
    listUpdated = true;
    emit(Success(editableOrders));
    return allSucceeded;
  }

  double getOrdersSubtotal(OrderModel order) {
    final subtotal = order.orderedProducts.asMap().entries.fold<double>(0.0, (
        sum,
        entry,
        ) {
      final i = entry.key;
      final p = entry.value;
      final qty = i < order.orderedQuantities.length
          ? order.orderedQuantities[i]
          : 0;
      return sum + (p.productPrice * qty);
    });
    return subtotal;
  }

  double getOrdersTotal(List<OrderModel> orders) {
    return orders.fold<double>(
      0.0,
          (sum, order) => sum + getOrdersSubtotal(order),
    );
  }

  OrderModel recalculateOrder(OrderModel order) {
    final subtotal = order.orderedProducts.asMap().entries.fold<double>(0.0, (
        sum,
        entry,
        ) {
      final i = entry.key;
      final p = entry.value;
      final qty = i < order.orderedQuantities.length
          ? order.orderedQuantities[i]
          : 0;

      return sum + (p.productPrice * qty);
    });

    return order.copyWith(orderPrice: subtotal);
  }

  void increaseQuantity({
    required OrderModel order,
    required int productIndex,
  }) {

    final index = editableOrders.indexWhere((o) => o.orderId == order.orderId);

    if (index != -1) {
      final targetOrder = editableOrders[index];

      final List<int> clonedQuantities = List.from(
        targetOrder.orderedQuantities,
      );
      clonedQuantities[productIndex] += 1;

      final updatedOrder = targetOrder.copyWith(
        orderedQuantities: clonedQuantities,
      );

      final List<OrderModel> updatedEditableList = List.from(editableOrders);
      updatedEditableList[index] = recalculateOrder(updatedOrder);

      editableOrders = updatedEditableList;
      total = getOrdersTotal(updatedEditableList);
      listUpdated = true;
      emit(Success(updatedEditableList));
    }
  }

  void decreaseQuantity({
    required OrderModel order,
    required int productIndex,
  }) {

    final index = editableOrders.indexWhere((o) => o.orderId == order.orderId);

    if (index != -1) {
      final targetOrder = editableOrders[index];

      if (targetOrder.orderedQuantities[productIndex] > 0) {
        final List<int> clonedQuantities = List.from(
          targetOrder.orderedQuantities,
        );
        clonedQuantities[productIndex] -= 1;

        final updatedOrder = targetOrder.copyWith(
          orderedQuantities: clonedQuantities,
        );

        final List<OrderModel> updatedEditableList = List.from(editableOrders);
        updatedEditableList[index] = recalculateOrder(updatedOrder);

        editableOrders = updatedEditableList;
        total = getOrdersTotal(updatedEditableList);
        listUpdated = true;
        emit(Success(updatedEditableList));
      }
    }
  }

  void resetOrder(String orderId) {
    final scannedOrder = scannedOrders.firstWhere((o) => o.orderId == orderId);
    final int editableIndex = editableOrders.indexWhere(
          (o) => o.orderId == orderId,
    );
    if (editableIndex != -1) {
      final List<OrderModel> updatedEditableList = List.from(editableOrders);
      updatedEditableList[editableIndex] = scannedOrder;
      editableOrders = updatedEditableList;
      emit(Success(updatedEditableList));
    }
  }

  void reset() {
    if (scannedOrders.isEmpty) return;
    final List<OrderModel> updatedEditableList = List.from(scannedOrders);
    editableOrders = updatedEditableList;
    listUpdated = false;
    emit(Success(updatedEditableList));
  }

  void removeProductFromOrder({
    required String orderId,
    required ProductModel productToRemove,
  }) {
    if (editableOrders.isEmpty) return;
    final int orderIndex = editableOrders.indexWhere(
          (o) => o.orderId == orderId,
    );
    if (orderIndex != -1) {
      final currentOrder = editableOrders[orderIndex];
      final int productIndex = currentOrder.orderedProducts.indexOf(
        productToRemove,
      );
      if (productIndex != -1) {
        final List<ProductModel> updatedProducts = List.from(
          currentOrder.orderedProducts,
        );
        final List<int> updatedQuantities = List.from(
          currentOrder.orderedQuantities,
        );
        final List<bool> updatedReceived = List.from(currentOrder.received);
        final int removedQuantity = updatedQuantities[productIndex];
        updatedProducts.removeAt(productIndex);
        updatedQuantities.removeAt(productIndex);
        if (updatedReceived.length > productIndex) {
          updatedReceived.removeAt(productIndex);
        }
        final double priceDeduction =
            productToRemove.productPrice * removedQuantity;
        final double newOrderPrice = (currentOrder.orderPrice - priceDeduction)
            .clamp(0.0, double.infinity);
        final OrderModel updatedOrder = currentOrder.copyWith(
          orderedProducts: updatedProducts,
          orderedQuantities: updatedQuantities,
          received: updatedReceived,
          orderPrice: newOrderPrice,
        );
        final List<OrderModel> updatedEditableList = List.from(editableOrders);
        updatedEditableList[orderIndex] = updatedOrder;
        editableOrders = updatedEditableList;
        listUpdated = true;
        emit(Success(updatedEditableList));
      }
    }
  }
}