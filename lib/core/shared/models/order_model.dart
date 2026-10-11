import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:flutter/foundation.dart';

import '../../shared/models/bakery_model.dart';
import '../../shared/models/product_model.dart';
import '../../utils/enums/orders_table_columns.dart';

class OrderModel {
  final String? orderId;
  final String customerId;
  final String customerName;
  final List<BakeryModel> bakeries;
  final String? deliveryManId;
  final String? deliveryManName;
  final double customerLat;
  final double customerLng;
  final List<ProductModel> orderedProducts;
  final List<int> orderedQuantities;
  final List<ProductModel>? receivedProducts;
  final List<int>? receivedQuantities;
  final List<bool> received;
  final double orderPrice;
  final double deliveryFee;
  final String orderStatus;
  final DateTime? date;
  final String? street;
  final String? building;
  final String? apartment;

  OrderModel({
    this.orderId,
    required this.customerId,
    required this.customerName,
    required this.bakeries,
    this.deliveryManId,
    this.deliveryManName,
    required this.customerLat,
    required this.customerLng,
    required this.orderedProducts,
    required this.orderedQuantities,
    this.receivedProducts,
    this.receivedQuantities,
    required this.received,
    required this.orderPrice,
    required this.deliveryFee,
    required this.orderStatus,
    this.date,
    this.street,
    this.building,
    this.apartment,
  });

  /// Computed property that dynamically calculates the total bill.
  double get totalBill => orderPrice + deliveryFee;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json[OrdersTableColumns.orderId] as String?,
      customerId: json[OrdersTableColumns.customerId] as String? ?? '',
      customerName: json[OrdersTableColumns.customerName] as String? ?? '',
      bakeries:
      (json[OrdersTableColumns.bakeryId] as List?)
          ?.map((e) => BakeryModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      deliveryManId: json[OrdersTableColumns.deliveryManId] as String?,
      deliveryManName: json[OrdersTableColumns.deliveryManName] as String?,
      customerLat:
      (json[OrdersTableColumns.customerLat] as num? ?? 0.0).toDouble(),
      customerLng:
      (json[OrdersTableColumns.customerLng] as num? ?? 0.0).toDouble(),
      orderedProducts:
      (json[OrdersTableColumns.orderedProducts] as List?)
          ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      orderedQuantities: List<int>.from(
        json[OrdersTableColumns.orderedQuantities] ?? [],
      ),
      receivedProducts: json[OrdersTableColumns.receivedProducts] != null
          ? (json[OrdersTableColumns.receivedProducts] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      receivedQuantities: json[OrdersTableColumns.receivedQuantities] != null
          ? List<int>.from(json[OrdersTableColumns.receivedQuantities])
          : null,
      received: List<bool>.from(json[OrdersTableColumns.received] ?? []),
      orderPrice: (json[OrdersTableColumns.orderPrice] as num? ?? 0.0)
          .toDouble(),
      deliveryFee: (json[OrdersTableColumns.deliveryFee] as num? ?? 0.0)
          .toDouble(),
      orderStatus:
      json[OrdersTableColumns.orderStatus] as String? ??
          OrderStatuses.pending,
      date: json[OrdersTableColumns.date] != null
          ? DateTime.tryParse(
        json[OrdersTableColumns.date] as String,
      )?.toLocal()
          : null,
      street: json[OrdersTableColumns.street] as String?,
      building: json[OrdersTableColumns.building] as String?,
      apartment: json[OrdersTableColumns.apartment] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (orderId != null) OrdersTableColumns.orderId: orderId,
      OrdersTableColumns.customerId: customerId,
      OrdersTableColumns.customerName: customerName,
      OrdersTableColumns.bakeryId: bakeries.map((b) => b.toJson()).toList(),
      if (deliveryManId != null)
        OrdersTableColumns.deliveryManId: deliveryManId,
      if (deliveryManName != null)
        OrdersTableColumns.deliveryManName: deliveryManName,
      OrdersTableColumns.customerLat: customerLat,
      OrdersTableColumns.customerLng: customerLng,
      OrdersTableColumns.orderedProducts: orderedProducts
          .map((p) => p.toJson())
          .toList(),
      OrdersTableColumns.orderedQuantities: orderedQuantities,
      if (receivedProducts != null)
        OrdersTableColumns.receivedProducts: receivedProducts!
            .map((p) => p.toJson())
            .toList(),
      if (receivedQuantities != null)
        OrdersTableColumns.receivedQuantities: receivedQuantities,
      OrdersTableColumns.received: received,
      OrdersTableColumns.orderPrice: orderPrice,
      OrdersTableColumns.deliveryFee: deliveryFee,
      OrdersTableColumns.orderStatus: orderStatus,
      if (date != null)
        OrdersTableColumns.date: date!.toUtc().toIso8601String(),
      if (street != null) OrdersTableColumns.street: street,
      if (building != null) OrdersTableColumns.building: building,
      if (apartment != null) OrdersTableColumns.apartment: apartment,
    };
  }

  OrderModel copyWith({
    String? orderId,
    String? customerId,
    String? customerName,
    List<BakeryModel>? bakeries,
    String? deliveryManId,
    String? deliveryManName,
    double? customerLat,
    double? customerLng,
    List<ProductModel>? orderedProducts,
    List<int>? orderedQuantities,
    List<ProductModel>? receivedProducts,
    List<int>? receivedQuantities,
    List<bool>? received,
    double? orderPrice,
    double? deliveryFee,
    String? orderStatus,
    DateTime? date,
    String? street,
    String? building,
    String? apartment,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      bakeries: bakeries ?? this.bakeries,
      deliveryManId: deliveryManId ?? this.deliveryManId,
      deliveryManName: deliveryManName ?? this.deliveryManName,
      customerLat: customerLat ?? this.customerLat,
      customerLng: customerLng ?? this.customerLng,
      orderedProducts: orderedProducts ?? this.orderedProducts,
      orderedQuantities: orderedQuantities ?? this.orderedQuantities,
      receivedProducts: receivedProducts ?? this.receivedProducts,
      receivedQuantities: receivedQuantities ?? this.receivedQuantities,
      received: received ?? this.received,
      orderPrice: orderPrice ?? this.orderPrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      orderStatus: orderStatus ?? this.orderStatus,
      date: date ?? this.date,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OrderModel &&
        other.orderId == orderId &&
        other.customerId == customerId &&
        other.customerName == customerName &&
        listEquals(other.bakeries, bakeries) &&
        other.deliveryManId == deliveryManId &&
        other.deliveryManName == deliveryManName &&
        other.customerLat == customerLat &&
        other.customerLng == customerLng &&
        listEquals(other.orderedProducts, orderedProducts) &&
        listEquals(other.orderedQuantities, orderedQuantities) &&
        listEquals(other.receivedProducts, receivedProducts) &&
        listEquals(other.receivedQuantities, receivedQuantities) &&
        listEquals(other.received, received) &&
        other.orderPrice == orderPrice &&
        other.deliveryFee == deliveryFee &&
        other.orderStatus == orderStatus &&
        other.date == date &&
        other.street == street &&
        other.building == building &&
        other.apartment == apartment;
  }

  @override
  int get hashCode => Object.hashAll([
    orderId,
    customerId,
    customerName,
    Object.hashAll(bakeries),
    deliveryManId,
    deliveryManName,
    customerLat,
    customerLng,
    Object.hashAll(orderedProducts),
    Object.hashAll(orderedQuantities),
    Object.hashAll(receivedProducts ?? []),
    Object.hashAll(receivedQuantities ?? []),
    Object.hashAll(received),
    orderPrice,
    deliveryFee,
    orderStatus,
    date,
    street,
    building,
    apartment,
  ]);
}