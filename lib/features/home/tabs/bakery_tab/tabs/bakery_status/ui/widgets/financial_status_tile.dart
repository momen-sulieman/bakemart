import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';

class FinancialStatusTile extends StatelessWidget {
  const FinancialStatusTile({super.key});

  @override
  Widget build(BuildContext context) {
    final months = List.generate(12, (index) => index + 1);
    final years = List.generate(11, (index) => 2026 + index);
    return BlocBuilder<StatusFinanceFilterCubit, StatusFinanceFilterState>(
      builder: (context, financeFilterState) {
        final cubit = context.read<StatusFinanceFilterCubit>();
        final selected = cubit.selectedDate;
        final days = cubit.dynamicDaysList;
        final dayIndex = days.indexOf(selected.day);
        final monthIndex = months.indexOf(selected.month);
        final yearIndex = years.indexOf(selected.year);
        return ExpansionTile(
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
                  "finance".tr(),
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
                                    initialIndex: dayIndex != -1 ? dayIndex : 0,
                                  ),
                                  style: WheelPickerStyle(
                                    itemExtent: 30,
                                    surroundingOpacity: 0.25,
                                    diameterRatio: 20,
                                  ),
                                  onIndexChanged: (index, _) {
                                    cubit.changeSelectedDate(day: days[index]);
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
                                  initialIndex: yearIndex != -1 ? yearIndex : 0,
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
            (financeFilterState is StatusFinanceFilterSuccess)
                ? Column(
                    children: [
                      Padding(
                        padding: .symmetric(horizontal: 25),
                        child: GlassCard(
                          radius: 20,
                          otherRadius: 20,
                          margin: .zero,
                          padding: .only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              Padding(
                                padding: .only(bottom: 10,left: 5,right: 5),
                                child: SizedBox(
                                  width: 120,
                                  child: GlassCard(
                                    margin: .zero,
                                    padding: .symmetric(vertical: 5),
                                    dark: true,
                                    otherRadius: 30,
                                    child: Text(
                                      "expenses".tr(),
                                      textAlign: .center,
                                      style: TextStyle(
                                        fontWeight: .bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: .symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    Text("sideExpenses".tr()),
                                    Spacer(),
                                    Text(
                                      financeFilterState
                                          .financeRecord
                                          .cleaningExpenses
                                          .toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      textAlign: .end,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(fontWeight: .bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: .symmetric(horizontal: 20),
                                padding: .only(top: 0.1),
                                color: ThemingColors.white,
                              ),
                              Padding(
                                padding: .symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    Text("payroll".tr()),
                                    Spacer(),
                                    Text(
                                      (financeFilterState
                                              .financeRecord
                                              .payrollExpenses)
                                          .toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      textAlign: .end,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(fontWeight: .bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: .symmetric(horizontal: 20),
                                padding: .only(top: 0.1),
                                color: ThemingColors.white,
                              ),
                              Padding(
                                padding: .symmetric(
                                  vertical: 8,
                                  horizontal: 20,
                                ),
                                child: Row(
                                  children: [
                                    Text("total".tr()),
                                    Spacer(),
                                    Text(
                                      (financeFilterState
                                              .financeRecord
                                              .totalExpenses)
                                          .toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      textAlign: .end,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(fontWeight: .bold),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: .symmetric(
                                  vertical: 15,
                                  horizontal: 5,
                                ),
                                child: SizedBox(
                                  width: 120,
                                  child: GlassCard(
                                    margin: .zero,
                                    padding: .symmetric(vertical: 5),
                                    dark: true,
                                    otherRadius: 30,
                                    child: Text(
                                      "income".tr(),
                                      textAlign: .center,
                                      style: TextStyle(
                                        fontWeight: .bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: .symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text("profit".tr()),
                                    Spacer(),
                                    Text(
                                      (financeFilterState.financeRecord.profit)
                                          .toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      textAlign: .end,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(fontWeight: .bold),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: .symmetric(horizontal: 20),
                                padding: .only(top: 0.1),
                                color: ThemingColors.white,
                              ),
                              Padding(
                                padding: .symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text("netProfit".tr()),
                                    Spacer(),
                                    Text(
                                      (financeFilterState
                                              .financeRecord
                                              .netProfit)
                                          .toStringAsFixed(2),
                                      maxLines: 1,
                                      overflow: .ellipsis,
                                      textAlign: .end,
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: .bold,
                                      ),
                                    ),
                                    Text(
                                      " \$",
                                      style: TextStyle(fontWeight: .bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: .only(left: 25, right: 25),
                    child: SizedBox(
                      width: double.infinity,
                      child: GlassCard(
                        margin: .zero,
                        padding: .symmetric(horizontal: 10, vertical: 5),
                        radius: 20,
                        otherRadius: 20,
                        child: Row(
                          mainAxisSize: .max,
                          mainAxisAlignment: .center,
                          children: [
                            Padding(
                              padding: .symmetric(vertical: 10),
                              child: Text(
                                "noRecordsForThisDate".tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: .bold,
                                  color: context.isDark
                                      ? ThemingColors.white.withAlpha(
                                          (0.4 * 255).toInt(),
                                        )
                                      : ThemingColors.black.withAlpha(
                                          (0.4 * 255).toInt(),
                                        ),
                                ),
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
