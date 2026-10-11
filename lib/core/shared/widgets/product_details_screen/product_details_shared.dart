import 'dart:ui';

import 'package:bakemart/core/shared/models/recipe_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/extensions/string_extension.dart';

class RecipeFieldSpec {
  final String label;
  final String unit;
  final int? Function(RecipeModel) getter;
  final RecipeModel Function(RecipeModel, int?) setter;

  const RecipeFieldSpec(
    this.label,
    this.getter,
    this.setter, {
    this.unit = "g",
  });
}

final List<RecipeFieldSpec> recipeFieldSpecs = [
  RecipeFieldSpec(
    StorageItems.yeast,
    (r) => r.yeast,
    (r, v) => r.copyWith(yeast: v),
  ),
  RecipeFieldSpec(
    StorageItems.salt,
    (r) => r.salt,
    (r, v) => r.copyWith(salt: v),
  ),
  RecipeFieldSpec(
    StorageItems.sugar,
    (r) => r.sugar,
    (r, v) => r.copyWith(sugar: v),
  ),
  RecipeFieldSpec(
    StorageItems.eggs,
    (r) => r.eggs,
    (r, v) => r.copyWith(eggs: v),
    unit: "egg",
  ),
  RecipeFieldSpec(
    StorageItems.ghee,
    (r) => r.ghee,
    (r, v) => r.copyWith(ghee: v),
  ),
  RecipeFieldSpec(StorageItems.oil, (r) => r.oil, (r, v) => r.copyWith(oil: v)),
  RecipeFieldSpec(
    StorageItems.butter,
    (r) => r.butter,
    (r, v) => r.copyWith(butter: v),
  ),
  RecipeFieldSpec(
    StorageItems.sesame,
    (r) => r.sesame,
    (r, v) => r.copyWith(sesame: v),
  ),
  RecipeFieldSpec(
    StorageItems.blackSeeds,
    (r) => r.blackSeeds,
    (r, v) => r.copyWith(blackSeeds: v),
  ),
  RecipeFieldSpec(
    StorageItems.fennel,
    (r) => r.fennel,
    (r, v) => r.copyWith(fennel: v),
  ),
  RecipeFieldSpec(
    StorageItems.anise,
    (r) => r.anise,
    (r, v) => r.copyWith(anise: v),
  ),
  RecipeFieldSpec(
    StorageItems.mahlab,
    (r) => r.mahlab,
    (r, v) => r.copyWith(mahlab: v),
  ),
  RecipeFieldSpec(
    StorageItems.cinnamon,
    (r) => r.cinnamon,
    (r, v) => r.copyWith(cinnamon: v),
  ),
  RecipeFieldSpec(
    StorageItems.bakingPowder,
    (r) => r.bakingPowder,
    (r, v) => r.copyWith(bakingPowder: v),
  ),
  RecipeFieldSpec(
    StorageItems.bakingSoda,
    (r) => r.bakingSoda,
    (r, v) => r.copyWith(bakingSoda: v),
  ),
  RecipeFieldSpec(
    StorageItems.chocolate,
    (r) => r.chocolate,
    (r, v) => r.copyWith(chocolate: v),
  ),
  RecipeFieldSpec(
    StorageItems.conditioner,
    (r) => r.conditioner,
    (r, v) => r.copyWith(conditioner: v),
  ),
  RecipeFieldSpec(
    StorageItems.vanilla,
    (r) => r.vanilla,
    (r, v) => r.copyWith(vanilla: v),
  ),
  RecipeFieldSpec(
    StorageItems.milk,
    (r) => r.milk,
    (r, v) => r.copyWith(milk: v),
  ),
  RecipeFieldSpec(
    StorageItems.milkPowder,
    (r) => r.milkPowder,
    (r, v) => r.copyWith(milkPowder: v),
  ),
  RecipeFieldSpec(
    StorageItems.whippingCream,
    (r) => r.whippingCream,
    (r, v) => r.copyWith(whippingCream: v),
  ),
  RecipeFieldSpec(
    StorageItems.condensedMilk,
    (r) => r.condensedMilk,
    (r, v) => r.copyWith(condensedMilk: v),
  ),
  RecipeFieldSpec(
    StorageItems.datePaste,
    (r) => r.datePaste,
    (r, v) => r.copyWith(datePaste: v),
  ),
  RecipeFieldSpec(
    StorageItems.malban,
    (r) => r.malban,
    (r, v) => r.copyWith(malban: v),
  ),
  RecipeFieldSpec(
    StorageItems.whiteCheese,
    (r) => r.whiteCheese,
    (r, v) => r.copyWith(whiteCheese: v),
  ),
  RecipeFieldSpec(
    StorageItems.roumyCheese,
    (r) => r.roumyCheese,
    (r, v) => r.copyWith(roumyCheese: v),
  ),
  RecipeFieldSpec(
    StorageItems.istanbouliCheese,
    (r) => r.istanbouliCheese,
    (r, v) => r.copyWith(istanbouliCheese: v),
  ),
  RecipeFieldSpec(
    StorageItems.mozzarella,
    (r) => r.mozzarella,
    (r, v) => r.copyWith(mozzarella: v),
  ),
  RecipeFieldSpec(
    StorageItems.olives,
    (r) => r.olives,
    (r, v) => r.copyWith(olives: v),
  ),
  RecipeFieldSpec(
    StorageItems.peanut,
    (r) => r.peanut,
    (r, v) => r.copyWith(peanut: v),
  ),
  RecipeFieldSpec(
    StorageItems.cashew,
    (r) => r.cashew,
    (r, v) => r.copyWith(cashew: v),
  ),
  RecipeFieldSpec(
    StorageItems.almond,
    (r) => r.almond,
    (r, v) => r.copyWith(almond: v),
  ),
  RecipeFieldSpec(
    StorageItems.pistachio,
    (r) => r.pistachio,
    (r, v) => r.copyWith(pistachio: v),
  ),
  RecipeFieldSpec(
    StorageItems.custard,
    (r) => r.custard,
    (r, v) => r.copyWith(custard: v),
  ),
  RecipeFieldSpec(
    StorageItems.cocoa,
    (r) => r.cocoa,
    (r, v) => r.copyWith(cocoa: v),
  ),
  RecipeFieldSpec(
    StorageItems.coconutPowder,
    (r) => r.coconutPowder,
    (r, v) => r.copyWith(coconutPowder: v),
  ),
  RecipeFieldSpec(
    StorageItems.blackMolasses,
    (r) => r.blackMolasses,
    (r, v) => r.copyWith(blackMolasses: v),
  ),
];

bool intChanged(String text, int oldValue) {
  final input = double.tryParse(text.toEnglishDigits())?.toInt();
  return input != oldValue && (input ?? 0) > 0;
}

Widget recipeDivider() => Container(
  margin: const EdgeInsets.symmetric(vertical: 10),
  padding: const EdgeInsets.only(top: 0.2),
  color: ThemingColors.primaryColor,
);

Widget editableValueRow({
  required BuildContext context,
  required String label,
  required String displayValue,
  required String unit,
  required VoidCallback onOpen,
}) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(label.tr()),
      const Spacer(),
      InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onOpen,
        child: Row(
          children: [
            Padding(
              padding: .symmetric(horizontal: 5),
              child: Text(
                displayValue,
                style: TextStyle(
                  color: ThemingColors.primaryColor,
                  decoration: TextDecoration.underline,
                  decorationColor: ThemingColors.primaryColor,
                ),
              ),
            ),
            if (unit.isNotEmpty)
              Text(
                " ${unit.tr()}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: context.isDark ? Colors.amber : Colors.orange,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget dialogActionsRow({
  required BuildContext dialogContext,
  required SettingsCubit cubit,
  required VoidCallback onConfirm,
}) {
  Widget backButton({required EdgeInsets padding}) => InkWell(
    hoverColor: Colors.transparent,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () {
      cubit.productDataChanged(false);
      Navigator.pop(dialogContext);
    },
    child: GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: padding,
      child: Icon(
        Icons.arrow_back,
        size: 18,
        color: ThemingColors.primaryColor,
      ),
    ),
  );

  return Row(
    children: [
      cubit.isProductDataChanged
          ? backButton(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
            )
          : Expanded(
              child: backButton(
                padding: const EdgeInsets.symmetric(vertical: 2),
              ),
            ),
      if (cubit.isProductDataChanged)
        Expanded(
          child: InkWell(
            onTap: () {
              onConfirm();
              cubit.productsSomethingChanged(true);
              cubit.productDataChanged(false);
              Navigator.pop(dialogContext);
            },
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: GlassCard(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: const Icon(Icons.done, size: 18, color: Colors.green),
            ),
          ),
        ),
    ],
  );
}

void openValueEditDialog({
  required BuildContext context,
  required SettingsCubit cubit,
  required String title,
  required TextEditingController controller,
  required bool Function(String text) hasChanged,
  required VoidCallback onSave,
  required bool textKeypad,
}) {
  showDialog(
    barrierColor: Colors.transparent,
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: cubit,
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: AlertDialog(
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
                (context.isDark ? ThemingColors.black : ThemingColors.white)
                    .withAlpha((0.8 * 255).toInt()),
            title: Text(
              title.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller,
                    keyboardType: textKeypad ? .text : .number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    textDirection: textKeypad
                        ? Bidi.hasAnyLtr(controller.text)
                              ? .ltr
                              : .rtl
                        : .ltr,
                    onChanged: (text) =>
                        cubit.productDataChanged(hasChanged(text)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              dialogActionsRow(
                dialogContext: dialogContext,
                cubit: cubit,
                onConfirm: onSave,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget productAvatarStack({
  required BuildContext context,
  required double radius,
  required Widget? avatarChild,
  Widget? editButton,
  required double priceRight,
  required Widget priceOverlay,
  required Widget weightOverlay,
}) {
  return IntrinsicWidth(
    child: Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: CircleAvatar(
            radius: radius,
            backgroundColor: context.isDark
                ? ThemingColors.darkGrey
                : Colors.grey,
            child: avatarChild,
          ),
        ),
        ?editButton,
        Positioned(top: 20, right: priceRight, child: priceOverlay),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Center(child: weightOverlay),
        ),
      ],
    ),
  );
}

Widget editImageButton({
  required BuildContext context,
  required VoidCallback onTap,
}) {
  return Positioned(
    bottom: 45,
    right: 45,
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemingColors.primaryColor.withAlpha(
              ((context.isDark ? 0.5 : 0.7) * 255).toInt(),
            ),
          ),
          child: Icon(Icons.edit, size: 22, color: ThemingColors.white),
        ),
      ),
    ),
  );
}

Widget productRatingRow(BuildContext context, double rate) {
  final color = context.isDark ? Colors.amber : Colors.orange;
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (i) {
      if (i < rate.floor()) return Icon(Icons.star, color: color, size: 16);
      if (i < rate) return Icon(Icons.star_half, color: color, size: 16);
      return Icon(Icons.star_border, color: color, size: 16);
    }),
  );
}
