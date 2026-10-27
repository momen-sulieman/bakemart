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
import '../../../../../core/shared/models/bakery_model.dart';
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
            child: Icon(Icons.edit, size: 16, color: ThemingColors.white),
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
                                    filter: .blur(sigmaX: 10, sigmaY: 10),
                                    child: AlertDialog(
                                      contentPadding: .symmetric(
                                        horizontal: 30,
                                        vertical: 40,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: .circular(20),
                                        side: BorderSide(
                                          width: 1,
                                          color: context.isDark
                                              ? ThemingColors.white.withAlpha(
                                                  (0.2 * 255).toInt(),
                                                )
                                              : ThemingColors.black.withAlpha(
                                                  (0.2 * 255).toInt(),
                                                ),
                                        ),
                                      ),
                                      backgroundColor: context.isDark
                                          ? ThemingColors.black.withAlpha(
                                              (0.2 * 255).toInt(),
                                            )
                                          : ThemingColors.white.withAlpha(
                                              (0.2 * 255).toInt(),
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
                                  final TextEditingController streetController =
                                      TextEditingController(
                                        text: cubit.user.street,
                                      );
                                  final TextEditingController
                                  buildingController = TextEditingController(
                                    text: cubit.user.building,
                                  );
                                  final TextEditingController
                                  apartmentController = TextEditingController(
                                    text: cubit.user.apartment,
                                  );
                                  showDialog(
                                    barrierColor: Colors.transparent,
                                    context: context,
                                    builder: (dialogContext) {
                                      return BlocProvider.value(
                                        value: cubit,
                                        child: BackdropFilter(
                                          filter: .blur(sigmaX: 10, sigmaY: 10),
                                          child: AlertDialog(
                                            contentPadding: .symmetric(
                                              horizontal: 30,
                                              vertical: 40,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: .circular(20),
                                              side: BorderSide(
                                                width: 1,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                          .withAlpha(
                                                            (0.2 * 255).toInt(),
                                                          )
                                                    : ThemingColors.black
                                                          .withAlpha(
                                                            (0.2 * 255).toInt(),
                                                          ),
                                              ),
                                            ),
                                            backgroundColor: context.isDark
                                                ? ThemingColors.black.withAlpha(
                                                    (0.2 * 255).toInt(),
                                                  )
                                                : ThemingColors.white.withAlpha(
                                                    (0.2 * 255).toInt(),
                                                  ),
                                            title: Text(
                                              "changeYourAddress".tr(),
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
                      onTap: () {
                        cubit.setSearchingMode(false);
                        Scaffold.of(innerContext).openDrawer();
                      },
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
            cubit.setSearchingMode(false);
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
                    (0.3 * 255).toInt(),
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
          TransparentButton(
            onTap: () {
              cubit.setSearchingMode(!cubit.searchingMode);
            },
            buttonWidget: BlocBuilder<HomeDataCubit, HomeDataState>(
              builder: (context, state) {
                return Icon(
                  cubit.searchingMode ? Icons.search_off : Icons.search,
                  color: cubit.searchingMode
                      ? null
                      : ThemingColors.primaryColor,
                  fontWeight: .bold,
                );
              },
            ),
            size: 25,
          ),
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
              if (cubit.searchingMode) {
                return const _SearchView();
              }
              if (cubit.nearbyBakeries.isEmpty) {
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
              return Padding(
                padding: .only(top: 200),
                child: Column(
                  children: [
                    //Todo stories
                    BlocProvider.value(
                      value: DependencyInjection.getIt<ActiveOrdersCubit>(),
                      child: ActiveOrdersWidget(),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        edgeOffset: 0,
                        strokeWidth: 2,
                        displacement: 20,
                        elevation: 0,
                        color: ThemingColors.primaryColor,
                        backgroundColor: Colors.transparent,
                        onRefresh: () async {
                          cubit.setRefresh(true);
                          await cubit.getHomeData(isRefreshing: true);
                          cubit.setRefresh(false);
                        },
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: .only(
                            top: cubit.refreshStatus ? 30 : 0,
                            bottom: 120,
                          ),
                          itemCount: cubit.nearbyBakeries.length,
                          itemBuilder: (_, index) {
                            final HomeDataBakeriesModel bakery =
                                cubit.nearbyBakeries[index];
                            return BakeryListTile(bakery: bakery);
                          },
                        ),
                      ),
                    ),
                  ],
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

class _SearchView extends StatelessWidget {
  const _SearchView();

  void _showBranchesDialog(
    BuildContext context,
    HomeDataCubit cubit,
    HomeDataBakeriesModel item,
  ) {
    final NavigatorState navigator = Navigator.of(context);
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              titlePadding: const EdgeInsets.only(top: 25, left: 25, right: 25),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 50,
              ),
              actionsPadding: const EdgeInsets.only(
                bottom: 25,
                left: 25,
                right: 25,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  width: 1,
                  color: context.isDark
                      ? ThemingColors.white.withAlpha((0.2 * 255).toInt())
                      : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
                ),
              ),
              backgroundColor: context.isDark
                  ? ThemingColors.black.withAlpha((0.9 * 255).toInt())
                  : ThemingColors.white.withAlpha((0.7 * 255).toInt()),
              title: Text(
                item.bakeryModel.bakeryName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: BlocBuilder<HomeDataCubit, HomeDataState>(
                  builder: (context, state) {
                    final List<BakeryModel> branches = cubit.branchesOf(
                      item.bakeryModel.bakeryId,
                    );
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: branches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, index) {
                        final BakeryModel branch = branches[index];
                        final bool isLoading =
                            cubit.loadingBranchId == branch.branchId;
                        return InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            final HomeDataBakeriesModel? details = await cubit
                                .getBranchDetails(branch);
                            if (details == null || !dialogContext.mounted) {
                              return;
                            }
                            Navigator.pop(dialogContext);
                            navigator.pushNamed(
                              AppRoutes.bakeryDetails.route,
                              arguments: details,
                            );
                          },
                          child: GlassCard(
                            margin: .symmetric(horizontal: 30),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            otherRadius: 30,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    branch.branchName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                isLoading
                                    ? LoadingAnimationWidget.staggeredDotsWave(
                                        color: ThemingColors.primaryColor,
                                        size: 18,
                                      )
                                    : Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: ThemingColors.primaryColor,
                                      ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (cubit.loadingBranchId != null) return;
                    Navigator.pop(dialogContext);
                  },
                  child: GlassCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Center(
                      child: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: ThemingColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeDataCubit>();
    return BlocBuilder<HomeDataCubit, HomeDataState>(
      builder: (context, state) {
        final List<HomeDataBakeriesModel> results = cubit.searchResults;
        final bool hasQuery = cubit.searchQuery.trim().isNotEmpty;
        return Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Column(
            children: [
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: .center,
                          children: [
                            Icon(
                              Icons.search,
                              size: 85,
                              color: hasQuery
                                  ? Colors.redAccent.withAlpha(
                                      (0.2 * 255).toInt(),
                                    )
                                  : context.isDark
                                  ? ThemingColors.white.withAlpha(
                                      (0.1 * 255).toInt(),
                                    )
                                  : ThemingColors.black.withAlpha(
                                      (0.1 * 255).toInt(),
                                    ),
                              fontWeight: .bold,
                            ),
                            SizedBox(height: 10),
                            hasQuery
                                ? Text("noBakeryFound".tr(),style: TextStyle(
                              color: context.isDark
                                  ? ThemingColors.white.withAlpha(
                                (0.5 * 255).toInt(),
                              )
                                  : ThemingColors.black.withAlpha(
                                (0.5 * 255).toInt(),
                              ),
                            ),):SizedBox(height: 16,)
                          ],
                        ),
                      )
                    : ListView.builder(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemCount: results.length,
                        itemBuilder: (_, index) {
                          final HomeDataBakeriesModel item = results[index];
                          final int count = cubit.branchesCount(
                            item.bakeryModel.bakeryId,
                          );
                          return BakeryListTile(
                            bakery: item,
                            numberOfBranches: count > 1 ? count : null,
                            branches: count > 1
                                ? cubit.branchesOf(item.bakeryModel.bakeryId)
                                : const [],
                            onTap: count > 1
                                ? () =>
                                      _showBranchesDialog(context, cubit, item)
                                : null,
                          );
                        },
                      ),
              ),
              Focus(
                onFocusChange: cubit.setSearchFocus,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    10,
                    20,
                    cubit.isSearchFocused ? 10 : 120,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: CustomTextFormField(
                            "searchForBakery".tr(),
                            hint: "bakeryName".tr(),
                            autofocus: true,
                            controller: cubit.searchController,
                            keyBoardType: TextInputType.text,
                            onChanged: cubit.setSearchQuery,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      TransparentButton(
                        onTap: () {
                          cubit.setSearchingMode(false);
                        },
                        isCircle: true,
                        icon: Icons.close,
                        buttonHorizontalPading: 0,
                        size: 22,
                        color: Colors.redAccent,
                        buttonSize: 35,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
