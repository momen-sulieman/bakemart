import 'dart:ui';

import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../../../core/routing/app_routes.dart';
import '../../../../../../../../core/shared/models/product_model.dart';
import '../../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../../../../core/shared/widgets/product_details_screen/product_details_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;
  final double routeDistance;
  final VoidCallback onDelivered, onAccept, onCancel;

  const OrderDetailsScreen({
    required this.order,
    required this.routeDistance,
    required this.onDelivered,
    required this.onAccept,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    String formatTime12h(DateTime? date) {
      if (date == null) return '--:--';
      final hour = date.hour == 0
          ? 12
          : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    }

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Material(
              color: Colors.transparent,
              child: GlassCard(
                green: (order.orderStatus == OrderStatuses.accepted),
                dark: (order.orderStatus != OrderStatuses.accepted),
                margin: .symmetric(horizontal: 15),
                padding: .all(20),
                responsive: true,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            borderRadius: .circular(5),
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.3 * 255).toInt(),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SupabaseImageProvider(
                              filePath: Buckets.usersImages,
                              fileName: order.customerId,
                              person: true,
                              iconSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: .symmetric(horizontal: 15),
                          child: Text(
                            order.customerName,
                            style: TextStyle(fontWeight: .bold),
                          ),
                        ),
                      ],
                    ),
                    GlassCard(
                      margin: .zero,
                      padding: .zero,
                      dark: true,
                      otherRadius: 50,
                      radius: 50,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.deliveryRouteMap.route,
                            arguments: order,
                          );
                        },
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: Column(
                            mainAxisAlignment: .center,
                            children: [
                              Text(
                                "${order.bakeries.length}",
                                style: TextStyle(
                                  fontWeight: .bold,
                                  fontSize: 12,
                                ),
                              ),
                              Padding(
                                padding: .symmetric(vertical: 5),
                                child: Transform(
                                  transform: Matrix4.diagonal3Values(
                                    4.5,
                                    1.0,
                                    1.0,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.route,
                                    size: 12,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Text(
                                    routeDistance.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 10),
                                  ),
                                  Padding(
                                    padding: .symmetric(horizontal: 3),
                                    child: Text(
                                      "km".tr(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: context.isDark
                                            ? Colors.amber
                                            : Colors.orange,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                GlassCard(
                  margin: .symmetric(horizontal: 15, vertical: 15),
                  padding: .zero,
                  responsive: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: GlassCard(
                          green: (order.orderStatus == OrderStatuses.accepted),
                          dark: (order.orderStatus != OrderStatuses.accepted),
                          margin: .zero,
                          padding: .only(
                            top: 5,
                            bottom: 10,
                            left: 15,
                            right: 15,
                          ),
                          responsive: true,
                          child: Text(
                            "bill".tr(),
                            style: TextStyle(fontWeight: .bold, fontSize: 16),
                          ),
                        ),
                      ),
                      Padding(
                        padding: .symmetric(horizontal: 25, vertical: 15),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          context.locale.languageCode == "ar"
                                          ? .only(left: 10)
                                          : .only(right: 10),
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
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      order.orderPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          context.locale.languageCode == "ar"
                                          ? .only(left: 10)
                                          : .only(right: 10),
                                      child: Icon(
                                        Icons.delivery_dining_outlined,
                                        size: 14,
                                        color: context.isDark
                                            ? Colors.amber
                                            : Colors.orange,
                                      ),
                                    ),
                                    Text(
                                      "deliveryFee".tr(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      order.deliveryFee.toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                          context.locale.languageCode == "ar"
                                          ? .only(left: 10)
                                          : .only(right: 10),
                                      child: Icon(
                                        Icons.receipt_long_outlined,
                                        size: 14,
                                        color: ThemingColors.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      "total".tr(),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      (order.deliveryFee + order.orderPrice)
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: .bold,
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
                  margin: .symmetric(horizontal: 15),
                  padding: .zero,
                  responsive: true,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: GlassCard(
                          green: (order.orderStatus == OrderStatuses.accepted),
                          dark: (order.orderStatus != OrderStatuses.accepted),
                          margin: .zero,
                          padding: .only(
                            top: 5,
                            bottom: 10,
                            left: 15,
                            right: 15,
                          ),
                          responsive: true,
                          child: Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Text(
                                "order".tr(),
                                style: TextStyle(
                                  fontWeight: .bold,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                textDirection: .ltr,
                                children: [
                                  Padding(
                                    padding: .only(right: 10),
                                    child: Icon(Icons.timer_outlined, size: 16),
                                  ),
                                  Text(
                                    formatTime12h(order.date),
                                    textDirection:.ltr,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: .all(10),
                        child: SizedBox(
                          height: screenHeight * 0.35,
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: order.bakeries.length,
                            separatorBuilder: (_, _) => SizedBox(),
                            itemBuilder: (_, index) {
                              final bakery = order.bakeries[index];
                              final List<ProductModel> bakeryProducts = order
                                  .orderedProducts
                                  .where(
                                    (product) =>
                                        product.bakeryId == bakery.bakeryId,
                                  )
                                  .toList();
                              final double bakeryTotal = bakeryProducts.fold(
                                0.0,
                                (sum, product) {
                                  final int productIndex = order.orderedProducts
                                      .indexOf(product);
                                  final int quantity =
                                      productIndex <
                                          order.orderedQuantities.length
                                      ? order.orderedQuantities[productIndex]
                                      : 0;
                                  return sum +
                                      (product.productPrice * quantity);
                                },
                              );
                              return Padding(
                                padding: .symmetric(vertical: 5),
                                child: ExpansionTile(
                                  childrenPadding: .only(bottom: 20, right: 5),
                                  backgroundColor: Colors.transparent,
                                  collapsedBackgroundColor: context.isDark
                                      ? ThemingColors.darkGrey
                                      : ThemingColors.lightGrey,
                                  initiallyExpanded: false,
                                  iconColor: ThemingColors.primaryColor,
                                  collapsedIconColor:
                                      ThemingColors.primaryColor,
                                  splashColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: .only(
                                      topRight:
                                          context.locale.languageCode == "ar"
                                          ? .circular(30)
                                          : .circular(0),
                                      bottomLeft:
                                          context.locale.languageCode == "ar"
                                          ? .circular(30)
                                          : .circular(0),
                                      topLeft:
                                          context.locale.languageCode == "ar"
                                          ? .circular(0)
                                          : .circular(30),
                                      bottomRight:
                                          context.locale.languageCode == "ar"
                                          ? .circular(0)
                                          : .circular(30),
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
                                      topRight:
                                          context.locale.languageCode == "ar"
                                          ? .circular(30)
                                          : .circular(0),
                                      bottomLeft:
                                          context.locale.languageCode == "ar"
                                          ? .circular(30)
                                          : .circular(0),
                                      topLeft:
                                          context.locale.languageCode == "ar"
                                          ? .circular(0)
                                          : .circular(30),
                                      bottomRight:
                                          context.locale.languageCode == "ar"
                                          ? .circular(0)
                                          : .circular(30),
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
                                  leading: Container(
                                    height: 50,
                                    width: 55,
                                    decoration: BoxDecoration(
                                      borderRadius: .only(
                                        topRight:
                                            context.locale.languageCode == "ar"
                                            ? .circular(20)
                                            : .circular(0),
                                        bottomLeft:
                                            context.locale.languageCode == "ar"
                                            ? .circular(20)
                                            : .circular(0),
                                        topLeft:
                                            context.locale.languageCode == "ar"
                                            ? .circular(0)
                                            : .circular(20),
                                        bottomRight:
                                            context.locale.languageCode == "ar"
                                            ? .circular(0)
                                            : .circular(20),
                                      ),
                                      color: ThemingColors.primaryColor
                                          .withAlpha((0.2 * 255).toInt()),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: .only(
                                        topRight:
                                            context.locale.languageCode == "ar"
                                            ? .circular(20)
                                            : .circular(0),
                                        bottomLeft:
                                            context.locale.languageCode == "ar"
                                            ? .circular(20)
                                            : .circular(0),
                                        topLeft:
                                            context.locale.languageCode == "ar"
                                            ? .circular(0)
                                            : .circular(20),
                                        bottomRight:
                                            context.locale.languageCode == "ar"
                                            ? .circular(0)
                                            : .circular(20),
                                      ),
                                      child: SupabaseImageProvider(
                                        filePath: Buckets.bakeriesImages,
                                        fileName:
                                            order.bakeries[index].bakeryId,
                                        cacheWidth: 120,
                                        cacheHeight: 120,
                                      ),
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          bakery.bakeryName,
                                          maxLines: 1,
                                          overflow: .ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        'total'.tr(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.isDark
                                              ? Colors.blueGrey
                                              : Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        ':',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: context.isDark
                                              ? Colors.blueGrey
                                              : Colors.grey,
                                        ),
                                      ),
                                      Padding(
                                        padding: .symmetric(horizontal: 5),
                                        child: Row(
                                          children: [
                                            Text(
                                              bakeryTotal.toStringAsFixed(2),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: .bold,
                                              ),
                                            ),
                                            Text(
                                              ' \$',
                                              style: TextStyle(
                                                fontWeight: .bold,
                                                color: context.isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: bakeryProducts.asMap().entries.map((
                                    entry,
                                  ) {
                                    final ProductModel product = entry.value;
                                    final int globalIndex = order
                                        .orderedProducts
                                        .indexOf(product);
                                    final int quantity =
                                        globalIndex <
                                            order.orderedQuantities.length
                                        ? order.orderedQuantities[globalIndex]
                                        : 0;
                                    final double productTotal =
                                        product.productPrice * quantity;
                                    return ListTile(
                                      leading: UnconstrainedBox(
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  context.locale.languageCode ==
                                                      "ar"
                                                  ? .only(left: 10)
                                                  : .only(right: 10),
                                              child: Text(
                                                'x$quantity',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: ThemingColors
                                                  .primaryColor
                                                  .withAlpha(
                                                    (0.2 * 255).toInt(),
                                                  ),
                                              child: ClipOval(
                                                child: SupabaseImageProvider(
                                                  filePath:
                                                      Buckets.productsImages,
                                                  fileName: product.productId,
                                                  iconSize: 14,
                                                  cacheWidth: 75,
                                                  cacheHeight: 75,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      title: InkWell(
                                        splashColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierColor: context.isDark
                                                ? ThemingColors.black.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  )
                                                : ThemingColors.white.withAlpha(
                                                    (0.3 * 255).toInt(),
                                                  ),
                                            builder: (context) {
                                              return ProductDetailsScreen(
                                                product: product,
                                              );
                                            },
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment: .start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        context
                                                                .locale
                                                                .languageCode ==
                                                            "ar"
                                                        ? .only(left: 15)
                                                        : .only(right: 15),
                                                    child: Text(
                                                      product.productName,
                                                      maxLines: 1,
                                                      overflow: .ellipsis,
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "(${product.productPrice.toStringAsFixed(2)} \$)",
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: context.isDark
                                                    ? Colors.blueGrey
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      trailing: RichText(
                                        text: TextSpan(
                                          text: productTotal.toStringAsFixed(2),
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: " \$ ",
                                              style: TextStyle(
                                                color: context.isDark
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Material(
              color: Colors.transparent,
              child: Padding(
                padding: .only(top: 15),
                child: SizedBox(
                  height: 30,
                  child: Row(
                    children: [
                      InkWell(
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () => Navigator.pop(context),
                        child: GlassCard(
                          margin: context.locale.languageCode == "ar"
                              ? .only(right: 15)
                              : .only(left: 15),
                          padding: .symmetric(horizontal: 15),
                          child: SizedBox(
                            child: Center(
                              child: Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: ThemingColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      (order.orderStatus == OrderStatuses.pending)
                          ? Expanded(
                              child: SizedBox(
                                height: 30,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    onAccept();
                                    Navigator.of(context).pop();
                                  },
                                  child: GlassCard(
                                    green: true,
                                    margin: .symmetric(horizontal: 15),
                                    padding: .zero,
                                    child: SizedBox(
                                      height: 35,
                                      child: Center(
                                        child: Text(
                                          "accept".tr(),
                                          style: TextStyle(
                                            color: context.isDark
                                                ? Colors.greenAccent
                                                : Colors.green,
                                            fontWeight: .bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Expanded(
                              child: SizedBox(
                                height: 30,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: onDelivered,
                                  child: GlassCard(
                                    margin: context.locale.languageCode == "ar"
                                        ? .only(right: 15)
                                        : .only(left: 15),
                                    padding: .zero,
                                    child: Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Icon(
                                          Icons.done_all,
                                          size: 20,
                                          color: Colors.blueAccent,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "delivered".tr(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      if (order.orderStatus == OrderStatuses.accepted)
                        SizedBox(width: 15),
                      if (order.orderStatus == OrderStatuses.accepted)
                        Expanded(
                          child: InkWell(
                            splashColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: onCancel,
                            child: GlassCard(
                              margin: context.locale.languageCode == "ar"
                                  ? .only(left: 15)
                                  : .only(right: 15),
                              padding: .symmetric(horizontal: 15),
                              child: SizedBox(
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: .center,
                                    children: [
                                      Icon(
                                        Icons.close,
                                        size: 20,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "cancelOrder".tr(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: .bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

