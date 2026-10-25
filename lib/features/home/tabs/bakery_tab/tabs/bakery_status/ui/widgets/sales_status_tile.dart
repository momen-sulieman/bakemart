import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/core/shared/widgets/product_details_screen/product_details_screen.dart';
import 'package:bakemart/core/shared/widgets/table_cells/product_cell.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_sales_filter_cubit/status_sales_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../../../../../../core/shared/models/recipe_model.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class SalesStatusTile extends StatelessWidget {
  const SalesStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusSalesFilterCubit, StatusSalesFilterState>(
      builder: (context, salesFilterState) {
        final cubit = context.read<StatusSalesFilterCubit>();
        final records = context
            .read<StatusSalesFilterCubit>()
            .filteredSalesRecords;
        return BranchPager(
          branches: cubit.branches,
          selectedBranchId: cubit.selectedBranchId,
          onBranchChanged: cubit.changeBranch,
          showIndicator: cubit.isExpanded,
          enabled: cubit.isExpanded,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
            ),
            child: ExpansionTile(
              splashColor: Colors.transparent,
              initiallyExpanded: true,
              iconColor: ThemingColors.primaryColor,
              collapsedIconColor: ThemingColors.primaryColor,
              shape: RoundedRectangleBorder(side: .none),
              controlAffinity: ListTileControlAffinity.leading,
              onExpansionChanged: (expanded) {
                cubit.updateTileExpansion(expanded);
              },
              title: SizedBox(
                height: 53,
                child: Row(
                  mainAxisAlignment: .start,
                  children: [
                    Text(
                      "sales".tr(),
                      style: TextStyle(fontWeight: .bold, fontSize: 18),
                    ),
                    Spacer(),
                    if (cubit.isExpanded) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: DatePeriodWheels(
                          selectedDate: cubit.selectedDate,
                          showDay: cubit.useDay,
                          showMonth: cubit.useMonth,
                          onChanged: ({year, month, day}) =>
                              cubit.changeSelectedDate(
                                year: year,
                                month: month,
                                day: day,
                              ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      DatePeriodFilterButton(
                        filter: cubit,
                        onApply: cubit.applyDateFilter,
                      ),
                    ],
                  ],
                ),
              ),
              children: [
                Padding(
                  padding: .only(right: 25, left: 25),
                  child: (salesFilterState is StatusSalesFilterSuccess)
                      ? GlassCard(
                    margin: .zero,
                    padding: .symmetric(horizontal: 10, vertical: 5),
                    radius: 20,
                    otherRadius: 20,
                    child: Table(
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
                        0: FlexColumnWidth(2.8),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(0.8),
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
                              padding: .symmetric(
                                vertical: 7,
                                horizontal: 10,
                              ),
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
                                      "produced".tr(),
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
                                      "sold".tr(),
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
                        if (records.isEmpty)
                          TableRow(
                            children: [
                              TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Align(
                                  alignment:
                                  context.locale.languageCode == 'ar'
                                      ? .centerRight
                                      : .centerLeft,
                                  child: Padding(
                                    padding: .all(10),
                                    child: Column(
                                      crossAxisAlignment: .center,
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
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
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
                                  padding: .symmetric(vertical: 10),
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
                              TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: .symmetric(vertical: 10),
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
                            ],
                          )
                        else
                          ...records.asMap().entries.map((entry) {
                            final SalesSummary record = entry.value;
                            final int sold = record.sold;
                            final int produced = record.produced;
                            final bakeryCubit = context
                                .read<BakeryTabCubit>();
                            final ProductModel product = bakeryCubit.products
                                .firstWhere(
                                  (prod) =>
                              prod.productId == record.productId,
                              orElse: () => ProductModel(
                                bakeryId: record.bakeryId,
                                branchId: record.branchId,
                                productName: "Unknown Product",
                                productWeight: 0,
                                productPrice: record.productPrice,
                                productRecipe: RecipeModel(
                                  bakeryId: record.bakeryId,
                                  yeast: 0,
                                  salt: 0,
                                  sugar: 0,
                                  flourType: "",
                                ),
                                quantityPerBatch: 0,
                                yesterdayProduced: 0,
                                yesterdaySold: 0,
                                totalProduced: 0,
                                totalSold: 0,
                                notSoldWaste: 0,
                                manufacturingWaste: 0,
                                mealsWaste: 0,
                                available: 0,
                              ),
                            );
                            return TableRow(
                              children: [
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierColor: context.isDark
                                          ? ThemingColors.black.withAlpha(
                                        (0.6 * 255).toInt(),
                                      )
                                          : ThemingColors.white.withAlpha(
                                        (0.6 * 255).toInt(),
                                      ),
                                      builder: (dialogContext) {
                                        return ProductDetailsScreen(
                                          product: product,
                                          statistict: true,
                                        );
                                      },
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: context.locale.languageCode == 'ar'?  .only(
                                          top: 15,
                                          bottom: 15,
                                          left: 10,
                                        ):.only(
                                          top: 15,
                                          bottom: 15,
                                          right: 10,
                                        ),
                                        child: Icon(
                                          Icons.info_outline,
                                          size: 13,
                                          color: ThemingColors.primaryColor,
                                        ),
                                      ),
                                      Expanded(
                                        child: ProductCell(
                                          productName: record.productName,
                                          productId: record.productId,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .symmetric(vertical: 15),
                                      child: TextCell(
                                        string: Text("$produced"),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .only(top: 15, bottom: 15),
                                      child: TextCell(string: Text("$sold")),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                      ],
                    ),
                  )
                      : (salesFilterState is StatusSalesFilterLoading)
                      ? LoadingAnimationWidget.staggeredDotsWave(
                    color: ThemingColors.primaryColor,
                    size: 25,
                  )
                      : (salesFilterState is StatusSalesFilterFialure)
                      ? SizedBox()
                      : SizedBox(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}