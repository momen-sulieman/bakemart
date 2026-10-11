import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../core/shared/functions/distance_calculator.dart';
import '../../../../../../core/shared/models/order_model.dart';
import '../../../../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../../../../core/theming/theming_colors.dart';

class DeliveryRouteMapScreen extends StatelessWidget {
  final OrderModel order;

  const DeliveryRouteMapScreen({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LocationCubit, LocationState>(
        builder: (context, locationState) {
          final double? liveLat = locationState is LocationUpdated
              ? locationState.lat
              : null;
          final double? liveLng = locationState is LocationUpdated
              ? locationState.lng
              : null;
          final List<MapMarkerData> markers = [
            for (final bakery in order.bakeries)
              MapMarkerData(
                lat: bakery.bakeryLat,
                lng: bakery.bakeryLng,
                icon: Icons.location_pin,
                color: ThemingColors.black.withAlpha((0.7 * 255).toInt()),
              ),
            MapMarkerData(
              lat: order.customerLat,
              lng: order.customerLng,
              icon: Icons.person_pin_circle,
              color: Colors.green,
            ),
          ];

          final List<LatLng> routeLine = (liveLat != null && liveLng != null)
              ? getOptimizedRouteWaypoints(
                  order: order,
                  deliveryManLat: liveLat,
                  deliveryManLng: liveLng,
                ).map((p) => LatLng(p['lat']!, p['lng']!)).toList()
              : const [];

          return Stack(
            children: [
              LocationPickerMap.viewer(
                initialLat: liveLat ?? order.customerLat,
                initialLng: liveLng ?? order.customerLng,
                deviceLat: liveLat,
                deviceLng: liveLng,
                markers: markers,
                routePoints: routeLine,
              ),
              Positioned(
                top: 0,
                left: context.locale.languageCode == "en" ? 20 : null,
                right: context.locale.languageCode == "en" ? null : 20,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        size: 35,
                        color: ThemingColors.black,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (order.street == null ||
                  order.building != null ||
                  order.apartment != null)
                Positioned(
                  bottom: 10,
                  left: 20,
                  child: Center(
                    child: Container(
                      width: 250,
                      padding: context.locale.languageCode == "ar"
                          ? .only(top: 10, bottom: 10, right: 15)
                          : .only(top: 10, bottom: 10, left: 15),
                      decoration: BoxDecoration(
                        color: ThemingColors.black.withAlpha(
                          (0.6 * 255).toInt(),
                        ),
                        borderRadius: .only(
                          topRight: .circular(100),
                          bottomLeft: .circular(100),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:context.locale.languageCode=="ar"? .only(right: 35):.zero,
                            child: Row(
                              children: [
                                Text(
                                  "house".tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: .symmetric(horizontal: 5),
                                    child: Text(
                                      order.apartment ?? "!!",
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ThemingColors.white,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: .symmetric(vertical: 3, horizontal: 15),
                            child: Row(
                              children: [
                                Text(
                                  "building".tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: .symmetric(horizontal: 5),
                                    child: Text(
                                      order.building ?? "!!",
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ThemingColors.white,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: .only(left: 35),
                            child: Row(
                              children: [
                                Text(
                                  "street".tr(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Text(
                                  ":",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: ThemingColors.white.withAlpha(
                                      (0.7 * 255).toInt(),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: .symmetric(horizontal: 5),
                                    child: Text(
                                      order.street ?? "!!",
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ThemingColors.white,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
