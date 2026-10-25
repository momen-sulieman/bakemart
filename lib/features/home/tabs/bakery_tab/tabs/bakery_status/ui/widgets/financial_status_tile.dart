import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../../core/shared/models/expenses_model.dart';
import '../../../../../../../../core/shared/widgets/date_period_filter/date_period_filter.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/status_finance_filter_cubit/status_finance_filter_cubit.dart';

class FinancialStatusTile extends StatelessWidget {
  const FinancialStatusTile({super.key});
  void _showExpensesInfoDialog(
      BuildContext context,
      List<ExpensesModel> expenses,
      ) {
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (dialogContext) {
        return BackdropFilter(
          filter: .blur(
            sigmaX: context.isDark ? 5 : 7,
            sigmaY: context.isDark ? 5 : 7,
          ),
          child: AlertDialog(
            titlePadding: .zero,
            contentPadding: .symmetric(vertical: 25, horizontal: 25),
            actionsPadding: .only(bottom: 15, right: 15, left: 15),
            insetPadding: .symmetric(horizontal: 20),
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
                ? ThemingColors.black.withAlpha((0.2 * 255).toInt())
                : ThemingColors.black.withAlpha((0.1 * 255).toInt()),
            title: Container(
              margin: .only(top: 15, right: 25, left: 25),
              padding: .symmetric(vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: context.isDark
                    ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                    : ThemingColors.white.withAlpha((0.7 * 255).toInt()),
                border: .all(
                  width: 0.2,
                  color: context.isDark
                      ? ThemingColors.white
                      : ThemingColors.black,
                ),
              ),
              child: Text("sideExpenses".tr(), textAlign: .center),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Container(
                padding: .symmetric(horizontal: 15, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: context.isDark
                      ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                      : ThemingColors.white.withAlpha((0.7 * 255).toInt()),
                  border: .all(
                    width: 0.2,
                    color: context.isDark
                        ? ThemingColors.white
                        : ThemingColors.black,
                  ),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: expenses.isEmpty
                      ? Center(
                    child: Padding(
                      padding: .symmetric(vertical: 10),
                      child: Text(
                        "noData".tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          (context.isDark
                              ? ThemingColors.white
                              : ThemingColors.black)
                              .withAlpha((0.4 * 255).toInt()),
                        ),
                      ),
                    ),
                  )
                      : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: .min,
                      children: expenses.map((expense) {
                        return Padding(
                          padding: .symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expense.item,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: Row(
                                  mainAxisAlignment: .end,
                                  children: [
                                    Text(
                                      expense.value.toStringAsFixed(2),
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
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pop(dialogContext),
                child: GlassCard(
                  margin: .symmetric(horizontal: 6),
                  padding: .symmetric(vertical: 2),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: ThemingColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _section(String key, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SizedBox(
        width: 120,
        child: GlassCard(
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.symmetric(vertical: 5),
          dark: true,
          otherRadius: 30,
          child: Text(
            key.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }

  Widget _valueRow(
    String key,
    double value, {
    bool divider = true,
    bool expenses = false,
    VoidCallback? onInfoTap,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (expenses)
                Padding(
                  padding: .symmetric(horizontal: 11),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: onInfoTap,
                    child: Icon(
                      Icons.info_outline,
                      size: 13,
                      color: ThemingColors.primaryColor,
                    ),
                  ),
                ),
              Padding(
                padding: .symmetric(horizontal: expenses ? 0 : 35),
                child: Text(key.tr()),
              ),
              const Spacer(),
              Padding(
                padding: const .symmetric(horizontal: 15),
                child: Row(
                  children: [
                    Text(
                      value.toStringAsFixed(2),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      " \$",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (divider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.only(top: 0.1),
            color: ThemingColors.white,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusFinanceFilterCubit, StatusFinanceFilterState>(
      builder: (context, financeFilterState) {
        final cubit = context.read<StatusFinanceFilterCubit>();
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
              shape: const RoundedRectangleBorder(side: BorderSide.none),
              controlAffinity: ListTileControlAffinity.leading,
              onExpansionChanged: cubit.updateTileExpansion,
              title: SizedBox(
                height: 53,
                child: Row(
                  children: [
                    Text(
                      "finance".tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
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
                (financeFilterState is StatusFinanceFilterSuccess)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GlassCard(
                          radius: 20,
                          otherRadius: 20,
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.only(bottom: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _section("expenses", Colors.redAccent),
                              _valueRow(
                                "sideExpenses",
                                financeFilterState.financeRecord.sideExpenses,
                                expenses: true,
                                onInfoTap: () => _showExpensesInfoDialog(
                                  context,
                                  financeFilterState.financeRecord.expenses,
                                ),
                              ),
                              _valueRow(
                                "payroll",
                                financeFilterState.financeRecord.payrollExpenses,
                              ),
                              _valueRow(
                                "total",
                                financeFilterState.financeRecord.totalExpenses,
                                divider: false,
                              ),
                              _section("income", Colors.green),
                              _valueRow(
                                "profit",
                                financeFilterState.financeRecord.profit,
                              ),
                              _valueRow(
                                "netProfit",
                                financeFilterState.financeRecord.netProfit,
                                divider: false,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: SizedBox(
                          width: double.infinity,
                          child: GlassCard(
                            margin: EdgeInsets.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            radius: 20,
                            otherRadius: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    "noRecordsForThisDate".tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          (context.isDark
                                                  ? ThemingColors.white
                                                  : ThemingColors.black)
                                              .withAlpha((0.4 * 255).toInt()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
