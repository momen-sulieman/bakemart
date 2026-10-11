import 'dart:ui' as ui;

import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/payroll_settings_tile.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/products_settings_tile.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/ui/widgets/staff_settings_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../core/utils/extensions/context_extensions.dart';

class SettingsTabScreen extends StatelessWidget {
  const SettingsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DependencyInjection.getIt<SettingsCubit>(),
        ),
        BlocProvider(
          create: (context) =>
              SettingsUpdateCubit(context.read<SettingsCubit>()),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          final cubit = context.read<SettingsCubit>();
          final updateCubit = context.read<SettingsUpdateCubit>();
          final locationState = context.read<LocationCubit>().state;
          final double? liveLat = locationState is LocationUpdated
              ? locationState.lat
              : null;
          final double? liveLng = locationState is LocationUpdated
              ? locationState.lng
              : null;
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: context.isDark
                  ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                  : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(20),
                child: Container(
                  height: 70,
                  width: .infinity,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: ThemingColors.primaryColor.withAlpha(
                          (0.15 * 255).toInt(),
                        ),
                        width: 5,
                      ),
                    ),
                    borderRadius: .only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              height: screenHeight + 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    context.isDark
                        ? ConstantImages.darkBackground
                        : ConstantImages.lightBackground,
                  ),
                  fit: BoxFit.cover,
                  opacity: context.isDark ? 0.35 : 0.25,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Directionality(
                textDirection: context.locale.languageCode == 'ar'
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                child: (settingsState is SettingsLoading)
                    ? Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: ThemingColors.primaryColor,
                          size: 25,
                        ),
                      )
                    : (settingsState is SettingsSuccess)
                    ? SingleChildScrollView(
                        padding: .only(bottom: 120, top: 190),
                        child: Column(
                          children: [
                            BlocProvider(
                              create: (_) =>
                                  DependencyInjection.getIt<SupabaseImageCubit>(
                                    param1: Buckets.bakeriesImages,
                                    param2: settingsState.bakery.bakeryId,
                                  ),
                              child: Builder(
                                builder: (imageContext) {
                                  return Center(
                                    child: Padding(
                                      padding: .symmetric(vertical: 15),
                                      child: Stack(
                                        children: [
                                          ClipOval(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: ThemingColors
                                                    .primaryColor
                                                    .withAlpha(
                                                      (0.3 * 255).toInt(),
                                                    ),
                                              ),
                                              width: screenWidth * 0.32,
                                              height: screenWidth * 0.32,
                                              child: SupabaseImage(),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            right: 5,
                                            child: InkWell(
                                              hoverColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                imageContext
                                                    .read<SupabaseImageCubit>()
                                                    .pickImage(false);
                                              },
                                              child: Container(
                                                height: 30,
                                                width: 30,
                                                padding: .all(5),
                                                decoration: BoxDecoration(
                                                  color: ThemingColors
                                                      .primaryColor
                                                      .withAlpha(
                                                        ((context.isDark
                                                                    ? 0.5
                                                                    : 0.7) *
                                                                255)
                                                            .toInt(),
                                                      ),
                                                  shape: .circle,
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color: ThemingColors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: .center,
                              children: [
                                SizedBox(width: 33),
                                Flexible(
                                  child: Text(
                                    settingsState.bakery.bakeryName,
                                    maxLines: 1,
                                    overflow: .ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    cubit.nameChanged(false);
                                    showDialog(
                                      barrierColor: Colors.transparent,
                                      context: context,
                                      builder: (dialogContext) {
                                        final TextEditingController
                                        nameController = TextEditingController(
                                          text: cubit.bakery!.bakeryName,
                                        );
                                        return BlocProvider.value(
                                          value: cubit,
                                          child: BlocBuilder<SettingsCubit, SettingsState>(
                                            builder: (context, state) {
                                              return BackdropFilter(
                                                filter: .blur(
                                                  sigmaX: 2,
                                                  sigmaY: 2,
                                                ),
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: .circular(20),
                                                    side: BorderSide(
                                                      width: 0.2,
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                          : ThemingColors.black,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      context.isDark
                                                      ? ThemingColors.black
                                                            .withAlpha(
                                                              (0.8 * 255)
                                                                  .toInt(),
                                                            )
                                                      : ThemingColors.white
                                                            .withAlpha(
                                                              (0.8 * 255)
                                                                  .toInt(),
                                                            ),
                                                  title: Text(
                                                    "bakeryName".tr(),
                                                    textAlign: .center,
                                                    style: TextStyle(
                                                      fontWeight: .bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  content: Row(
                                                    mainAxisSize: .min,
                                                    mainAxisAlignment: .center,
                                                    children: [
                                                      Expanded(
                                                        child: SizedBox(
                                                          child: TextFormField(
                                                            controller:
                                                                nameController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                            autofocus: true,
                                                            textAlign: .center,
                                                            textDirection:
                                                                Bidi.hasAnyLtr(
                                                                  nameController
                                                                      .text,
                                                                )
                                                                ? .ltr
                                                                : .rtl,
                                                            onChanged: (text) {
                                                              final oldValue =
                                                                  cubit
                                                                      .bakery!
                                                                      .bakeryName;
                                                              if (text !=
                                                                      oldValue &&
                                                                  text.isNotEmpty) {
                                                                cubit
                                                                    .nameChanged(
                                                                      true,
                                                                    );
                                                              } else {
                                                                cubit
                                                                    .nameChanged(
                                                                      false,
                                                                    );
                                                              }
                                                            },
                                                            decoration:
                                                                InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  focusedBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  enabledBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  errorBorder:
                                                                      InputBorder
                                                                          .none,
                                                                  disabledBorder:
                                                                      InputBorder
                                                                          .none,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    Row(
                                                      children: [
                                                        cubit.isNameChanged
                                                            ? InkWell(
                                                                hoverColor: Colors
                                                                    .transparent,
                                                                splashColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  cubit
                                                                      .productDataChanged(
                                                                        false,
                                                                      );
                                                                  Navigator.pop(
                                                                    dialogContext,
                                                                  );
                                                                },
                                                                child: GlassCard(
                                                                  margin:
                                                                      .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                      ),
                                                                  padding:
                                                                      .symmetric(
                                                                        vertical:
                                                                            2,
                                                                        horizontal:
                                                                            10,
                                                                      ),
                                                                  child: Icon(
                                                                    Icons
                                                                        .arrow_back,
                                                                    size: 18,
                                                                    color: ThemingColors
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              )
                                                            : Expanded(
                                                                child: InkWell(
                                                                  hoverColor: Colors
                                                                      .transparent,
                                                                  splashColor:
                                                                      Colors
                                                                          .transparent,
                                                                  highlightColor:
                                                                      Colors
                                                                          .transparent,
                                                                  onTap: () {
                                                                    cubit
                                                                        .productDataChanged(
                                                                          false,
                                                                        );
                                                                    Navigator.pop(
                                                                      dialogContext,
                                                                    );
                                                                  },
                                                                  child: GlassCard(
                                                                    margin: .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                    ),
                                                                    padding:
                                                                        .symmetric(
                                                                          vertical:
                                                                              2,
                                                                        ),
                                                                    child: Icon(
                                                                      Icons
                                                                          .arrow_back,
                                                                      size: 18,
                                                                      color: ThemingColors
                                                                          .primaryColor,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                        if (cubit.isNameChanged)
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                final updatedBakery = cubit
                                                                    .bakery!
                                                                    .copyWith(
                                                                      bakeryName:
                                                                          nameController
                                                                              .text,
                                                                    );
                                                                cubit.changeBakeryData(
                                                                  updatedBakery:
                                                                      updatedBakery,
                                                                );
                                                                cubit
                                                                    .nameChanged(
                                                                      false,
                                                                    );
                                                                Navigator.pop(
                                                                  dialogContext,
                                                                );
                                                              },
                                                              hoverColor: Colors
                                                                  .transparent,
                                                              splashColor: Colors
                                                                  .transparent,
                                                              highlightColor:
                                                                  Colors
                                                                      .transparent,
                                                              child: GlassCard(
                                                                margin:
                                                                    .symmetric(
                                                                      horizontal:
                                                                          6,
                                                                    ),
                                                                padding:
                                                                    .symmetric(
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                child: Icon(
                                                                  Icons.done,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: context.locale.languageCode == 'ar'
                                        ? .only(right: 15)
                                        : .only(left: 15),
                                    child: Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: ThemingColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                cubit.locationEditingMode(
                                  !cubit.isLocationEditing,
                                );
                              },
                              child: GlassCard(
                                margin: .zero,
                                padding: .symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                otherRadius: 30,
                                orange: !cubit.isLocationEditing,
                                dark: cubit.isLocationEditing,
                                child: Row(
                                  mainAxisSize: .min,
                                  mainAxisAlignment: .center,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: ThemingColors.primaryColor,
                                      size: 18,
                                    ),
                                    Padding(
                                      padding: .symmetric(horizontal: 5),
                                      child: Text(
                                        "location".tr(),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: .bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (cubit.isLocationEditing)
                              Container(
                                height: screenHeight * 0.5,
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                  vertical: 10,
                                ),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.2 * 255).toInt(),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: LocationPickerMap.setter(
                                  initialLat: cubit.bakery!.bakeryLat,
                                  initialLng: cubit.bakery!.bakeryLng,
                                  deviceLat: liveLat,
                                  deviceLng: liveLng,
                                  resetLat: cubit.bakery!.bakeryLat,
                                  resetLng: cubit.bakery!.bakeryLng,
                                  resetMarkerIcon: Icons.location_on_outlined,
                                  alwaysShow: false,
                                  hideWhenRecenter: false,
                                  onSet: (lat, lng) {
                                    final updatedBakery = cubit.bakery!
                                        .copyWith(
                                          bakeryLat: lat,
                                          bakeryLng: lng,
                                        );
                                    updateCubit.changeBakeryData(
                                      updatedBakery: updatedBakery,
                                      targetId: 'location',
                                    );
                                    cubit.locationCancelEditing();
                                  },
                                ),
                              ),
                            ProductsSettingsTile(
                              products: settingsState.products,
                            ),
                            PayrollSettingsTile(),
                            StaffSettingsTile(staff: settingsState.staff),
                          ],
                        ),
                      )
                    : Center(child: Text("Somthing went wrong")),
              ),
            ),
          );
        },
      ),
    );
  }
}
