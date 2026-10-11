import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/features/bakery_details/ui/widgets/product_counter.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../core/theming/theming_colors.dart';
import '../../../../core/utils/enums/buckts.dart';
import '../../../../core/utils/extensions/context_extensions.dart';

class ProductListTile extends StatelessWidget {
  final HomeDataBakeriesModel bakery;
  final int index;

  const ProductListTile({required this.bakery, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder: (context) {
            final product = bakery.productModelList[index];
            return ProductDetailsScreen(product: product);
          },
        );
      },
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Row(
          children: [
            Padding(
              padding: .only(right: 10),
              child: Icon(
                Icons.info_outline,
                size: 15,
                color: ThemingColors.primaryColor,
              ),
            ),
            Padding(
              padding: .only(right: 20),
              child: CircleAvatar(
                backgroundColor: ThemingColors.primaryColor.withAlpha(
                  (0.3 * 255).toInt(),
                ),
                child: ClipOval(
                  child: SupabaseImageProvider(
                    filePath: Buckets.productsImages,
                    fileName: bakery.productModelList[index].productId,
                    loadingIconSize: 14,
                    iconSize: 14,
                    addIconSize: 14,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        children: [
                          Text(
                            bakery.productModelList[index].productName,
                            style: TextStyle(fontWeight: .bold),
                          ),
                          SizedBox(width: 10),
                          Text(
                            bakery.productModelList[index].productPrice
                                .toString(),
                            style: TextStyle(fontSize: 12, color: Colors.green),
                          ),
                          Text(" \$", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 7),
                      Row(
                        children: [
                          Padding(
                            padding: .only(right: 5),
                            child: Text(
                              bakery.productModelList[index].rate.toStringAsFixed(
                                1,
                              ),
                              style: TextStyle(fontSize: 12, fontWeight: .bold),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (starIndex) {
                              final double rate =
                                  bakery.productModelList[index].rate;
                              final double starValue = rate - starIndex;

                              if (starValue >= 0.95) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 13,
                                );
                              } else if (starValue >= 0.05) {
                                return const Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                  size: 13,
                                );
                              } else {
                                return const Icon(
                                  Icons.star_border,
                                  color: Colors.amber,
                                  size: 13,
                                );
                              }
                            }),
                          ),
                          Padding(
                            padding: .symmetric(horizontal: 15),
                            child: Icon(
                              Icons.circle,
                              size: 7,
                              color: ThemingColors.primaryColor.withAlpha(
                                (0.3 * 255).toInt(),
                              ),
                            ),
                          ),
                          Directionality(
                            textDirection: context.locale.languageCode == 'ar'
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                            child: Row(
                              children: [
                                Text(
                                  bakery.productModelList[index].productWeight
                                      .truncate()
                                      .toString(),
                                  style: TextStyle(fontSize: 12, fontWeight: .bold),
                                ),
                                Padding(
                                  padding:.symmetric(horizontal: 7),
                                  child: Text(
                                    "gram".tr(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: context.isDark
                                          ? Colors.amber
                                          : Colors.orange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: .only(left: 15, right: 8),
              child: IconButton(
                onPressed: () {
                  final isAdded = context.read<CartCubit>().isInCart(
                    bakery.productModelList[index].productId!,
                  );
                  if (isAdded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GlassCard(
                                margin: EdgeInsets.zero,
                                padding: .symmetric(
                                  vertical: 7,
                                  horizontal: 20,
                                ),
                                otherRadius: 30,
                                dark: true,
                                child: Text(
                                  "alreadyInCart".tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: context.isDark
                                        ? ThemingColors.white
                                        : ThemingColors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                    );
                    return;
                  }
                  showModalBottomSheet(
                    barrierColor:Colors.transparent,
                    backgroundColor:Colors.transparent,
                    context: context,
                    builder: (context) {
                      return BlocProvider.value(
                        value: DependencyInjection.getIt<CartCubit>(),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: context.isDark ? 15 : 8,
                            sigmaY: context.isDark ? 15 : 8,
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color:
                                    (context.isDark ? Colors.white : Colors.black)
                                        .withAlpha((0.1 * 255).toInt()),
                                width: 2,
                              ),
                            ),
                            child: ProductCounter(bakery: bakery, index: index),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    final isAdded = context.read<CartCubit>().isInCart(
                      bakery.productModelList[index].productId!,
                    );
                    return Icon(
                      Icons.shopping_cart_outlined,
                      color: isAdded ? Colors.grey : ThemingColors.primaryColor,
                      size: 20,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
