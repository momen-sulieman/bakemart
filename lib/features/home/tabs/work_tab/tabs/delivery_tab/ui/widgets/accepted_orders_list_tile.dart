import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/table_cells/worker_cell.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/order_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../../../core/routing/app_routes.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/delivery_cubit/delivery_cubit.dart';

class AcceptedOrdersListTile extends StatelessWidget {
  final double routeDistance;
  final OrderModel order;
  final VoidCallback onDelivered, onCancel;

  const AcceptedOrdersListTile({
    required this.routeDistance,
    required this.order,
    required this.onDelivered,
    required this.onCancel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final numberOfBakeries = order.bakeries.length;
    return Stack(
      children: [
        InkWell(
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            showDialog(
              context: context,
              barrierColor: Colors.transparent,
              builder: (context) {
                return OrderDetailsScreen(
                  order: order,
                  routeDistance: routeDistance,
                  onDelivered: () {
                    onDelivered();
                    Navigator.of(context).pop();
                  },
                  onAccept: () {},
                  onCancel: () {
                    onCancel();
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          },
          child: GlassCard(
            green: true,
            margin: .symmetric(horizontal: 30, vertical: 5),
            padding: .symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: context.locale.languageCode == "ar"
                      ? .only(right: 20)
                      : .only(left: 20),
                  child: SizedBox(
                    width: 145,
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.deliveryRouteMap.route,
                              arguments: order,
                            );
                          },
                          child: GlassCard(
                            margin: context.locale.languageCode == "ar"
                                ? .only(left: 10)
                                : .only(right: 10),
                            padding: .zero,
                            otherRadius: 30,
                            dark: true,
                            child: SizedBox(
                              height: 35,
                              width: 35,
                              child: Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Text(
                                    "$numberOfBakeries",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: ThemingColors.primaryColor,
                                    fontWeight: .bold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: context.locale.languageCode == "ar"
                              ? .only(left: 10)
                              : .only(right: 10),
                          child: Icon(
                            Icons.receipt_long,
                            size: 15,
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            (order.totalBill).toStringAsFixed(2),
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: TextStyle(
                              color: context.isDark
                                  ? Colors.lightGreen
                                  : Colors.green,
                              fontWeight: .bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: .symmetric(horizontal: 3),
                          child: Text("\$"),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: context.locale.languageCode == "ar"
                        ? .only(right: 10, left: 5)
                        : .only(left: 10, right: 5),
                    child: WorkerCell(
                      workerName: order.customerName,
                      workerId: order.customerId,
                      noPadding: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: context.locale.languageCode == "ar" ? null : 15,
          right: context.locale.languageCode == "ar" ? 15 : null,
          child: Center(
            child: BlocBuilder<DeliveryCubit, DeliveryState>(
              builder: (context, state) {
                final cubit = context.read<DeliveryCubit>();
                final anyLoading = cubit.loadingOrderId == order.orderId;
                final cancelling = cubit.isActionLoading(
                  order.orderId ?? '',
                  DeliveryActionType.cancel,
                );
                return TransparentButton(
                  onTap: anyLoading ? null : onCancel,
                  icon: cancelling ? null : Icons.close,
                  buttonWidget: cancelling
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.redAccent,
                            size: 14,
                          ),
                        )
                      : null,
                  color: Colors.redAccent,
                  size: 16,
                  isCircle: true,
                  buttonHorizontalPading: 0,
                  buttonSize: 20,
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: context.locale.languageCode == "ar" ? null : 15,
          left: context.locale.languageCode == "ar" ? 15 : null,
          child: Center(
            child: BlocBuilder<DeliveryCubit, DeliveryState>(
              builder: (context, state) {
                final cubit = context.read<DeliveryCubit>();
                final anyLoading = cubit.loadingOrderId == order.orderId;
                final delivering = cubit.isActionLoading(
                  order.orderId ?? '',
                  DeliveryActionType.deliver,
                );
                return TransparentButton(
                  onTap: anyLoading ? null : onDelivered,
                  icon: delivering ? null : Icons.done_all,
                  buttonWidget: delivering
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.blue,
                            size: 14,
                          ),
                        )
                      : null,
                  color: Colors.blue,
                  size: 16,
                  isCircle: true,
                  buttonHorizontalPading: 0,
                  buttonSize: 20,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
