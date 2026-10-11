import 'dart:ui';
import 'dart:ui' as ui;

import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/supabase_image/ui/supabase_image.dart';
import 'package:bakemart/core/shared/widgets/table_cells/text_cell.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/enums/buckts.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'product_details_shared.dart';

class ProductViewOnly extends StatelessWidget {
  final ProductModel product;
  final bool statistict;
  final bool nutrition;

  const ProductViewOnly({
    required this.product,
    this.statistict = false,
    this.nutrition = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                GlassCard(
                  margin: EdgeInsets.only(
                    top: statistict ? 30 : 0,
                    bottom: 20,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 40,
                  ),
                  radius: 0,
                  otherRadius: 30,
                  dark: true,
                  child: Text(
                    "${product.productName} ",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: CircleAvatar(
                            radius: screenWidth * 0.4,
                            backgroundColor: context.isDark
                                ? ThemingColors.darkGrey
                                : Colors.grey,
                            child: ClipOval(
                              child: SupabaseImageProvider(
                                filePath: Buckets.productsImages,
                                fileName: product.productId,
                                iconSize: 40,
                                addIconSize: 40,
                                iconDarkOpacity: 0.1,
                                iconLightOpacity: 0.1,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 10,
                          child: Material(
                            color: Colors.transparent,
                            child: SizedBox(
                              width: screenWidth * 0.25,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomLeft: Radius.circular(30),
                                  ),
                                  border: Border.all(
                                    width: context.isDark ? 0.2 : 0.4,
                                    color: context.isDark
                                        ? ThemingColors.white
                                        : ThemingColors.black,
                                  ),
                                  color: context.isDark
                                      ? ThemingColors.darkGrey
                                      : ThemingColors.lightGrey,
                                ),
                                child: Directionality(
                                  textDirection: ui.TextDirection.ltr,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          product.productPrice.toStringAsFixed(
                                            2,
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(" \$"),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
                              child: SizedBox(
                                width: screenWidth * 0.3,
                                child: GlassCard(
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  radius: 30,
                                  otherRadius: 30,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.productWeight.toStringAsFixed(
                                          0,
                                        ),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Padding(
                                        padding: .symmetric(horizontal: 7),
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
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                productRatingRow(context, product.rate),
                const SizedBox(height: 40),
                if (statistict) _statisticsCard(context),
                if (statistict && nutrition) const SizedBox(height: 10),
                if (nutrition) _nutritionCard(context),
              ],
            ),
          ),
          Positioned(
            right: 5,
            top: statistict ? 30 : 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => GlassCard(
    dark: true,
    margin: EdgeInsets.zero,
    responsive: true,
    padding: const EdgeInsets.only(top: 5, bottom: 10, left: 15, right: 20),
    child: Material(
      color: Colors.transparent,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    ),
  );

  Widget _statisticsCard(BuildContext context) {
    final rows = <(String, num)>[
      ("availableNow".tr(), product.available),
      ("totalProduction".tr(), product.totalProduced),
      ("totalSold".tr(), product.totalSold),
      ("totalNotSold".tr(), product.notSoldWaste),
      ("mealExhaustion".tr(), product.mealsWaste),
      ("manufacturingWaste".tr(), product.manufacturingWaste),
    ];
    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: EdgeInsets.zero,
      responsive: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("statistics".tr()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(rows[i].$1),
                      const Spacer(),
                      Text("${rows[i].$2}"),
                    ],
                  ),
                  if (i < rows.length - 1) recipeDivider(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutritionCard(BuildContext context) {
    final grayColor =
        (context.isDark ? ThemingColors.white : ThemingColors.black).withAlpha(
          (0.3 * 255).toInt(),
        );
    Widget headerCell(String text, {String? sub}) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Padding(
        padding: .symmetric(horizontal: 10),
        child: TextCell(
          string: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: grayColor,
            ),
          ),
          subString: sub == null
              ? null
              : Padding(
                padding: .symmetric(horizontal: 5),
                child: Text(sub, style: TextStyle(fontSize: 12, color: grayColor)),
              ),
        ),
      ),
    );

    return Directionality(
      textDirection: context.locale.languageCode == 'ar'
          ? ui.TextDirection.rtl
          : ui.TextDirection.ltr,
      child: GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.zero,
        responsive: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("nutrition".tr()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Table(
                border: TableBorder(
                  horizontalInside: BorderSide(
                    width: 1,
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.2 * 255).toInt(),
                    ),
                  ),
                  verticalInside: BorderSide(
                    width: 3,
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.15 * 255).toInt(),
                    ),
                  ),
                ),
                columnWidths: {0: FlexColumnWidth(1.1), 1: FlexColumnWidth(1.9)},
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 3,
                          color: ThemingColors.primaryColor.withAlpha(
                            (0.2 * 255).toInt(),
                          ),
                        ),
                      ),
                    ),
                    children: [
                      headerCell("ingredient".tr()),
                      headerCell("amount".tr(), sub: "perOnePiece".tr()),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: .symmetric(vertical: 5,horizontal: 10),
                        child: TextCell(
                          string:Text(
                            "flour".tr(),
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: .symmetric(vertical: 5,horizontal: 10),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.productRecipe.flourType.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  _nutritionRow(
                    "sugar".tr(),
                    (product.productRecipe.sugar ?? 0) / product.quantityPerBatch,
                    context.isDark ? Colors.amber : Colors.orange,
                  ),
                  _nutritionRow(
                    "salt".tr(),
                    (product.productRecipe.salt ?? 0) / product.quantityPerBatch,
                    context.isDark ? Colors.amber : Colors.orange,
                  ),
                  _nutritionRow(
                    "fat".tr(),
                    product.fat,
                    context.isDark ? Colors.amber : Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _nutritionRow(String label, double perPiece, Color unitColor) {
    return TableRow(
      children: [
        Padding(
          padding: .symmetric(vertical: 5,horizontal: 10),
          child: TextCell(
            string: Text(label, style: const TextStyle(fontSize: 12)),
          ),
        ),
        Padding(
          padding: .symmetric(vertical: 5,horizontal: 10),
          child: TextCell(
            string: Text(
              perPiece.toStringAsFixed(0),
              style: const TextStyle(fontSize: 12, fontWeight: .bold),
            ),
            subString: Padding(
              padding: .symmetric(horizontal: 3),
              child: Text(
                "g".tr(),
                style: TextStyle(color: unitColor, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
