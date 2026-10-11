import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'product_creation_view.dart';
import 'product_pending_edit_view.dart';
import 'product_recipe_edit_view.dart';
import 'product_view_only.dart';


class ProductDetailsScreen extends StatelessWidget {
  final ProductModel product;
  final int? productIndex;
  final BakeryTabCubit? cubit;
  final bool statistict, nutrition, recipe, creation;

  const ProductDetailsScreen({
    required this.product,
    this.statistict = false,
    this.nutrition = true,
    this.recipe = false,
    this.creation = false,
    this.productIndex,
    this.cubit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (creation && cubit != null && productIndex != null) {
      return ProductCreationView(product: product, cubit: cubit!, productIndex: productIndex!);
    }
    if (recipe) {
      final settingsCubit = context.read<SettingsCubit>();
      final isPersisted = settingsCubit.products.any((p) => p.productId == product.productId);
      return isPersisted
          ? ProductRecipeEditView(product: product)
          : ProductPendingEditView(product: product, cubit: settingsCubit);
    }
    return ProductViewOnly(product: product, statistict: statistict, nutrition: nutrition);
  }
}