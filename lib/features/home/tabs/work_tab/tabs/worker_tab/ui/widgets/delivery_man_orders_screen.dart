import 'dart:ui';
import 'package:bakemart/core/shared/widgets/table_cells/worker_cell.dart';
import 'package:collection/collection.dart';
import 'package:action_slider/action_slider.dart';
import 'package:bakemart/core/shared/widgets/faded_screen/faded_screen.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../../../../core/shared/models/order_model.dart';
import '../../../../../../../../core/shared/models/product_model.dart';
import '../../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class DeliveryManOrdersScreen extends StatelessWidget {
  const DeliveryManOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BlocBuilder<DeliverySalesCubit, DeliverySalesState>(
        builder: (context, state) {
          final deliveryCubit = context.read<DeliverySalesCubit>();
          final workerCubit = context.read<WorkerCubit>();
          final total = deliveryCubit.total;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GlassCard(
                  dark: true,
                  margin: .symmetric(horizontal: 15),
                  padding: .symmetric(vertical: 5),
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delivery_dining_outlined,
                            color: context.isDark
                                ? Colors.amber
                                : Colors.orange,
                            size: 22,
                          ),
                          SizedBox(width: 7),
                          Text(
                            "deliveryOrders".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GlassCard(
                  margin: .all(15),
                  padding: .only(bottom: 12),
                  child: SizedBox(
                    height: screenHeight * 0.5,
                    child: (state is Loading || state is ProcessingAll)
                        ? Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: ThemingColors.primaryColor,
                              size: 25,
                            ),
                          )
                        : (state is Failure)
                        ? SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: .center,
                              children: [
                                FadedScreen(
                                  size: 25,
                                  icon: Icons.error_outline,
                                  text: "Try again",
                                  iconColor: ThemingColors.primaryColor,
                                ),
                              ],
                            ),
                          )
                        : (state as Success).orders.isEmpty
                        ? SizedBox(
                            width: .infinity,
                            child: Column(
                              mainAxisAlignment: .center,
                              children: [
                                Text(
                                  "No orders found",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              GlassCard(
                                dark: true,
                                margin: .only(bottom: 10),
                                padding: .symmetric(
                                  horizontal: 20,
                                  vertical: 5,
                                ),
                                child: Directionality(
                                  textDirection:
                                      context.locale.languageCode == "ar"
                                      ? .rtl
                                      : .ltr,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: .only(
                                          right:
                                              context.locale.languageCode ==
                                                  "ar"
                                              ? 0
                                              : 10,
                                          left:
                                              context.locale.languageCode ==
                                                  "ar"
                                              ? 10
                                              : 0,
                                        ),
                                        child: Icon(
                                          Icons.delivery_dining_outlined,
                                          color: context.isDark
                                              ? Colors.amber
                                              : Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      Expanded(
                                        child: WorkerCell(
                                          workerName:
                                              state.orders[0].deliveryManName ??
                                              "",
                                          workerId:
                                              state.orders[0].deliveryManId ??
                                              "",
                                        ),
                                      ),
                                      Container(
                                        padding: .symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: .circular(15),
                                          color: context.isDark
                                              ? ThemingColors.darkGrey
                                              : ThemingColors.lightGrey,
                                        ),
                                        child: Directionality(
                                          textDirection: .ltr,
                                          child: Row(
                                            children: [
                                              Text(
                                                total.toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.green,
                                                  fontWeight: .bold,
                                                ),
                                              ),
                                              Text(
                                                " \$ ",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: context.isDark
                                                      ? ThemingColors.white
                                                      : ThemingColors.black,
                                                  fontWeight: .bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  padding: .only(
                                    right: 10,
                                    left: 10,
                                    bottom: 10,
                                  ),
                                  itemCount: state.orders.length,
                                  separatorBuilder: (_, _) => const SizedBox(),
                                  itemBuilder: (_, orderIndex) {
                                    final OrderModel order =
                                        state.orders[orderIndex];
                                    final double subtotal = deliveryCubit
                                        .getOrdersSubtotal(
                                          state.orders[orderIndex],
                                        );
                                    final scannedOrder = deliveryCubit
                                        .scannedOrders
                                        .firstWhereOrNull(
                                          (o) => o.orderId == order.orderId,
                                        );
                                    return Padding(
                                      padding: .symmetric(vertical: 5),
                                      child: ExpansionTile(
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        backgroundColor: context.isDark
                                            ? ThemingColors.darkGrey.withAlpha(
                                                (0.5 * 255).toInt(),
                                              )
                                            : ThemingColors.lightGrey.withAlpha(
                                                (0.01 * 255).toInt(),
                                              ),
                                        collapsedBackgroundColor: context.isDark
                                            ? ThemingColors.darkGrey
                                            : ThemingColors.lightGrey,
                                        initiallyExpanded:
                                            state.orders.length == 1,
                                        iconColor: ThemingColors.primaryColor,
                                        collapsedIconColor:
                                            ThemingColors.primaryColor,
                                        splashColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: .only(
                                            topLeft: .circular(30),
                                            bottomRight: .circular(30),
                                          ),
                                          side: BorderSide(
                                            width: context.isDark ? 0.7 : 0.8,
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  )
                                                : ThemingColors.black.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  ),
                                          ),
                                        ),
                                        collapsedShape: RoundedRectangleBorder(
                                          borderRadius: .only(
                                            topLeft: .circular(30),
                                            bottomRight: .circular(30),
                                          ),
                                          side: BorderSide(
                                            width: context.isDark ? 0.5 : 0.3,
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                                    (0.3 * 255).toInt(),
                                                  )
                                                : ThemingColors.black.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  ),
                                          ),
                                        ),
                                        title: Row(
                                          children: [
                                            Expanded(
                                              child: WorkerCell(
                                                workerName: state
                                                    .orders[orderIndex]
                                                    .customerName,
                                                workerId: state
                                                    .orders[orderIndex]
                                                    .customerId,
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing:
                                            deliveryCubit
                                                    .editableOrders[orderIndex] ==
                                                deliveryCubit
                                                    .scannedOrders[orderIndex]
                                            ? SizedBox()
                                            : InkWell(
                                                hoverColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  deliveryCubit.resetOrder(
                                                    order.orderId!,
                                                  );
                                                },
                                                child: SizedBox(
                                                  width: 50,
                                                  child: Center(
                                                    child: Icon(Icons.refresh),
                                                  ),
                                                ),
                                              ),
                                        subtitle: Row(
                                          children: [
                                            Text(
                                              'total'.tr(),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                          .withAlpha(
                                                            (0.4 * 255).toInt(),
                                                          )
                                                    : ThemingColors.black
                                                          .withAlpha(
                                                            (0.35 * 255)
                                                                .toInt(),
                                                          ),
                                              ),
                                            ),
                                            Text(
                                              ' : ',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                          .withAlpha(
                                                            (0.4 * 255).toInt(),
                                                          )
                                                    : ThemingColors.black
                                                          .withAlpha(
                                                            (0.35 * 255)
                                                                .toInt(),
                                                          ),
                                              ),
                                            ),
                                            Padding(
                                              padding: .symmetric(
                                                horizontal: 5,
                                              ),
                                              child: Directionality(
                                                textDirection: .ltr,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      subtotal.toStringAsFixed(
                                                        2,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Colors.lightGreen,
                                                      ),
                                                    ),
                                                    Text(
                                                      ' \$ ',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        children: [
                                          ...order.orderedProducts.asMap().entries.map((
                                            entry,
                                          ) {
                                            final int productIndex = entry.key;
                                            final ProductModel product =
                                                entry.value;

                                            final int quantity =
                                                productIndex <
                                                    order
                                                        .orderedQuantities
                                                        .length
                                                ? order
                                                      .orderedQuantities[productIndex]
                                                : 0;

                                            final double productTotal =
                                                product.productPrice * quantity;

                                            final int originalQuantity = () {
                                              if (scannedOrder == null) {
                                                return 0;
                                              }
                                              final int originalIndex =
                                                  scannedOrder.orderedProducts
                                                      .indexWhere(
                                                        (p) =>
                                                            p.productId ==
                                                            product.productId,
                                                      );
                                              if (originalIndex == -1 ||
                                                  originalIndex >=
                                                      scannedOrder
                                                          .orderedQuantities
                                                          .length) {
                                                return 0;
                                              }
                                              return scannedOrder
                                                  .orderedQuantities[originalIndex];
                                            }();
                                            final bool isThisQuantityChanged =
                                                quantity != originalQuantity;
                                            return Column(
                                              children: [
                                                Padding(
                                                  padding: .symmetric(
                                                    vertical: 8,
                                                    horizontal: 5,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding: .only(
                                                                left:
                                                                    context
                                                                            .locale
                                                                            .languageCode ==
                                                                        "ar"
                                                                    ? 0
                                                                    : 10,
                                                                right:
                                                                    context
                                                                            .locale
                                                                            .languageCode ==
                                                                        "ar"
                                                                    ? 10
                                                                    : 0,
                                                              ),
                                                              child: CircleAvatar(
                                                                radius: 18,
                                                                backgroundColor: ThemingColors
                                                                    .primaryColor
                                                                    .withAlpha(
                                                                      (0.12 * 255)
                                                                          .toInt(),
                                                                    ),
                                                                child: ClipOval(
                                                                  child: SupabaseImageProvider(
                                                                    filePath:
                                                                        Buckets
                                                                            .productsImages,
                                                                    fileName:
                                                                        product
                                                                            .productId,
                                                                    iconSize:
                                                                        16,
                                                                    loadingIconSize:
                                                                        14,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 15),
                                                            InkWell(
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder: (context) {
                                                                    return ProductDetailsScreen(
                                                                      product:
                                                                          product,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 150,
                                                                    child: Row(
                                                                      children: [
                                                                        Flexible(
                                                                          child: Text(
                                                                            product.productName,
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                .ellipsis,
                                                                            style: TextStyle(
                                                                              fontSize: 12,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        Directionality(
                                                                          textDirection:
                                                                              .ltr,
                                                                          child: Row(
                                                                            children: [
                                                                              Text(
                                                                                "(${product.productPrice.toStringAsFixed(2)}",
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: context.isDark
                                                                                      ? ThemingColors.white.withAlpha(
                                                                                          (0.5 *
                                                                                                  255)
                                                                                              .toInt(),
                                                                                        )
                                                                                      : ThemingColors.black.withAlpha(
                                                                                          (0.4 *
                                                                                                  255)
                                                                                              .toInt(),
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                " \$)",
                                                                                style: TextStyle(
                                                                                  fontSize: 12,
                                                                                  color: context.isDark
                                                                                      ? ThemingColors.white.withAlpha(
                                                                                          (0.5 *
                                                                                                  255)
                                                                                              .toInt(),
                                                                                        )
                                                                                      : ThemingColors.black.withAlpha(
                                                                                          (0.4 *
                                                                                                  255)
                                                                                              .toInt(),
                                                                                        ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Directionality(
                                                                    textDirection:
                                                                        .ltr,
                                                                    child: Row(
                                                                      children: [
                                                                        Text(
                                                                          productTotal.toStringAsFixed(
                                                                            2,
                                                                          ),
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                context.isDark
                                                                                ? Colors.lightGreen
                                                                                : Colors.green,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          " \$",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                14,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.white
                                                                                : ThemingColors.black,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: .only(
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
                                                        child: Row(
                                                          children: [
                                                            (quantity == 1)
                                                                ? InkWell(
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      deliveryCubit.removeProductFromOrder(
                                                                        orderId:
                                                                            order.orderId!,
                                                                        productToRemove:
                                                                            product,
                                                                      );
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .delete_sweep_outlined,
                                                                      size: 17,
                                                                      color: Colors
                                                                          .redAccent,
                                                                    ),
                                                                  )
                                                                : InkWell(
                                                                    hoverColor:
                                                                        Colors
                                                                            .transparent,
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      deliveryCubit.decreaseQuantity(
                                                                        order:
                                                                            order,
                                                                        productIndex:
                                                                            productIndex,
                                                                      );
                                                                    },
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove,
                                                                      size: 17,
                                                                      color: ThemingColors
                                                                          .primaryColor,
                                                                    ),
                                                                  ),
                                                            SizedBox(width: 20),
                                                            Text(
                                                              "$quantity",
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                color:
                                                                    isThisQuantityChanged
                                                                    ? null
                                                                    : (context.isDark
                                                                          ? ThemingColors.white.withAlpha(
                                                                              (0.25 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            )
                                                                          : ThemingColors.black.withAlpha(
                                                                              (0.2 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            )),
                                                              ),
                                                            ),
                                                            SizedBox(width: 20),
                                                            InkWell(
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              onTap: () {
                                                                if (quantity <
                                                                    originalQuantity) {
                                                                  deliveryCubit.increaseQuantity(
                                                                    order:
                                                                        order,
                                                                    productIndex:
                                                                        productIndex,
                                                                  );
                                                                }
                                                              },
                                                              child: Icon(
                                                                Icons.add,
                                                                size: 17,
                                                                color:
                                                                    quantity <
                                                                        originalQuantity
                                                                    ? ThemingColors
                                                                          .primaryColor
                                                                    : ThemingColors
                                                                          .primaryColor
                                                                          .withAlpha(
                                                                            (0.2 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (productIndex <
                                                    order
                                                            .orderedProducts
                                                            .length -
                                                        1)
                                                  Padding(
                                                    padding: .symmetric(
                                                      vertical: 4,
                                                    ),
                                                    child: Container(
                                                      height: 0.1,
                                                      width: screenWidth * 0.45,
                                                      color: context.isDark
                                                          ? ThemingColors
                                                                .lightGrey
                                                          : ThemingColors
                                                                .darkGrey,
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }),
                                          Directionality(
                                            textDirection: .ltr,
                                            child: Padding(
                                              padding: .symmetric(
                                                horizontal: 15,
                                                vertical: 20,
                                              ),
                                              child: ActionSlider.dual(
                                                boxShadow: [],
                                                height: 35,
                                                loadingIcon:
                                                    LoadingAnimationWidget.staggeredDotsWave(
                                                      color: context.isDark
                                                          ? Colors.lightGreen
                                                          : Colors.green,
                                                      size: 16,
                                                    ),
                                                successIcon: Icon(
                                                  Icons.check_circle_outline,
                                                  color: context.isDark
                                                      ? Colors.lightGreen
                                                      : Colors.green,
                                                ),
                                                failureIcon: Icon(
                                                  Icons.error_outline,
                                                  color: Colors.redAccent,
                                                ),
                                                backgroundBorderRadius: .only(
                                                  topRight: .circular(30),
                                                  bottomLeft: .circular(30),
                                                ),
                                                foregroundBorderRadius: .only(
                                                  topRight: .circular(30),
                                                  bottomLeft: .circular(30),
                                                ),
                                                backgroundColor: context.isDark
                                                    ? ThemingColors.white
                                                          .withAlpha(
                                                            (0.1 * 255).toInt(),
                                                          )
                                                    : ThemingColors.black
                                                          .withAlpha(
                                                            (0.06 * 255)
                                                                .toInt(),
                                                          ),
                                                toggleColor: Colors.transparent,
                                                startChild: Padding(
                                                  padding: .only(right: 90),
                                                  child: Icon(
                                                    Icons.delete_sweep_outlined,
                                                    color: context.isDark
                                                        ? Colors.redAccent
                                                              .withAlpha(
                                                                (0.6 * 255)
                                                                    .toInt(),
                                                              )
                                                        : Colors.redAccent
                                                              .withAlpha(
                                                                (0.4 * 255)
                                                                    .toInt(),
                                                              ),
                                                    fontWeight: .bold,
                                                    size: 20,
                                                  ),
                                                ),
                                                endChild: Padding(
                                                  padding: .only(left: 90),
                                                  child: Icon(
                                                    Icons.check_circle_outline,
                                                    color: context.isDark
                                                        ? Colors.lightGreen
                                                              .withAlpha(
                                                                (0.5 * 255)
                                                                    .toInt(),
                                                              )
                                                        : Colors.lightGreen
                                                              .withAlpha(
                                                                (0.7 * 255)
                                                                    .toInt(),
                                                              ),
                                                    fontWeight: .bold,
                                                    size: 20,
                                                  ),
                                                ),
                                                borderWidth: 0,
                                                icon: Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  padding: .only(left: 3),
                                                  decoration: BoxDecoration(
                                                    color: ThemingColors
                                                        .primaryColor,
                                                    borderRadius: .only(
                                                      topRight: .circular(15),
                                                      bottomLeft: .circular(15),
                                                    ),
                                                    border: Border.all(
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                )
                                                          : ThemingColors.black
                                                                .withAlpha(
                                                                  (0.3 * 255)
                                                                      .toInt(),
                                                                ),
                                                      width: 1,
                                                    ),
                                                    gradient: LinearGradient(
                                                      end:
                                                          Alignment.bottomRight,
                                                      begin: Alignment.topLeft,
                                                      colors: [
                                                        context.isDark
                                                            ? Colors.white
                                                                  .withAlpha(
                                                                    (0.08 * 255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.black
                                                                  .withAlpha(
                                                                    (0.03 * 255)
                                                                        .toInt(),
                                                                  ),
                                                        context.isDark
                                                            ? Colors.white
                                                                  .withAlpha(
                                                                    (0.03 * 255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.black
                                                                  .withAlpha(
                                                                    (0.01 * 255)
                                                                        .toInt(),
                                                                  ),
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: context.isDark
                                                            ? Colors.white
                                                                  .withAlpha(
                                                                    (0.1 * 255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.black
                                                                  .withAlpha(
                                                                    (0.1 * 255)
                                                                        .toInt(),
                                                                  ),
                                                        blurRadius: 10,
                                                        spreadRadius: -2,
                                                        offset: Offset(5, -5),
                                                      ),
                                                      BoxShadow(
                                                        color: context.isDark
                                                            ? Colors.black
                                                                  .withAlpha(
                                                                    (0.4 * 255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.white
                                                                  .withAlpha(
                                                                    (0.4 * 255)
                                                                        .toInt(),
                                                                  ),
                                                        blurRadius: 20,
                                                        spreadRadius: 2,
                                                        offset: Offset(15, 8),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        .spaceAround,
                                                    children: [
                                                      Icon(
                                                        Icons.arrow_back_ios,
                                                        size: 10,
                                                        fontWeight: .bold,
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 10,
                                                        fontWeight: .bold,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                startAction:
                                                    (controller) async {
                                                      deliveryCubit.removeOrder(
                                                        order: order,
                                                      );
                                                      if (deliveryCubit
                                                              .editableOrders
                                                              .isEmpty &&
                                                          context.mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                endAction: (controller) async {
                                                  controller.loading();
                                                  final handOver =
                                                      await deliveryCubit
                                                          .handOneOrder(
                                                            order: order,
                                                            bakeryId:
                                                                workerCubit
                                                                    .bakery!
                                                                    .bakeryId,
                                                            branchId:
                                                                workerCubit
                                                                    .bakery!
                                                                    .branchId,
                                                          );
                                                  if (handOver) {
                                                    controller.success();
                                                    await Future.delayed(
                                                      Duration(seconds: 1),
                                                    );
                                                    deliveryCubit
                                                        .removeOrderWithoutChangingTotal(
                                                          order: order,
                                                        );
                                                    await workerCubit
                                                        .updateProducts(
                                                          workerCubit
                                                              .bakery!
                                                              .bakeryId,
                                                          workerCubit
                                                              .bakery!
                                                              .branchId,
                                                        ); // add this
                                                    controller.reset();
                                                    if (deliveryCubit
                                                            .editableOrders
                                                            .isEmpty &&
                                                        context.mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                  } else {
                                                    controller.failure();
                                                    await Future.delayed(
                                                      Duration(seconds: 2),
                                                    );
                                                    controller.reset();
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: Row(
                    children:
                        (state is Failure ||
                            ((state is Success) && state.orders.isEmpty))
                        ? [
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () => Navigator.pop(context),
                                child: GlassCard(
                                  margin: .symmetric(horizontal: 15),
                                  padding: .zero,
                                  child: SizedBox(
                                    height: 30,
                                    child: Row(
                                      mainAxisSize: .max,
                                      mainAxisAlignment: .center,
                                      children: [
                                        Icon(
                                          Icons.arrow_back,
                                          size: 18,
                                          color: ThemingColors.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]
                        : [
                            InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () => Navigator.pop(context),
                              child: GlassCard(
                                margin: context.locale.languageCode == "ar"
                                    ? .only(right: 15)
                                    : .only(left: 15),
                                padding: .symmetric(horizontal: 15),
                                child: SizedBox(
                                  height: 30,
                                  child: Row(
                                    mainAxisSize: .max,
                                    mainAxisAlignment: .center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back,
                                        size: 18,
                                        color: ThemingColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: InkWell(
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: (state is ProcessingAll)
                                    ? null
                                    : () async {
                                        final ordersSnapshot =
                                            List<OrderModel>.from(
                                              deliveryCubit.editableOrders,
                                            );
                                        if (ordersSnapshot.isEmpty) {
                                          Navigator.pop(context);
                                          return;
                                        }
                                        await deliveryCubit.handAllOrders(
                                          orders: ordersSnapshot,
                                          bakeryId:
                                              workerCubit.bakery!.bakeryId,
                                          branchId:
                                              workerCubit.bakery!.branchId,
                                        );
                                        await workerCubit.updateProducts(
                                          workerCubit.bakery!.bakeryId,
                                          workerCubit.bakery!.branchId,
                                        );
                                        await workerCubit.updateFinance(
                                          workerCubit.bakery!.bakeryId,
                                          workerCubit.bakery!.branchId,
                                        );
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                child: GlassCard(
                                  margin: context.locale.languageCode == "ar"
                                      ? .only(left: 15)
                                      : .only(right: 15),
                                  padding: .zero,
                                  child: SizedBox(
                                    height: 30,
                                    child: (state is ProcessingAll)
                                        ? Center(
                                            child:
                                                LoadingAnimationWidget.staggeredDotsWave(
                                                  color: ThemingColors
                                                      .primaryColor,
                                                  size: 20,
                                                ),
                                          )
                                        : Row(
                                            mainAxisSize: .max,
                                            mainAxisAlignment: .center,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                color: context.isDark
                                                    ? Colors.lightGreen
                                                    : Colors.green,
                                                size: 18,
                                              ),
                                              Padding(
                                                padding: .symmetric(
                                                  horizontal: 5,
                                                ),
                                                child: Text(
                                                  "all".tr(),
                                                  textAlign: .center,
                                                  style: TextStyle(
                                                    fontWeight: .bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
