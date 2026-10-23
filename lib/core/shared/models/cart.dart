import 'package:bakemart/core/shared/models/product_model.dart';
import 'bakery_model.dart';

class Cart {
  final Map<String, BakeryModel> bakeries;
  final Map<String, ProductModel> products;
  final Map<String, int> quantities;
  final double deliveryFee;
  final double orderPrice;
  final double totalBill;
  final double userLat;
  final double userLng;
  final String? street;
  final String? building;
  final String? apartment;

  Cart({
    Map<String, BakeryModel>? bakeries,
    Map<String, ProductModel>? products,
    Map<String, int>? quantities,
    this.deliveryFee = 0.0,
    this.orderPrice = 0.0,
    this.totalBill = 0.0,
    this.userLat = 0.0,
    this.userLng = 0.0,
    this.street,
    this.building,
    this.apartment,
  })  : bakeries = Map.unmodifiable(bakeries ?? {}),
        products = Map.unmodifiable(products ?? {}),
        quantities = Map.unmodifiable(quantities ?? {});

  static String itemKey(String productId, String branchId) =>
      '$productId::$branchId';

  bool get isEmpty => products.isEmpty;

  Cart copyWith({
    Map<String, BakeryModel>? bakeries,
    Map<String, ProductModel>? products,
    Map<String, int>? quantities,
    double? deliveryFee,
    double? orderPrice,
    double? totalBill,
    double? userLat,
    double? userLng,
    String? street,
    String? building,
    String? apartment,
  }) {
    return Cart(
      bakeries: bakeries != null ? Map.from(bakeries) : this.bakeries,
      products: products != null ? Map.from(products) : this.products,
      quantities: quantities != null ? Map.from(quantities) : this.quantities,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      orderPrice: orderPrice ?? this.orderPrice,
      totalBill: totalBill ?? this.totalBill,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      street: street ?? this.street,
      building: building ?? this.building,
      apartment: apartment ?? this.apartment,
    );
  }
}