import 'package:bakemart/core/shared/models/recipe_model.dart';
import '../../utils/enums/products_table_columns.dart';

class ProductModel {
  final String? productId;
  final String bakeryId;
  final String branchId;
  final String productName;
  final int productWeight;
  final double productPrice;
  final RecipeModel productRecipe;
  final int quantityPerBatch;
  final double yesterdayProduced;
  final double yesterdaySold;
  final int totalProduced;
  final int totalSold;
  final int notSoldWaste;
  final int manufacturingWaste;
  final int mealsWaste;
  final int available;

  ProductModel({
    this.productId,
    required this.bakeryId,
    required this.branchId,
    required this.productName,
    required this.productWeight,
    required this.productPrice,
    required this.productRecipe,
    required this.quantityPerBatch,
    required this.yesterdayProduced,
    required this.yesterdaySold,
    required this.totalProduced,
    required this.totalSold,
    required this.notSoldWaste,
    required this.manufacturingWaste,
    required this.mealsWaste,
    required this.available,
  });

  /// Dynamic getter calculating product rating out of 5.0 using the 4-part weighted score
  double get rate {
    // --- Part 1: Lifetime Sell-Through Score (Max 1.0 pt) ---
    final int netSellableProduction = totalProduced - mealsWaste;
    double lifetimeEfficiencyScore = 0.0;

    if (netSellableProduction > 0) {
      final double lifetimeRatio =
      (totalSold / netSellableProduction).clamp(0.0, 1.0);
      lifetimeEfficiencyScore = lifetimeRatio * 1.0;
    }

    // --- Part 2: Yesterday's Sell-Through Score (Max 1.0 pt) ---
    double yesterdayEfficiencyScore = 0.0;

    if (yesterdayProduced > 0) {
      final double yesterdayRatio =
      (yesterdaySold / yesterdayProduced).clamp(0.0, 1.0);
      yesterdayEfficiencyScore = yesterdayRatio * 1.0;
    }

    // --- Part 3: Yesterday's Production Volume Tier (Max 2.0 pts) ---
    double volumeScore;
    if (yesterdayProduced < 100.0) {
      volumeScore = 0.50; // Tier 1: 0 - 99 units
    } else if (yesterdayProduced < 500.0) {
      volumeScore = 1.00; // Tier 2: 100 - 499 units
    } else if (yesterdayProduced < 2000.0) {
      volumeScore = 1.50; // Tier 3: 500 - 1,999 units
    } else {
      volumeScore = 2.00; // Tier 4: 2,000+ units
    }

    // --- Part 4: Yesterday's Revenue Impact Score (Max 1.0 pt) ---
    final double yesterdayRevenue = yesterdaySold * productPrice;

    double revenueScore;
    if (yesterdayRevenue < 100.0) {
      revenueScore = 0.35;
    } else if (yesterdayRevenue <= 500.0) {
      revenueScore = 0.70;
    } else {
      revenueScore = 1.00;
    }

    // Combined score (Max 5.0)
    final double totalScore = lifetimeEfficiencyScore +
        yesterdayEfficiencyScore +
        volumeScore +
        revenueScore;

    return double.parse(totalScore.clamp(0.0, 5.0).toStringAsFixed(2));
  }

  double get fat {
    if (quantityPerBatch == 0) return 0.0;

    final double oilPerUnit = (productRecipe.oil ?? 0) / quantityPerBatch;
    final double gheePerUnit = (productRecipe.ghee ?? 0) / quantityPerBatch;
    final double butterPerUnit = (productRecipe.butter ?? 0) / quantityPerBatch;

    return oilPerUnit + gheePerUnit + butterPerUnit;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json[ProductsTableColumns.productId] as String?,
      bakeryId: json[ProductsTableColumns.bakeryId] as String? ?? "",
      branchId: json[ProductsTableColumns.branchId] as String? ?? "",
      productName:
      json[ProductsTableColumns.productName] as String? ??
          "Unknown Product",
      productWeight:
      (json[ProductsTableColumns.productWeight] as num?)?.toInt() ?? 0,
      productPrice:
      (json[ProductsTableColumns.productPrice] as num?)?.toDouble() ?? 0.0,
      productRecipe: RecipeModel.fromJson(
        json[ProductsTableColumns.productRecipe] as Map<String, dynamic>? ?? {},
      ),
      quantityPerBatch:
      (json[ProductsTableColumns.quantityPerBatch] as num?)?.toInt() ?? 1,
      yesterdayProduced:
      (json[ProductsTableColumns.yesterdayProduced] as num?)?.toDouble() ?? 0.0,
      yesterdaySold:
      (json[ProductsTableColumns.yesterdaySold] as num?)?.toDouble() ?? 0.0,
      totalProduced:
      (json[ProductsTableColumns.totalProduced] as num?)?.toInt() ?? 0,
      totalSold: (json[ProductsTableColumns.totalSold] as num?)?.toInt() ?? 0,
      notSoldWaste:
      (json[ProductsTableColumns.notSoldWaste] as num?)?.toInt() ?? 0,
      manufacturingWaste:
      (json[ProductsTableColumns.manufacturingWaste] as num?)?.toInt() ?? 0,
      mealsWaste: (json[ProductsTableColumns.mealsWaste] as num?)?.toInt() ?? 0,
      available: (json[ProductsTableColumns.available] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (productId != null && productId!.isNotEmpty)
        ProductsTableColumns.productId: productId,
      ProductsTableColumns.bakeryId: bakeryId,
      ProductsTableColumns.branchId: branchId,
      ProductsTableColumns.productName: productName,
      ProductsTableColumns.productWeight: productWeight,
      ProductsTableColumns.productPrice: productPrice,
      ProductsTableColumns.productRecipe: productRecipe.toJson(),
      ProductsTableColumns.quantityPerBatch: quantityPerBatch,
      ProductsTableColumns.yesterdayProduced: yesterdayProduced,
      ProductsTableColumns.yesterdaySold: yesterdaySold,
      ProductsTableColumns.totalProduced: totalProduced,
      ProductsTableColumns.totalSold: totalSold,
      ProductsTableColumns.notSoldWaste: notSoldWaste,
      ProductsTableColumns.manufacturingWaste: manufacturingWaste,
      ProductsTableColumns.mealsWaste: mealsWaste,
      ProductsTableColumns.available: available,
    };
  }

  ProductModel copyWith({
    String? productId,
    String? bakeryId,
    String? branchId,
    String? productName,
    int? productWeight,
    double? productPrice,
    RecipeModel? productRecipe,
    int? quantityPerBatch,
    double? yesterdayProduced,
    double? yesterdaySold,
    int? totalProduced,
    int? totalSold,
    int? notSoldWaste,
    int? manufacturingWaste,
    int? mealsWaste,
    int? available,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      bakeryId: bakeryId ?? this.bakeryId,
      branchId: branchId ?? this.branchId,
      productName: productName ?? this.productName,
      productWeight: productWeight ?? this.productWeight,
      productPrice: productPrice ?? this.productPrice,
      productRecipe: productRecipe ?? this.productRecipe,
      quantityPerBatch: quantityPerBatch ?? this.quantityPerBatch,
      yesterdayProduced: yesterdayProduced ?? this.yesterdayProduced,
      yesterdaySold: yesterdaySold ?? this.yesterdaySold,
      totalProduced: totalProduced ?? this.totalProduced,
      totalSold: totalSold ?? this.totalSold,
      notSoldWaste: notSoldWaste ?? this.notSoldWaste,
      manufacturingWaste: manufacturingWaste ?? this.manufacturingWaste,
      mealsWaste: mealsWaste ?? this.mealsWaste,
      available: available ?? this.available,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductModel &&
        other.productId == productId &&
        other.bakeryId == bakeryId &&
        other.branchId == branchId &&
        other.productName == productName &&
        other.productWeight == productWeight &&
        other.productPrice == productPrice &&
        other.productRecipe == productRecipe &&
        other.quantityPerBatch == quantityPerBatch &&
        other.yesterdayProduced == yesterdayProduced &&
        other.yesterdaySold == yesterdaySold &&
        other.totalProduced == totalProduced &&
        other.totalSold == totalSold &&
        other.notSoldWaste == notSoldWaste &&
        other.manufacturingWaste == manufacturingWaste &&
        other.mealsWaste == mealsWaste &&
        other.available == available;
  }

  @override
  int get hashCode => Object.hashAll([
    productId,
    bakeryId,
    branchId,
    productName,
    productWeight,
    productPrice,
    productRecipe,
    quantityPerBatch,
    yesterdayProduced,
    yesterdaySold,
    totalProduced,
    totalSold,
    notSoldWaste,
    manufacturingWaste,
    mealsWaste,
    available,
  ]);
}