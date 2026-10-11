import 'dart:ui' as ui;

import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/widgets/cart/ui/cart_screen.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/features/bakery_details/ui/widgets/product_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../core/utils/enums/buckts.dart';

class BakeryDetailsScreen extends StatelessWidget {
  final HomeDataBakeriesModel bakery;

  const BakeryDetailsScreen({required this.bakery, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          titleSpacing: 0,
          centerTitle: true,
          leadingWidth: 100,
          leading: TransparentButton(
            onTap: () {
              Navigator.pop(context);
            },
            icon: Icons.arrow_back_ios_new,
            size: 25,
          ),
          title: TransparentButton(
            onTap: () {
              final cartCubit = context.read<CartCubit>();
              final locationCubit = context.read<LocationCubit>();
              showDialog(
                context: context,
                barrierColor: context.isDark
                    ? ThemingColors.black.withAlpha((0.5 * 255).toInt())
                    : ThemingColors.white.withAlpha((0.3 * 255).toInt()),
                builder: (dialogContext) {
                  return MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: cartCubit),
                      BlocProvider.value(value: locationCubit),
                    ],
                    child: CartScreen(),
                  );
                },
              );
            },
            icon: Icons.shopping_cart_outlined,
            size: 25,
          ),
          actions: [
            TransparentButton(
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
                          final double? liveLat = locationState is LocationUpdated
                              ? locationState.lat
                              : null;
                          final double? liveLng = locationState is LocationUpdated
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
                                          onTap: () => Navigator.pop(context),
                                          icon: Icons.close,
                                          color: Colors.redAccent,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    Dialog(
                                      insetPadding: const EdgeInsets.all(20),
                                      backgroundColor: Colors.transparent,
                                      child: SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
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
                                              lat: bakery.bakeryModel.bakeryLat,
                                              lng: bakery.bakeryModel.bakeryLng,
                                              icon: Icons.location_pin,
                                              color: ThemingColors.primaryColor,
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
              icon: Icons.location_on,
              size: 25,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: .symmetric(vertical: 25),
                    child: CircleAvatar(
                      radius: screenWidth * 0.35,
                      backgroundColor: ThemingColors.primaryColor.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
                      child: ClipOval(
                        child: SupabaseImageProvider(
                          filePath: Buckets.bakeriesImages,
                          fileName: bakery.bakeryModel.bakeryId,
                          addIconSize: 40,
                          iconSize: 40,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    bakery.bakeryModel.bakeryName,
                    style: GoogleFonts.zenOldMincho(
                      fontSize: 20,
                      fontWeight: .bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    margin: .all(15),
                    padding: .only(left: 20, top: 20, bottom: 20),
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? ThemingColors.darkGrey
                          : ThemingColors.white,
                      borderRadius: .circular(25),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (_, index) {
                        return ProductListTile(bakery: bakery, index: index);
                      },
                      separatorBuilder: (_, index) {
                        return Container(
                          height: 2,
                          margin: .symmetric(
                            vertical: 14,
                            horizontal: screenWidth * 0.15,
                          ),
                          color: context.isDark
                              ? ThemingColors.black
                              : ThemingColors.lightGrey,
                        );
                      },
                      itemCount: bakery.productModelList.length,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
