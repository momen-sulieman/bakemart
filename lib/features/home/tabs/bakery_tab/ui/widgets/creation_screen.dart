import 'dart:io';
import 'dart:ui';

import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../core/shared/models/bakery_model.dart';
import '../../../../../../core/shared/models/payroll_model.dart';
import '../../../../../../core/shared/models/product_model.dart';
import '../../../../../../core/shared/models/storage_model.dart';
import '../../../../../../core/shared/widgets/dialogs/add_product_dialog/ui/add_product_dialog.dart';
import '../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../../../../core/shared/widgets/product_details_screen/product_details_screen.dart';
import '../../../../../../core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import '../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../../../core/utils/enums/storage_items.dart';
import '../../../../../../core/utils/extensions/context_extensions.dart';
import '../../../../../../core/utils/extensions/string_extension.dart';

class CreationScreen extends StatelessWidget {
  const CreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final cubit = context.read<BakeryTabCubit>();
    final List<String> payrollMethods = ["dailyWage".tr(), "batchWage".tr()];

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: context.isDark ? 5 : 10,
        sigmaY: context.isDark ? 5 : 10,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Material(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.only(
                  top: 10,
                  bottom: 10,
                  left: context.locale.languageCode == "ar" ? 0 : 20,
                  right: context.locale.languageCode == "ar" ? 20 : 0,
                ),
                dark: true,
                responsive: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "createYourBakery".tr(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TransparentButton(
                      onTap: () {
                        cubit.setCertificateImage(null);
                        Navigator.pop(context);
                      },
                      icon: Icons.close,
                      isCircle: true,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              BlocProvider(
                create: (_) => DependencyInjection.getIt<SupabaseImageCubit>(
                  param1: Buckets.bakeriesImages,
                  param2: null,
                ),
                child: Builder(
                  builder: (imageContext) {
                    return Center(
                      child: Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.32,
                            height: screenWidth * 0.32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.isDark
                                  ? ThemingColors.darkGrey
                                  : Colors.grey,
                            ),
                            child: ClipOval(
                              child: const SupabaseImage(addIconSize: 40),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 5,
                            child: InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                imageContext
                                    .read<SupabaseImageCubit>()
                                    .pickImage(false);
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.3 * 255).toInt(),
                                  ),
                                ),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(10),
                      radius: 15,
                      otherRadius: 15,
                      child: Text(
                        "locationNote".tr(),
                        style: TextStyle(
                          fontSize: context.locale.languageCode == "ar"
                              ? 14
                              : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 35,
                      child: CustomTextFormField(
                        "bakeryName".tr(),
                        controller: cubit.nameController,
                        onChanged: cubit.onNameSet,
                      ),
                    ),
                  ),
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      cubit.locationEditingMode(!cubit.isLocationEditing);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      margin: context.locale.languageCode == "ar"
                          ? const EdgeInsets.only(right: 10)
                          : const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.isDark
                            ? ThemingColors.black.withAlpha((0.8 * 255).toInt())
                            : ThemingColors.white.withAlpha(
                                (0.7 * 255).toInt(),
                              ),
                        border: Border.all(
                          color: context.isDark
                              ? ThemingColors.white.withAlpha(
                                  (0.2 * 255).toInt(),
                                )
                              : ThemingColors.black.withAlpha(
                                  (0.2 * 255).toInt(),
                                ),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 23,
                        color: ThemingColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  if (cubit.isLocationEditing) {
                    final locationState = context.read<LocationCubit>().state;
                    final double? liveLat = locationState is LocationUpdated
                        ? locationState.lat
                        : null;
                    final double? liveLng = locationState is LocationUpdated
                        ? locationState.lng
                        : null;
                    return Container(
                      height: screenHeight * 0.5,
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: ThemingColors.primaryColor.withAlpha(
                          (0.2 * 255).toInt(),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: LocationPickerMap.setter(
                        initialLat: cubit.bakeryLat,
                        initialLng: cubit.bakeryLng,
                        deviceLat: liveLat,
                        deviceLng: liveLng,
                        alwaysShow: true,
                        onPositionChanged: (lat, lng) {
                          cubit.updatePendingLocation(lat: lat, lng: lng);
                        },
                        onSet: (lat, lng) {
                          cubit.updatePendingLocation(lat: lat, lng: lng);
                          cubit.locationEditingMode(false);
                        },
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.all(10),
                      radius: 15,
                      otherRadius: 15,
                      child: Text(
                        "branchNameNote".tr(),
                        style: TextStyle(
                          fontSize: context.locale.languageCode == "ar"
                              ? 14
                              : 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 35,
                child: CustomTextFormField(
                  "branchName".tr(),
                  controller: cubit.branchNameController,
                  onChanged: cubit.onBranchNameSet,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "${"note".tr()}: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: context.isDark ? Colors.amber : Colors.orange,
                      ),
                    ),
                    TextSpan(
                      text: "mainBranchNote".tr(),
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  final captured = cubit.pendingCertificateImage != null;
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    orange: !captured,
                    green: captured,
                    responsive: true,
                    child: SizedBox(
                      width: (screenWidth * 0.5) - 60,
                      child: Text(
                        "photographicConfirmation".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.locale.languageCode == "ar"
                              ? 18
                              : 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  final captured = cubit.pendingCertificateImage != null;
                  return InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      final XFile? picked = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        preferredCameraDevice: CameraDevice.rear,
                        imageQuality: 85,
                      );
                      if (picked == null) return;
                      cubit.setCertificateImage(File(picked.path));
                    },
                    child: GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      radius: 20,
                      otherRadius: 20,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 15, bottom: 5),
                            child: Text(
                              "pictureBakery".tr(),
                              style: TextStyle(
                                fontSize: context.locale.languageCode == "ar"
                                    ? 14
                                    : 12,
                              ),
                            ),
                          ),
                          GlassCard(
                            margin: .symmetric(vertical: 10),
                            padding: .zero,
                            otherRadius: 25,
                            orange: !captured,
                            green: captured,
                            child: SizedBox(
                              height: 30,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.linked_camera,
                                    color: ThemingColors.primaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    captured
                                        ? "recapture".tr()
                                        : "captureBakery".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == "ar"
                                          ? 14
                                          : 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  final products = cubit.editableProducts;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassCard(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 5,
                        ),
                        orange: cubit.editableProducts.isEmpty,
                        green: cubit.editableProducts.isNotEmpty,
                        responsive: true,
                        child: SizedBox(
                          width: (screenWidth * 0.5) - 60,
                          child: Text(
                            "products".tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.locale.languageCode == "ar"
                                  ? 18
                                  : 16,
                            ),
                          ),
                        ),
                      ),
                      GlassCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        radius: 20,
                        otherRadius: 20,
                        child: Column(
                          children: [
                            products.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Text(
                                      "addYourProductsHere".tr(),
                                      style: TextStyle(
                                        fontSize:
                                            context.locale.languageCode == "ar"
                                            ? 14
                                            : 12,
                                      ),
                                    ),
                                  )
                                : Table(
                                    border: TableBorder(
                                      horizontalInside: BorderSide(
                                        width: 0.5,
                                        color: ThemingColors.primaryColor
                                            .withAlpha((0.2 * 255).toInt()),
                                      ),
                                      verticalInside: BorderSide(
                                        width: 2,
                                        color: ThemingColors.primaryColor
                                            .withAlpha((0.2 * 255).toInt()),
                                      ),
                                    ),
                                    columnWidths: const {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(1),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              width: 2,
                                              color: ThemingColors.primaryColor
                                                  .withAlpha(
                                                    (0.4 * 255).toInt(),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 7,
                                              horizontal: 10,
                                            ),
                                            child: TextCell(
                                              string: Text(
                                                "product".tr(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: context.isDark
                                                      ? ThemingColors.white
                                                            .withAlpha(
                                                              (0.3 * 255)
                                                                  .toInt(),
                                                            )
                                                      : ThemingColors.black
                                                            .withAlpha(
                                                              (0.3 * 255)
                                                                  .toInt(),
                                                            ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 7,
                                                    ),
                                                child: TextCell(
                                                  string: Text(
                                                    "weight".tr(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                                .withAlpha(
                                                                  (0.3 * 255)
                                                                      .toInt(),
                                                                )
                                                          : ThemingColors.black
                                                                .withAlpha(
                                                                  (0.3 * 255)
                                                                      .toInt(),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 7,
                                                    ),
                                                child: TextCell(
                                                  string: Text(
                                                    "price".tr(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                                .withAlpha(
                                                                  (0.3 * 255)
                                                                      .toInt(),
                                                                )
                                                          : ThemingColors.black
                                                                .withAlpha(
                                                                  (0.3 * 255)
                                                                      .toInt(),
                                                                ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      ...products.asMap().entries.map((entry) {
                                        final int index = entry.key;
                                        final ProductModel product =
                                            entry.value;
                                        return TableRow(
                                          children: [
                                            InkWell(
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (dialogContext) {
                                                    return BlocProvider.value(
                                                      value: cubit,
                                                      child:
                                                          ProductDetailsScreen(
                                                            product: product,
                                                            creation: true,
                                                            nutrition: false,
                                                            cubit: cubit,
                                                            productIndex: index,
                                                          ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? const EdgeInsets.only(
                                                              left: 10,
                                                            )
                                                          : const EdgeInsets.only(
                                                              right: 10,
                                                            ),
                                                      child: InkWell(
                                                        hoverColor:
                                                            Colors.transparent,
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () {
                                                          cubit.removeProduct(
                                                            index: index,
                                                          );
                                                        },
                                                        child: const Icon(
                                                          Icons
                                                              .delete_forever_outlined,
                                                          size: 16,
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? const EdgeInsets.only(
                                                              left: 10,
                                                            )
                                                          : const EdgeInsets.only(
                                                              right: 10,
                                                            ),
                                                      child: CircleAvatar(
                                                        radius: 13,
                                                        backgroundColor:
                                                            ThemingColors
                                                                .primaryColor
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                ),
                                                        child: ClipOval(
                                                          child:
                                                              cubit
                                                                  .pendingProductImages
                                                                  .containsKey(
                                                                    product
                                                                        .productId,
                                                                  )
                                                              ? SizedBox.expand(
                                                                  child: Image.file(
                                                                    cubit
                                                                        .pendingProductImages[product
                                                                        .productId]!,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                )
                                                              : SupabaseImageProvider(
                                                                  filePath: Buckets
                                                                      .productsImages,
                                                                  fileName: product
                                                                      .productId,
                                                                  iconSize: 13,
                                                                  loadingIconSize:
                                                                      14,
                                                                  cacheWidth:
                                                                      75,
                                                                  cacheHeight:
                                                                      75,
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        product.productName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              context
                                                                      .locale
                                                                      .languageCode ==
                                                                  "ar"
                                                              ? 14
                                                              : 12,
                                                          color: ThemingColors
                                                              .primaryColor,
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          decorationColor:
                                                              ThemingColors
                                                                  .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 10,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                          ),
                                                      child: Text(
                                                        "${product.productWeight}",
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize:
                                                              context
                                                                      .locale
                                                                      .languageCode ==
                                                                  "ar"
                                                              ? 14
                                                              : 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "g".tr(),
                                                    style: TextStyle(
                                                      fontSize:
                                                          context
                                                                  .locale
                                                                  .languageCode ==
                                                              "ar"
                                                          ? 14
                                                          : 12,
                                                      color: context.isDark
                                                          ? Colors.amber
                                                          : Colors.orange,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 10,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      product.productPrice
                                                          .toStringAsFixed(2),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize:
                                                            context
                                                                    .locale
                                                                    .languageCode ==
                                                                "ar"
                                                            ? 14
                                                            : 12,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    " \$",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                    ],
                                  ),
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 15,
                                bottom: 10,
                              ),
                              child: TransparentButton(
                                onTap: () {
                                  showDialog(
                                    barrierColor: Colors.transparent,
                                    context: context,
                                    builder: (dialogContext) =>
                                        AddProductDialog(
                                          bakeryId: "",
                                          branchIds: const [""],
                                          initialFlourIndex: 1,
                                          onSave: (products, image) =>
                                              cubit.addProduct(
                                                products.first,
                                                image: image,
                                              ),
                                        ),
                                  );
                                },
                                icon: Icons.add,
                                size: 18,
                                verticalPadding: 5,
                                buttonHorizontalPading: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    orange: !cubit.payrollValidity,
                    green: cubit.payrollValidity,
                    responsive: true,
                    child: SizedBox(
                      width: (screenWidth * 0.5) - 60,
                      child: Text(
                        "payroll".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.locale.languageCode == "ar"
                              ? 18
                              : 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              GlassCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                otherRadius: 30,
                child: Column(
                  children: [
                    GlassCard(
                      margin: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 5,
                        bottom: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      otherRadius: 15,
                      radius: 15,
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: context.locale.languageCode == "ar"
                                ? 14
                                : 12,
                          ),
                          children: [
                            TextSpan(text: "payrollNote1".tr()),
                            TextSpan(
                              text: "payrollNote2".tr(),
                              style: TextStyle(
                                fontSize: context.locale.languageCode == "ar"
                                    ? 14
                                    : 12,
                                color: context.isDark
                                    ? ThemingColors.white.withAlpha(
                                        (0.5 * 255).toInt(),
                                      )
                                    : ThemingColors.black.withAlpha(
                                        (0.3 * 255).toInt(),
                                      ),
                              ),
                            ),
                            TextSpan(text: "payrollNote3".tr()),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: context.locale.languageCode == "ar"
                              ? const EdgeInsets.only(left: 10)
                              : const EdgeInsets.only(right: 10),
                          child: Text(
                            "payrollMethod".tr(),
                            style: TextStyle(
                              fontSize: context.locale.languageCode == "ar"
                                  ? 14
                                  : 12,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: context.isDark
                                ? ThemingColors.black.withAlpha(
                                    (0.6 * 255).toInt(),
                                  )
                                : ThemingColors.white.withAlpha(
                                    (0.6 * 255).toInt(),
                                  ),
                            border: Border.all(
                              width: 0.3,
                              color: context.isDark
                                  ? ThemingColors.white.withAlpha(
                                      (0.4 * 255).toInt(),
                                    )
                                  : ThemingColors.black.withAlpha(
                                      (0.5 * 255).toInt(),
                                    ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_right,
                                size: 25,
                                color: ThemingColors.primaryColor,
                              ),
                              SizedBox(
                                height: 70,
                                width: 90,
                                child: WheelPicker(
                                  controller: WheelPickerController(
                                    itemCount: payrollMethods.length,
                                    initialIndex: cubit.selectedPayrollMethod
                                        ? 0
                                        : 1,
                                  ),
                                  looping: false,
                                  style: const WheelPickerStyle(
                                    itemExtent: 22,
                                    surroundingOpacity: 0.4,
                                    diameterRatio: 10,
                                    magnification: 1,
                                  ),
                                  onIndexChanged: (index, _) {
                                    cubit.setPayrollMethod(index == 0);
                                  },
                                  builder: (context, index) {
                                    return Center(
                                      child: Text(payrollMethods[index]),
                                    );
                                  },
                                ),
                              ),
                              Icon(
                                Icons.arrow_left,
                                size: 25,
                                color: ThemingColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...cubit.payrollFields.map((field) {
                      final String label = field.$1;
                      final TextEditingController controller = field.$2;
                      final bool isRequired = field.$3;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.4,
                              height: 40,
                              child: CustomTextFormField(
                                label.tr(),
                                controller: controller,
                                onChanged: (_) => cubit.validatePayrollInputs(),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                "\$",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            if (isRequired) ...[
                              Padding(
                                padding: context.locale.languageCode == "ar"
                                    ? const EdgeInsets.only(right: 10)
                                    : const EdgeInsets.only(left: 10),
                                child: Text(
                                  "required".tr(),
                                  style: TextStyle(
                                    fontSize:
                                        context.locale.languageCode == "ar"
                                        ? 12
                                        : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Text(
                                "*",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              BlocBuilder<BakeryTabCubit, BakeryTabState>(
                builder: (context, state) {
                  return GlassCard(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    orange: !cubit.storageValidity,
                    green: cubit.storageValidity,
                    responsive: true,
                    child: SizedBox(
                      width: (screenWidth * 0.5) - 60,
                      child: Text(
                        "storageTab".tr(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: context.locale.languageCode == "ar"
                              ? 18
                              : 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
              GlassCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                otherRadius: 30,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GlassCard(
                            margin: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 5,
                              bottom: 20,
                            ),
                            padding: const EdgeInsets.all(10),
                            otherRadius: 15,
                            radius: 15,
                            child: Text(
                              "storageNote".tr(),
                              style: TextStyle(
                                fontSize: context.locale.languageCode == "ar"
                                    ? 14
                                    : 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...cubit.storageFields.map((field) {
                      final label = field.$1;
                      final controller = field.$2;
                      final unit = field.$3;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            SizedBox(
                              width: screenWidth * 0.4,
                              height: 40,
                              child: CustomTextFormField(
                                label.tr(),
                                controller: controller,
                                onChanged: (_) => cubit.onStorageFieldChanged(),
                              ),
                            ),
                            Padding(
                              padding: context.locale.languageCode == "ar"
                                  ? const EdgeInsets.only(right: 10)
                                  : const EdgeInsets.only(left: 10),
                              child: Text(
                                unit.tr(),
                                style: TextStyle(
                                  fontSize: context.locale.languageCode == "ar"
                                      ? 14
                                      : 12,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDark
                                      ? Colors.amber
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: BlocBuilder<BakeryTabCubit, BakeryTabState>(
                  builder: (context, state) {
                    return Row(
                      children: [
                        cubit.formValidity
                            ? InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: GlassCard(
                                  margin: context.locale.languageCode == "ar"
                                      ? const EdgeInsets.only(left: 6)
                                      : const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 18,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                              )
                            : Expanded(
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: GlassCard(
                                    margin: EdgeInsets.zero,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 18,
                                      color: ThemingColors.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                        if (cubit.formValidity)
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                final BakeryModel bakeryData = BakeryModel(
                                  bakeryName: cubit.nameController.text
                                      .capitalize(),
                                  branchName: cubit.branchNameController.text
                                      .capitalize(),
                                  bakeryId: "",
                                  branchId: "",
                                  bakeryLat: cubit.bakeryLat,
                                  bakeryLng: cubit.bakeryLng,
                                  supervisorId: [],
                                  branchNumber: 1,
                                );

                                double? valueFor(String label) {
                                  final field = cubit.payrollFields.firstWhere(
                                    (f) => f.$1 == label,
                                  );
                                  return double.tryParse(
                                    field.$2.text.toEnglishDigits(),
                                  );
                                }

                                int? storageValueFor(String label) {
                                  final field = cubit.storageFields.firstWhere(
                                    (f) => f.$1 == label,
                                  );
                                  return int.tryParse(
                                    field.$2.text.toEnglishDigits(),
                                  );
                                }

                                final PayrollModel payroll = PayrollModel(
                                  bakeryId: "",
                                  branchId: "",
                                  payrollMethod: cubit.selectedPayrollMethod,
                                  supervisor: valueFor(
                                    PayrollsTableColumns.supervisor,
                                  ),
                                  chef: valueFor(PayrollsTableColumns.chef),
                                  coChef: valueFor(PayrollsTableColumns.coChef),
                                  ajan: valueFor(PayrollsTableColumns.ajan),
                                  faran: valueFor(PayrollsTableColumns.faran),
                                  tawlaji: valueFor(
                                    PayrollsTableColumns.tawlaji,
                                  ),
                                  bagger: valueFor(PayrollsTableColumns.bagger),
                                );

                                final StorageModel storage = StorageModel(
                                  bakeryId: "",
                                  branchId: "",
                                  fineWheat: storageValueFor(
                                    StorageItems.fineWheat,
                                  ),
                                  wholeWheat: storageValueFor(
                                    StorageItems.wholeWheat,
                                  ),
                                  corn: storageValueFor(StorageItems.corn),
                                  oats: storageValueFor(StorageItems.oats),
                                  barley: storageValueFor(StorageItems.barley),
                                  semolina: storageValueFor(
                                    StorageItems.semolina,
                                  ),
                                  phyllo: storageValueFor(StorageItems.phyllo),
                                  yeast: storageValueFor(StorageItems.yeast),
                                  salt: storageValueFor(StorageItems.salt),
                                  sugar: storageValueFor(StorageItems.sugar),
                                  eggs: storageValueFor(StorageItems.eggs),
                                  ghee: storageValueFor(StorageItems.ghee),
                                  oil: storageValueFor(StorageItems.oil),
                                  butter: storageValueFor(StorageItems.butter),
                                  sesame: storageValueFor(StorageItems.sesame),
                                  blackSeeds: storageValueFor(
                                    StorageItems.blackSeeds,
                                  ),
                                  fennel: storageValueFor(StorageItems.fennel),
                                  anise: storageValueFor(StorageItems.anise),
                                  mahlab: storageValueFor(StorageItems.mahlab),
                                  cinnamon: storageValueFor(
                                    StorageItems.cinnamon,
                                  ),
                                  bakingPowder: storageValueFor(
                                    StorageItems.bakingPowder,
                                  ),
                                  bakingSoda: storageValueFor(
                                    StorageItems.bakingSoda,
                                  ),
                                  chocolate: storageValueFor(
                                    StorageItems.chocolate,
                                  ),
                                  conditioner: storageValueFor(
                                    StorageItems.conditioner,
                                  ),
                                  vanilla: storageValueFor(
                                    StorageItems.vanilla,
                                  ),
                                  milk: storageValueFor(StorageItems.milk),
                                  milkPowder: storageValueFor(
                                    StorageItems.milkPowder,
                                  ),
                                  whippingCream: storageValueFor(
                                    StorageItems.whippingCream,
                                  ),
                                  condensedMilk: storageValueFor(
                                    StorageItems.condensedMilk,
                                  ),
                                  datePaste: storageValueFor(
                                    StorageItems.datePaste,
                                  ),
                                  malban: storageValueFor(StorageItems.malban),
                                  whiteCheese: storageValueFor(
                                    StorageItems.whiteCheese,
                                  ),
                                  roumyCheese: storageValueFor(
                                    StorageItems.roumyCheese,
                                  ),
                                  istanbouliCheese: storageValueFor(
                                    StorageItems.istanbouliCheese,
                                  ),
                                  mozzarella: storageValueFor(
                                    StorageItems.mozzarella,
                                  ),
                                  olives: storageValueFor(StorageItems.olives),
                                  peanut: storageValueFor(StorageItems.peanut),
                                  cashew: storageValueFor(StorageItems.cashew),
                                  almond: storageValueFor(StorageItems.almond),
                                  pistachio: storageValueFor(
                                    StorageItems.pistachio,
                                  ),
                                  custard: storageValueFor(
                                    StorageItems.custard,
                                  ),
                                  cocoa: storageValueFor(StorageItems.cocoa),
                                  coconutPowder: storageValueFor(
                                    StorageItems.coconutPowder,
                                  ),
                                  blackMolasses: storageValueFor(
                                    StorageItems.blackMolasses,
                                  ),
                                );

                                final List<ProductModel> products =
                                    cubit.editableProducts;
                                cubit.createBakery(
                                  bakeryData: bakeryData,
                                  products: products,
                                  payroll: payroll,
                                  storage: storage,
                                );
                                Navigator.pop(context);
                              },
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: GlassCard(
                                margin: context.locale.languageCode == "ar"
                                    ? const EdgeInsets.only(right: 6)
                                    : const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: const Icon(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
