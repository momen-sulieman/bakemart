import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/shared/models/home_screen_model.dart';
import 'package:bakemart/core/shared/widgets/faded_screen/faded_screen.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/utils/constants/constant_images.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/active_orders_cubit/active_orders_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/logic/home_data_cubit/home_data_cubit.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/widgets/active_orders_widget.dart';
import 'package:bakemart/features/home/tabs/home_tab/ui/widgets/bakery_list_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:popup_menu/popup_menu.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../core/shared/widgets/cart/logic/cart_cubit/cart_cubit.dart';
import '../../../../../core/shared/widgets/cart/ui/cart_screen.dart';
import '../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../../../core/theming/theming_colors.dart';
import '../../../../../core/utils/enums/buckts.dart';
import '../../../../../core/utils/extensions/context_extensions.dart';

final GlobalKey _editImageButtonKey = GlobalKey();

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  Future<void> _pickAndSave(
    SupabaseImageCubit imageCubit,
    HomeDataCubit homeCubit,
  ) async {
    final uploaded = await imageCubit.pickImage(false);
    if (uploaded) await homeCubit.updateProfileImageStatus(true);
  }

  void _showImageMenu(BuildContext imageContext) {
    final imageCubit = imageContext.read<SupabaseImageCubit>();
    final homeCubit = imageContext.read<HomeDataCubit>();
    PopupMenu menu = PopupMenu(
      context: imageContext,
      config: MenuConfig(
        backgroundColor: imageContext.isDark
            ? ThemingColors.black
            : ThemingColors.white,
        arrowHeight: 15,
        itemWidth: imageContext.locale.languageCode == "ar" ? 130 : 160,
        itemHeight: 40,
        type: MenuType.list,
      ),
      items: [
        MenuItem(
          title: 'changePic'.tr(),
          textStyle: TextStyle(
            fontSize: imageContext.locale.languageCode == "ar" ? 13 : 11,
          ),
          image: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.edit,
              size: 16,
              color: ThemingColors.white,
            ),
          ),
          userInfo: 1,
        ),
        MenuItem(
          title: 'removePic'.tr(),
          textStyle: TextStyle(
            fontSize: imageContext.locale.languageCode == "ar" ? 13 : 11,
          ),
          image: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Icon(
              Icons.delete_sweep_outlined,
              size: 16,
              color: Colors.redAccent,
            ),
          ),
          userInfo: 2,
        ),
      ],
      onClickMenu: (MenuItemProvider item) async {
        if (item.menuUserInfo == 1) {
          await _pickAndSave(imageCubit, homeCubit);
        } else if (item.menuUserInfo == 2) {
          imageCubit.showLoading();
          final removed = await homeCubit.removeProfileImage();
          if (removed) {
            imageCubit.clear();
          } else {
            imageCubit.loadImage();
          }
        }
      },
    );
    menu.show(widgetKey: _editImageButtonKey);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final cubit = context.read<HomeDataCubit>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: Drawer(
        width: screenWidth * 0.75,
        backgroundColor: context.isDark
            ? ThemingColors.darkGrey
            : ThemingColors.lightGrey,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: .zero),
        child: SafeArea(
          child: Column(
            children: [
              Directionality(
                textDirection: ui.TextDirection.ltr,
                child: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    await cubit.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.splash.route,
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(width: 20),
                      Icon(
                        Icons.logout,
                        size: 16,
                        color: ThemingColors.primaryColor,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "logout".tr(),
                        style: TextStyle(fontSize: 11, fontWeight: .bold),
                      ),
                      Spacer(),
                      Padding(
                        padding: .symmetric(horizontal: 10),
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            if (context.locale.languageCode == "en") {
                              await context.setLocale(Locale("ar"));
                            } else {
                              await context.setLocale(Locale("en"));
                            }
                          },
                          child: SizedBox(
                            width: 50,
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                Icon(
                                  Icons.language,
                                  color: ThemingColors.primaryColor,
                                ),
                                Text(
                                  context.locale.languageCode == "en"
                                      ? "العربية"
                                      : "English",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: .bold,
                                    color: context.isDark
                                        ? ThemingColors.white
                                        : ThemingColors.black,
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
              ),
              BlocProvider(
                create: (_) => SupabaseImageCubit(
                  Buckets.usersImages,
                  cubit.user.id,
                  skipInitialFetch: !cubit.user.hasProfileImage,
                ),
                child: Builder(
                  builder: (imageContext) {
                    return Center(
                      child: Padding(
                        padding: .only(bottom: 15, top: 25),
                        child: Stack(
                          children: [
                            ClipOval(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.3 * 255).toInt(),
                                  ),
                                ),
                                width: screenWidth * 0.4,
                                height: screenWidth * 0.4,
                                child: SupabaseImage(
                                  addIconSize: 30,
                                  iconSize: 30,
                                  person: true,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              right: 5,
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  if (cubit.user.hasProfileImage) {
                                    _showImageMenu(imageContext);
                                  } else {
                                    _pickAndSave(
                                      imageContext.read<SupabaseImageCubit>(),
                                      cubit,
                                    );
                                  }
                                },
                                child: Container(
                                  key: _editImageButtonKey,
                                  height: 30,
                                  width: 30,
                                  padding: .all(5),
                                  decoration: BoxDecoration(
                                    color: ThemingColors.primaryColor.withAlpha(
                                      ((context.isDark ? 0.5 : 0.7) * 255)
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
              SizedBox(height: 10),
              BlocBuilder<HomeDataCubit, HomeDataState>(
                builder: (context, state) {
                  if (state is HomeDataSuccess) {
                    return Row(
                      mainAxisAlignment: .center,
                      children: [
                        Padding(
                          padding: .symmetric(horizontal: 15),
                          child: Text(
                            "${cubit.user.firstName} ${cubit.user.secondName}",
                            style: TextStyle(fontWeight: .bold),
                          ),
                        ),
                        InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            cubit.nameChanged(
                              firstName: false,
                              secondName: false,
                            );
                            showDialog(
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (dialogContext) {
                                final TextEditingController
                                firstNameController = TextEditingController(
                                  text: cubit.user.firstName,
                                );
                                final TextEditingController
                                secondNameController = TextEditingController(
                                  text: cubit.user.secondName,
                                );
                                return BlocProvider.value(
                                  value: cubit,
                                  child: BackdropFilter(
                                    filter: .blur(sigmaX: 2, sigmaY: 2),
                                    child: AlertDialog(
                                      contentPadding: .symmetric(
                                        horizontal: 30,
                                        vertical: 40,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: .circular(20),
                                        side: BorderSide(
                                          width: 0.2,
                                          color: context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black,
                                        ),
                                      ),
                                      backgroundColor: context.isDark
                                          ? ThemingColors.black.withAlpha(
                                              (0.1 * 255).toInt(),
                                            )
                                          : ThemingColors.white.withAlpha(
                                              (0.1 * 255).toInt(),
                                            ),
                                      title: Text(
                                        "changeYourName".tr(),
                                        textAlign: .center,
                                        style: TextStyle(
                                          fontWeight: .bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      content: Column(
                                        mainAxisSize: .min,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: CustomTextFormField(
                                                    "firstName".tr(),
                                                    controller:
                                                        firstNameController,
                                                    keyBoardType:
                                                        TextInputType.text,
                                                    onChanged: (text) {
                                                      final oldValue =
                                                          cubit.user.firstName;
                                                      if (text != oldValue &&
                                                          text.isNotEmpty) {
                                                        cubit.nameChanged(
                                                          firstName: true,
                                                        );
                                                      } else {
                                                        cubit.nameChanged(
                                                          firstName: false,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 25),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SizedBox(
                                                  height: 40,
                                                  child: CustomTextFormField(
                                                    "secondName".tr(),
                                                    controller:
                                                        secondNameController,
                                                    keyBoardType:
                                                        TextInputType.text,
                                                    onChanged: (text) {
                                                      final oldValue =
                                                          cubit.user.secondName;
                                                      if (text != oldValue &&
                                                          text.isNotEmpty) {
                                                        cubit.nameChanged(
                                                          secondName: true,
                                                        );
                                                      } else {
                                                        cubit.nameChanged(
                                                          secondName: false,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        BlocBuilder<
                                          HomeDataCubit,
                                          HomeDataState
                                        >(
                                          builder: (context, state) {
                                            return Row(
                                              children: [
                                                cubit.isNameChanged
                                                    ? InkWell(
                                                        hoverColor:
                                                            Colors.transparent,
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          cubit.nameChanged(
                                                            firstName: false,
                                                            secondName: false,
                                                          );
                                                          Navigator.pop(
                                                            dialogContext,
                                                          );
                                                        },
                                                        child: GlassCard(
                                                          margin: .symmetric(
                                                            horizontal: 6,
                                                          ),
                                                          padding: .symmetric(
                                                            vertical: 2,
                                                            horizontal: 10,
                                                          ),
                                                          child: Icon(
                                                            Icons.arrow_back,
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
                                                          splashColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          onTap: () {
                                                            cubit.nameChanged(
                                                              firstName: false,
                                                              secondName: false,
                                                            );
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                          child: GlassCard(
                                                            margin: .symmetric(
                                                              horizontal: 6,
                                                            ),
                                                            padding: .symmetric(
                                                              vertical: 2,
                                                            ),
                                                            child: Icon(
                                                              Icons.arrow_back,
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
                                                        final userData = cubit.user.copyWith(
                                                          firstName:
                                                              firstNameController
                                                                  .text
                                                                  .capitalize(),
                                                          secondName:
                                                              secondNameController
                                                                  .text
                                                                  .capitalize(),
                                                        );
                                                        cubit.changeUserData(
                                                          updatedUserData:
                                                              userData,
                                                        );
                                                        Navigator.pop(
                                                          dialogContext,
                                                        );
                                                      },
                                                      hoverColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      child: GlassCard(
                                                        margin: .symmetric(
                                                          horizontal: 6,
                                                        ),
                                                        padding: .symmetric(
                                                          vertical: 2,
                                                        ),
                                                        child: Icon(
                                                          Icons.done,
                                                          size: 18,
                                                          color: Colors.green,
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
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: ThemingColors.primaryColor,
                          ),
                        ),
                      ],
                    );
                  } else if (state is HomeDataLoading) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: ThemingColors.primaryColor,
                        size: 25,
                      ),
                    );
                  }
                  return SizedBox();
                },
              ),
              SizedBox(height: 30),
              Container(
                margin: .symmetric(horizontal: 10),
                padding: .only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: .circular(20),
                  color:
                      (context.isDark
                              ? ThemingColors.white
                              : ThemingColors.black)
                          .withAlpha(
                            ((context.isDark ? 0.05 : 0.1) * 255).toInt(),
                          ),
                ),
                child: BlocBuilder<HomeDataCubit, HomeDataState>(
                  builder: (context, state) {
                    return Directionality(
                      textDirection: context.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: .spaceBetween,
                            children: [
                              Padding(
                                padding: .symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                child: Text(
                                  "address".tr(),
                                  style: TextStyle(fontWeight: .bold),
                                ),
                              ),
                              InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  cubit.addressChanged(
                                    street: false,
                                    building: false,
                                    apartment: false,
                                  );
                                  showDialog(
                                    barrierColor: Colors.transparent,
                                    context: context,
                                    builder: (dialogContext) {
                                      final TextEditingController
                                      streetController = TextEditingController(
                                        text: cubit.user.street,
                                      );
                                      final TextEditingController
                                      buildingController =
                                          TextEditingController(
                                            text: cubit.user.building,
                                          );
                                      final TextEditingController
                                      apartmentController =
                                          TextEditingController(
                                            text: cubit.user.apartment,
                                          );
                                      return BlocProvider.value(
                                        value: cubit,
                                        child: BackdropFilter(
                                          filter: .blur(sigmaX: 2, sigmaY: 2),
                                          child: AlertDialog(
                                            contentPadding: .symmetric(
                                              horizontal: 30,
                                              vertical: 40,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: .circular(20),
                                              side: BorderSide(
                                                width: 0.2,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                    : ThemingColors.black,
                                              ),
                                            ),
                                            backgroundColor: context.isDark
                                                ? ThemingColors.black.withAlpha(
                                                    (0.1 * 255).toInt(),
                                                  )
                                                : ThemingColors.white.withAlpha(
                                                    (0.1 * 255).toInt(),
                                                  ),
                                            title: Text(
                                              "changeYourName".tr(),
                                              textAlign: .center,
                                              style: TextStyle(
                                                fontWeight: .bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            content: Column(
                                              mainAxisSize: .min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 40,
                                                        child: CustomTextFormField(
                                                          "street".tr(),
                                                          controller:
                                                              streetController,
                                                          keyBoardType:
                                                              TextInputType
                                                                  .text,
                                                          onChanged: (text) {
                                                            final oldValue =
                                                                cubit
                                                                    .user
                                                                    .street;
                                                            if (text !=
                                                                oldValue) {
                                                              cubit
                                                                  .addressChanged(
                                                                    street:
                                                                        true,
                                                                  );
                                                            } else {
                                                              cubit
                                                                  .addressChanged(
                                                                    street:
                                                                        false,
                                                                  );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 25),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 40,
                                                        child: CustomTextFormField(
                                                          "building".tr(),
                                                          controller:
                                                              buildingController,
                                                          keyBoardType:
                                                              TextInputType
                                                                  .text,
                                                          onChanged: (text) {
                                                            final oldValue =
                                                                cubit
                                                                    .user
                                                                    .building;
                                                            if (text !=
                                                                oldValue) {
                                                              cubit
                                                                  .addressChanged(
                                                                    building:
                                                                        true,
                                                                  );
                                                            } else {
                                                              cubit
                                                                  .addressChanged(
                                                                    building:
                                                                        false,
                                                                  );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 25),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: SizedBox(
                                                        height: 40,
                                                        child: CustomTextFormField(
                                                          "house".tr(),
                                                          controller:
                                                              apartmentController,
                                                          keyBoardType:
                                                              TextInputType
                                                                  .text,
                                                          onChanged: (text) {
                                                            final oldValue =
                                                                cubit
                                                                    .user
                                                                    .apartment;
                                                            if (text !=
                                                                oldValue) {
                                                              cubit
                                                                  .addressChanged(
                                                                    apartment:
                                                                        true,
                                                                  );
                                                            } else {
                                                              cubit
                                                                  .addressChanged(
                                                                    apartment:
                                                                        false,
                                                                  );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              BlocBuilder<
                                                HomeDataCubit,
                                                HomeDataState
                                              >(
                                                builder: (context, state) {
                                                  return Row(
                                                    children: [
                                                      cubit.isAddressChanged
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
                                                                    .addressChanged(
                                                                      street:
                                                                          false,
                                                                      building:
                                                                          false,
                                                                      apartment:
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
                                                                splashColor: Colors
                                                                    .transparent,
                                                                highlightColor:
                                                                    Colors
                                                                        .transparent,
                                                                onTap: () {
                                                                  cubit.addressChanged(
                                                                    street:
                                                                        false,
                                                                    building:
                                                                        false,
                                                                    apartment:
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
                                                      if (cubit
                                                          .isAddressChanged)
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              final userData = cubit.user.copyWith(
                                                                street:
                                                                    streetController
                                                                        .text,
                                                                building:
                                                                    buildingController
                                                                        .text,
                                                                apartment:
                                                                    apartmentController
                                                                        .text,
                                                              );
                                                              cubit.changeUserData(
                                                                updatedUserData:
                                                                    userData,
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
                                                                    vertical: 2,
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
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: .all(15),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: GlassCard(
                                      margin: .symmetric(horizontal: 20),
                                      padding: .zero,
                                      child: Row(
                                        children: [
                                          GlassCard(
                                            margin: .zero,
                                            padding: .zero,
                                            dark: true,
                                            child: SizedBox(
                                              width: 100,
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "street".tr(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: .bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                            child: Padding(
                                              padding: .symmetric(
                                                horizontal: 15,
                                              ),
                                              child: Text(
                                                cubit.user.street ?? "",
                                                maxLines: 1,
                                                overflow: .ellipsis,
                                                style: TextStyle(fontSize: 12),
                                              ),
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
                                  Expanded(
                                    child: GlassCard(
                                      margin: .symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      padding: .zero,
                                      child: Row(
                                        children: [
                                          GlassCard(
                                            margin: .zero,
                                            padding: .zero,
                                            dark: true,
                                            child: SizedBox(
                                              width: 100,
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "building".tr(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: .bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: .symmetric(horizontal: 15),
                                            child: Text(
                                              cubit.user.building ?? "",
                                              style: TextStyle(fontSize: 12),
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
                                  Expanded(
                                    child: GlassCard(
                                      margin: .symmetric(horizontal: 20),
                                      padding: .zero,
                                      child: Row(
                                        children: [
                                          GlassCard(
                                            margin: .zero,
                                            padding: .zero,
                                            dark: true,
                                            child: SizedBox(
                                              width: 100,
                                              height: 25,
                                              child: Center(
                                                child: Text(
                                                  "house".tr(),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: .bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: .symmetric(horizontal: 15),
                                            child: Text(
                                              cubit.user.apartment ?? "",
                                              style: TextStyle(fontSize: 12),
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
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: context.isDark
            ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
            : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        titleSpacing: 0,
        leadingWidth: 100,
        leading: BlocBuilder<HomeDataCubit, HomeDataState>(
          builder: (context, state) {
            return Builder(
              builder: (innerContext) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Scaffold.of(innerContext).openDrawer(),
                      child: Container(
                        padding: .all(5),
                        margin: .symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? ThemingColors.white.withAlpha(
                                  (0.1 * 255).toInt(),
                                )
                              : ThemingColors.black.withAlpha(
                                  (0.08 * 255).toInt(),
                                ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color:
                                (context.isDark ? Colors.white : Colors.black)
                                    .withAlpha((0.1 * 255).toInt()),
                            width: 2,
                          ),
                          shape: BoxShape.rectangle,
                        ),
                        alignment: .center,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: ThemingColors.primaryColor.withAlpha(
                            (0.2 * 255).toInt(),
                          ),
                          child: ClipOval(
                            child: cubit.user.hasProfileImage
                                ? SupabaseImageProvider(
                                    key: ValueKey(cubit.user.id),
                                    filePath: Buckets.usersImages,
                                    fileName: cubit.user.id,
                                    iconSize: 14,
                                    addIconSize: 14,
                                    loadingIconSize: 12,
                                    person: true,
                                    cacheWidth: 75,
                                    cacheHeight: 75,
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 18,
                                    color: ThemingColors.primaryColor,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        centerTitle: true,
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
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(76),
          child: Container(
            width: double.infinity,
            height: 76,
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
        actions: [
          TransparentButton(onTap: () {}, icon: Icons.search, size: 25),
        ],
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
        child: BlocBuilder<HomeDataCubit, HomeDataState>(
          builder: (context, homeDataState) {
            final cubit = context.read<HomeDataCubit>();
            if (homeDataState is HomeDataFailure) {
              return Center(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    cubit.getHomeData();
                  },
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      FadedScreen(
                        size: 80,
                        icon: Icons.cell_tower,
                        text: "noInternet".tr(),
                      ),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Padding(
                            padding: .only(right: 5),
                            child: Icon(
                              Icons.refresh,
                              size: 16,
                              color: ThemingColors.primaryColor,
                              fontWeight: .bold,
                            ),
                          ),
                          Text(
                            "tapToRetry".tr(),
                            style: TextStyle(fontSize: 12, fontWeight: .bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (homeDataState is HomeDataSuccess) {
              if (cubit.bakeries.isEmpty) {
                return Center(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      context.read<HomeDataCubit>().getHomeData();
                    },
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        FadedScreen(
                          size: 80,
                          icon: Icons.inbox_outlined,
                          text: "noNearbyBakeries".tr(),
                        ),
                        Row(
                          mainAxisAlignment: .center,
                          children: [
                            Padding(
                              padding: .only(right: 5),
                              child: Icon(
                                Icons.refresh,
                                size: 16,
                                color: ThemingColors.primaryColor,
                                fontWeight: .bold,
                              ),
                            ),
                            Text(
                              "tapToRetry".tr(),
                              style: TextStyle(fontSize: 12, fontWeight: .bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return RefreshIndicator(
                edgeOffset: 180,
                strokeWidth: 2,
                displacement: 0,
                elevation: 0,
                color: ThemingColors.primaryColor,
                backgroundColor: Colors.transparent,
                onRefresh: () async {
                  cubit.setRefresh(true);
                  await cubit.getHomeData(isRefreshing: true);
                  cubit.setRefresh(false);
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: .only(
                    top: cubit.refreshStatus ? 230 : 200,
                    bottom: 120,
                  ),
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      //TODO stories
                      BlocProvider.value(
                        value: DependencyInjection.getIt<ActiveOrdersCubit>(),
                        child: ActiveOrdersWidget(),
                      ),
                      ListView.separated(
                        padding: .zero,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: cubit.bakeries.length,
                        separatorBuilder: (_, index) {
                          return SizedBox();
                        },
                        itemBuilder: (_, index) {
                          final HomeDataBakeriesModel bakery =
                              cubit.bakeries[index];
                          return BakeryListTile(bakery: bakery);
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (homeDataState is HomeDataInitial) {
              return SizedBox();
            }
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: ThemingColors.primaryColor,
                size: 25,
              ),
            );
          },
        ),
      ),
    );
  }
}
