import 'dart:io';

import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_inline_edit_form.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductPendingEditView extends StatelessWidget {
  final ProductModel product;
  final SettingsCubit cubit;

  const ProductPendingEditView({
    required this.product,
    required this.cubit,
    super.key,
  });

  ProductModel _latest() =>
      cubit.editableProducts.firstWhereOrNull(
            (p) =>
        p.productId == product.productId &&
            p.branchId == product.branchId,
      ) ??
          product;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SettingsCubit, SettingsState, File?>(
      bloc: cubit,
      selector: (_) => cubit.pendingProductImages[product.productId],
      builder: (context, pendingImage) {
        return ProductInlineEditForm(
          product: _latest(),
          pendingImage: pendingImage,
          onPickImage: (file) =>
              cubit.setProductImage(product.productId!, file),
          onUpdate: (update) => cubit.editProduct(update(_latest())),
        );
      },
    );
  }
}