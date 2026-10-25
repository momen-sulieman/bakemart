import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/history_filter_cubit/history_filter_cubit.dart';

class ShiftHistoryTile extends StatelessWidget {
  const ShiftHistoryTile({super.key});

  static const List<String> _monthAbbreviations = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final List<int> years = List.generate(10, (index) => 2026 + index);

    return BlocBuilder<HistoryFilterCubit, HistoryFilterState>(
      builder: (context, shiftHistoryFilterState) {
        final cubit = context.read<HistoryFilterCubit>();
        final int monthIndex = cubit.selectedMonth - 1;
        final int yearIndex = years.indexOf(cubit.selectedYear);
        return Theme(
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
            onExpansionChanged: (expanded) {
              cubit.updateTileExpansion(expanded);
            },
            title: SizedBox(
              height: 55,
              child: Row(
                mainAxisAlignment: .start,
                children: [
                  Text(
                    "workHistory".tr(),
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
                            width: 45,
                            child: Column(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_drop_up,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.6 * 255).toInt(),
                                  ),
                                ),
                                Expanded(
                                  child: WheelPicker(
                                    looping: false,
                                    controller: WheelPickerController(
                                      itemCount: 12,
                                      initialIndex: monthIndex,
                                    ),
                                    style: WheelPickerStyle(
                                      itemExtent: 30,
                                      surroundingOpacity: 0.25,
                                      diameterRatio: 10,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.filterByMonth(index + 1);
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          _monthAbbreviations[index],
                                          style: TextStyle(
                                            fontSize: 12,
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
                                    (0.6 * 255).toInt(),
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
                              (0.5 * 255).toInt(),
                            ),
                          ),
                          SizedBox(
                            width: 45,
                            child: Column(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Icon(
                                  Icons.arrow_drop_up,
                                  size: 20,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.6 * 255).toInt(),
                                  ),
                                ),
                                Expanded(
                                  child: WheelPicker(
                                    looping: false,
                                    itemCount: years.length,
                                    initialIndex: yearIndex != -1 ? yearIndex : 0,
                                    style: WheelPickerStyle(
                                      itemExtent: 40,
                                      surroundingOpacity: 0.25,
                                      squeeze: 0.9,
                                      diameterRatio: 3,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.filterByYear(years[index]);
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          "${years[index]}",
                                          style: TextStyle(
                                            fontSize: 12,
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
                                    (0.6 * 255).toInt(),
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
            shape: RoundedRectangleBorder(side: .none),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
              Padding(
                padding: .symmetric(horizontal: 25),
                child: (shiftHistoryFilterState is HistoryFilterSuccess)
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
                            0: FlexColumnWidth(1),
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
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .symmetric(
                                        vertical: 7,
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        "date".tr(),
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
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .symmetric(
                                        vertical: 7,
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        "amount".tr(),
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
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .symmetric(
                                        vertical: 7,
                                        horizontal: 10,
                                      ),
                                      child: Text(
                                        "role".tr(),
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
                                  ],
                                ),
                              ],
                            ),
                            if (shiftHistoryFilterState.filteredShifts.isEmpty)
                              TableRow(
                                children: [
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
                              )
                            else
                              ...shiftHistoryFilterState.filteredShifts.asMap().entries.map((
                                entry,
                              ) {
                                final ShiftModel shift = entry.value;
                                final int? batches = shift.numberOfBatches.isEmpty
                                    ? null
                                    : shift.numberOfBatches.fold<int>(
                                        0,
                                        (sum, item) => sum + item,
                                      );
                                final String? rateNumberStr = shift.rate == null
                                    ? null
                                    : (shift.rate! * 100).toStringAsFixed(0);
                                final List<String> roles = shift.role;
                                final String? dayStr = shift.date?.day
                                    .toString()
                                    .padLeft(2, '0');
                                final String? monthStr = shift.date?.month
                                    .toString()
                                    .padLeft(2, '0');
                                final String? yearStr = shift.date?.year
                                    .toString();
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: .symmetric(vertical: 7),
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        children: [
                                          dayStr != null
                                              ? Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: dayStr,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: " / ",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: .bold,
                                                          color: ThemingColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: monthStr,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: " / ",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: .bold,
                                                          color: ThemingColors
                                                              .primaryColor,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: yearStr,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  '',
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: .symmetric(vertical: 7),
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        children: [
                                          (batches == null &&
                                                  rateNumberStr != null)
                                              ? Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "\u200E$rateNumberStr%  ",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight: .bold
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: "day".tr(),
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: context.isDark
                                                              ? ThemingColors
                                                                    .white
                                                                    .withAlpha(
                                                                      (0.4 * 255)
                                                                          .toInt(),
                                                                    )
                                                              : ThemingColors
                                                                    .black
                                                                    .withAlpha(
                                                                      (0.4 * 255)
                                                                          .toInt(),
                                                                    ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Text(
                                                  batches!.toString(),
                                                  style: TextStyle(fontSize: 13),
                                                ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: .symmetric(
                                        vertical: roles.length > 1 ? 0 : 7,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: .center,
                                        children: [
                                          roles.length > 1
                                              ? InkWell(
                                                  hoverColor: Colors.transparent,
                                                  splashColor: Colors.transparent,
                                                  highlightColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      builder: (dialogContext) {
                                                        return BackdropFilter(
                                                          filter: .blur(
                                                            sigmaY: 2,
                                                            sigmaX: 2,
                                                          ),
                                                          child: AlertDialog(
                                                            backgroundColor:
                                                                context.isDark
                                                                ? ThemingColors
                                                                      .black
                                                                      .withAlpha(
                                                                        (0.1 * 255)
                                                                            .toInt(),
                                                                      )
                                                                : ThemingColors
                                                                      .white
                                                                      .withAlpha(
                                                                        (0.1 * 255)
                                                                            .toInt(),
                                                                      ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    20,
                                                                  ),
                                                              side: BorderSide(
                                                                color:
                                                                    context.isDark
                                                                    ? ThemingColors
                                                                          .lightGrey
                                                                    : ThemingColors
                                                                          .black,
                                                                width:
                                                                    context.isDark
                                                                    ? 0.2
                                                                    : 0.3,
                                                              ),
                                                            ),
                                                            content: SingleChildScrollView(
                                                              child: Container(
                                                                margin: .all(15),
                                                                padding:
                                                                    .symmetric(
                                                                      vertical:
                                                                          10,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        10,
                                                                      ),
                                                                  color:
                                                                      context
                                                                          .isDark
                                                                      ? ThemingColors
                                                                            .black
                                                                            .withAlpha(
                                                                              (0.4 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            )
                                                                      : ThemingColors
                                                                            .white
                                                                            .withAlpha(
                                                                              (0.9 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            ),
                                                                  border: .all(
                                                                    width: 0.2,
                                                                    color:
                                                                        context
                                                                            .isDark
                                                                        ? ThemingColors
                                                                              .white
                                                                        : ThemingColors
                                                                              .black,
                                                                  ),
                                                                ),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: roles.map((
                                                                    role,
                                                                  ) {
                                                                    return Padding(
                                                                      padding:
                                                                          .symmetric(
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                      child: Text(
                                                                        role,
                                                                        style: const TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ),
                                                            actions: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    .center,
                                                                children: [
                                                                  InkWell(
                                                                    hoverColor: Colors
                                                                        .transparent,
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () =>
                                                                        Navigator.pop(
                                                                          dialogContext,
                                                                        ),
                                                                    child: const Text(
                                                                      "Close",
                                                                      style: TextStyle(
                                                                        color: ThemingColors
                                                                            .primaryColor,
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            .bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.more_horiz,
                                                    size: 30,
                                                    color: ThemingColors
                                                        .primaryColor,
                                                  ),
                                                )
                                              : Text(
                                                  roles[0].tr(),
                                                  style: TextStyle(fontSize: 13),
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
                    : (shiftHistoryFilterState is HistoryFilterLoading)
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: ThemingColors.primaryColor,
                        size: 25,
                      )
                    : SizedBox(),
              ),
            ],
          ),
        );
      },
    );
  }
}
