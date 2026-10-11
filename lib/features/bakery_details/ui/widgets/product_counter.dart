import 'dart:ui' as ui;

import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../core/shared/models/home_screen_model.dart';
import '../../../../core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../core/theming/theming_colors.dart';
import '../../../../core/utils/enums/buckts.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/quantity_counter_cubit/quantity_counter_cubit.dart';

class ProductCounter extends StatelessWidget {
  final HomeDataBakeriesModel bakery;
  final int index;

  const ProductCounter({required this.bakery, required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DependencyInjection.getIt<QuantityCounterCubit>(),
      child: BlocBuilder<QuantityCounterCubit, int>(
        builder: (context, counter) {
          return Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Column(
              mainAxisSize: .min,
              children: [
                Container(
                  margin: .only(top: 20),
                  width: 45,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? ThemingColors.white.withAlpha((0.2 * 255).toInt())
                        : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                SizedBox(height: 30),
                CircleAvatar(
                  radius: 20,
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
                SizedBox(height: 7),
                Text(
                  bakery.productModelList[index].productName,
                  style: TextStyle(fontSize: 12, fontWeight: .bold),
                ),
                SizedBox(height: 30),
                Container(
                  margin: .symmetric(horizontal: 10),
                  padding: .all(15),
                  decoration: BoxDecoration(
                    color: context.isDark
                        ? ThemingColors.black.withAlpha((0.8 * 255).toInt())
                        : ThemingColors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: .all(
                      width: 1,
                      color: context.isDark
                          ? ThemingColors.white.withAlpha((0.15*255).toInt())
                          : ThemingColors.black.withAlpha((0.15*255).toInt()),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: .only(right: 35),
                            child: TransparentButton(
                              onTap: () {
                                context.read<QuantityCounterCubit>().minusTen();
                              },
                              onLongPress: () {
                                context
                                    .read<QuantityCounterCubit>()
                                    .minusHundred();
                              },
                              buttonWidget: Text(
                                "-10",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemingColors.primaryColor,
                                ),
                              ),
                              buttonHorizontalPading: 0,
                              isCircle: true,
                              buttonSize: 35,
                            ),
                          ),
                          TransparentButton(
                            onTap: () {
                              context.read<QuantityCounterCubit>().minusOne();
                            },
                            icon: Icons.remove,
                            buttonHorizontalPading: 0,
                            isCircle: true,
                            size: 16,
                            buttonSize: 16,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Text(
                          counter.toString(),
                          textAlign: .center,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      Row(
                        children: [
                          TransparentButton(
                            onTap: () {
                              context.read<QuantityCounterCubit>().plusOne();
                            },
                            icon: Icons.add,
                            buttonHorizontalPading: 0,
                            isCircle: true,
                            size: 16,
                            buttonSize: 16,
                          ),
                          Padding(
                            padding: .only(left: 35),
                            child: TransparentButton(
                              onTap: () {
                                context.read<QuantityCounterCubit>().plusTen();
                              },
                              onLongPress: () {
                                context
                                    .read<QuantityCounterCubit>()
                                    .plusHundred();
                              },
                              buttonWidget: Text(
                                "+10",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ThemingColors.primaryColor,
                                ),
                              ),
                              buttonHorizontalPading: 0,
                              isCircle: true,
                              buttonSize: 35,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                InkWell(
                  onTap: () {
                    if (counter >= 1) {
                      context.read<CartCubit>().addToCart(
                        bakery: bakery.bakeryModel,
                        product: bakery.productModelList[index],
                        quantity: counter,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "addToCart".tr(),
                    style: TextStyle(
                      color: ThemingColors.primaryColor,
                      fontWeight: .bold,
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
    );
  }
}
