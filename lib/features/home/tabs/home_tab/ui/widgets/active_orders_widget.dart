import 'dart:ui' as ui;

import 'package:bakemart/core/utils/enums/order_statuses.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../core/shared/models/order_model.dart';
import '../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../core/theming/theming_colors.dart';
import '../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/active_orders_cubit/active_orders_cubit.dart';

class ActiveOrdersWidget extends StatelessWidget {
  const ActiveOrdersWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ActiveOrdersCubit>();
    String formatTime12h(DateTime? date) {
      if (date == null) return '--:--';
      final hour = date.hour == 0
          ? 12
          : (date.hour > 12 ? date.hour - 12 : date.hour);
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    }

    return StreamBuilder<List<OrderModel>>(
      stream: cubit.liveActiveOrders,
      builder: (context, snapshot) {
        final orders = snapshot.data;
        if (orders == null || orders.isEmpty) {
          return const SizedBox();
        }
        return Column(
          children: orders.map((order) {
            return GlassCard(
              margin: .only(left: 5, right: 5, bottom: 5),
              padding: .all(15),
              otherRadius: 20,
              radius: 20,
              dark: order.orderStatus == OrderStatuses.pending,
              green: order.orderStatus == OrderStatuses.accepted,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: .only(right: 10),
                              child: Icon(
                                Icons.sell_outlined,
                                size: 16,
                                color: context.isDark
                                    ? Colors.cyan
                                    : Colors.teal,
                              ),
                            ),
                            SizedBox(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: ui.TextDirection.ltr,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: order.orderPrice.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.isDark
                                            ? ThemingColors.white
                                            : ThemingColors.black,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " \$ ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.isDark
                                            ? Colors.lightGreen
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: .only(right: 10),
                              child: Icon(
                                Icons.delivery_dining_outlined,
                                size: 16,
                                color: context.isDark
                                    ? Colors.amber
                                    : Colors.orange,
                              ),
                            ),
                            SizedBox(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: ui.TextDirection.ltr,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: order.deliveryFee.toStringAsFixed(
                                        2,
                                      ),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    TextSpan(
                                      text: " \$ ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.isDark
                                            ? Colors.lightGreen
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: .only(right: 10),
                              child: Icon(
                                Icons.receipt_long,
                                size: 16,
                                color: ThemingColors.primaryColor,
                              ),
                            ),
                            SizedBox(
                              child: RichText(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textDirection: ui.TextDirection.ltr,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          (order.deliveryFee + order.orderPrice)
                                              .toStringAsFixed(2),
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    TextSpan(
                                      text: " \$ ",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.isDark
                                            ? Colors.lightGreen
                                            : Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      child: ListView.separated(
                        padding: .zero,
                        shrinkWrap: true,
                        itemBuilder: (_, bakeryIndex) {
                          final bakery = order.bakeries[bakeryIndex];
                          final received = order.received[bakeryIndex];
                          return GlassCard(
                            margin: .zero,
                            padding: .symmetric(horizontal: 5, vertical: 5),
                            green: received,
                            otherRadius: 30,
                            child: Directionality(
                              textDirection: context.locale.languageCode == 'ar'
                                  ? ui.TextDirection.rtl
                                  : ui.TextDirection.ltr,
                              child: Row(
                                children: [
                                  Container(
                                    height: 20,
                                    width: 20,
                                    margin: context.locale.languageCode == "ar"
                                        ? .only(left: 10)
                                        : .only(right: 10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          context.locale.languageCode == "ar"
                                          ? .only(
                                              bottomRight: .circular(10),
                                              topRight: .circular(10),
                                            )
                                          : .only(
                                              bottomLeft: .circular(10),
                                              topLeft: .circular(10),
                                            ),
                                      color: ThemingColors.primaryColor
                                          .withAlpha((0.3 * 255).toInt()),
                                    ),
                                    child: SupabaseImageProvider(
                                      filePath: Buckets.bakeriesImages,
                                      fileName:
                                          order.bakeries[bakeryIndex].bakeryId,
                                      iconSize: 12,
                                      loadingIconSize: 12,
                                      addIconSize: 12,
                                      cacheWidth: 75,
                                      cacheHeight: 75,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      bakery.bakeryName,
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  if (order.orderStatus ==
                                      OrderStatuses.accepted)
                                    Padding(
                                      padding: .symmetric(horizontal: 5),
                                      child: Icon(
                                        received
                                            ? Icons.done
                                            : Icons.hourglass_top,
                                        size: 16,
                                        color: received
                                            ? context.isDark
                                                  ? Colors.greenAccent
                                                  : Colors.green
                                            : Colors.blueGrey,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, _) {
                          return SizedBox(height: 5);
                        },
                        itemCount: order.bakeries.length,
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: .start,
                      children: [
                        order.orderStatus == OrderStatuses.pending
                            ? StreamBuilder<Set<String>>(
                                stream: cubit.cancellingOrderIdsStream,
                                initialData: cubit.cancellingOrderIds,
                                builder: (context, cancelSnapshot) {
                                  final isCancelling =
                                      (cancelSnapshot.data ?? const {})
                                          .contains(order.orderId);
                                  return InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: isCancelling
                                        ? null
                                        : () => cubit.cancelOrder(
                                            orderId: order.orderId!,
                                          ),
                                    child: SizedBox(
                                      width: 120,
                                      child: GlassCard(
                                        margin: .zero,
                                        padding: .symmetric(
                                          horizontal: 15,
                                          vertical: 3,
                                        ),
                                        orange: true,
                                        otherRadius: 30,
                                        child: isCancelling
                                            ? Center(
                                                child:
                                                    LoadingAnimationWidget.staggeredDotsWave(
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                          : ThemingColors.black,
                                                      size: 14,
                                                    ),
                                              )
                                            : Text(
                                                "cancelOrder".tr(),
                                                textAlign: .center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: .bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Row(
                                children: [
                                  Padding(
                                    padding: .only(right: 10),
                                    child: Icon(
                                      Icons.delivery_dining_outlined,
                                      size: 16,
                                    ),
                                  ),
                                  Text(
                                    order.deliveryManName ?? "!!",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                        Spacer(),
                        Padding(
                          padding: .only(right: 10),
                          child: Icon(Icons.timer_outlined, size: 16),
                        ),
                        Text(formatTime12h(order.date)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
