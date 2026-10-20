import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/logic/bakery_tab_cubit/bakery_tab_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_status/logic/status_shifts_filter_cubit/status_shifts_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/models/shift_model.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/shared/widgets/table_cells/worker_cell.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class ShiftsStatusTile extends StatelessWidget {
  const ShiftsStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (index) => index + 1);
    final years = List.generate(11, (index) => 2026 + index);
    return BlocBuilder<StatusShiftsFilterCubit, StatusShiftsFilterState>(
      builder: (context, financeFilterState) {
        final bakeryCubit = context.read<BakeryTabCubit>();
        final cubit = context.read<StatusShiftsFilterCubit>();
        final payrollMethod = bakeryCubit
            .payrollFor(cubit.selectedBranchId)
            .payrollMethod;
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
                    "shifts".tr(),
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
              Padding(
                padding: .only(right: 25, left: 25),
                child: (financeFilterState is StatusShiftsFilterSuccess)
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
                            0: FlexColumnWidth(2.0),
                            1: FlexColumnWidth(0.7),
                            2: FlexColumnWidth(0.7),
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
                                      "worker".tr(),
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
                                          payrollMethod
                                              ? "hours".tr()
                                              : "batches".tr(),
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
                                          "wage".tr(),
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
                            if (financeFilterState.shifts.isEmpty)
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
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
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
                                  TableCell(
                                    verticalAlignment:
                                        TableCellVerticalAlignment.middle,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
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
                                ],
                              )
                            else
                              ...financeFilterState.shifts.asMap().entries.map((
                                entry,
                              ) {
                                final ShiftModel shift = entry.value;
                                final int totalBatches = shift.numberOfBatches
                                    .fold(0, (sum, element) => sum + element);
                                final rate = shift.rate;
                                final rateString = rate == 1
                                    ? "100%"
                                    : rate == 0.5
                                    ? "50%"
                                    : rate == 0.25
                                    ? "25%"
                                    : "--";
                                return TableRow(
                                  children: [
                                    InkWell(
                                      highlightColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.transparent,
                                          builder: (dialogContext) {
                                            return BackdropFilter(
                                              filter: .blur(
                                                sigmaX: context.isDark ? 2 : 5,
                                                sigmaY: context.isDark ? 2 : 5,
                                              ),
                                              child: AlertDialog(
                                                titlePadding: .only(
                                                  top: 20,
                                                  right: 20,
                                                  left: 20,
                                                ),
                                                contentPadding: .all(20),
                                                actionsPadding: .only(
                                                  bottom: 20,
                                                  right: 20,
                                                  left: 20,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: .circular(20),
                                                  side: BorderSide(
                                                    width: 0.2,
                                                    color: context.isDark
                                                        ? ThemingColors.white
                                                        : ThemingColors.black,
                                                  ),
                                                ),
                                                backgroundColor: context.isDark
                                                    ? ThemingColors.black
                                                          .withAlpha(
                                                            (0.4 * 255).toInt(),
                                                          )
                                                    : ThemingColors.black
                                                          .withAlpha(
                                                            (0.05 * 255)
                                                                .toInt(),
                                                          ),
                                                title: Container(
                                                  padding: .all(15),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    color: context.isDark
                                                        ? ThemingColors.black
                                                              .withAlpha(
                                                                (0.4 * 255)
                                                                    .toInt(),
                                                              )
                                                        : ThemingColors.white
                                                              .withAlpha(
                                                                (0.4 * 255)
                                                                    .toInt(),
                                                              ),
                                                    border: .all(
                                                      width: 0.3,
                                                      color: context.isDark
                                                          ? ThemingColors.white
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                )
                                                          : ThemingColors.black
                                                                .withAlpha(
                                                                  (0.5 * 255)
                                                                      .toInt(),
                                                                ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: WorkerCell(
                                                          workerName:
                                                              shift.workerName,
                                                          workerId:
                                                              shift.workerId,
                                                          noPadding: true,
                                                        ),
                                                      ),
                                                      GlassCard(
                                                        margin: .zero,
                                                        padding: .symmetric(
                                                          vertical: 3,
                                                          horizontal: 15,
                                                        ),
                                                        otherRadius: 30,
                                                        child: Text.rich(
                                                          TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    shift
                                                                        .numberOfBatches
                                                                        .isEmpty
                                                                    ? shift
                                                                          .role[0]
                                                                    : "$totalBatches",
                                                              ),
                                                              if (shift
                                                                  .numberOfBatches
                                                                  .isNotEmpty)
                                                                TextSpan(
                                                                  text: "  ",
                                                                ),
                                                              if (shift
                                                                  .numberOfBatches
                                                                  .isNotEmpty)
                                                                TextSpan(
                                                                  text: "batch"
                                                                      .tr(),
                                                                  style: TextStyle(
                                                                    color:
                                                                        context
                                                                            .isDark
                                                                        ? ThemingColors.white.withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                        : ThemingColors.black.withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                content: SizedBox(
                                                  height:
                                                      shift
                                                          .numberOfBatches
                                                          .isEmpty
                                                      ? 50
                                                      : 220,
                                                  width: double.maxFinite,
                                                  child: Column(
                                                    mainAxisSize: .min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      if (shift
                                                          .numberOfBatches
                                                          .isNotEmpty)
                                                        Container(
                                                          padding: .symmetric(
                                                            horizontal: 15,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                            color:
                                                                context.isDark
                                                                ? ThemingColors
                                                                      .black
                                                                      .withAlpha(
                                                                        (0.4 * 255)
                                                                            .toInt(),
                                                                      )
                                                                : ThemingColors
                                                                      .white
                                                                      .withAlpha(
                                                                        (0.4 * 255)
                                                                            .toInt(),
                                                                      ),
                                                            border: .all(
                                                              width: 0.3,
                                                              color:
                                                                  context.isDark
                                                                  ? ThemingColors
                                                                        .white
                                                                        .withAlpha(
                                                                          (0.4 *
                                                                                  255)
                                                                              .toInt(),
                                                                        )
                                                                  : ThemingColors
                                                                        .black
                                                                        .withAlpha(
                                                                          (0.5 *
                                                                                  255)
                                                                              .toInt(),
                                                                        ),
                                                            ),
                                                          ),
                                                          child: ListView.separated(
                                                            shrinkWrap: true,
                                                            padding: .symmetric(
                                                              vertical: 10,
                                                            ),
                                                            itemCount: shift
                                                                .numberOfBatches
                                                                .length,
                                                            separatorBuilder: (context, index) => Divider(
                                                              color:
                                                                  context.isDark
                                                                  ? ThemingColors
                                                                        .white
                                                                        .withAlpha(
                                                                          (0.1 *
                                                                                  255)
                                                                              .toInt(),
                                                                        )
                                                                  : ThemingColors
                                                                        .black
                                                                        .withAlpha(
                                                                          (0.1 *
                                                                                  255)
                                                                              .toInt(),
                                                                        ),
                                                              height: 25,
                                                              thickness: 0.5,
                                                            ),
                                                            itemBuilder: (context, index) {
                                                              final role = shift
                                                                  .role[index];
                                                              double rate = 0;
                                                              final payroll =
                                                                  bakeryCubit
                                                                      .payrollFor(
                                                                        shift
                                                                            .branchId,
                                                                      );
                                                              switch (role) {
                                                                case PayrollsTableColumns
                                                                    .ajan:
                                                                  rate =
                                                                      payroll
                                                                          .ajan ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .faran:
                                                                  rate =
                                                                      payroll
                                                                          .faran ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .tawlaji:
                                                                  rate =
                                                                      payroll
                                                                          .tawlaji ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .chef:
                                                                  rate =
                                                                      payroll
                                                                          .chef ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .coChef:
                                                                  rate =
                                                                      payroll
                                                                          .coChef ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .bagger:
                                                                  rate =
                                                                      payroll
                                                                          .bagger ??
                                                                      0;
                                                                  break;
                                                                case PayrollsTableColumns
                                                                    .supervisor:
                                                                  rate =
                                                                      payroll
                                                                          .supervisor ??
                                                                      0;
                                                                  break;
                                                              }
                                                              final wage =
                                                                  shift
                                                                      .numberOfBatches[index] *
                                                                  rate;
                                                              return Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            30,
                                                                        child: Text(
                                                                          "${shift.numberOfBatches[index]}",
                                                                          textAlign:
                                                                              .center,
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        "as ",
                                                                        style: TextStyle(
                                                                          color:
                                                                              context.isDark
                                                                              ? Colors.amber.withAlpha(
                                                                                  (0.7 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                )
                                                                              : Colors.orange.withAlpha(
                                                                                  (0.7 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                      Text(
                                                                        role.isNotEmpty
                                                                            ? '${role[0].toUpperCase()}${role.substring(1)}'
                                                                            : '',
                                                                        style:
                                                                            TextStyle(),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Spacer(),
                                                                  Text(
                                                                    "$wage",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                  Text(" \$"),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      Container(
                                                        padding: .symmetric(
                                                          horizontal: 15,
                                                          vertical: 10,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          color: context.isDark
                                                              ? ThemingColors
                                                                    .black
                                                                    .withAlpha(
                                                                      (0.4 * 255)
                                                                          .toInt(),
                                                                    )
                                                              : ThemingColors
                                                                    .white
                                                                    .withAlpha(
                                                                      (0.4 * 255)
                                                                          .toInt(),
                                                                    ),
                                                          border: .all(
                                                            width: 0.3,
                                                            color:
                                                                context.isDark
                                                                ? ThemingColors
                                                                      .white
                                                                      .withAlpha(
                                                                        (0.4 * 255)
                                                                            .toInt(),
                                                                      )
                                                                : ThemingColors
                                                                      .black
                                                                      .withAlpha(
                                                                        (0.5 * 255)
                                                                            .toInt(),
                                                                      ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              shift
                                                                      .numberOfBatches
                                                                      .isEmpty
                                                                  ? "hours".tr()
                                                                  : "batches"
                                                                        .tr(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    context
                                                                        .isDark
                                                                    ? ThemingColors
                                                                          .white
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                    : ThemingColors
                                                                          .black
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                              ),
                                                            ),
                                                            Text(
                                                              ":",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    context
                                                                        .isDark
                                                                    ? ThemingColors
                                                                          .white
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                    : ThemingColors
                                                                          .black
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  .symmetric(
                                                                    horizontal:
                                                                        7,
                                                                  ),
                                                              child: Text(
                                                                shift
                                                                        .numberOfBatches
                                                                        .isEmpty
                                                                    ? rateString
                                                                    : "$totalBatches",
                                                              ),
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              "wage".tr(),
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    context
                                                                        .isDark
                                                                    ? ThemingColors
                                                                          .white
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                    : ThemingColors
                                                                          .black
                                                                          .withAlpha(
                                                                            (0.5 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                              ),
                                                            ),
                                                            Text(
                                                              ":",
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    context
                                                                        .isDark
                                                                    ? ThemingColors
                                                                          .white
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                    : ThemingColors
                                                                          .black
                                                                          .withAlpha(
                                                                            (0.4 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  context
                                                                          .locale
                                                                          .languageCode ==
                                                                      'ar'
                                                                  ? .only(
                                                                      right: 7,
                                                                    )
                                                                  : .only(
                                                                      left: 7,
                                                                    ),
                                                              child: Row(
                                                                children: [
                                                                  Text(
                                                                    "${shift.wage}",
                                                                    style: TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                    ),
                                                                  ),
                                                                  Text(" \$"),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  SizedBox(
                                                    width: double.infinity,
                                                    child: InkWell(
                                                      hoverColor:
                                                          Colors.transparent,
                                                      splashColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        Navigator.pop(
                                                          dialogContext,
                                                        );
                                                      },
                                                      child: GlassCard(
                                                        margin: .zero,
                                                        padding: .symmetric(
                                                          vertical: 2,
                                                          horizontal: 10,
                                                        ),
                                                        child: Icon(
                                                          Icons.arrow_back,
                                                          size: 18,
                                                          color: ThemingColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding:
                                                context.locale.languageCode ==
                                                    'ar'
                                                ? .only(left: 10)
                                                : .only(right: 10),
                                            child: Icon(
                                              Icons.info_outline,
                                              size: 13,
                                              color: ThemingColors.primaryColor,
                                            ),
                                          ),
                                          Flexible(
                                            fit: .tight,
                                            child: WorkerCell(
                                              workerName: shift.workerName,
                                              workerId: shift.workerId,
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
                                            string: Text(
                                              payrollMethod
                                                  ? rateString
                                                  : "$totalBatches",
                                              style: TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: .symmetric(vertical: 15),
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        children: [
                                          Text(
                                            shift.wage.toStringAsFixed(2),
                                            textAlign: .center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.green,
                                            ),
                                          ),
                                          Text(
                                            " \$",
                                            style: TextStyle(
                                              color: context.isDark
                                                  ? ThemingColors.white
                                                  : ThemingColors.black,
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
                      )
                    : (financeFilterState is StatusShiftsFilterLoading)
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: ThemingColors.primaryColor,
                        size: 25,
                      )
                    : (financeFilterState is StatusShiftsFilterFialure)
                    ? SizedBox()
                    : SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}
