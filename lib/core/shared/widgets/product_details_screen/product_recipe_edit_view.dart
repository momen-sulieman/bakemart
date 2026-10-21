import 'dart:ui';

import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/ui/supabase_image.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import 'product_details_shared.dart';

const _flourTypes = kFlourTypes;

class ProductRecipeEditView extends StatelessWidget {
  final ProductModel product;

  const ProductRecipeEditView({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final productEditingController = TextEditingController();
    final cubit = context.read<SettingsCubit>();
    Future<void> confirmDeleteProduct({required String productId,required String branchId,}) async {
      final isConfirmed = await showDialog<bool>(
        context: context,
        barrierColor: Colors.transparent,
        builder: (dialogContext) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            titlePadding: .only(left: 15, right: 15, top: 15),
            contentPadding: .symmetric(horizontal: 10, vertical: 50),
            actionsPadding: .only(left: 20, right: 20, bottom: 20),
            shape: RoundedRectangleBorder(
              borderRadius: .circular(20),
              side: BorderSide(
                width: 0.3,
                color: context.isDark
                    ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
                    : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
              ),
            ),
            backgroundColor:
            (context.isDark ? ThemingColors.black : ThemingColors.white)
                .withAlpha((0.8 * 255).toInt()),
            title: Text(
              "deleteProduct".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "deleteProductConfirmation".tr(),
              textAlign: TextAlign.center,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => Navigator.pop(dialogContext, false),
                      child: GlassCard(
                        margin: .zero,
                        padding: .symmetric(vertical: 2),
                        child: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: ThemingColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => Navigator.pop(dialogContext, true),
                    child: GlassCard(
                      margin: .zero,
                      padding: .symmetric(vertical: 2, horizontal: 15),
                      green: true,
                      child: Icon(
                        Icons.delete_forever_outlined,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (isConfirmed == true && context.mounted) {
        await cubit.deleteProduct(productId: productId,branchId: branchId);
        if (!context.mounted) return;
        Navigator.pop(context);
      }
    }

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final currentProduct = state is SettingsSuccess
            ? state.products.firstWhereOrNull(
                    (p) => p.productId == product.productId,
                  ) ??
                  product
            : product;

        void editField({
          required String title,
          required String initialText,
          required bool Function(String) hasChanged,
          required VoidCallback onSave,
          bool textKeypad = false,
        }) {
          productEditingController.text = initialText;
          openValueEditDialog(
            context: context,
            cubit: cubit,
            title: title,
            textKeypad: textKeypad,
            controller: productEditingController,
            hasChanged: hasChanged,
            onSave: onSave,
          );
        }

        void openFlourTypeDialog() {
          final oldIndex = _flourTypes.indexOf(
            currentProduct.productRecipe.flourType,
          );
          String newFlourType = _flourTypes[oldIndex];
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            builder: (dialogContext) => BlocProvider.value(
              value: cubit,
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) => BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: AlertDialog(
                    contentPadding: const EdgeInsets.all(15),
                    titlePadding: const EdgeInsets.only(
                      top: 15,
                      left: 15,
                      right: 15,
                    ),
                    actionsPadding: const EdgeInsets.only(
                      bottom: 15,
                      left: 15,
                      right: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        width: 0.2,
                        color: context.isDark
                            ? ThemingColors.white
                            : ThemingColors.black,
                      ),
                    ),
                    backgroundColor:
                        (context.isDark
                                ? ThemingColors.black
                                : ThemingColors.white)
                            .withAlpha((0.2 * 255).toInt()),
                    title: _boxedContent(
                      context,
                      Text("flourType".tr(), textAlign: TextAlign.center),
                    ),
                    content: _boxedContent(
                      context,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_right,
                            size: 22,
                            color: ThemingColors.primaryColor,
                          ),
                          SizedBox(
                            height: 70,
                            width: 150,
                            child: WheelPicker(
                              controller: WheelPickerController(
                                itemCount: _flourTypes.length,
                                initialIndex: oldIndex,
                              ),
                              looping: false,
                              style: const WheelPickerStyle(
                                itemExtent: 25,
                                surroundingOpacity: 0.4,
                                diameterRatio: 10,
                                magnification: 1,
                              ),
                              onIndexChanged: (index, _) {
                                newFlourType = _flourTypes[index];
                                cubit.productDataChanged(index != oldIndex);
                              },
                              builder: (context, index) =>
                                  Center(child: Text(_flourTypes[index].tr())),
                            ),
                          ),
                          Icon(
                            Icons.arrow_left,
                            size: 22,
                            color: ThemingColors.primaryColor,
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      dialogActionsRow(
                        dialogContext: dialogContext,
                        cubit: cubit,
                        onConfirm: () => cubit.editProduct(
                          currentProduct.copyWith(
                            productRecipe: currentProduct.productRecipe
                                .copyWith(flourType: newFlourType),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return BlocProvider(
          create: (_) => DependencyInjection.getIt<SupabaseImageCubit>(
            param1: Buckets.productsImages,
            param2: currentProduct.productId,
          ),
          child: Builder(
            builder: (imageContext) {
              return Material(
                color: Colors.transparent,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: context.isDark ? 2 : 5,
                    sigmaY: context.isDark ? 2 : 5,
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: InkWell(
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () => editField(
                                    title: "productName",
                                    textKeypad: true,
                                    initialText: currentProduct.productName,
                                    hasChanged: (text) =>
                                        text != product.productName &&
                                        text.isNotEmpty,
                                    onSave: () => cubit.editProduct(
                                      currentProduct.copyWith(
                                        productName: productEditingController
                                            .text
                                            .capitalize(),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        GlassCard(
                                          margin: const EdgeInsets.only(
                                            bottom: 20,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 40,
                                          ),
                                          dark: true,
                                          radius: 0,
                                          otherRadius: 30,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${currentProduct.productName} ",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Positioned(
                                          right: 0,
                                          child: Icon(
                                            Icons.edit,
                                            size: 20,
                                            color: ThemingColors.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: .symmetric(vertical: 5),
                                child: productAvatarStack(
                                  context: context,
                                  radius: screenWidth * 0.4,
                                  avatarChild: ClipOval(
                                    child:
                                        cubit.pendingProductImages.containsKey(
                                          currentProduct.productId,
                                        )
                                        ? SizedBox.expand(
                                            child: Image.file(
                                              cubit
                                                  .pendingProductImages[currentProduct
                                                  .productId]!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const SupabaseImage(
                                            iconSize: 100,
                                            iconDarkOpacity: 0.1,
                                            iconLightOpacity: 0.1,
                                          ),
                                  ),
                                  editButton: editImageButton(
                                    context: context,
                                    onTap: () async {
                                      final imageCubit = imageContext
                                          .read<SupabaseImageCubit>();
                                      await imageCubit.pickImage(false);
                                      if (imageCubit.state is ImageLoaded) {
                                        cubit.bumpProductImageVersion(
                                          currentProduct.productId!,
                                        );
                                        cubit.setProductPictureChanged(
                                          currentProduct.productId!,
                                          true,
                                        );
                                      }
                                    },
                                  ),
                                  priceRight: 0,
                                  priceOverlay: SizedBox(
                                    width: screenWidth * 0.35,
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      onTap: () => editField(
                                        title: "price",
                                        initialText: currentProduct.productPrice
                                            .toStringAsFixed(2),
                                        hasChanged: (text) {
                                          final input = double.tryParse(text);
                                          return input !=
                                                  product.productPrice &&
                                              (input ?? 0) > 0;
                                        },
                                        onSave: () => cubit.editProduct(
                                          currentProduct.copyWith(
                                            productPrice: double.tryParse(
                                              productEditingController.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3,
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topRight: Radius.circular(
                                                      30,
                                                    ),
                                                    bottomLeft: Radius.circular(
                                                      30,
                                                    ),
                                                  ),
                                              border: Border.all(
                                                width: context.isDark
                                                    ? 0.2
                                                    : 0.4,
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                    : ThemingColors.black,
                                              ),
                                              color: context.isDark
                                                  ? ThemingColors.darkGrey
                                                  : ThemingColors.lightGrey,
                                            ),

                                            child: Row(
                                              mainAxisAlignment: .center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    currentProduct.productPrice
                                                        .toStringAsFixed(2),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: context.isDark
                                                          ? Colors.lightGreen
                                                          : Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(" \$"),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: ThemingColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  weightOverlay: SizedBox(
                                    width: screenWidth * 0.3,
                                    child: InkWell(
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () => editField(
                                        title: "weight",
                                        initialText: currentProduct
                                            .productWeight
                                            .toStringAsFixed(0),
                                        hasChanged: (text) => intChanged(
                                          text,
                                          product.productWeight.toInt(),
                                        ),
                                        onSave: () => cubit.editProduct(
                                          currentProduct.copyWith(
                                            productWeight: int.tryParse(
                                              productEditingController.text,
                                            ),
                                          ),
                                        ),
                                      ),
                                      child: Stack(
                                        children: [
                                          GlassCard(
                                            margin: EdgeInsets.zero,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 3,
                                            ),
                                            otherRadius: 30,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  currentProduct.productWeight
                                                      .toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: .symmetric(
                                                    horizontal: 5,
                                                  ),
                                                  child: Text(
                                                    "gram".tr(),
                                                    style: TextStyle(
                                                      color: context.isDark
                                                          ? Colors.amber
                                                          : Colors.orange,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: ThemingColors.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              productRatingRow(context, product.rate),
                              const SizedBox(height: 40),
                              GlassCard(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                ),
                                padding: EdgeInsets.zero,
                                responsive: true,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        GlassCard(
                                          dark: true,
                                          responsive: true,
                                          margin: EdgeInsets.zero,
                                          padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 10,
                                            left: 15,
                                            right: 20,
                                          ),

                                          child: Text(
                                            "recipe".tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: .only(
                                            right:
                                                context.locale.languageCode ==
                                                    'ar'
                                                ? 0
                                                : 20,
                                            left:
                                                context.locale.languageCode ==
                                                    'ar'
                                                ? 20
                                                : 0,
                                            top: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: .symmetric(
                                                  horizontal: 5,
                                                ),
                                                child: Text(
                                                  "perBatch".tr(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "kgFlour".tr(),
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 25,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text("flourType".tr()),
                                              const Spacer(),
                                              InkWell(
                                                highlightColor:
                                                    Colors.transparent,
                                                splashColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                onTap: openFlourTypeDialog,
                                                child: Text(
                                                  currentProduct
                                                      .productRecipe
                                                      .flourType
                                                      .tr(),
                                                  style: TextStyle(
                                                    color: ThemingColors
                                                        .primaryColor,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    decorationColor:
                                                        ThemingColors
                                                            .primaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          recipeDivider(),
                                          editableValueRow(
                                            context: context,
                                            label: "quantityProduced".tr(),
                                            displayValue:
                                                "${currentProduct.quantityPerBatch}",
                                            unit: "",
                                            onOpen: () => editField(
                                              title: "quantityProduced".tr(),
                                              initialText: currentProduct
                                                  .quantityPerBatch
                                                  .toString(),
                                              hasChanged: (text) => intChanged(
                                                text,
                                                product.quantityPerBatch,
                                              ),
                                              onSave: () => cubit.editProduct(
                                                currentProduct.copyWith(
                                                  quantityPerBatch:
                                                      int.tryParse(
                                                        productEditingController
                                                            .text,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          ...recipeFieldSpecs.map(
                                            (spec) => Column(
                                              children: [
                                                recipeDivider(),
                                                editableValueRow(
                                                  context: context,
                                                  label: spec.label,
                                                  displayValue:
                                                      (spec.getter(
                                                                currentProduct
                                                                    .productRecipe,
                                                              ) ??
                                                              0)
                                                          .toStringAsFixed(0),
                                                  unit: spec.unit,
                                                  onOpen: () => editField(
                                                    title: spec.label,
                                                    initialText:
                                                        (spec.getter(
                                                                  currentProduct
                                                                      .productRecipe,
                                                                ) ??
                                                                0)
                                                            .toStringAsFixed(0),
                                                    hasChanged: (text) =>
                                                        intChanged(
                                                          text,
                                                          (spec.getter(
                                                                    product
                                                                        .productRecipe,
                                                                  ) ??
                                                                  0)
                                                              .toInt(),
                                                        ),
                                                    onSave: () => cubit.editProduct(
                                                      currentProduct.copyWith(
                                                        productRecipe: spec.setter(
                                                          currentProduct
                                                              .productRecipe,
                                                          int.tryParse(
                                                            productEditingController
                                                                .text,
                                                          ),
                                                        ),
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        BlocBuilder<SupabaseImageCubit, SupabaseImageState>(
                          bloc: imageContext.read<SupabaseImageCubit>(),
                          builder: (context, imageState) {
                            if (imageState is ImageLoading) {
                              return const SizedBox.shrink();
                            }
                            return Stack(
                              children: [
                                Positioned(
                                  right: 5,
                                  top: 5,
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await Future.delayed(
                                        const Duration(seconds: 2),
                                      );
                                      cubit.oneProductChanged(false);
                                    },
                                    child: Icon(
                                      cubit.isOneProductChanged ||
                                              cubit.changedProductPictures
                                                  .contains(
                                                    currentProduct.productId,
                                                  )
                                          ? Icons.done
                                          : Icons.close,
                                      size: 30,
                                      color:
                                          cubit.isOneProductChanged ||
                                              cubit.changedProductPictures
                                                  .contains(
                                                    currentProduct.productId,
                                                  )
                                          ? Colors.green
                                          : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (cubit.editableProducts.length > 1)
                                  Positioned(
                                    top: 5,
                                    left: 5,
                                    child: InkWell(
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () => confirmDeleteProduct(
                                        productId: currentProduct.productId!,
                                        branchId: currentProduct.branchId,
                                      ),
                                      child: const Icon(
                                        Icons.delete_forever_outlined,
                                        size: 30,
                                        color: Colors.redAccent,
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
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _boxedContent(BuildContext context, Widget child) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: (context.isDark ? ThemingColors.black : ThemingColors.white)
          .withAlpha((0.4 * 255).toInt()),
      border: Border.all(
        width: 0.3,
        color: context.isDark
            ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
            : ThemingColors.black.withAlpha((0.5 * 255).toInt()),
      ),
    ),
    child: child,
  );
}
