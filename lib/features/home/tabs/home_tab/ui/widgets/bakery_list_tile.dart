import 'dart:ui' as ui;

import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/ui/supabase_image.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../../core/routing/app_routes.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../../../../core/theming/theming_colors.dart';
import '../../../../../../core/utils/enums/buckts.dart';

class BakeryListTile extends StatelessWidget {
  final HomeDataBakeriesModel bakery;

  const BakeryListTile({required this.bakery, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.bakeryDetails.route,
          arguments: bakery,
        );
      },
      child: GlassCard(
        margin: .symmetric(horizontal: 25, vertical: 8),
        padding: .only(top: 10, bottom: 10, left: 15, right: 5),
        radius: 50,
        otherRadius: 10,
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: Row(
            children: [
              Container(
                width: 75,
                height: 75,
                margin: .only(right: 20),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: .only(
                    topLeft: .circular(35),
                    topRight: .circular(5),
                    bottomRight: .circular(35),
                    bottomLeft: .circular(5),
                  ),
                  color: ThemingColors.primaryColor.withAlpha(
                    (0.2 * 255).toInt(),
                  ),
                ),
                child: SupabaseImageProvider(
                  filePath: Buckets.bakeriesImages,
                  fileName: bakery.bakeryModel.bakeryId,
                  addIconSize: 24,
                  cacheWidth: 75,
                  cacheHeight: 75,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      bakery.bakeryModel.bakeryName,
                      style: TextStyle(fontSize: 15,fontWeight: .bold),
                    ),
                    Row(
                      children: [
                        Text(
                          "branch".tr(),
                          style: TextStyle(
                            fontSize: 11,
                            color: context.isDark
                                ? ThemingColors.white.withAlpha(
                                    (0.5 * 255).toInt(),
                                  )
                                : ThemingColors.white.withAlpha(
                                    (0.5 * 255).toInt(),
                                  ),
                          ),
                        ),
                        Text(
                          ":",
                          style: TextStyle(
                            fontSize: 11,
                            color: context.isDark
                                ? ThemingColors.white.withAlpha(
                                    (0.5 * 255).toInt(),
                                  )
                                : ThemingColors.white.withAlpha(
                                    (0.5 * 255).toInt(),
                                  ),
                          ),
                        ),
                        SizedBox(width: 5,),
                        Flexible(
                          child: Padding(
                            padding: .only(right: 10),
                            child: Text(bakery.bakeryModel.branchName,
                              overflow: .ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 11,
                              ),),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: .symmetric(vertical: 7),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 60,
                            child: Stack(
                              children: [
                                if (bakery.productModelList.length > 1)
                                  Positioned(
                                    left: 20,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: ThemingColors
                                              .primaryColor
                                              .withAlpha((0.2 * 255).toInt()),
                                          child: ClipOval(
                                            child: SupabaseImageProvider(
                                              filePath: Buckets.productsImages,
                                              fileName: bakery
                                                  .productModelList[1]
                                                  .productId,
                                              showPlaceholderIcon: false,
                                              cacheWidth: 75,
                                              cacheHeight: 75,
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          radius: 15,
                                          backgroundColor: ThemingColors.black
                                              .withAlpha(
                                                ((context.isDark ? 0.8 : 0.1) *
                                                        255)
                                                    .toInt(),
                                              ),
                                        ),
                                        Positioned(
                                          right: 5,
                                          child: Icon(
                                            Icons.more_horiz,
                                            size: 15,
                                            color: ThemingColors.white
                                                .withAlpha((0.5 * 255).toInt()),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: ThemingColors.primaryColor
                                      .withAlpha((0.2 * 255).toInt()),
                                  child: ClipOval(
                                    child: SupabaseImageProvider(
                                      filePath: Buckets.productsImages,
                                      fileName:
                                          bakery.productModelList[0].productId,
                                      iconSize: 14,
                                      loadingIconSize: 14,
                                      iconLightOpacity: 0.1,
                                      iconDarkOpacity: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          Padding(
                            padding: .symmetric(horizontal: 5),
                            child: Text(
                              bakery.bakeryRate.toString(),
                              style: TextStyle(fontSize: 11, fontWeight: .bold),
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(5, (starIndex) {
                                final double rate = bakery.bakeryRate;
                                final double starValue = rate - starIndex;

                                if (starValue >= 0.95) {
                                  return const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 12,
                                  );
                                } else if (starValue >= 0.05) {
                                  return const Icon(
                                    Icons.star_half,
                                    color: Colors.amber,
                                    size: 12,
                                  );
                                } else {
                                  return const Icon(
                                    Icons.star_border,
                                    color: Colors.amber,
                                    size: 12,
                                  );
                                }
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: .only(right: 20),
                child: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    final locationCubit = context.read<LocationCubit>();
                    showDialog(
                      context: context,
                      barrierColor: context.isDark
                          ? ThemingColors.black.withAlpha((0.5 * 255).toInt())
                          : ThemingColors.white.withAlpha((0.3 * 255).toInt()),
                      builder: (dialogContext) {
                        return BlocProvider.value(
                          value: locationCubit,
                          child: BlocBuilder<LocationCubit, LocationState>(
                            builder: (context, locationState) {
                              final double? liveLat =
                                  locationState is LocationUpdated
                                  ? locationState.lat
                                  : null;
                              final double? liveLng =
                                  locationState is LocationUpdated
                                  ? locationState.lng
                                  : null;
                              return Material(
                                color: Colors.transparent,
                                child: BackdropFilter(
                                  filter: .blur(sigmaX: 5, sigmaY: 5),
                                  child: Directionality(
                                    textDirection: ui.TextDirection.ltr,
                                    child: Column(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Row(
                                          mainAxisAlignment: .end,
                                          children: [
                                            TransparentButton(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              icon: Icons.close,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        Dialog(
                                          insetPadding: const EdgeInsets.all(
                                            20,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          child: SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.6,
                                            child: LocationPickerMap.viewer(
                                              initialLat:
                                                  liveLat ??
                                                  bakery.bakeryModel.bakeryLat,
                                              initialLng:
                                                  liveLng ??
                                                  bakery.bakeryModel.bakeryLng,
                                              deviceLat: liveLat,
                                              deviceLng: liveLng,
                                              markers: [
                                                MapMarkerData(
                                                  lat: bakery
                                                      .bakeryModel
                                                      .bakeryLat,
                                                  lng: bakery
                                                      .bakeryModel
                                                      .bakeryLng,
                                                  icon: Icons.location_pin,
                                                  color: ThemingColors.black,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.location_pin,
                    color: ThemingColors.primaryColor,
                    size: 33,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
