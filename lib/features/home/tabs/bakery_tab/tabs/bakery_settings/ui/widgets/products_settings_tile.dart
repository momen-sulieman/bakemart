import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../../../../core/shared/widgets/dialogs/add_product_dialog/ui/add_product_dialog.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/product_details_screen/product_details_screen.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/shared/widgets/table_cells/product_cell.dart';
import '../../../../../../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/settings_update_cubit/settings_update_cubit.dart';

class ProductsSettingsTile extends StatelessWidget {
  final List<ProductModel> products;

  const ProductsSettingsTile({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return ExpansionTile(
          splashColor: Colors.transparent,
          initiallyExpanded: true,
          iconColor: ThemingColors.primaryColor,
          collapsedIconColor: ThemingColors.primaryColor,
          shape: RoundedRectangleBorder(side: .none),
          controlAffinity: ListTileControlAffinity.leading,
          onExpansionChanged: (expanded) {
            cubit.updateProductsTileExpansion(expanded);
          },
          title: SizedBox(
            height: 53,
            child: Row(
              mainAxisAlignment: .start,
              children: [
                Text(
                  "products".tr(),
                  style: TextStyle(fontWeight: .bold, fontSize: 18),
                ),
                Spacer(),
                cubit.isProductsEditing
                    ? Container(
                  margin: .only(right: 10),
                  padding: .symmetric(
                    horizontal: cubit.isProductsChanged ? 15 : 5,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: .circular(50),
                    border: Border.all(
                      color: context.isDark
                          ? Colors.white.withAlpha((0.2 * 255).toInt())
                          : ThemingColors.black.withAlpha(
                        (0.2 * 255).toInt(),
                      ),
                      width: 0.7,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.isDark
                            ? Colors.white.withAlpha((0.1 * 255).toInt())
                            : Colors.black.withAlpha((0.1 * 255).toInt()),
                        blurRadius: 10,
                        spreadRadius: -2,
                        offset: Offset(5, -5),
                      ),
                      BoxShadow(
                        color: context.isDark
                            ? Colors.black.withAlpha((0.4 * 255).toInt())
                            : Colors.white.withAlpha((0.4 * 255).toInt()),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(15, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          cubit.productsCancelEditing();
                        },
                        child: Icon(
                          cubit.changedProductPictures.isNotEmpty
                              ? Icons.done
                              : Icons.close,
                          size: 18,
                          color: cubit.changedProductPictures.isNotEmpty
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),
                      if (cubit.isProductsChanged)
                        SizedBox(
                          height: 17,
                          width: 35,
                          child: Center(
                            child: Container(
                              width: 1,
                              color: context.isDark
                                  ? ThemingColors.white.withAlpha(
                                (0.4 * 255).toInt(),
                              )
                                  : ThemingColors.black.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                            ),
                          ),
                        ),
                      if (cubit.isProductsChanged)
                        InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {},
                          child:
                          BlocBuilder<
                              SettingsUpdateCubit,
                              SettingsUpdateState
                          >(
                            builder: (context, updateState) {
                              final updateCubit = context
                                  .read<SettingsUpdateCubit>();
                              return SizedBox(
                                width: 18,
                                child:
                                (updateState
                                is SettingsUpdateInitial)
                                    ? InkWell(
                                  onTap: () async {
                                    await updateCubit
                                        .updateProducts(
                                      cubit
                                          .editableProducts,
                                    );
                                  },
                                  child: Icon(
                                    Icons.done,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                )
                                    : LoadingAnimationWidget.staggeredDotsWave(
                                  color: Colors.green,
                                  size: 13,
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                )
                    : cubit.isProductsExpanded
                    ? Padding(
                  padding: .only(right: 10),
                  child: InkWell(
                    onTap: () {
                      cubit.productsEditingMode(!cubit.isProductsEditing);
                    },
                    child: Icon(Icons.edit),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          ),
          children: [
            BranchPager(
              branches: cubit.bakeries,
              selectedBranchId: cubit.productsViewedBranch,
              onBranchChanged: cubit.productsBranchChanged,
              child: Padding(
                padding: .symmetric(horizontal: 25),
                child: GlassCard(
                  margin: .zero,
                  padding: .symmetric(horizontal: 10, vertical: 5),
                  radius: 20,
                  otherRadius: 20,
                  child: Column(
                    children: [
                      Table(
                        border: TableBorder(
                          horizontalInside: BorderSide(
                            width: 0.5,
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.2 * 255).toInt(),
                            ),
                          ),
                          verticalInside: BorderSide(
                            width: 2,
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.2 * 255).toInt(),
                            ),
                          ),
                        ),
                        columnWidths: {
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
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: .symmetric(vertical: 7, horizontal: 10),
                                child: TextCell(
                                  string: Text(
                                    "product".tr(),
                                    textAlign: .center,
                                    style: TextStyle(
                                      fontWeight: .bold,
                                      color: context.isDark
                                          ? ThemingColors.white.withAlpha(
                                        (0.3 * 255).toInt(),
                                      )
                                          : ThemingColors.black.withAlpha(
                                        (0.3 * 255).toInt(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Padding(
                                    padding: .symmetric(vertical: 7),
                                    child: TextCell(
                                      string: Text(
                                        "weight".tr(),
                                        style: TextStyle(
                                          fontWeight: .bold,
                                          color: context.isDark
                                              ? ThemingColors.white.withAlpha(
                                            (0.3 * 255).toInt(),
                                          )
                                              : ThemingColors.black.withAlpha(
                                            (0.3 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Padding(
                                    padding: .symmetric(vertical: 7),
                                    child: TextCell(
                                      string: Text(
                                        "price".tr(),
                                        style: TextStyle(
                                          fontWeight: .bold,
                                          color: context.isDark
                                              ? ThemingColors.white.withAlpha(
                                            (0.3 * 255).toInt(),
                                          )
                                              : ThemingColors.black.withAlpha(
                                            (0.3 * 255).toInt(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (products.isEmpty)
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                                  child: Align(
                                    alignment: context.locale.languageCode == 'ar'
                                        ? .centerRight
                                        : .centerLeft,
                                    child: Padding(
                                      padding: .all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.assignment_late_outlined,
                                            size: 16,
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black.withAlpha(
                                              (0.2 * 255).toInt(),
                                            ),
                                          ),
                                          Text(
                                            "noData".tr(),
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.white.withAlpha(
                                                (0.3 * 255).toInt(),
                                              )
                                                  : ThemingColors.black.withAlpha(
                                                (0.5 * 255).toInt(),
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_late_outlined,
                                          size: 16,
                                          color: context.isDark
                                              ? ThemingColors.white.withAlpha(
                                            (0.3 * 255).toInt(),
                                          )
                                              : ThemingColors.black.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                        ),
                                        Text(
                                          "noData".tr(),
                                          style: TextStyle(
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black.withAlpha(
                                              (0.5 * 255).toInt(),
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TableCell(
                                  verticalAlignment:
                                  TableCellVerticalAlignment.middle,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.assignment_late_outlined,
                                          size: 16,
                                          color: context.isDark
                                              ? ThemingColors.white.withAlpha(
                                            (0.3 * 255).toInt(),
                                          )
                                              : ThemingColors.black.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                        ),
                                        Text(
                                          "noData".tr(),
                                          style: TextStyle(
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black.withAlpha(
                                              (0.5 * 255).toInt(),
                                            ),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            ...products.asMap().entries.map((entry) {
                              final int index = entry.key;
                              final ProductModel product = entry.value;
                              final List<ProductModel> oldProducts =
                                  cubit.products;
                              final ProductModel? oldProduct = oldProducts
                                  .firstWhereOrNull(
                                    (p) => p.productId == product.productId,
                              );
                              final bool changed =
                                  oldProduct == null ||
                                      product != oldProduct ||
                                      cubit.changedProductPictures.contains(
                                        product.productId,
                                      );
                              return TableRow(
                                children: [
                                  InkWell(
                                    hoverColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () {
                                      if (cubit.isProductsEditing) {
                                        showDialog(
                                          context: context,
                                          barrierColor: context.isDark
                                              ? ThemingColors.black.withAlpha(
                                            (0.4 * 255).toInt(),
                                          )
                                              : ThemingColors.white.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          builder: (dialogContext) {
                                            return BlocProvider.value(
                                              value: cubit,
                                              child: ProductDetailsScreen(
                                                product: product,
                                                recipe: true,
                                                nutrition: false,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Padding(
                                      padding: .symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          cubit.isProductsEditing
                                              ? Padding(
                                            padding:
                                            context
                                                .locale
                                                .languageCode ==
                                                'ar'
                                                ? .only(left: 15, right: 3)
                                                : .only(right: 15, left: 3),
                                            child: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: ThemingColors
                                                  .primaryColor,
                                            ),
                                          )
                                              : SizedBox(
                                            width: 34,
                                            child: Padding(
                                              padding:
                                              context
                                                  .locale
                                                  .languageCode ==
                                                  'ar'
                                                  ? .only(right: 7)
                                                  : .only(left: 7),
                                              child: Text(
                                                "${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: .bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: ProductCell(
                                              key: ValueKey(
                                                'product_avatar_${product.productId}_${cubit.productImageVersion[product.productId] ?? 0}',
                                              ),
                                              productName: product.productName,
                                              productId: product.productId!,
                                              pendingImage:
                                              cubit
                                                  .pendingProductImages[product
                                                  .productId],
                                              opacity: cubit.isProductsEditing
                                                  ? (changed ? 1 : 0.3)
                                                  : 1,
                                              textColor: cubit.isProductsEditing
                                                  ? (context.isDark
                                                  ? ThemingColors.white
                                                  : ThemingColors.black)
                                                  .withAlpha(
                                                ((changed ? 1 : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: .symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            "${product.productWeight}",
                                            maxLines: 1,
                                            overflow: .ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cubit.isProductsEditing
                                                  ? context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                ((changed
                                                    ? 1
                                                    : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                ((changed
                                                    ? 1
                                                    : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: .symmetric(horizontal: 5),
                                          child: Text(
                                            "g".tr(),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.isDark
                                                  ? cubit.isProductsEditing
                                                  ? Colors.amber.withAlpha(
                                                ((changed ? 1 : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : Colors.amber
                                                  : cubit.isProductsEditing
                                                  ? Colors.orange.withAlpha(
                                                ((changed ? 1 : 0.5) * 255)
                                                    .toInt(),
                                              )
                                                  : Colors.orange,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: .symmetric(
                                      vertical: 15,
                                      horizontal: 10,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            product.productPrice.toStringAsFixed(
                                              2,
                                            ),
                                            maxLines: 1,
                                            overflow: .ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: cubit.isProductsEditing
                                                  ? context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                ((changed
                                                    ? 1
                                                    : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                ((changed
                                                    ? 1
                                                    : 0.5) *
                                                    255)
                                                    .toInt(),
                                              )
                                                  : null,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          " \$",
                                          style: TextStyle(
                                            color: cubit.isProductsEditing
                                                ? Colors.green.withAlpha(
                                              ((changed ? 1 : 0.5) * 255)
                                                  .toInt(),
                                            )
                                                : Colors.green,
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
                      if (cubit.isProductsEditing)
                        Padding(
                          padding: .only(top: 10, bottom: 10),
                          child: TransparentButton(
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (dialogContext) => AddProductDialog(
                                  bakeryId: cubit.bakeries.first.bakeryId,
                                  initialFlourIndex: 1,
                                  onSave: (product, image) => cubit.addProduct(
                                    product.copyWith(
                                      branchId: cubit.productsViewedBranch,
                                    ),
                                    image: image,
                                  ),
                                ),
                              );
                            },
                            icon: Icons.add,
                            size: 18,
                            verticalPadding: 2,
                            buttonHorizontalPading: 0,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}