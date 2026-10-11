import 'dart:io';
import 'dart:ui';

import 'package:bakemart/core/dependency_injection/dependency_injection.dart';
import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import 'product_details_shared.dart';

class ProductInlineEditForm extends StatelessWidget {
  final ProductModel product;
  final File? pendingImage;
  final void Function(File file) onPickImage;
  final void Function(ProductModel Function(ProductModel) update) onUpdate;

  const ProductInlineEditForm({
    required this.product,
    required this.pendingImage,
    required this.onPickImage,
    required this.onUpdate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final nameController = TextEditingController(text: product.productName);
    final priceController = TextEditingController(
      text: product.productPrice.toStringAsFixed(2),
    );
    final weightController = TextEditingController(
      text: product.productWeight.toStringAsFixed(0),
    );
    final quantityController = TextEditingController(
      text: product.quantityPerBatch.toStringAsFixed(0),
    );
    final fieldControllers = {
      for (final spec in recipeFieldSpecs)
        spec: TextEditingController(
          text: (spec.getter(product.productRecipe) ?? 0).toStringAsFixed(0),
        ),
    };

    final oldFlourTypeIndex = kFlourTypes.indexOf(
      product.productRecipe.flourType,
    );
    void onRecipeFieldChanged(String text, RecipeFieldSpec spec) {
      final input = int.tryParse(text);
      if (input == null || input <= 0) return;
      onUpdate(
        (p) => p.copyWith(productRecipe: spec.setter(p.productRecipe, input)),
      );
    }

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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        height: 35,
                        width: 250,
                        child: CustomTextFormField(
                          "productName".tr(),
                          controller: nameController,
                          onChanged: (text) {
                            if (text.isNotEmpty)
                              onUpdate((p) => p.copyWith(productName: text));
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: BlocProvider(
                        create: (_) =>
                            DependencyInjection.getIt<SupabaseImageCubit>(
                              param1: Buckets.productsImages,
                              param2: null,
                            ),
                        child: Builder(
                          builder: (imageContext) => productAvatarStack(
                            context: context,
                            radius: screenWidth * 0.4,
                            avatarChild: pendingImage != null
                                ? ClipOval(
                                    child: SizedBox.expand(
                                      child: Image.file(
                                        pendingImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : null,
                            editButton: editImageButton(
                              context: context,
                              onTap: () async {
                                final imageCubit = imageContext
                                    .read<SupabaseImageCubit>();
                                await imageCubit.pickImage(false);
                                final imageState = imageCubit.state;
                                if (imageState is ImagePicked)
                                  onPickImage(imageState.imageFile);
                              },
                            ),
                            priceRight: 10,
                            priceOverlay: SizedBox(
                              height: 35,
                              width: 100,
                              child: CustomTextFormField(
                                "price".tr(),
                                controller: priceController,
                                onChanged: (text) {
                                  final input = double.tryParse(text);
                                  if (input != null && input > 0)
                                    onUpdate(
                                      (p) => p.copyWith(productPrice: input),
                                    );
                                },
                              ),
                            ),
                            weightOverlay: SizedBox(
                              width: screenWidth * 0.3,
                              child: SizedBox(
                                height: 35,
                                width: 150,
                                child: CustomTextFormField(
                                  "weight".tr(),
                                  controller: weightController,
                                  onChanged: (text) {
                                    final input = int.tryParse(text);
                                    if (input != null && input > 0)
                                      onUpdate(
                                        (p) => p.copyWith(productWeight: input),
                                      );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      padding: EdgeInsets.zero,
                      responsive: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GlassCard(
                                dark: true,
                                margin: EdgeInsets.zero,
                                padding: const EdgeInsets.only(
                                  top: 5,
                                  bottom: 10,
                                  left: 15,
                                  right: 20,
                                ),
                                responsive: true,
                                child: Text(
                                  "recipe".tr(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: .only(
                                  right: context.locale.languageCode == "ar"
                                      ? 0
                                      : 20,
                                  left: context.locale.languageCode == "ar"
                                      ? 20
                                      : 0,
                                  top: 10,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      "perBatch".tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
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
                                    Padding(
                                      padding:
                                          context.locale.languageCode == "ar"
                                          ? .only(left: 10)
                                          : .only(right: 10),
                                      child: Text(
                                        "flourType".tr(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          color:
                                              (context.isDark
                                                      ? ThemingColors.black
                                                      : ThemingColors.white)
                                                  .withAlpha(
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.arrow_right,
                                              size: 25,
                                              color: ThemingColors.primaryColor,
                                            ),
                                            SizedBox(
                                              height: 70,
                                              width: 130,
                                              child: WheelPicker(
                                                controller:
                                                    WheelPickerController(
                                                      itemCount:
                                                          kFlourTypes.length,
                                                      initialIndex:
                                                          oldFlourTypeIndex,
                                                    ),
                                                looping: false,
                                                style: const WheelPickerStyle(
                                                  itemExtent: 22,
                                                  surroundingOpacity: 0.4,
                                                  diameterRatio: 10,
                                                  magnification: 1,
                                                ),
                                                onIndexChanged: (index, _) {
                                                  onUpdate(
                                                    (p) => p.copyWith(
                                                      productRecipe: p
                                                          .productRecipe
                                                          .copyWith(
                                                            flourType:
                                                                kFlourTypes[index],
                                                          ),
                                                    ),
                                                  );
                                                },
                                                builder: (context, index) =>
                                                    Center(
                                                      child: Text(
                                                        kFlourTypes[index].tr(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
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
                                    ),
                                  ],
                                ),
                                recipeDivider(),
                                SizedBox(
                                  height: 35,
                                  width: double.infinity,
                                  child: CustomTextFormField(
                                    "quantityProducedBy".tr(),
                                    controller: quantityController,
                                    onChanged: (text) {
                                      final input = int.tryParse(text);
                                      if (input != null && input > 0) {
                                        onUpdate(
                                          (p) => p.copyWith(
                                            quantityPerBatch: input,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                                ...recipeFieldSpecs.map(
                                  (spec) => Column(
                                    children: [
                                      recipeDivider(),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: SizedBox(
                                              height: 35,
                                              child: CustomTextFormField(
                                                spec.label.tr(),
                                                controller:
                                                    fieldControllers[spec]!,
                                                onChanged: (text) =>
                                                    onRecipeFieldChanged(
                                                      text,
                                                      spec,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 40,
                                            child: Padding(
                                              padding: .symmetric(horizontal: 5),
                                              child: Text(
                                                spec.unit.tr(),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: context.isDark
                                                      ? Colors.amber
                                                      : Colors.orange,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
              Positioned(
                right: 5,
                top: 10,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () async {
                    Navigator.pop(context);
                    await Future.delayed(const Duration(seconds: 2));
                  },
                  child: const Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
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
