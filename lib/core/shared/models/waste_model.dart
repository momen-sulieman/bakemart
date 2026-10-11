import '../../utils/enums/wastes_table_columns.dart';

class WasteModel {
  final String productId;
  final String productName;
  final int meal;
  final int notSold;
  final int manufacturing;
  final double productPrice;
  final DateTime? date;

  WasteModel({
    required this.productId,
    required this.productName,
    required this.meal,
    required this.notSold,
    required this.manufacturing,
    required this.productPrice,
    this.date,
  });

  /// Total sum of all waste items (meal + not sold + manufacturing)
  int get totalQuantity => meal + notSold + manufacturing;

  /// Total financial loss from waste (totalQuantity * productPrice)
  double get totalPrice => totalQuantity * productPrice;

  factory WasteModel.fromJson(Map<String, dynamic> json) {
    return WasteModel(
      productId: json[WastesTableColumns.productId] as String? ?? '',
      productName: json[WastesTableColumns.productName] as String? ?? '',
      meal: (json[WastesTableColumns.meal] as num?)?.toInt() ?? 0,
      notSold: (json[WastesTableColumns.notSold] as num?)?.toInt() ?? 0,
      manufacturing:
      (json[WastesTableColumns.manufacturing] as num?)?.toInt() ?? 0,
      productPrice:
      (json[WastesTableColumns.productPrice] as num?)?.toDouble() ?? 0.0,
      date: json[WastesTableColumns.date] != null
          ? DateTime.parse(json[WastesTableColumns.date] as String).toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      WastesTableColumns.productId: productId,
      WastesTableColumns.productName: productName,
      WastesTableColumns.meal: meal,
      WastesTableColumns.notSold: notSold,
      WastesTableColumns.manufacturing: manufacturing,
      WastesTableColumns.productPrice: productPrice,
      if (date != null)
        WastesTableColumns.date: date!.toIso8601String().split('T').first,
    };
  }

  WasteModel copyWith({
    String? productId,
    String? productName,
    int? meal,
    int? notSold,
    int? manufacturing,
    double? productPrice,
    DateTime? date,
  }) {
    return WasteModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      meal: meal ?? this.meal,
      notSold: notSold ?? this.notSold,
      manufacturing: manufacturing ?? this.manufacturing,
      productPrice: productPrice ?? this.productPrice,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WasteModel &&
        other.productId == productId &&
        other.productName == productName &&
        other.meal == meal &&
        other.notSold == notSold &&
        other.manufacturing == manufacturing &&
        other.productPrice == productPrice &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(
    productId,
    productName,
    meal,
    notSold,
    manufacturing,
    productPrice,
    date,
  );
}