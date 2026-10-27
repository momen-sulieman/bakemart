import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/logic/supabase_image_cubit/supabase_image_cubit.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/ui/supabase_image.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../logic/add_product_cubit/add_product_cubit.dart';

class AddProductDialog extends StatelessWidget {
  const AddProductDialog({
    required this.bakeryId,
    required this.branchIds,
    required this.onSave,
    this.flourTypes = const [
      StorageItems.wholeWheat,
      StorageItems.fineWheat,
      StorageItems.semolina,
      StorageItems.phyllo,
      StorageItems.barley,
      StorageItems.corn,
      StorageItems.oats,
    ],
    this.initialFlourIndex = 1,
    super.key,
  });

  final String bakeryId;
  final List<String> branchIds;
  final List<String> flourTypes;
  final int initialFlourIndex;
  final void Function(List<ProductModel> products, File? image) onSave;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddProductCubit(
        bakeryId: bakeryId,
        branchIds: branchIds,
        flourTypes: flourTypes,
        initialFlourIndex: initialFlourIndex,
        onSave: onSave,
      ),
      child: Builder(
        builder: (context) {
          final cubit = context.read<AddProductCubit>();
          return BlocProvider.value(
            value: cubit.imageCubit,
            child: const _AddProductDialogView(),
          );
        },
      ),
    );
  }
}

class _AddProductDialogView extends StatelessWidget {
  const _AddProductDialogView();

  Widget _panel(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: context.isDark
            ? ThemingColors.black.withAlpha((0.6 * 255).toInt())
            : ThemingColors.white.withAlpha((0.6 * 255).toInt()),
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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AddProductCubit>();
    final double screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: AlertDialog(
        titlePadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
        contentPadding: const EdgeInsets.all(15),
        actionsPadding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            width: 0.2,
            color: context.isDark ? ThemingColors.white : ThemingColors.black,
          ),
        ),
        backgroundColor: context.isDark
            ? ThemingColors.black.withAlpha((0.2 * 255).toInt())
            : ThemingColors.white.withAlpha((0.2 * 255).toInt()),
        title: _panel(
          context,
          child: Text("newProduct".tr(), textAlign: TextAlign.center),
        ),
        content: _panel(
          context,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: SingleChildScrollView(
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Builder(
                    builder: (imageContext) => Stack(
                      children: [
                        Container(
                          width: screenWidth * 0.16,
                          height: screenWidth * 0.16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.isDark
                                ? ThemingColors.darkGrey
                                : Colors.grey,
                          ),
                          child: const ClipOval(child: SupabaseImage()),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () => imageContext
                                .read<SupabaseImageCubit>()
                                .pickImage(false),
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ThemingColors.primaryColor,
                              ),
                              child: Icon(
                                Icons.add,
                                size: 14,
                                color: context.isDark
                                    ? ThemingColors.darkGrey
                                    : ThemingColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 35,
                    child: Directionality(
                      textDirection: context.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      child: CustomTextFormField(
                        "productName".tr(),
                        controller: cubit.productNameController,
                        onChanged: (_) => cubit.revalidate(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Directionality(
                    textDirection: context.locale.languageCode == 'ar'
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: CustomTextFormField(
                              "price".tr(),
                              keyBoardType: .number,
                              controller: cubit.productPriceController,
                              onChanged: (_) => cubit.revalidate(),
                            ),
                          ),
                        ),
                        Container(
                          alignment: context.locale.languageCode == 'en'
                              ? .centerLeft
                              : .centerRight,
                          width: 40,
                          child: Icon(
                            Icons.sell_outlined,
                            size: 18,
                            color: context.isDark ? Colors.cyan : Colors.teal,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: CustomTextFormField(
                              "weight".tr(),
                              keyBoardType: .number,
                              controller: cubit.productWeightController,
                              onChanged: (_) => cubit.revalidate(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Padding(
                            padding: .symmetric(horizontal: 5),
                            child: Text(
                              "gram".tr(),
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
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          margin: const EdgeInsets.only(bottom: 5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 5,
                          ),
                          dark: true,
                          child: Text(
                            "recipe".tr(),
                            textDirection: context.locale.languageCode == 'ar'
                                ? ui.TextDirection.rtl
                                : ui.TextDirection.ltr,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  GlassCard(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(10),
                    otherRadius: 15,
                    radius: 15,
                    child: Text(
                      "newProductNote".tr(),
                      style: TextStyle(fontSize: 12),
                      textDirection: context.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                    ),
                  ),
                  Directionality(
                    textDirection: context.locale.languageCode == 'ar'
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: context.locale.languageCode == 'ar' ? 0 : 10,
                            left: context.locale.languageCode == 'ar' ? 10 : 0,
                          ),
                          child: Text(
                            "flourType".tr(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Container(
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
                                  width: 130,
                                  child: WheelPicker(
                                    controller: WheelPickerController(
                                      itemCount: cubit.flourTypes.length,
                                      initialIndex: cubit.initialFlourIndex,
                                    ),
                                    looping: false,
                                    style: const WheelPickerStyle(
                                      itemExtent: 22,
                                      surroundingOpacity: 0.4,
                                      diameterRatio: 10,
                                      magnification: 1,
                                    ),
                                    onIndexChanged: (index, _) => cubit
                                        .setFlourType(cubit.flourTypes[index]),
                                    builder: (context, index) => Center(
                                      child: Text(
                                        cubit.flourTypes[index].tr(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
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
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 35,
                    child: Directionality(
                      textDirection: context.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      child: CustomTextFormField(
                        "quantityProducedBy".tr(),
                        keyBoardType: .number,
                        controller: cubit.quantityController,
                        onChanged: (_) => cubit.revalidate(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...cubit.recipeFields.map((field) {
                    final label = field.$1;
                    final controller = field.$2;
                    final unit = field.$3;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Directionality(
                        textDirection: context.locale.languageCode == 'ar'
                            ? ui.TextDirection.rtl
                            : ui.TextDirection.ltr,
                        child: Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 35,
                                child: CustomTextFormField(
                                  label.tr(),
                                  keyBoardType: .number,
                                  controller: controller,
                                  onChanged: (_) => cubit.revalidate(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 40,
                              child: Text(
                                " $unit",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: context.isDark
                                      ? Colors.amber
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        actions: [
          BlocBuilder<AddProductCubit, AddProductState>(
            builder: (context, state) {
              return Row(
                children: [
                  state.isValid
                      ? InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () => Navigator.pop(context),
                          child: GlassCard(
                            margin: const EdgeInsets.only(right: 6),
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
                            onTap: () => Navigator.pop(context),
                            child: GlassCard(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: ThemingColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                  if (state.isValid)
                    Expanded(
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          cubit.save();
                          Navigator.pop(context);
                        },
                        child: const GlassCard(
                          margin: EdgeInsets.zero,
                          padding: EdgeInsets.symmetric(vertical: 2),
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
    );
  }
}
