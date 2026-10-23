import 'dart:ui';

import 'package:bakemart/core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import 'package:bakemart/core/shared/widgets/cart/ui/widgets/order_tile.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../theming/theming_colors.dart';
import '../../../../utils/extensions/context_extensions.dart';
import '../../../cubits/location_cubit/location_cubit.dart';
import '../../../cubits/location_cubit/location_state.dart';
import '../../../models/bakery_model.dart';
import '../../../models/cart.dart';
import '../../../models/product_model.dart';
import '../../location_picker_map/location_picker_map.dart';
import '../../text_form_field/text_form_field.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CartCubit>();
    final locationState = context.read<LocationCubit>().state;
    final double? liveLat = locationState is LocationUpdated
        ? locationState.lat
        : null;
    final double? liveLng = locationState is LocationUpdated
        ? locationState.lng
        : null;
    return BlocListener<CartCubit, CartState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
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
                      green: true,
                      child: Text(
                        "orderPlacedSuccsessfully".tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
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
        } else if (state is LocationError) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
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
                      orange: true,
                      child: Text(
                        "failedFetchingYourLocation".tr(),
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: .bold,
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
        }
      },
      child: Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        margin: const EdgeInsets.all(15),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        dark: true,
                        responsive: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "cart".tr(),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: ThemingColors.primaryColor,
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: BlocBuilder<CartCubit, CartState>(
                      builder: (context, state) {
                        if (state is CartInitial) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GlassCard(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                responsive: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GlassCard(
                                          margin: EdgeInsets.zero,
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 20,
                                            right: 20,
                                            bottom: 10,
                                          ),
                                          dark: true,
                                          responsive: true,
                                          child: Text(
                                            "bill".tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 15,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons.sell_outlined,
                                                      size: 14,
                                                      color: context.isDark
                                                          ? Colors.cyan
                                                          : Colors.teal,
                                                    ),
                                                  ),
                                                  Text(
                                                    "totalOrderPrice".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: const [
                                                  Text(
                                                    "00.00",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .delivery_dining_outlined,
                                                      size: 14,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                  Text(
                                                    "deliveryFee".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: const [
                                                  Text(
                                                    "00.00",
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .receipt_long_outlined,
                                                      size: 14,
                                                      color: ThemingColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "total".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: const [
                                                  Text(
                                                    "00.00",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GlassCard(
                                padding: .zero,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                responsive: true,
                                child: SizedBox(
                                  height: 475,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          GlassCard(
                                            margin: EdgeInsets.zero,
                                            padding: const EdgeInsets.only(
                                              top: 5,
                                              left: 20,
                                              right: 20,
                                              bottom: 10,
                                            ),
                                            dark: true,
                                            responsive: true,
                                            child: Text(
                                              "order".tr(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          Icon(
                                            Icons.shopping_cart_outlined,
                                            color: ThemingColors.primaryColor
                                                .withAlpha(
                                                  (0.14 * 255).toInt(),
                                                ),
                                            size: 80,
                                          ),
                                          Text(
                                            "cartIsEmpty".tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else if (state is CartUpdated ||
                            state is PlacingOrder) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassCard(
                                margin: EdgeInsets.zero,
                                padding: EdgeInsets.zero,
                                responsive: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        GlassCard(
                                          margin: EdgeInsets.zero,
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            left: 20,
                                            right: 20,
                                            bottom: 10,
                                          ),
                                          dark: true,
                                          responsive: true,
                                          child: Text(
                                            "bill".tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 15,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons.sell_outlined,
                                                      size: 14,
                                                      color: context.isDark
                                                          ? Colors.cyan
                                                          : Colors.teal,
                                                    ),
                                                  ),
                                                  Text(
                                                    "totalOrderPrice".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    cubit.cart.orderPrice
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .delivery_dining_outlined,
                                                      size: 14,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                  Text(
                                                    "deliveryFee".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    cubit.cart.deliveryFee
                                                        .toStringAsFixed(2),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                      right:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 0
                                                          : 10,
                                                      left:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 10
                                                          : 0,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .receipt_long_outlined,
                                                      size: 14,
                                                      color: ThemingColors
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  Text(
                                                    "total".tr(),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    cubit.cart.totalBill
                                                        .toStringAsFixed(2),
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!cubit.mapOpen)
                                SizedBox(
                                  height: 475,
                                  child: GlassCard(
                                    padding: EdgeInsets.zero,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                    responsive: true,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            GlassCard(
                                              margin: EdgeInsets.zero,
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                                left: 20,
                                                right: 20,
                                                bottom: 10,
                                              ),
                                              dark: true,
                                              responsive: true,
                                              child: Text(
                                                "order".tr(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                              top: 10,
                                              right: 15,
                                              left: 15,
                                              bottom: 10,
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              itemBuilder: (_, index) {
                                                final String branchId = cubit.cart.bakeries.keys.elementAt(index);
                                                final BakeryModel bakery = cubit.cart.bakeries[branchId]!;

                                                final List<ProductModel> bakeryProducts = cubit.cart.products.values
                                                    .where((product) => product.branchId == branchId)
                                                    .toList();

                                                final double bakeryTotal = bakeryProducts.fold(0.0, (sum, p) {
                                                  return sum +
                                                      (p.productPrice *
                                                          (cubit.cart.quantities[Cart.itemKey(p.productId!, p.branchId)] ??
                                                              0));
                                                });
                                                return Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: OrderTile(
                                                    initiallyExpanded: false,
                                                    bakery: bakery,
                                                    bakeryTotal: bakeryTotal,
                                                    bakeryProducts: bakeryProducts,
                                                    cart: cubit.cart,
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (_, _) {
                                                return const SizedBox();
                                              },
                                              itemCount:
                                                  cubit.cart.bakeries.length,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (cubit.mapOpen)
                                Column(
                                  children: [
                                    Container(
                                      height: 235,
                                      margin: const EdgeInsets.only(
                                        left: 5,
                                        right: 5,
                                        bottom: 10,
                                        top: 15,
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        color: ThemingColors.primaryColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: LocationPickerMap.setter(
                                        initialLat: cubit.cart.userLat,
                                        initialLng: cubit.cart.userLng,
                                        deviceLat: liveLat,
                                        deviceLng: liveLng,
                                        alwaysShow: false,
                                        hideWhenRecenter: false,
                                        hideOnSet: true,
                                        alwaysShowPin: true,
                                        onSet: (lat, lng) {
                                          cubit.setLocation(lat: lat, lng: lng);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: GlassCard(
                                        margin: .zero,
                                        padding: .zero,
                                        responsive: true,
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                GlassCard(
                                                  margin: .zero,
                                                  padding: .only(
                                                    top: 5,
                                                    left: 20,
                                                    right: 20,
                                                    bottom: 10,
                                                  ),
                                                  dark: true,
                                                  responsive: true,
                                                  child: Text(
                                                    "address".tr(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: .all(25),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: 35,
                                                    child: CustomTextFormField(
                                                      "street".tr(),
                                                      controller: cubit
                                                          .streetController,
                                                    ),
                                                  ),
                                                  SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 35,
                                                          child: CustomTextFormField(
                                                            "building".tr(),
                                                            controller: cubit
                                                                .buildingController,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Expanded(
                                                        child: SizedBox(
                                                          height: 35,
                                                          child: CustomTextFormField(
                                                            "house".tr(),
                                                            controller: cubit
                                                                .apartmentController,
                                                          ),
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
                                    SizedBox(height: 15),
                                  ],
                                ),
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  cubit.setMapOpen();
                                },
                                child: GlassCard(
                                  margin: .only(bottom: 15),
                                  padding: .zero,
                                  responsive: true,
                                  child: SizedBox(
                                    height: 30,
                                    child: Center(
                                      child: Text(
                                        cubit.mapOpen
                                            ? "done".tr()
                                            : "confirmLocation".tr(),
                                        style: TextStyle(
                                          color: ThemingColors.primaryColor,
                                          fontSize: 12,
                                          fontWeight: .bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    if (cartState is CartInitial) {
                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  cubit.closeMap();
                                  Navigator.pop(context);
                                },
                                child: GlassCard(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  padding: EdgeInsets.zero,
                                  child: Icon(
                                    Icons.arrow_downward,
                                    size: 18,
                                    fontWeight: FontWeight.bold,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: cubit.mapOpen
                          ? [SizedBox(height: 30)]
                          : [
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  cubit.closeMap();
                                  Navigator.pop(context);
                                },
                                child: SizedBox(
                                  width: 90,
                                  height: 30,
                                  child: GlassCard(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),
                                    responsive: true,
                                    child: Icon(
                                      Icons.arrow_downward,
                                      size: 18,
                                      fontWeight: FontWeight.bold,
                                      color: ThemingColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(
                                  height: 30,
                                  child: InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      if (cartState is CartUpdated) {
                                        context.read<CartCubit>().placeOrder();
                                      }
                                    },
                                    child: GlassCard(
                                      margin: EdgeInsets.zero,
                                      padding: EdgeInsets.zero,
                                      responsive: true,
                                      child: BlocBuilder<CartCubit, CartState>(
                                        builder: (context, state) {
                                          return (state is PlacingOrder)
                                              ? SizedBox(
                                                  child: Center(
                                                    child:
                                                        LoadingAnimationWidget.staggeredDotsWave(
                                                          color: Colors.green,
                                                          size: 25,
                                                        ),
                                                  ),
                                                )
                                              : Center(
                                                  child: Text(
                                                    "placeOrder".tr(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    context.read<CartCubit>().clearCart();
                                  },
                                  child: SizedBox(
                                    height: 30,
                                    child: GlassCard(
                                      margin:
                                          context.locale.languageCode == "ar"
                                          ? .only(left: 15)
                                          : .only(right: 15),
                                      padding: EdgeInsets.zero,
                                      responsive: true,
                                      child: Center(
                                        child: Text(
                                          "clearCart".tr(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
