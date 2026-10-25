import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/core/shared/widgets/table_cells/product_cell.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class WastesStatusTile extends StatelessWidget {
  const WastesStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusMealsFilterCubit, StatusMealsFilterState>(
      builder: (context, mealsFilterState) {
        final cubit = context.read<StatusMealsFilterCubit>();
        final wastes = cubit.filteredWastes;
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
                      "wastage".tr(),
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
                (mealsFilterState is StatusMealsFilterSuccess)
                    ? Column(
                  children: [
                    Padding(
                      padding: .symmetric(horizontal: 25),
                      child: GlassCard(
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
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(0.9),
                            2: FlexColumnWidth(1.2),
                            3: FlexColumnWidth(0.8),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 2,
                                    color: ThemingColors.primaryColor
                                        .withAlpha((0.4 * 255).toInt()),
                                  ),
                                ),
                              ),
                              children: [
                                Row(
                                  mainAxisAlignment: .start,
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
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
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
                                          "manuf".tr(),
                                          style: TextStyle(
                                            fontWeight: .bold,
                                            color: context.isDark
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
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
                                          "notSold".tr(),
                                          style: TextStyle(
                                            fontWeight: .bold,
                                            color: context.isDark
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
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
                                          "meals".tr(),
                                          style: TextStyle(
                                            fontWeight: .bold,
                                            color: context.isDark
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
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
                            if (wastes.isEmpty)
                              TableRow(
                                children: [
                                  TableCell(
                                    verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                                    child: Align(
                                      alignment:
                                      context.locale.languageCode ==
                                          'ar'
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
                                              Icons
                                                  .assignment_late_outlined,
                                              size: 16,
                                              color: context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                (0.3 * 255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                (0.2 * 255)
                                                    .toInt(),
                                              ),
                                            ),
                                            Text(
                                              "noData".tr(),
                                              style: TextStyle(
                                                color: context.isDark
                                                    ? ThemingColors.white
                                                    .withAlpha(
                                                  (0.3 * 255)
                                                      .toInt(),
                                                )
                                                    : ThemingColors.black
                                                    .withAlpha(
                                                  (0.5 * 255)
                                                      .toInt(),
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
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
                                              (0.2 * 255).toInt(),
                                            ),
                                          ),
                                          Text(
                                            "noData".tr(),
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                (0.3 * 255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                (0.5 * 255)
                                                    .toInt(),
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
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
                                              (0.2 * 255).toInt(),
                                            ),
                                          ),
                                          Text(
                                            "noData".tr(),
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                (0.3 * 255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                (0.5 * 255)
                                                    .toInt(),
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
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.assignment_late_outlined,
                                            size: 16,
                                            color: context.isDark
                                                ? ThemingColors.white
                                                .withAlpha(
                                              (0.3 * 255).toInt(),
                                            )
                                                : ThemingColors.black
                                                .withAlpha(
                                              (0.2 * 255).toInt(),
                                            ),
                                          ),
                                          Text(
                                            "noData".tr(),
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.white
                                                  .withAlpha(
                                                (0.3 * 255)
                                                    .toInt(),
                                              )
                                                  : ThemingColors.black
                                                  .withAlpha(
                                                (0.5 * 255)
                                                    .toInt(),
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
                              ...wastes.asMap().entries.map((entry) {
                                final WasteSummary waste = entry.value;
                                return TableRow(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding:
                                          context
                                              .locale
                                              .languageCode ==
                                              'ar'
                                              ? .only(
                                            top: 15,
                                            bottom: 15,
                                            left: 10,
                                          )
                                              : .only(
                                            top: 15,
                                            bottom: 15,
                                            right: 10,
                                          ),
                                          child: Icon(
                                            Icons.info_outline,
                                            size: 13,
                                            color: context.isDark
                                                ? Colors.blueGrey.withAlpha(
                                              (0.5 * 255).toInt(),
                                            )
                                                : Colors.grey,
                                          ),
                                        ),
                                        Expanded(
                                          child: ProductCell(
                                            productName: waste.productName,
                                            productId: waste.productId,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Padding(
                                          padding: .symmetric(vertical: 10),
                                          child: TextCell(
                                            string: Text(
                                              "${waste.manufacturing}",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Padding(
                                          padding: .symmetric(vertical: 10),
                                          child: TextCell(
                                            string: Text(
                                              "${waste.notSold}",
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: .center,
                                      children: [
                                        Padding(
                                          padding: .symmetric(vertical: 10),
                                          child: TextCell(
                                            string: Text("${waste.meal}"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                    : Padding(
                  padding: .symmetric(horizontal: 25),
                  child: GlassCard(
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
                        0: FlexColumnWidth(2),
                        1: FlexColumnWidth(0.9),
                        2: FlexColumnWidth(1.2),
                        3: FlexColumnWidth(0.8),
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
                            Row(
                              mainAxisAlignment: .start,
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
                              ],
                            ),
                            Row(
                              mainAxisAlignment: .center,
                              children: [
                                Padding(
                                  padding: .symmetric(vertical: 7),
                                  child: TextCell(
                                    string: Text(
                                      "manuf".tr(),
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
                                      "notSold".tr(),
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
                                      "meals".tr(),
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
                                padding: EdgeInsets.symmetric(vertical: 5),
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
                                padding: EdgeInsets.symmetric(vertical: 5),
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
                                padding: EdgeInsets.symmetric(vertical: 5),
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
    );
  }
}