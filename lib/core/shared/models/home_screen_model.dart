import 'package:bakemart/core/shared/models/product_model.dart';
import '../../utils/enums/home_screen_table_columns.dart';
import 'bakery_model.dart';

class HomeDataBakeriesModel {
  final BakeryModel bakeryModel;
  final List<ProductModel> productModelList;

  HomeDataBakeriesModel({
    required this.bakeryModel,
    required this.productModelList,
  });

  double get bakeryRate {
    if (productModelList.isEmpty) return 0.0;

    final double totalRate = productModelList.fold(
      0.0,
          (sum, product) => sum + product.rate,
    );

    final double average = totalRate / productModelList.length;

    return double.parse(average.clamp(0.0, 5.0).toStringAsFixed(1));
  }

  factory HomeDataBakeriesModel.fromJson(Map<String, dynamic> json) {
    return HomeDataBakeriesModel(
      bakeryModel: BakeryModel.fromJson(
        json[HomeScreenTableColumns.bakery] ?? {},
      ),
      productModelList: (json[HomeScreenTableColumns.products] as List? ?? [])
          .map((item) => ProductModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      HomeScreenTableColumns.bakery: bakeryModel.toJson(),
      HomeScreenTableColumns.products:
      productModelList.map((x) => x.toJson()).toList(),
    };
  }

  HomeDataBakeriesModel copyWith({
    BakeryModel? bakeryModel,
    List<ProductModel>? productModelList,
  }) {
    return HomeDataBakeriesModel(
      bakeryModel: bakeryModel ?? this.bakeryModel,
      productModelList: productModelList ?? this.productModelList,
    );
  }
}