import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/cart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../theming/theming_colors.dart';
import '../../../../../utils/enums/buckts.dart';
import '../../../../../utils/extensions/context_extensions.dart';
import '../../../../models/product_model.dart';
import '../../../product_details_screen/product_details_screen.dart';
import '../../../supabase_image/ui/supabase_image.dart';
import '../../logic/cart_cubit/cart_cubit.dart';

class OrderTile extends StatelessWidget {
  final bool initiallyExpanded;
  final BakeryModel bakery;
  final double bakeryTotal;
  final List<ProductModel> bakeryProducts;
  final Cart cart;

  const OrderTile({
    required this.initiallyExpanded,
    required this.bakery,
    required this.bakeryTotal,
    required this.bakeryProducts,
    required this.cart,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return ExpansionTile(
      backgroundColor: context.isDark
          ? Colors.transparent
          : ThemingColors.white.withAlpha((0.6 * 255).toInt()),
      collapsedBackgroundColor: context.isDark
          ? ThemingColors.darkGrey
          : ThemingColors.white,
      initiallyExpanded: initiallyExpanded,
      iconColor: ThemingColors.secondaryColor,
      collapsedIconColor: ThemingColors.primaryColor,
      splashColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: context.locale.languageCode == "ar"
            ? .only(topRight: .circular(30), bottomLeft: .circular(30))
            : .only(topLeft: .circular(30), bottomRight: .circular(30)),
        side: BorderSide(
          width: context.isDark ? 0.8 : 1.5,
          color: context.isDark
              ? ThemingColors.white.withAlpha((0.5 * 255).toInt())
              : ThemingColors.black.withAlpha((0.4 * 255).toInt()),
        ),
      ),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: context.locale.languageCode == "ar"
            ? .only(topRight: .circular(30), bottomLeft: .circular(30))
            : .only(topLeft: .circular(30), bottomRight: .circular(30)),
        side: BorderSide(
          width: context.isDark ? 0.6 : 0.4,
          color: context.isDark
              ? ThemingColors.white.withAlpha((0.3 * 255).toInt())
              : ThemingColors.black.withAlpha((0.5 * 255).toInt()),
        ),
      ),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: context.locale.languageCode == "ar"
              ? .only(topRight: .circular(20), bottomLeft: .circular(20))
              : .only(topLeft: .circular(20), bottomRight: .circular(20)),
          color: ThemingColors.primaryColor.withAlpha((0.1 * 255).toInt()),
        ),
        child: ClipRRect(
          borderRadius: context.locale.languageCode == "ar"
              ? .only(topRight: .circular(20), bottomLeft: .circular(20))
              : .only(topLeft: .circular(20), bottomRight: .circular(20)),
          child: SupabaseImageProvider(
            filePath: Buckets.bakeriesImages,
            fileName: bakery.bakeryId,
            addIconSize: 24,
            cacheWidth: 75,
            cacheHeight: 75,
          ),
        ),
      ),
      title: Text(
        bakery.bakeryName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Row(
        children: [
          Text('total'.tr(), style: TextStyle(fontSize: 10, fontWeight: .bold)),
          Text(':', style: TextStyle(fontSize: 10, fontWeight: .bold)),
          Padding(
            padding: .symmetric(horizontal: 5),
            child: RichText(
              textDirection: .ltr,
              text: TextSpan(
                text: bakeryTotal.toStringAsFixed(2),
                style: TextStyle(color: Colors.green, fontSize: 12),
                children: [
                  TextSpan(
                    text: " \$ ",
                    style: TextStyle(
                      color: context.isDark
                          ? ThemingColors.lightGrey
                          : ThemingColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      children: bakeryProducts.asMap().entries.map((entry) {
        final int productIndex = entry.key;
        final ProductModel product = entry.value;
        final int quantity = cart.quantities[product.productId] ?? 0;
        final double productTotal = product.productPrice * quantity;

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ProductDetailsScreen(product: product);
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Padding(
                            padding: context.locale.languageCode == "ar"
                                ? .only(right: 30)
                                : .only(left: 30),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: ThemingColors.primaryColor
                                      .withAlpha((0.12 * 255).toInt()),
                                  child: ClipOval(
                                    child: SupabaseImageProvider(
                                      filePath: Buckets.productsImages,
                                      fileName: product.productId,
                                      addIconSize: 14,
                                      loadingIconSize: 14,
                                      iconSize: 14,
                                      cacheWidth: 75,
                                      cacheHeight: 75,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${product.productName} (${product.productPrice.toStringAsFixed(2)}\$)",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(height: 4),
                                    RichText(
                                      textDirection: .ltr,
                                      text: TextSpan(
                                        text: productTotal.toStringAsFixed(2),
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: " \$ ",
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.lightGrey
                                                  : ThemingColors.darkGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          context.read<CartCubit>().updateQuantity(
                            productId: product.productId!,
                            quantity: quantity - 1,
                          );
                        },
                        child: Icon(
                          quantity == 1
                              ? Icons.delete_sweep_outlined
                              : Icons.remove,
                          size: 17,
                          color: ThemingColors.primaryColor,
                        ),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(
                          '$quantity',
                          textAlign: .center,
                          style: TextStyle(fontSize: 16, fontWeight: .bold),
                        ),
                      ),
                      Padding(
                        padding: context.locale.languageCode == "ar"
                            ? .only(left: 10)
                            : .only(right: 10),
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            context.read<CartCubit>().updateQuantity(
                              productId: product.productId!,
                              quantity: quantity + 1,
                            );
                          },
                          child: Icon(
                            Icons.add,
                            size: 17,
                            color: ThemingColors.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (productIndex < bakeryProducts.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Container(
                  height: 0.1,
                  width: screenWidth * 0.45,
                  color: context.isDark
                      ? ThemingColors.lightGrey
                      : ThemingColors.darkGrey,
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
