import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/core/shared/widgets/table_cells/product_cell.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_meals_filter_cubit/status_meals_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/models/waste_model.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class WastesStatusTile extends StatelessWidget {
  const WastesStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (index) => index + 1);
    final years = List.generate(11, (index) => 2026 + index);
    return BlocBuilder<StatusMealsFilterCubit, StatusMealsFilterState>(
      builder: (context, mealsFilterState) {
        final cubit = context.read<StatusMealsFilterCubit>();
        final selected = cubit.selectedDate;
        final days = cubit.dynamicDaysList;
        final dayIndex = days.indexOf(selected.day);
        final monthIndex = months.indexOf(selected.month);
        final yearIndex = years.indexOf(selected.year);
        return BranchPager(
          branches: cubit.branches,
          selectedBranchId: cubit.selectedBranchId,
          onBranchChanged: cubit.changeBranch,
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
                    "wastes".tr(),
                    style: TextStyle(fontWeight: .bold, fontSize: 18),
                  ),
                  Spacer(),
                  if (cubit.isExpanded)
                    Padding(
                      padding: .only(right: 5),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          SizedBox(
                            width: 40,
                            child: Column(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_drop_up,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                                Expanded(
                                  child: WheelPicker(
                                    key: ValueKey(days.length),
                                    controller: WheelPickerController(
                                      itemCount: days.length,
                                      initialIndex: dayIndex != -1
                                          ? dayIndex
                                          : 0,
                                    ),
                                    style: WheelPickerStyle(
                                      itemExtent: 30,
                                      surroundingOpacity: 0.25,
                                      diameterRatio: 20,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.changeSelectedDate(
                                        day: days[index],
                                      );
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          "${days[index]}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 3,
                            margin: .symmetric(horizontal: 3),
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                          ),
                          SizedBox(
                            width: 40,
                            child: Column(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_drop_up,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                                Expanded(
                                  child: WheelPicker(
                                    itemCount: months.length,
                                    initialIndex: monthIndex != -1
                                        ? monthIndex
                                        : 0,
                                    style: WheelPickerStyle(
                                      itemExtent: 40,
                                      surroundingOpacity: 0.25,
                                      squeeze: 0.9,
                                      diameterRatio: 3,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.changeSelectedDate(
                                        month: months[index],
                                      );
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          "${months[index]}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 20,
                            width: 3,
                            margin: .symmetric(horizontal: 3),
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.4 * 255).toInt(),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Column(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_drop_up,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
                                  ),
                                ),
                                Expanded(
                                  child: WheelPicker(
                                    itemCount: years.length,
                                    initialIndex: yearIndex != -1
                                        ? yearIndex
                                        : 0,
                                    style: WheelPickerStyle(
                                      itemExtent: 40,
                                      surroundingOpacity: 0.25,
                                      squeeze: 0.9,
                                      diameterRatio: 3,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.changeSelectedDate(
                                        year: years[index],
                                      );
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          "${years[index]}",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.4 * 255).toInt(),
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
                                if (mealsFilterState.mealsRecord.wastes.isEmpty)
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
                                  ...mealsFilterState.mealsRecord.wastes
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                        final WasteModel waste = entry.value;
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
                                                        ? Colors.blueGrey
                                                              .withAlpha(
                                                                (0.5 * 255)
                                                                    .toInt(),
                                                              )
                                                        : Colors.grey,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ProductCell(
                                                    productName:
                                                        waste.productName,
                                                    productId: waste.productId,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: .center,
                                              children: [
                                                Padding(
                                                  padding: .symmetric(
                                                    vertical: 10,
                                                  ),
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
                                                  padding: .symmetric(
                                                    vertical: 10,
                                                  ),
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
                                                  padding: .symmetric(
                                                    vertical: 10,
                                                  ),
                                                  child: TextCell(
                                                    string: Text(
                                                      "${waste.meal}",
                                                    ),
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
        );
      },
    );
  }
}
