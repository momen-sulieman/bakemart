import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_inline_edit_form.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ProductCreationView extends StatelessWidget {
  final ProductModel product;
  final BakeryTabCubit cubit;
  final int productIndex;

  const ProductCreationView({
    required this.product,
    required this.cubit,
    required this.productIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BakeryTabCubit, BakeryTabState>(
      builder: (context, state) {
        final current = cubit.editableProducts[productIndex];
        return ProductInlineEditForm(
          product: current,
          pendingImage: cubit.pendingProductImages[product.productId],
          onPickImage: (file) => cubit.setProductImage(product.productId!, file),
          onUpdate: (update) => cubit.editProduct(
            updatedProduct: update(cubit.editableProducts[productIndex]),
            index: productIndex,
          ),
        );
      },
    );
  }
}