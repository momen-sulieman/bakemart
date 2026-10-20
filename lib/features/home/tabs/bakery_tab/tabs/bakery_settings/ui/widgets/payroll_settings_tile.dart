import 'package:bakemart/core/shared/models/payroll_model.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_cubit/settings_cubit.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';

class PayrollSettingsTile extends StatelessWidget {
  const PayrollSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController rateController = TextEditingController();
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();

        final PayrollModel? currentOldPayroll = cubit.payroll;
        final PayrollModel? currentEditablePayroll = cubit.editablePayroll;
        if (currentOldPayroll == null || currentEditablePayroll == null) {
          return const SizedBox.shrink();
        }
        final PayrollModel oldPayroll = currentOldPayroll;
        final PayrollModel payroll = currentEditablePayroll;

        final List<MapEntry<String, double?>> allRoles = [
          MapEntry(PayrollsTableColumns.supervisor, payroll.supervisor),
          MapEntry(PayrollsTableColumns.chef, payroll.chef),
          MapEntry(PayrollsTableColumns.coChef, payroll.coChef),
          MapEntry(PayrollsTableColumns.ajan, payroll.ajan),
          MapEntry(PayrollsTableColumns.faran, payroll.faran),
          MapEntry(PayrollsTableColumns.tawlaji, payroll.tawlaji),
          MapEntry(PayrollsTableColumns.bagger, payroll.bagger),
        ];

        final Map<String, double?> oldRolesByKey = {
          PayrollsTableColumns.supervisor: oldPayroll.supervisor,
          PayrollsTableColumns.chef: oldPayroll.chef,
          PayrollsTableColumns.coChef: oldPayroll.coChef,
          PayrollsTableColumns.ajan: oldPayroll.ajan,
          PayrollsTableColumns.faran: oldPayroll.faran,
          PayrollsTableColumns.tawlaji: oldPayroll.tawlaji,
          PayrollsTableColumns.bagger: oldPayroll.bagger,
        };
        final payrollMethod = payroll.payrollMethod;
        final List<MapEntry<String, double?>> visibleRoles =
        cubit.isPayrollEditing
            ? allRoles
            : allRoles.where((e) => e.value != null && e.value! > 0).toList();

        final List<TableRow> payrollRoleRows = visibleRoles.map((entry) {
          final String roleName = entry.key;
          final double? value = entry.value;
          final double? oldValue = oldRolesByKey[roleName];
          bool changed = value != oldValue;
          return TableRow(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        roleName.tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: cubit.isPayrollEditing
                              ? context.isDark
                              ? ThemingColors.white.withAlpha(
                            ((changed ? 1 : 0.5) * 255).toInt(),
                          )
                              : ThemingColors.black.withAlpha(
                            ((changed ? 1 : 0.5) * 255).toInt(),
                          )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: TextCell(
                      string: InkWell(
                        onTap: () {
                          if (cubit.isPayrollEditing) {
                            final oldRate = double.parse(
                              (value ?? 0.0).toStringAsFixed(2),
                            );
                            rateController.text = oldRate.toStringAsFixed(2);
                            showDialog(
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (dialogContext) {
                                return BlocProvider.value(
                                  value: cubit,
                                  child: BlocBuilder<SettingsCubit, SettingsState>(
                                    builder: (context, state) {
                                      return BackdropFilter(
                                        filter: .blur(sigmaX: 2, sigmaY: 2),
                                        child: AlertDialog(
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
                                              ? ThemingColors.black.withAlpha(
                                            (0.8 * 255).toInt(),
                                          )
                                              : ThemingColors.white.withAlpha(
                                            (0.8 * 255).toInt(),
                                          ),
                                          title: Text(
                                            roleName.tr(),
                                            textAlign: .center,
                                            style: TextStyle(
                                              fontWeight: .bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          content: Row(
                                            mainAxisSize: .min,
                                            mainAxisAlignment: .center,
                                            children: [
                                              SizedBox(
                                                width: 100,
                                                child: TextFormField(
                                                  controller: rateController,
                                                  keyboardType:
                                                  TextInputType.number,
                                                  textAlign: .center,
                                                  onTap: () {
                                                    rateController.text = "";
                                                  },
                                                  onChanged: (text) {
                                                    final number =
                                                    double.tryParse(
                                                      text.toEnglishDigits(),
                                                    );
                                                    if (number != oldRate &&
                                                        text.isNotEmpty &&
                                                        roleName ==
                                                            PayrollsTableColumns
                                                                .supervisor &&
                                                        number != null &&
                                                        number > 0) {
                                                      cubit.payrollRateChanged(
                                                        true,
                                                      );
                                                    } else if (number !=
                                                        oldRate &&
                                                        text.isNotEmpty &&
                                                        roleName !=
                                                            PayrollsTableColumns
                                                                .supervisor) {
                                                      cubit.payrollRateChanged(
                                                        true,
                                                      );
                                                    } else {
                                                      cubit.payrollRateChanged(
                                                        false,
                                                      );
                                                    }
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    focusedBorder:
                                                    InputBorder.none,
                                                    enabledBorder:
                                                    InputBorder.none,
                                                    errorBorder:
                                                    InputBorder.none,
                                                    disabledBorder:
                                                    InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                cubit.isPayrollRateChanged
                                                    ? InkWell(
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
                                                    margin: .symmetric(
                                                      horizontal: 6,
                                                    ),
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
                                                )
                                                    : Expanded(
                                                  child: InkWell(
                                                    hoverColor: Colors
                                                        .transparent,
                                                    splashColor: Colors
                                                        .transparent,
                                                    highlightColor: Colors
                                                        .transparent,
                                                    onTap: () {
                                                      Navigator.pop(
                                                        dialogContext,
                                                      );
                                                    },
                                                    child: GlassCard(
                                                      margin: .symmetric(
                                                        horizontal: 6,
                                                      ),
                                                      padding: .symmetric(
                                                        vertical: 2,
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
                                                if (cubit.isPayrollRateChanged)
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        final double newRate =
                                                            double.tryParse(
                                                              rateController
                                                                  .text
                                                                  .toEnglishDigits(),
                                                            ) ??
                                                                0;
                                                        cubit.postNewRate(
                                                          role: roleName,
                                                          newRate: newRate,
                                                          branchId:
                                                          payroll.branchId,
                                                        );
                                                        Navigator.pop(
                                                          dialogContext,
                                                        );
                                                      },
                                                      hoverColor:
                                                      Colors.transparent,
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      child: GlassCard(
                                                        margin: .symmetric(
                                                          horizontal: 6,
                                                        ),
                                                        padding: .symmetric(
                                                          vertical: 2,
                                                        ),
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
                            );
                          }
                        },
                        child: Text(
                          (value ?? 0.0).toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 12,
                            color: cubit.isPayrollEditing
                                ? ThemingColors.primaryColor.withAlpha(
                              ((changed ? 1 : 0.5) * 255).toInt(),
                            )
                                : null,
                            decoration: cubit.isPayrollEditing
                                ? TextDecoration.underline
                                : null,
                            decorationColor: ThemingColors.primaryColor
                                .withAlpha(((changed ? 1 : 0.5) * 255).toInt()),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList();
        return ExpansionTile(
          splashColor: Colors.transparent,
          initiallyExpanded: true,
          iconColor: ThemingColors.primaryColor,
          collapsedIconColor: ThemingColors.primaryColor,
          shape: RoundedRectangleBorder(side: .none),
          controlAffinity: ListTileControlAffinity.leading,
          onExpansionChanged: (expanded) {
            cubit.updatePayrollTileExpansion(expanded);
          },
          title: SizedBox(
            height: 53,
            child: Row(
              mainAxisAlignment: .start,
              children: [
                Text(
                  "payroll".tr(),
                  style: TextStyle(fontWeight: .bold, fontSize: 18),
                ),
                Spacer(),
                cubit.isPayrollEditing
                    ? Container(
                  margin: .only(right: 10),
                  padding: .symmetric(
                    horizontal: cubit.isPayrollChanged ? 15 : 5,
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
                          cubit.payrollCancelEditing();
                        },
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                      ),
                      if (cubit.isPayrollChanged)
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
                      if (cubit.isPayrollChanged)
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
                                        .updatePayroll(
                                      cubit
                                          .editablePayroll!,
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
                    : cubit.isPayrollExpanded
                    ? Padding(
                  padding: .only(right: 10),
                  child: InkWell(
                    onTap: () {
                      cubit.payrollEditingMode(!cubit.isPayrollEditing);
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
              selectedBranchId: cubit.payrollsViewedBranch,
              onBranchChanged: cubit.payrollsBranchChanged,
              child: Padding(
                padding: .symmetric(horizontal: 25),
                child: Column(
                  children: [
                    GlassCard(
                      margin: .zero,
                      padding: context.locale.languageCode == 'ar'
                          ? .only(top: 10, bottom: 10, right: 15, left: 5)
                          : .only(top: 10, bottom: 10, left: 15, right: 5),
                      otherRadius: 30,
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Text(
                            "payrollMethod".tr(),
                            style: TextStyle(
                              fontSize: 12,
                              color: cubit.isPayrollEditing
                                  ? context.isDark
                                  ? ThemingColors.white.withAlpha(
                                (((cubit.payroll!.payrollMethod !=
                                    cubit
                                        .editablePayroll!
                                        .payrollMethod)
                                    ? 1
                                    : 0.5) *
                                    255)
                                    .toInt(),
                              )
                                  : ThemingColors.black.withAlpha(
                                (((cubit.payroll!.payrollMethod !=
                                    cubit
                                        .editablePayroll!
                                        .payrollMethod)
                                    ? 1
                                    : 0.5) *
                                    255)
                                    .toInt(),
                              )
                                  : null,
                            ),
                          ),
                          InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              if (cubit.isPayrollEditing) {
                                final List<String> methods = [
                                  "dailyPayment".tr(),
                                  "batchPayment".tr(),
                                ];
                                final oldMethodIndex = payrollMethod ? 0 : 1;
                                bool updatedMethod = payrollMethod;
                                cubit.payrollRateChanged(false);
                                showDialog(
                                  barrierColor: Colors.transparent,
                                  context: context,
                                  builder: (dialogContext) {
                                    return BlocProvider.value(
                                      value: cubit,
                                      child: BlocBuilder<SettingsCubit, SettingsState>(
                                        builder: (context, state) {
                                          return BackdropFilter(
                                            filter: .blur(sigmaX: 2, sigmaY: 2),
                                            child: AlertDialog(
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
                                                  ? ThemingColors.black.withAlpha(
                                                (0.8 * 255).toInt(),
                                              )
                                                  : ThemingColors.white.withAlpha(
                                                (0.8 * 255).toInt(),
                                              ),
                                              title: Text(
                                                "payrollMethod".tr(),
                                                textAlign: .center,
                                                style: TextStyle(
                                                  fontWeight: .bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              titlePadding: .only(top: 25),
                                              contentPadding: .symmetric(
                                                vertical: 20,
                                              ),
                                              content: SizedBox(
                                                width: 100,
                                                height: 100,
                                                child: Row(
                                                  mainAxisAlignment: .center,
                                                  children: [
                                                    Icon(
                                                      Icons.arrow_right,
                                                      size: 22,
                                                      color: ThemingColors
                                                          .primaryColor,
                                                    ),
                                                    SizedBox(
                                                      width: 100,
                                                      child: WheelPicker(
                                                        controller:
                                                        WheelPickerController(
                                                          itemCount:
                                                          methods.length,
                                                          initialIndex:
                                                          oldMethodIndex,
                                                        ),
                                                        looping: false,
                                                        style: WheelPickerStyle(
                                                          itemExtent: 30,
                                                          surroundingOpacity: 0.4,
                                                          diameterRatio: 10,
                                                          magnification: 1,
                                                        ),
                                                        onIndexChanged: (index, _) {
                                                          if (index !=
                                                              oldMethodIndex) {
                                                            updatedMethod =
                                                            index == 0
                                                                ? true
                                                                : false;
                                                            cubit
                                                                .payrollRateChanged(
                                                              true,
                                                            );
                                                          } else {
                                                            updatedMethod =
                                                            index == 0
                                                                ? true
                                                                : false;
                                                            cubit
                                                                .payrollRateChanged(
                                                              false,
                                                            );
                                                          }
                                                        },
                                                        builder:
                                                            (context, index) {
                                                          return Center(
                                                            child: Text(
                                                              methods[index],
                                                              maxLines: 1,
                                                              overflow:
                                                                  .ellipsis,
                                                              style:
                                                              TextStyle(
                                                                fontSize:
                                                                12,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons.arrow_left,
                                                      size: 22,
                                                      color: ThemingColors
                                                          .primaryColor,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    cubit.isPayrollRateChanged
                                                        ? InkWell(
                                                      hoverColor: Colors
                                                          .transparent,
                                                      splashColor: Colors
                                                          .transparent,
                                                      highlightColor: Colors
                                                          .transparent,
                                                      onTap: () {
                                                        Navigator.pop(
                                                          dialogContext,
                                                        );
                                                      },
                                                      child: GlassCard(
                                                        margin: .symmetric(
                                                          horizontal: 6,
                                                        ),
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
                                                    )
                                                        : Expanded(
                                                      child: InkWell(
                                                        hoverColor: Colors
                                                            .transparent,
                                                        splashColor: Colors
                                                            .transparent,
                                                        highlightColor:
                                                        Colors
                                                            .transparent,
                                                        onTap: () {
                                                          Navigator.pop(
                                                            dialogContext,
                                                          );
                                                        },
                                                        child: GlassCard(
                                                          margin:
                                                              .symmetric(
                                                            horizontal:
                                                            6,
                                                          ),
                                                          padding:
                                                              .symmetric(
                                                            vertical: 2,
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .arrow_back,
                                                            size: 18,
                                                            color: ThemingColors
                                                                .primaryColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (cubit
                                                        .isPayrollRateChanged)
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            cubit
                                                                .updatePayrollMethod(
                                                              payroll.copyWith(
                                                                payrollMethod:
                                                                updatedMethod,
                                                              ),
                                                            );
                                                            Navigator.pop(
                                                              dialogContext,
                                                            );
                                                          },
                                                          hoverColor:
                                                          Colors.transparent,
                                                          splashColor:
                                                          Colors.transparent,
                                                          highlightColor:
                                                          Colors.transparent,
                                                          child: GlassCard(
                                                            margin: .symmetric(
                                                              horizontal: 6,
                                                            ),
                                                            padding: .symmetric(
                                                              vertical: 2,
                                                            ),
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
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_right,
                                  size: 22,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    ((cubit.isPayrollEditing
                                        ? (cubit.payroll!.payrollMethod ==
                                        cubit
                                            .editablePayroll!
                                            .payrollMethod)
                                        ? 0.5
                                        : 1
                                        : 0) *
                                        255)
                                        .toInt(),
                                  ),
                                ),
                                Text(
                                  payrollMethod
                                      ? "dailyPayment".tr()
                                      : "batchPayment".tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: cubit.isPayrollEditing
                                        ? (cubit.payroll!.payrollMethod ==
                                        cubit
                                            .editablePayroll!
                                            .payrollMethod)
                                        ? ThemingColors.primaryColor
                                        .withAlpha(
                                      ((context.isDark
                                          ? 0.5
                                          : 0.7) *
                                          255)
                                          .toInt(),
                                    )
                                        : ThemingColors.primaryColor
                                        : null,
                                    decoration: .underline,
                                    decorationColor: cubit.isPayrollEditing
                                        ? (cubit.payroll!.payrollMethod ==
                                        cubit
                                            .editablePayroll!
                                            .payrollMethod)
                                        ? ThemingColors.primaryColor
                                        .withAlpha(
                                      ((context.isDark
                                          ? 0.5
                                          : 0.7) *
                                          255)
                                          .toInt(),
                                    )
                                        : ThemingColors.primaryColor
                                        : null,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_left,
                                  size: 22,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    ((cubit.isPayrollEditing
                                        ? (cubit.payroll!.payrollMethod ==
                                        cubit
                                            .editablePayroll!
                                            .payrollMethod)
                                        ? 0.5
                                        : 1
                                        : 0) *
                                        255)
                                        .toInt(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7),
                    GlassCard(
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
                          1: FlexColumnWidth(2.5),
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
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: .center,
                                children: [
                                  Padding(
                                    padding: .symmetric(vertical: 7),
                                    child: TextCell(
                                      string: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: payrollMethod
                                                  ? "ratePerDay".tr()
                                                  : "ratePerBatch".tr(),
                                            ),
                                            if (payrollMethod)
                                              TextSpan(
                                                text: "24hours".tr(),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
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
                          ...payrollRoleRows,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}