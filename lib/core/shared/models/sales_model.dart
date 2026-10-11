import '../../utils/enums/sales_table_columns.dart';

class SalesModel {
  final String bakeryId;
  final String productId;
  final String productName;
  final double productPrice;
  final DateTime? date;
  final int produced;
  final int sold;

  SalesModel({
    required this.bakeryId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.date,
    this.produced = 0,
    this.sold = 0,
  });

  factory SalesModel.fromJson(Map<String, dynamic> json) {
    return SalesModel(
      bakeryId: json[SalesTableColumns.bakeryId] as String? ?? '',
      productId: json[SalesTableColumns.productId] as String? ?? '',
      productName: json[SalesTableColumns.productName] as String? ?? '',
      date: json[SalesTableColumns.date] != null
          ? DateTime.parse(json[SalesTableColumns.date] as String)
          : null,
      produced: (json[SalesTableColumns.produced] as num?)?.toInt() ?? 0,
      sold: (json[SalesTableColumns.sold] as num?)?.toInt() ?? 0,
      productPrice: (json[SalesTableColumns.productPrice] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SalesTableColumns.bakeryId: bakeryId,
      SalesTableColumns.productId: productId,
      SalesTableColumns.productName: productName,
      SalesTableColumns.date: date?.toIso8601String().split('T').first,
      SalesTableColumns.produced: produced,
      SalesTableColumns.sold: sold,
      SalesTableColumns.productPrice: productPrice,
    };
  }

  SalesModel copyWith({
    String? bakeryId,
    String? productId,
    String? productName,
    DateTime? date,
    int? produced,
    int? sold,
    double? productPrice,
  }) {
    return SalesModel(
      bakeryId: bakeryId ?? this.bakeryId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      date: date ?? this.date,
      produced: produced ?? this.produced,
      sold: sold ?? this.sold,
      productPrice: productPrice ?? this.productPrice,
    );
  }
}