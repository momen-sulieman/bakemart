import 'package:bakemart/core/shared/models/order_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/table_cells/worker_cell.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/order_details_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../../../core/routing/app_routes.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/delivery_cubit/delivery_cubit.dart';

class OrdersListTile extends StatelessWidget {
  final double routeDistance;
  final OrderModel order;
  final VoidCallback onAccept;

  const OrdersListTile({
    required this.routeDistance,
    required this.order,
    required this.onAccept,
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
                  onAccept: onAccept,
                  onDelivered: () {},
                  onCancel: () {},
                );
              },
            );
          },
          child: GlassCard(
            margin: .symmetric(horizontal: 35, vertical: 10),
            padding: .symmetric(horizontal: 60, vertical: 10),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: .symmetric(horizontal: 10),
                        child: WorkerCell(
                          workerName: order.customerName,
                          workerId: order.customerId,
                          noPadding: true,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: .symmetric(horizontal: 20),
                      child: Icon(
                        Icons.sell_outlined,
                        size: 14,
                        color: context.isDark ? Colors.cyan : Colors.teal,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "${order.orderPrice}",
                            style: TextStyle(
                              color: context.isDark
                                  ? Colors.lightGreen
                                  : Colors.green,
                              fontWeight: .bold,
                            ),
                          ),
                          Text(" \$"),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: .start,
                  children: [
                    Padding(
                      padding: .symmetric(horizontal: 20),
                      child: Icon(
                        Icons.delivery_dining_outlined,
                        size: 15,
                        color: context.isDark ? Colors.amber : Colors.orange,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "${order.deliveryFee}",
                            style: TextStyle(
                              color: context.isDark
                                  ? Colors.lightGreen
                                  : Colors.green,
                              fontWeight: .bold,
                            ),
                          ),
                          Text(" \$"),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: context.locale.languageCode == "ar" ? null : 10,
          left: context.locale.languageCode == "ar" ? 10 : null,
          child: Center(
            child: BlocBuilder<DeliveryCubit, DeliveryState>(
              builder: (context, state) {
                final cubit = context.read<DeliveryCubit>();
                final loading = cubit.isActionLoading(
                  order.orderId ?? '',
                  DeliveryActionType.accept,
                );
                return InkWell(
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: loading ? null : onAccept,
                  child: GlassCard(
                    margin: .zero,
                    padding: .zero,
                    green: true,
                    otherRadius: 50,
                    radius: 50,
                    child: SizedBox(
                      height: 65,
                      width: 65,
                      child: Center(
                        child: loading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: LoadingAnimationWidget.staggeredDotsWave(
                                  color: context.isDark
                                      ? Colors.greenAccent
                                      : Colors.green,
                                  size: 20,
                                ),
                              )
                            : Text(
                                "accept".tr(),
                                style: TextStyle(
                                  color: context.isDark
                                      ? Colors.greenAccent
                                      : Colors.green,
                                  fontWeight: .bold,
                                  fontSize: 13,
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          left: context.locale.languageCode == "ar" ? null : 10,
          right: context.locale.languageCode == "ar" ? 10 : null,
          child: Center(
            child: InkWell(
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: GlassCard(
                margin: .zero,
                padding: .zero,
                dark: true,
                otherRadius: 50,
                radius: 50,
                child: SizedBox(
                  height: 65,
                  width: 65,
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          Text(
                            "$numberOfBakeries",
                            style: TextStyle(fontWeight: .bold, fontSize: 12),
                          ),
                          Padding(
                            padding: .symmetric(vertical: 5),
                            child: Transform(
                              transform: Matrix4.diagonal3Values(4.5, 1.0, 1.0),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
