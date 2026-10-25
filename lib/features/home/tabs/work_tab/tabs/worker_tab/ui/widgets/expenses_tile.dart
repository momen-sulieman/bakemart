import 'package:bakemart/core/shared/models/expenses_model.dart';
import 'package:bakemart/core/shared/widgets/dialogs/value_changing_dialog.dart';
import 'package:bakemart/core/shared/widgets/table_cells/product_cell.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/models/finance_model.dart';
import '../../../../../../../../core/shared/models/waste_model.dart';
import '../../../../../../../../core/shared/models/product_model.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/shared/widgets/text_form_field/text_form_field.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/expenses_cubit/expenses_cubit.dart';
import '../../logic/expenses_filter_cubit/expenses_filter_cubit.dart';
import '../../logic/worker_cubit/worker_cubit.dart';

class ExpensesTile extends StatelessWidget {
  final WorkerState workerState;

  const ExpensesTile({required this.workerState, super.key});

  List<ProductModel> getTheRestOfTheProducts({
    required FinanceModel expensesRecord,
    required List<ProductModel> allProducts,
  }) {
    final Set<String> mealProductIds = expensesRecord.wastes
        .map((meal) => meal.productId)
        .toSet();

    return allProducts
        .where((product) => !mealProductIds.contains(product.productId))
        .toList();
  }

  DateTime safeDate(int year, int month, int day) {
    final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final int clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
    return DateTime(year, month, clampedDay);
  }

  bool _anyAddFieldValid(
      TextEditingController meal,
      TextEditingController notSold,
      TextEditingController manuf,
      ) {
    return (int.tryParse(meal.text.toEnglishDigits()) ?? 0) > 0 ||
        (int.tryParse(notSold.text.toEnglishDigits()) ?? 0) > 0 ||
        (int.tryParse(manuf.text.toEnglishDigits()) ?? 0) > 0;
  }

  List<ExpensesModel> _collectExpenses(
      List<TextEditingController> itemControllers,
      List<TextEditingController> valueControllers,
      ) {
    final List<ExpensesModel> result = [];
    for (int i = 0; i < itemControllers.length; i++) {
      final String item = itemControllers[i].text.trim();
      final double? value = double.tryParse(
        valueControllers[i].text.trim().toEnglishDigits(),
      );
      if (item.isEmpty || value == null) continue;
      result.add(ExpensesModel(item: item, value: value));
    }
    return result;
  }
  bool _syncRows({
    required List<TextEditingController> itemControllers,
    required List<TextEditingController> valueControllers,
  }) {
    bool isEmptyRow(int i) =>
        itemControllers[i].text.trim().isEmpty &&
            valueControllers[i].text.trim().isEmpty;

    bool changed = false;
    final List<TextEditingController> removed = [];

    for (int i = itemControllers.length - 2; i >= 0; i--) {
      if (isEmptyRow(i)) {
        removed.add(itemControllers.removeAt(i));
        removed.add(valueControllers.removeAt(i));
        changed = true;
      }
    }

    bool hasPartial = false;
    for (int i = 0; i < itemControllers.length; i++) {
      if (itemControllers[i].text.trim().isEmpty !=
          valueControllers[i].text.trim().isEmpty) {
        hasPartial = true;
        break;
      }
    }

    final bool lastEmpty =
        itemControllers.isNotEmpty && isEmptyRow(itemControllers.length - 1);

    if (hasPartial && lastEmpty) {
      removed.add(itemControllers.removeLast());
      removed.add(valueControllers.removeLast());
      changed = true;
    } else if (!hasPartial && !lastEmpty) {
      itemControllers.add(TextEditingController());
      valueControllers.add(TextEditingController());
      changed = true;
    }

    if (removed.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final controller in removed) {
          controller.dispose();
        }
      });
    }
    return changed;
  }
  List<String> _snapshot(
      List<TextEditingController> itemControllers,
      List<TextEditingController> valueControllers,
      ) {
    final List<String> result = [];
    for (int i = 0; i < itemControllers.length; i++) {
      final String item = itemControllers[i].text.trim();
      final String value = valueControllers[i].text.trim();
      if (item.isEmpty && value.isEmpty) continue;
      result.add('$item|$value');
    }
    return result;
  }

  void _handleChange({
    required ExpensesFilterCubit cubit,
    required List<TextEditingController> itemControllers,
    required List<TextEditingController> valueControllers,
    required List<String> initialSnapshot,
  }) {
    final bool rowsChanged = _syncRows(
      itemControllers: itemControllers,
      valueControllers: valueControllers,
    );
    final bool differs = !const ListEquality<String>().equals(
      _snapshot(itemControllers, valueControllers),
      initialSnapshot,
    );
    if (rowsChanged) {
      cubit.setExpensesRowCount(itemControllers.length);
    }
    if (cubit.expenseUpdated != differs) {
      cubit.setExpensesUpdated(differs);
    }
  }

  void _showExpensesDialog(BuildContext context, ExpensesFilterCubit cubit) {
    cubit.resetExpensesDraft();
    final List<TextEditingController> itemControllers = [];
    final List<TextEditingController> valueControllers = [];
    for (final expense in cubit.editableExpenses) {
      itemControllers.add(TextEditingController(text: expense.item));
      valueControllers.add(
        TextEditingController(
          text: expense.value == expense.value.truncateToDouble()
              ? expense.value.toInt().toString()
              : expense.value.toString(),
        ),
      );
    }
    final List<String> initialSnapshot = _snapshot(
      itemControllers,
      valueControllers,
    );
    showDialog(
      barrierColor: Colors.transparent,
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: cubit,
          child: BlocBuilder<ExpensesFilterCubit, ExpensesFilterState>(
            builder: (context, _) {
              final int rows = cubit.expensesCounter + 1;
              while (itemControllers.length < rows) {
                itemControllers.add(TextEditingController());
                valueControllers.add(TextEditingController());
              }
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
                      width: 1,
                      color: context.isDark
                          ? ThemingColors.white.withAlpha((0.2*255).toInt())
                          : ThemingColors.black.withAlpha((0.2*255).toInt()),
                    ),
                  ),
                  backgroundColor: context.isDark
                      ? ThemingColors.black.withAlpha((0.2 * 255).toInt())
                      : ThemingColors.black.withAlpha((0.1 * 255).toInt()),
                  title: Container(
                    margin: .only(top: 15, right: 25, left: 25),
                    padding: .symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: context.isDark
                          ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                          : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
                      border: .all(
                        width: 1,
                        color: context.isDark
                            ? ThemingColors.white.withAlpha((0.2*255).toInt())
                            : ThemingColors.black.withAlpha((0.2*255).toInt()),
                      ),
                    ),
                    child: Text("sideExpenses".tr(), textAlign: .center),
                  ),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Container(
                      padding: .symmetric(horizontal: 10,vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: context.isDark
                            ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
                            : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
                        border: .all(
                          width: 1,
                          color: context.isDark
                              ? ThemingColors.white.withAlpha((0.2*255).toInt())
                              : ThemingColors.black.withAlpha((0.2*255).toInt()),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: .min,
                            children: List.generate(rows, (index) {
                              return Padding(
                                key: ObjectKey(itemControllers[index]),
                                padding: .symmetric(vertical: 5),
                                child: SizedBox(
                                  height: 35,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextFormField(
                                          "item".tr(),
                                          isDense: true,
                                          contentPadding: .all(10),
                                          controller: itemControllers[index],
                                          keyBoardType: TextInputType.text,
                                          labelSize: 12,
                                          onChanged: (text) {
                                            _handleChange(
                                              cubit: cubit,
                                              itemControllers: itemControllers,
                                              valueControllers: valueControllers,
                                              initialSnapshot: initialSnapshot,
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        width: 90,
                                        child: CustomTextFormField(
                                          "value".tr(),
                                          isDense: true,
                                          contentPadding: .all(10),
                                          controller: valueControllers[index],
                                          keyBoardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                          labelSize: 12,
                                          onChanged: (text) {
                                            _handleChange(
                                              cubit: cubit,
                                              itemControllers: itemControllers,
                                              valueControllers: valueControllers,
                                              initialSnapshot: initialSnapshot,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Row(
                      children: [
                        cubit.expenseUpdated
                            ? InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: (){
                            cubit.resetExpensesDraft();
                            Navigator.pop(dialogContext);
                          },
                          child: GlassCard(
                            margin: .symmetric(horizontal: 6),
                            padding: .symmetric(vertical: 2, horizontal: 10),
                            child: Icon(
                              Icons.arrow_back,
                              size: 18,
                              color: ThemingColors.primaryColor,
                            ),
                          ),
                        )
                            : Expanded(
                          child: InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              cubit.resetExpensesDraft();
                              Navigator.pop(dialogContext);
                            },
                            child: GlassCard(
                              margin: .symmetric(horizontal: 6),
                              padding: .symmetric(vertical: 2),
                              child: Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: ThemingColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        if (cubit.expenseUpdated)
                          Expanded(
                            child: InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                cubit.applyExpensesDraft(
                                  _collectExpenses(
                                    itemControllers,
                                    valueControllers,
                                  ),
                                );
                                Navigator.pop(dialogContext);
                              },
                              child: GlassCard(
                                margin: .symmetric(horizontal: 6),
                                padding: .symmetric(vertical: 2),
                                child: Icon(
                                  Icons.done,
                                  size: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      Future.delayed(Duration(milliseconds: 500), () {
        for (final controller in itemControllers) {
          controller.dispose();
        }
        for (final controller in valueControllers) {
          controller.dispose();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExpensesFilterCubit>();
    final expensesCubit = context.read<ExpensesCubit>();
    final workerCubit = context.read<WorkerCubit>();
    final date = DateTime.now();
    final List<DateTime> last5Days = List.generate(
      5,
          (index) => DateTime(date.year, date.month, date.day - (4 - index)),
    );
    final days = last5Days.map((d) => d.day).toList();
    final List<int> months = last5Days.map((d) => d.month).toSet().toList();
    final int currentMonthIndex = months.length - 1;
    final year = date.year;
    final TextEditingController inputController = TextEditingController();
    ProductModel? productToBeAdded;
    return BlocBuilder<ExpensesFilterCubit, ExpensesFilterState>(
      builder: (context, expensesFilterstate) {
        if (expensesFilterstate is ExpensesFilterLoading) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: ThemingColors.primaryColor,
              size: 25,
            ),
          );
        }
        if (expensesFilterstate is! ExpensesFilterSuccess) {
          return Center(child: Text("Error"));
        }
        final dayIndex = days.indexOf(cubit.selectedDay);
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
              context.read<ExpensesFilterCubit>().updateTileExpansion(expanded);
            },
            title: SizedBox(
              height: 55,
              child: Row(
                mainAxisAlignment: .start,
                children: [
                  Text(
                    "wastage".tr(),
                    style: TextStyle(fontWeight: .bold, fontSize: 18),
                  ),
                  Spacer(),
                  cubit.editMode && cubit.isExpanded
                      ? SizedBox()
                      : cubit.isExpanded
                      ? Padding(
                    padding: .only(right: 5),
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        SizedBox(
                          width: 35,
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
                                    cubit.filterByDay(days[index]);
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
                          width: 30,
                          child: Column(
                            children: [
                              Icon(
                                Icons.arrow_drop_up,
                                size: 20,
                                color: ThemingColors.primaryColor.withAlpha(
                                  ((months.length == 1 ? 0 : 0.6) * 255)
                                      .toInt(),
                                ),
                              ),
                              Expanded(
                                child: WheelPicker(
                                  looping: false,
                                  itemCount: months.length,
                                  initialIndex:
                                  months.contains(cubit.selectedMonth)
                                      ? months.indexOf(cubit.selectedMonth)
                                      : currentMonthIndex,
                                  style: WheelPickerStyle(
                                    itemExtent: 22,
                                    surroundingOpacity: 0.25,
                                    squeeze: 0.9,
                                    diameterRatio: 3,
                                  ),
                                  onIndexChanged: (index, _) {
                                    cubit.filterByMonth(months[index]);
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
                                  ((months.length == 1 ? 0 : 0.6) * 255)
                                      .toInt(),
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
                          child: Text(
                            "$year",
                            textAlign: .center,
                            style: TextStyle(
                              fontSize: 16,
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
                  )
                      : SizedBox(),
                  cubit.editMode
                      ? Container(
                    margin: .symmetric(horizontal: 10),
                    padding: .symmetric(
                      horizontal: cubit.updated ? 15 : 5,
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
                            cubit.cancelChanges();
                          },
                          child: Icon(
                            cubit.mealDeleted ? Icons.done : Icons.close,
                            size: 18,
                            color: cubit.mealDeleted
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                        if (cubit.updated)
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
                        if (cubit.updated)
                          InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await expensesCubit.save(
                                financeRecord:
                                cubit.editableCurrentFilteredExpenses,
                                baselineRecord:
                                cubit.currentFilteredExpenses,
                                bakeryId: workerCubit.bakery!.bakeryId,
                                branchId: workerCubit.bakery!.branchId,
                              );
                              cubit.filter();
                              cubit.changeEditMode();
                            },
                            child: BlocBuilder<ExpensesCubit, ExpensesState>(
                              builder: (context, expensesState) {
                                final bool isSaving =
                                    expensesState is ExpensesLoading &&
                                        expensesState.action ==
                                            ExpensesAction.save;
                                return SizedBox(
                                  width: 18,
                                  child: isSaving
                                      ? LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.green,
                                    size: 13,
                                  )
                                      : Icon(
                                    Icons.done,
                                    size: 18,
                                    color: Colors.green,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  )
                      : cubit.isExpanded
                      ? IconButton(
                    onPressed: () {
                      context.read<ExpensesFilterCubit>().changeEditMode();
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 23,
                      color: ThemingColors.primaryColor,
                    ),
                  )
                      : SizedBox(),
                ],
              ),
            ),
            shape: RoundedRectangleBorder(side: .none),
            controlAffinity: ListTileControlAffinity.leading,
            children: [
              GlassCard(
                margin: .symmetric(horizontal: 25),
                padding: .symmetric(vertical: 5, horizontal: 20),
                otherRadius: 30,
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Text("sideExpenses".tr(), style: TextStyle(fontSize: 12)),
                    Row(
                      mainAxisAlignment: .center,
                      children: [
                        Padding(
                          padding: .symmetric(vertical: 7),
                          child: TextCell(
                            string: InkWell(
                              onTap: () {
                                if (cubit.editMode) {
                                  _showExpensesDialog(context, cubit);
                                }
                              },
                              child: Directionality(
                                textDirection: .ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      "view".tr(),
                                      style: TextStyle(
                                        color:
                                        (cubit.isExpanded && cubit.editMode)
                                            ? ThemingColors.primaryColor
                                            : ThemingColors.primaryColor
                                            .withAlpha((0.5 * 255).toInt()),
                                        decoration: cubit.editMode
                                            ? TextDecoration.underline
                                            : null,
                                        decorationColor:
                                        ThemingColors.primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 7),
              GlassCard(
                margin: .symmetric(horizontal: 25),
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
                        1: FlexColumnWidth(0.9),
                        2: FlexColumnWidth(1.1),
                        3: FlexColumnWidth(0.9),
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
                                      "manufWaste".tr(),
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
                        if (cubit.editableCurrentFilteredExpenses.wastes.isEmpty)
                          TableRow(
                            children: [
                              TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Align(
                                  alignment: context.locale.languageCode == "ar"
                                      ? .centerRight
                                      : .centerLeft,
                                  child: Padding(
                                    padding: .all(10),
                                    child: Column(
                                      crossAxisAlignment: .center,
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
                              ),
                              TableCell(
                                verticalAlignment:
                                TableCellVerticalAlignment.middle,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
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
                                  padding: EdgeInsets.symmetric(vertical: 5),
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
                                  padding: EdgeInsets.symmetric(vertical: 5),
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
                          ...cubit.editableCurrentFilteredExpenses.wastes.asMap().entries.map((
                              entry,
                              ) {
                            final int index = entry.key;
                            final WasteModel waste = entry.value;
                            final List<WasteModel> oldMeals =
                                cubit.currentFilteredExpenses.wastes;
                            final WasteModel? oldMeal = oldMeals.firstWhereOrNull(
                                  (m) => m.productId == waste.productId,
                            );
                            final bool changed =
                                oldMeal == null || waste != oldMeal;
                            return TableRow(
                              children: [
                                Padding(
                                  padding: .symmetric(vertical: 12),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: .only(right: 5),
                                        child: SizedBox(
                                          width: 25,
                                          child: cubit.editMode
                                              ? InkWell(
                                            hoverColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            highlightColor:
                                            Colors.transparent,
                                            onTap: () async {
                                              await expensesCubit
                                                  .deleteMealFromDatabase(
                                                financeRecord: cubit
                                                    .editableCurrentFilteredExpenses,
                                                bakeryId: workerCubit
                                                    .bakery!
                                                    .bakeryId,
                                                branchId: workerCubit
                                                    .bakery!
                                                    .branchId,
                                                product: waste,
                                              );
                                              cubit.setMealDeleted(true);
                                              cubit.filter();
                                            },
                                            child: BlocBuilder<ExpensesCubit, ExpensesState>(
                                              builder: (context, state) {
                                                final bool isThisDeleting =
                                                    state
                                                    is ExpensesLoading &&
                                                        state.action ==
                                                            ExpensesAction
                                                                .deleteProduct &&
                                                        state.productId ==
                                                            waste.productId;
                                                if (isThisDeleting) {
                                                  return SizedBox(
                                                    child: Center(
                                                      child:
                                                      LoadingAnimationWidget.staggeredDotsWave(
                                                        color: Colors
                                                            .redAccent,
                                                        size: 14,
                                                      ),
                                                    ),
                                                  );
                                                }
                                                return Icon(
                                                  Icons
                                                      .delete_forever_outlined,
                                                  size: 18,
                                                  color: context.isDark
                                                      ? Colors.redAccent
                                                      .withAlpha(
                                                    (0.7 * 255)
                                                        .toInt(),
                                                  )
                                                      : Colors.redAccent
                                                      .withAlpha(
                                                    (0.4 * 255)
                                                        .toInt(),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                              : Text(
                                            "${index + 1}",
                                            textAlign: .center,
                                            style: TextStyle(
                                              fontWeight: .bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ProductCell(
                                          productName: waste.productName,
                                          productId: waste.productId,
                                          opacity: cubit.editMode
                                              ? changed
                                              ? 1
                                              : 0.3
                                              : 1,
                                          textColor: cubit.editMode
                                              ? (context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black)
                                              .withAlpha(
                                            ((changed ? 1 : 0.5) * 255)
                                                .toInt(),
                                          )
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: .center,
                                  children: [
                                    Padding(
                                      padding: .symmetric(vertical: 12),
                                      child: TextCell(
                                        string: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          onTap: () {
                                            if (cubit.editMode) {
                                              final int oldValue = cubit
                                                  .editableCurrentFilteredExpenses
                                                  .wastes[index]
                                                  .manufacturing;
                                              inputController.text = waste
                                                  .manufacturing
                                                  .toString();
                                              showDialog(
                                                barrierColor: Colors.transparent,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<
                                                        ExpensesFilterCubit
                                                    >(),
                                                    child:
                                                    BlocBuilder<
                                                        ExpensesFilterCubit,
                                                        ExpensesFilterState
                                                    >(
                                                      builder: (context, manufDialoge) {
                                                        return ValueChangingDialog(
                                                          valueOfProduct:
                                                          true,
                                                          wasteType: "manuf"
                                                              .tr(),
                                                          inputValidity: cubit
                                                              .inputValidity,
                                                          title: waste
                                                              .productName,
                                                          productId:
                                                          waste.productId,
                                                          oldValue: oldValue,
                                                          inputController:
                                                          inputController,
                                                          onChanged: (text) {
                                                            final number =
                                                            int.tryParse(
                                                              text.toEnglishDigits(),
                                                            );
                                                            if (number !=
                                                                oldValue &&
                                                                text.isNotEmpty) {
                                                              cubit
                                                                  .setInputValidity(
                                                                true,
                                                              );
                                                            } else {
                                                              cubit
                                                                  .setInputValidity(
                                                                false,
                                                              );
                                                            }
                                                          },
                                                          onTapCancel: () {
                                                            cubit
                                                                .setInputValidity(
                                                              false,
                                                            );
                                                            inputController
                                                                .text =
                                                            "";
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                          onTapDone: () {
                                                            cubit.editManufacturingQuantity(
                                                              productId: waste
                                                                  .productId,
                                                              newQuantity:
                                                              int.tryParse(
                                                                inputController
                                                                    .text
                                                                    .toEnglishDigits(),
                                                              ) ??
                                                                  0,
                                                            );
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            width: 30,
                                            height: 20,
                                            child: Text(
                                              "${waste.manufacturing}",
                                              textAlign: .center,
                                              style: TextStyle(
                                                color: cubit.editMode
                                                    ? ThemingColors.primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) *
                                                      255)
                                                      .toInt(),
                                                )
                                                    : null,
                                                decoration: cubit.editMode
                                                    ? TextDecoration.underline
                                                    : null,
                                                decorationColor: ThemingColors
                                                    .primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) * 255)
                                                      .toInt(),
                                                ),
                                              ),
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
                                      padding: .symmetric(vertical: 12),
                                      child: TextCell(
                                        string: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          onTap: () {
                                            if (cubit.editMode) {
                                              final int oldValue = cubit
                                                  .editableCurrentFilteredExpenses
                                                  .wastes[index]
                                                  .notSold;
                                              inputController.text = waste.notSold
                                                  .toString();
                                              showDialog(
                                                barrierColor: Colors.transparent,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<
                                                        ExpensesFilterCubit
                                                    >(),
                                                    child:
                                                    BlocBuilder<
                                                        ExpensesFilterCubit,
                                                        ExpensesFilterState
                                                    >(
                                                      builder: (context, notSoldDialoge) {
                                                        return ValueChangingDialog(
                                                          valueOfProduct:
                                                          true,
                                                          wasteType: "notSold"
                                                              .tr(),
                                                          inputValidity: cubit
                                                              .inputValidity,
                                                          title: waste
                                                              .productName,
                                                          productId:
                                                          waste.productId,
                                                          oldValue: oldValue,
                                                          inputController:
                                                          inputController,
                                                          onChanged: (text) {
                                                            final number =
                                                            int.tryParse(
                                                              text.toEnglishDigits(),
                                                            );
                                                            if (number !=
                                                                oldValue &&
                                                                text.isNotEmpty) {
                                                              cubit
                                                                  .setInputValidity(
                                                                true,
                                                              );
                                                            } else {
                                                              cubit
                                                                  .setInputValidity(
                                                                false,
                                                              );
                                                            }
                                                          },
                                                          onTapCancel: () {
                                                            cubit
                                                                .setInputValidity(
                                                              false,
                                                            );
                                                            inputController
                                                                .text =
                                                            "";
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                          onTapDone: () {
                                                            cubit.editNotSoldQuantity(
                                                              productId: waste
                                                                  .productId,
                                                              newQuantity:
                                                              int.tryParse(
                                                                inputController
                                                                    .text
                                                                    .toEnglishDigits(),
                                                              ) ??
                                                                  0,
                                                            );
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            width: 30,
                                            height: 20,
                                            child: Text(
                                              "${waste.notSold}",
                                              textAlign: .center,
                                              style: TextStyle(
                                                color: cubit.editMode
                                                    ? ThemingColors.primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) *
                                                      255)
                                                      .toInt(),
                                                )
                                                    : null,
                                                decoration: cubit.editMode
                                                    ? TextDecoration.underline
                                                    : null,
                                                decorationColor: ThemingColors
                                                    .primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) * 255)
                                                      .toInt(),
                                                ),
                                              ),
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
                                      padding: .symmetric(vertical: 12),
                                      child: TextCell(
                                        string: InkWell(
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          onTap: () {
                                            if (cubit.editMode) {
                                              final int oldValue = cubit
                                                  .editableCurrentFilteredExpenses
                                                  .wastes[index]
                                                  .meal;
                                              inputController.text = waste.meal
                                                  .toString();
                                              showDialog(
                                                barrierColor: Colors.transparent,
                                                context: context,
                                                builder: (dialogContext) {
                                                  return BlocProvider.value(
                                                    value: context
                                                        .read<
                                                        ExpensesFilterCubit
                                                    >(),
                                                    child:
                                                    BlocBuilder<
                                                        ExpensesFilterCubit,
                                                        ExpensesFilterState
                                                    >(
                                                      builder: (context, mealsDialoge) {
                                                        return ValueChangingDialog(
                                                          valueOfProduct:
                                                          true,
                                                          wasteType: "meals"
                                                              .tr(),
                                                          inputValidity: cubit
                                                              .inputValidity,
                                                          title: waste
                                                              .productName,
                                                          productId:
                                                          waste.productId,
                                                          oldValue: oldValue,
                                                          inputController:
                                                          inputController,
                                                          onChanged: (text) {
                                                            final number =
                                                            int.tryParse(
                                                              text.toEnglishDigits(),
                                                            );
                                                            if (number !=
                                                                oldValue &&
                                                                text.isNotEmpty) {
                                                              cubit
                                                                  .setInputValidity(
                                                                true,
                                                              );
                                                            } else {
                                                              cubit
                                                                  .setInputValidity(
                                                                false,
                                                              );
                                                            }
                                                          },
                                                          onTapCancel: () {
                                                            cubit
                                                                .setInputValidity(
                                                              false,
                                                            );
                                                            inputController
                                                                .text =
                                                            "";
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                          onTapDone: () {
                                                            cubit.editMealQuantity(
                                                              productId: waste
                                                                  .productId,
                                                              newQuantity:
                                                              int.tryParse(
                                                                inputController
                                                                    .text
                                                                    .toEnglishDigits(),
                                                              ) ??
                                                                  0,
                                                            );
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            width: 30,
                                            height: 20,
                                            child: Text(
                                              "${waste.meal}",
                                              textAlign: .center,
                                              style: TextStyle(
                                                color: cubit.editMode
                                                    ? ThemingColors.primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) *
                                                      255)
                                                      .toInt(),
                                                )
                                                    : null,
                                                decoration: cubit.editMode
                                                    ? TextDecoration.underline
                                                    : null,
                                                decorationColor: ThemingColors
                                                    .primaryColor
                                                    .withAlpha(
                                                  ((changed ? 1 : 0.5) * 255)
                                                      .toInt(),
                                                ),
                                              ),
                                            ),
                                          ),
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
                    if (cubit.editMode)
                      Padding(
                        padding: .only(top: 15, bottom: 10),
                        child: TransparentButton(
                          onTap: () {
                            final List<ProductModel> productsToAdd =
                            getTheRestOfTheProducts(
                              expensesRecord:
                              cubit.editableCurrentFilteredExpenses,
                              allProducts: context
                                  .read<WorkerCubit>()
                                  .products!,
                            );
                            if (productsToAdd.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                  duration: Duration(seconds: 2),
                                  content: Center(
                                    child: GlassCard(
                                      margin: .zero,
                                      padding: .symmetric(
                                        vertical: 7,
                                        horizontal: 20,
                                      ),
                                      orange: true,
                                      otherRadius: 30,
                                      child: Text(
                                        'No more products to add',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: .bold,
                                          color: context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                            int indexOfProductToBeAdded = productsToAdd.length > 2
                                ? 1
                                : 0;
                            productToBeAdded =
                            productsToAdd[indexOfProductToBeAdded];
                            final TextEditingController manufController =
                            TextEditingController(text: "0");
                            final TextEditingController notSoldController =
                            TextEditingController(text: "0");
                            final TextEditingController mealController =
                            TextEditingController(text: "0");
                            cubit.setInputValidity(false);
                            showDialog(
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (dialogContext) {
                                return BlocProvider.value(
                                  value: context.read<ExpensesFilterCubit>(),
                                  child:
                                  BlocBuilder<
                                      ExpensesFilterCubit,
                                      ExpensesFilterState
                                  >(
                                    builder: (context, mealsDialoge) {
                                      return ValueChangingDialog(
                                        mealWheelPicker: WheelPicker(
                                          itemCount: productsToAdd.length,
                                          initialIndex:
                                          indexOfProductToBeAdded,
                                          looping: false,
                                          style: WheelPickerStyle(
                                            itemExtent: 30,
                                            surroundingOpacity: 0.4,
                                            squeeze: 0.9,
                                            diameterRatio: 3,
                                          ),
                                          onIndexChanged: (index, _) {
                                            productToBeAdded =
                                            productsToAdd[index];
                                          },
                                          builder: (context, index) {
                                            return ProductCell(
                                              productName:
                                              productsToAdd[index]
                                                  .productName,
                                              productId:
                                              productsToAdd[index]
                                                  .productId ??
                                                  "",
                                            );
                                          },
                                        ),
                                        addingAMeal: true,
                                        valueOfProduct: true,
                                        inputValidity: cubit.inputValidity,
                                        title: "",
                                        oldValue: 0,
                                        manufController: manufController,
                                        notSoldController: notSoldController,
                                        mealController: mealController,
                                        onChanged: (_) {
                                          cubit.setInputValidity(
                                            _anyAddFieldValid(
                                              mealController,
                                              notSoldController,
                                              manufController,
                                            ),
                                          );
                                        },
                                        onTapCancel: () {
                                          cubit.setInputValidity(false);
                                          Navigator.pop(dialogContext);
                                        },
                                        onTapDone: () {
                                          final int mealQuantity =
                                              int.tryParse(
                                                mealController.text
                                                    .toEnglishDigits(),
                                              ) ??
                                                  0;
                                          final int notSoldQuantity =
                                              int.tryParse(
                                                notSoldController.text
                                                    .toEnglishDigits(),
                                              ) ??
                                                  0;
                                          final int manufacturingQuantity =
                                              int.tryParse(
                                                manufController.text
                                                    .toEnglishDigits(),
                                              ) ??
                                                  0;
                                          cubit.addAProduct(
                                            product: productToBeAdded!,
                                            mealQuantity: mealQuantity,
                                            notSoldQuantity: notSoldQuantity,
                                            manufacturingQuantity:
                                            manufacturingQuantity,
                                          );
                                          Navigator.pop(dialogContext);
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
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
            ],
          ),
        );
      },
    );
  }
}