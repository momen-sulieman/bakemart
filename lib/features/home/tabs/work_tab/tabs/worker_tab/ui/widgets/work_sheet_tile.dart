import 'dart:ui' as ui;

import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/models/payroll_model.dart';
import '../../../../../../../../core/shared/models/shift_model.dart';
import '../../../../../../../../core/shared/models/staff_model.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/shared/widgets/table_cells/worker_cell.dart';
import '../../../../../../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/shifts_cubit/shifts_cubit.dart';
import '../../logic/shifts_filter_cubit/shifts_filter_cubit.dart';
import '../../logic/worker_cubit/worker_cubit.dart';

class WorkSheetTile extends StatelessWidget {
  final WorkerState workerState;

  const WorkSheetTile({required this.workerState, super.key});

  List<StaffModel> getTheRestOfStaff({
    required List<ShiftModel> addedStaff,
    required List<StaffModel> allStaff,
  }) {
    final Set<String> addedWorkerIds = addedStaff
        .map((shift) => shift.workerId)
        .toSet();

    return allStaff
        .where((staff) => !addedWorkerIds.contains(staff.workerId))
        .toList();
  }

  DateTime safeDate(int year, int month, int day) {
    final int lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final int clampedDay = day > lastDayOfMonth ? lastDayOfMonth : day;
    return DateTime(year, month, clampedDay);
  }

  List<String> getTheRestOfRoles({
    required List<String> existingRoles,
    required List<String> activeRoles,
  }) {
    return activeRoles.where((role) => !existingRoles.contains(role)).toList();
  }

  List<String> getActiveRoles(PayrollModel payroll) {
    final List<String> allRoles = [
      PayrollsTableColumns.ajan,
      PayrollsTableColumns.faran,
      PayrollsTableColumns.tawlaji,
      PayrollsTableColumns.chef,
      PayrollsTableColumns.coChef,
      PayrollsTableColumns.bagger,
      PayrollsTableColumns.supervisor,
    ];

    final payrollMap = payroll.toJson();

    return allRoles
        .where((role) => payrollMap[role] != null && payrollMap[role] != 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final List<DateTime> last5Days = List.generate(
      5,
      (index) => DateTime(date.year, date.month, date.day - (4 - index)),
    );
    final days = last5Days.map((d) => d.day).toList();
    final List<int> months = last5Days.map((d) => d.month).toSet().toList();
    final int currentMonthIndex = months.length - 1;
    final year = date.year;
    TextEditingController workerNumberOfBatchesController =
        TextEditingController(text: "0");
    final roles = [
      PayrollsTableColumns.ajan,
      PayrollsTableColumns.faran,
      PayrollsTableColumns.tawlaji,
      PayrollsTableColumns.chef,
      PayrollsTableColumns.coChef,
      PayrollsTableColumns.bagger,
      PayrollsTableColumns.supervisor,
    ];
    final rates = ["100", "50", "25"];
    StaffModel workerToAdd = StaffModel(
      workerName: "",
      workerId: "",
      bakeryId: "",
      branchId: "",
    );
    List<StaffModel> workersToAdd = [];
    double wageRate = 0;
    String role = roles[1];
    return BlocBuilder<ShiftsFilterCubit, ShiftsFilterState>(
      builder: (context, shiftsFilterState) {
        final cubit = context.read<ShiftsFilterCubit>();
        final shiftsCubit = context.read<ShiftsCubit>();
        final dailyPayment = cubit.getPayrollMethod();
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
              context.read<ShiftsFilterCubit>().updateTileExpansion(expanded);
            },
            title: SizedBox(
              height: 55,
              child: Row(
                mainAxisAlignment: .start,
                children: [
                  Text(
                    "shifts".tr(),
                    style: TextStyle(fontWeight: .bold, fontSize: 18),
                  ),
                  Spacer(),
                  cubit.editMode && cubit.isExpanded
                      ? SizedBox()
                      : cubit.isExpanded
                      ? Padding(
                          padding: .symmetric(horizontal: 5),
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
                                  (cubit.workerDeleted && !cubit.updated)
                                      ? Icons.done
                                      : Icons.close,
                                  size: 18,
                                  color: (cubit.workerDeleted && !cubit.updated)
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
                                    await shiftsCubit.save(
                                      shiftTable:
                                          cubit.editableCurrentFilteredShifts,
                                      date: cubit.selectedDate,
                                    );
                                    cubit.filter();
                                    cubit.changeEditMode();
                                  },
                                  child: BlocBuilder<ShiftsCubit, ShiftsState>(
                                    builder: (context, shiftsState) {
                                      return SizedBox(
                                        width: 18,
                                        child: (shiftsState is ShiftsInitial)
                                            ? Icon(
                                                Icons.done,
                                                size: 18,
                                                color: Colors.green,
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
                      : cubit.isExpanded
                      ? IconButton(
                          onPressed: () {
                            context.read<ShiftsFilterCubit>().changeEditMode();
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
              Padding(
                padding: .symmetric(horizontal: 25),
                child: (shiftsFilterState is ShiftsFilterSuccess)
                    ? GlassCard(
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
                                              "worker".tr(),
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
                                              dailyPayment
                                                  ? "hours".tr()
                                                  : "batches".tr(),
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
                                              "wage".tr(),
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
                                if (cubit.editableCurrentFilteredShifts.isEmpty)
                                  TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10,
                                          ),
                                          child: Align(
                                            alignment:
                                                context.locale.languageCode ==
                                                    "ar"
                                                ? .centerRight
                                                : .centerLeft,
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
                                    ],
                                  )
                                else
                                  ...cubit.editableCurrentFilteredShifts.asMap().entries.map((
                                    entry,
                                  ) {
                                    final int shiftIndex = entry.key;
                                    final ShiftModel shift = entry.value;
                                    final int totalBatches = shift.numberOfBatches
                                        .fold(0, (sum, element) => sum + element);
                                    final List<ShiftModel> oldShifts =
                                        cubit.currentFilteredShifts;
                                    final ShiftModel? oldShift = oldShifts
                                        .firstWhereOrNull(
                                          (s) => s.workerId == shift.workerId,
                                        );
                                    final bool changed =
                                        oldShift == null || shift != oldShift;
                                    return TableRow(
                                      children: [
                                        Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  context.locale.languageCode ==
                                                      "ar"
                                                  ? .only(left: 10)
                                                  : .only(right: 10),
                                              child: SizedBox(
                                                width: 20,
                                                child:
                                                    context
                                                        .read<ShiftsFilterCubit>()
                                                        .editMode
                                                    ? InkWell(
                                                        hoverColor:
                                                            Colors.transparent,
                                                        splashColor:
                                                            Colors.transparent,
                                                        highlightColor:
                                                            Colors.transparent,
                                                        onTap: () async {
                                                          await shiftsCubit
                                                              .deleteWorker(
                                                                worker: shift,
                                                              );
                                                          cubit.setWorkerDeleted(
                                                            true,
                                                          );
                                                        },
                                                        child: BlocBuilder<ShiftsCubit, ShiftsState>(
                                                          builder: (context, state) {
                                                            final bool
                                                            isThisDeleting =
                                                                state
                                                                    is ShiftsLoading &&
                                                                state.action ==
                                                                    ShiftsAction
                                                                        .deleteWorker &&
                                                                state.targetId ==
                                                                    shift
                                                                        .workerId;
                                                            if (isThisDeleting) {
                                                              return LoadingAnimationWidget.staggeredDotsWave(
                                                                color: Colors
                                                                    .redAccent,
                                                                size: 14,
                                                              );
                                                            }
                                                            return Icon(
                                                              Icons
                                                                  .delete_forever_outlined,
                                                              size: 18,
                                                              color:
                                                                  context.isDark
                                                                  ? Colors
                                                                        .redAccent
                                                                        .withAlpha(
                                                                          (0.7 * 255)
                                                                              .toInt(),
                                                                        )
                                                                  : Colors
                                                                        .redAccent
                                                                        .withAlpha(
                                                                          (0.4 * 255)
                                                                              .toInt(),
                                                                        ),
                                                            );
                                                          },
                                                        ),
                                                      )
                                                    : Text(
                                                        "${shiftIndex + 1}",
                                                        textAlign: .center,
                                                        style: TextStyle(
                                                          fontWeight: .bold,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            Flexible(
                                              fit: .tight,
                                              child: WorkerCell(
                                                workerName: shift.workerName,
                                                workerId: shift.workerId,
                                                opacity: cubit.editMode
                                                    ? changed
                                                          ? 1
                                                          : 0.3
                                                    : 1,
                                                textColor: cubit.editMode
                                                    ? (context.isDark
                                                              ? ThemingColors
                                                                    .white
                                                              : ThemingColors
                                                                    .black)
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
                                        Row(
                                          mainAxisAlignment: .center,
                                          children: [
                                            Padding(
                                              padding: .symmetric(vertical: 15),
                                              child: InkWell(
                                                hoverColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  if (cubit.editMode) {
                                                    List<String> rolesToAdd =
                                                        getTheRestOfRoles(
                                                          existingRoles:
                                                              shift.role,
                                                          activeRoles:
                                                              getActiveRoles(
                                                                cubit
                                                                    .getPayroll(),
                                                              ),
                                                        );
                                                    String newRole =
                                                        rolesToAdd.isEmpty
                                                        ? ''
                                                        : (rolesToAdd.length > 2
                                                              ? rolesToAdd[1]
                                                              : rolesToAdd[0]);
                                                    cubit.setAddingRole(false);
                                                    cubit.setInputValidity(false);
                                                    cubit.setNumberOfBatchUpdated(
                                                      false,
                                                    );
                                                    final List<
                                                      TextEditingController
                                                    >
                                                    controllers = List.generate(
                                                      shift
                                                          .numberOfBatches
                                                          .length,
                                                      (
                                                        i,
                                                      ) => TextEditingController(
                                                        text: shift
                                                            .numberOfBatches[i]
                                                            .toString(),
                                                      ),
                                                    );
                                                    final activeRoles =
                                                        getActiveRoles(
                                                          cubit.getPayroll(),
                                                        );
                                                    int oldRoleIndex = activeRoles
                                                        .indexOf(shift.role[0]);
                                                    String oldRole =
                                                        activeRoles[oldRoleIndex];
                                                    role = oldRole;
                                                    double? oldRate = shift.rate;
                                                    double? xrate = oldRate;
                                                    int oldRateIndex =
                                                        oldRate == 1
                                                        ? 0
                                                        : oldRate == 0.5
                                                        ? 1
                                                        : 2;
                                                    showDialog(
                                                      context: context,
                                                      barrierColor:
                                                          Colors.transparent,
                                                      builder: (dialogContext) {
                                                        TextEditingController
                                                        batchInputController =
                                                            TextEditingController(
                                                              text: '0',
                                                            );
                                                        return BlocProvider.value(
                                                          value: context
                                                              .read<
                                                                ShiftsFilterCubit
                                                              >(),
                                                          child:
                                                              BlocBuilder<
                                                                ShiftsFilterCubit,
                                                                ShiftsFilterState
                                                              >(
                                                                builder:
                                                                    (
                                                                      context,
                                                                      batchesDialogState,
                                                                    ) {
                                                                      return BackdropFilter(
                                                                        filter: .blur(
                                                                          sigmaX:
                                                                              context.isDark
                                                                              ? 5
                                                                              : 7,
                                                                          sigmaY:
                                                                              context.isDark
                                                                              ? 5
                                                                              : 7,
                                                                        ),
                                                                        child: AlertDialog(
                                                                          contentPadding:
                                                                              .zero,
                                                                          actionsPadding: .only(
                                                                            right:
                                                                                10,
                                                                            left:
                                                                                10,
                                                                            bottom:
                                                                                20,
                                                                          ),
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: .circular(
                                                                              20,
                                                                            ),
                                                                            side: BorderSide(
                                                                              width:
                                                                                  context.isDark
                                                                                  ? 0.2
                                                                                  : 0.3,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          backgroundColor:
                                                                              context.isDark
                                                                              ? ThemingColors.black.withAlpha(
                                                                                  (0.4 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                )
                                                                              : ThemingColors.black.withAlpha(
                                                                                  (0.1 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                ),
                                                                          titlePadding:
                                                                              .zero,
                                                                          title: Container(
                                                                            margin: .symmetric(
                                                                              horizontal:
                                                                                  15,
                                                                              vertical:
                                                                                  15,
                                                                            ),
                                                                            padding: .symmetric(
                                                                              horizontal:
                                                                                  15,
                                                                              vertical:
                                                                                  10,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(
                                                                                15,
                                                                              ),
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.black.withAlpha(
                                                                                      (0.4 *
                                                                                              255)
                                                                                          .toInt(),
                                                                                    )
                                                                                  : ThemingColors.white.withAlpha(
                                                                                      (0.4 *
                                                                                              255)
                                                                                          .toInt(),
                                                                                    ),
                                                                              border: .all(
                                                                                width: 0.2,
                                                                                color: context.isDark
                                                                                    ? ThemingColors.white
                                                                                    : ThemingColors.black,
                                                                              ),
                                                                            ),
                                                                            child: Column(
                                                                              crossAxisAlignment:
                                                                                  .center,
                                                                              children: [
                                                                                Container(
                                                                                  height: 25,
                                                                                  width: 25,
                                                                                  decoration: BoxDecoration(
                                                                                    color: ThemingColors.primaryColor.withAlpha(
                                                                                      (0.3 *
                                                                                              255)
                                                                                          .toInt(),
                                                                                    ),
                                                                                    borderRadius: .circular(
                                                                                      3,
                                                                                    ),
                                                                                  ),
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      3,
                                                                                    ),
                                                                                    child: SupabaseImageProvider(
                                                                                      filePath: Buckets.usersImages,
                                                                                      fileName: shift.workerId,
                                                                                      person: true,
                                                                                      iconSize: 18,
                                                                                      loadingIconSize: 12,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Text(
                                                                                  shift.workerName,
                                                                                  style: TextStyle(
                                                                                    fontWeight: .bold,
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                                if (!dailyPayment)
                                                                                  Text(
                                                                                    "$totalBatches",
                                                                                    style: TextStyle(
                                                                                      fontSize: 14,
                                                                                    ),
                                                                                  ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          content:
                                                                              dailyPayment
                                                                              ? Padding(
                                                                                  padding: .only(
                                                                                    bottom: 15,
                                                                                    left: 10,
                                                                                    right: 10,
                                                                                  ),
                                                                                  child: Row(
                                                                                    children: [
                                                                                      Expanded(
                                                                                        child: SizedBox(
                                                                                          width: 120,
                                                                                          height: 100,
                                                                                          child: Container(
                                                                                            margin:
                                                                                                context.locale.languageCode ==
                                                                                                    "ar"
                                                                                                ? .only(
                                                                                                    right: 5,
                                                                                                  )
                                                                                                : .only(
                                                                                                    left: 5,
                                                                                                  ),
                                                                                            alignment: .center,
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                10,
                                                                                              ),
                                                                                              color: context.isDark
                                                                                                  ? ThemingColors.black.withAlpha(
                                                                                                      (0.4 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    )
                                                                                                  : ThemingColors.white.withAlpha(
                                                                                                      (0.4 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    ),
                                                                                              border: .all(
                                                                                                width: 0.2,
                                                                                                color: context.isDark
                                                                                                    ? ThemingColors.white
                                                                                                    : ThemingColors.black,
                                                                                              ),
                                                                                            ),
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Icon(
                                                                                                  Icons.arrow_right,
                                                                                                  size: 20,
                                                                                                  color: ThemingColors.primaryColor,
                                                                                                ),
                                                                                                Expanded(
                                                                                                  child: WheelPicker(
                                                                                                    controller: WheelPickerController(
                                                                                                      itemCount: activeRoles.length,
                                                                                                      initialIndex: oldRoleIndex,
                                                                                                    ),
                                                                                                    looping: false,
                                                                                                    style: WheelPickerStyle(
                                                                                                      itemExtent: 33,
                                                                                                      surroundingOpacity: 0.4,
                                                                                                      diameterRatio: 10,
                                                                                                      magnification: 1,
                                                                                                    ),
                                                                                                    onIndexChanged:
                                                                                                        (
                                                                                                          i,
                                                                                                          _,
                                                                                                        ) {
                                                                                                          role = activeRoles[i];
                                                                                                          if (role !=
                                                                                                              oldRole) {
                                                                                                            cubit.setDailyPaymentShiftUpdated(
                                                                                                              true,
                                                                                                            );
                                                                                                          } else {
                                                                                                            cubit.setDailyPaymentShiftUpdated(
                                                                                                              false,
                                                                                                            );
                                                                                                          }
                                                                                                        },
                                                                                                    builder:
                                                                                                        (
                                                                                                          context,
                                                                                                          index,
                                                                                                        ) {
                                                                                                          return Center(
                                                                                                            child: Text(
                                                                                                              activeRoles[index].tr(),
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 12,
                                                                                                              ),
                                                                                                            ),
                                                                                                          );
                                                                                                        },
                                                                                                  ),
                                                                                                ),
                                                                                                Icon(
                                                                                                  Icons.arrow_left,
                                                                                                  size: 20,
                                                                                                  color: ThemingColors.primaryColor,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        child: SizedBox(
                                                                                          width: 85,
                                                                                          height: 100,
                                                                                          child: Container(
                                                                                            margin: .symmetric(
                                                                                              horizontal: 5,
                                                                                            ),
                                                                                            alignment: .center,
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                10,
                                                                                              ),
                                                                                              color: context.isDark
                                                                                                  ? ThemingColors.black.withAlpha(
                                                                                                      (0.4 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    )
                                                                                                  : ThemingColors.white.withAlpha(
                                                                                                      (0.4 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    ),
                                                                                              border: .all(
                                                                                                width: 0.2,
                                                                                                color: context.isDark
                                                                                                    ? ThemingColors.white
                                                                                                    : ThemingColors.black,
                                                                                              ),
                                                                                            ),
                                                                                            child: Directionality(
                                                                                              textDirection: ui.TextDirection.ltr,
                                                                                              child: Row(
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons.arrow_right,
                                                                                                    size: 20,
                                                                                                    color: ThemingColors.primaryColor,
                                                                                                  ),
                                                                                                  Expanded(
                                                                                                    child: WheelPicker(
                                                                                                      controller: WheelPickerController(
                                                                                                        itemCount: rates.length,
                                                                                                        initialIndex: oldRateIndex,
                                                                                                      ),
                                                                                                      looping: false,
                                                                                                      style: WheelPickerStyle(
                                                                                                        itemExtent: 33,
                                                                                                        surroundingOpacity: 0.4,
                                                                                                        diameterRatio: 10,
                                                                                                        magnification: 1,
                                                                                                      ),
                                                                                                      onIndexChanged:
                                                                                                          (
                                                                                                            i,
                                                                                                            _,
                                                                                                          ) {
                                                                                                            if (i ==
                                                                                                                0) {
                                                                                                              xrate = 1.0;
                                                                                                            } else if (i ==
                                                                                                                1) {
                                                                                                              xrate = 0.5;
                                                                                                            } else {
                                                                                                              xrate = 0.25;
                                                                                                            }
                                                                                                            if (xrate !=
                                                                                                                oldRate) {
                                                                                                              cubit.setDailyPaymentShiftUpdated(
                                                                                                                true,
                                                                                                              );
                                                                                                            } else {
                                                                                                              cubit.setDailyPaymentShiftUpdated(
                                                                                                                false,
                                                                                                              );
                                                                                                            }
                                                                                                          },
                                                                                                      builder:
                                                                                                          (
                                                                                                            context,
                                                                                                            ind,
                                                                                                          ) {
                                                                                                            return Row(
                                                                                                              mainAxisAlignment: .center,
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  rates[ind],
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 12,
                                                                                                                  ),
                                                                                                                ),
                                                                                                                Text(
                                                                                                                  "%",
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 9,
                                                                                                                    fontWeight: .bold,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                    ),
                                                                                                  ),
                                                                                                  Icon(
                                                                                                    Icons.arrow_left,
                                                                                                    size: 20,
                                                                                                    color: ThemingColors.primaryColor,
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                )
                                                                              : SizedBox(
                                                                                  height: 220,
                                                                                  width: double.maxFinite,
                                                                                  child: Column(
                                                                                    mainAxisSize: .min,
                                                                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                                    children: [
                                                                                      Container(
                                                                                        height: 122,
                                                                                        margin: .symmetric(
                                                                                          horizontal: 15,
                                                                                        ),
                                                                                        padding: .symmetric(
                                                                                          horizontal: 15,
                                                                                        ),
                                                                                        decoration: BoxDecoration(
                                                                                          borderRadius: BorderRadius.circular(
                                                                                            15,
                                                                                          ),
                                                                                          color: context.isDark
                                                                                              ? ThemingColors.black.withAlpha(
                                                                                                  (0.4 *
                                                                                                          255)
                                                                                                      .toInt(),
                                                                                                )
                                                                                              : ThemingColors.white.withAlpha(
                                                                                                  (0.4 *
                                                                                                          255)
                                                                                                      .toInt(),
                                                                                                ),
                                                                                          border: .all(
                                                                                            width: 0.3,
                                                                                            color: context.isDark
                                                                                                ? ThemingColors.white.withAlpha(
                                                                                                    (0.4 *
                                                                                                            255)
                                                                                                        .toInt(),
                                                                                                  )
                                                                                                : ThemingColors.black.withAlpha(
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
                                                                                          itemCount: shift.numberOfBatches.length,
                                                                                          separatorBuilder:
                                                                                              (
                                                                                                context,
                                                                                                index,
                                                                                              ) => Divider(
                                                                                                color: context.isDark
                                                                                                    ? ThemingColors.white.withAlpha(
                                                                                                        (0.1 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      )
                                                                                                    : ThemingColors.black.withAlpha(
                                                                                                        (0.1 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      ),
                                                                                                height: 25,
                                                                                                thickness: 0.5,
                                                                                              ),
                                                                                          itemBuilder:
                                                                                              (
                                                                                                context,
                                                                                                index,
                                                                                              ) {
                                                                                                return Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Row(
                                                                                                      children: [
                                                                                                        SizedBox(
                                                                                                          width: 30,
                                                                                                          child: cubit.addingRole
                                                                                                              ? SizedBox(
                                                                                                                  child: Text(
                                                                                                                    "${index + 1}",
                                                                                                                    textAlign: .center,
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 12,
                                                                                                                      fontWeight: .bold,
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                )
                                                                                                              : InkWell(
                                                                                                                  hoverColor: Colors.transparent,
                                                                                                                  splashColor: Colors.transparent,
                                                                                                                  highlightColor: Colors.transparent,
                                                                                                                  onTap: () {
                                                                                                                    context
                                                                                                                        .read<
                                                                                                                          ShiftsFilterCubit
                                                                                                                        >()
                                                                                                                        .deleteRole(
                                                                                                                          workerId: shift.workerId,
                                                                                                                          indexOfRole: index,
                                                                                                                        );
                                                                                                                    Navigator.pop(
                                                                                                                      dialogContext,
                                                                                                                    );
                                                                                                                  },
                                                                                                                  child: Icon(
                                                                                                                    Icons.delete_forever_outlined,
                                                                                                                    size: 18,
                                                                                                                    color: Colors.redAccent,
                                                                                                                  ),
                                                                                                                ),
                                                                                                        ),
                                                                                                        Text(
                                                                                                          shift.role[index],
                                                                                                          style: TextStyle(
                                                                                                            fontSize: 13,
                                                                                                            color: context.isDark
                                                                                                                ? ThemingColors.white.withAlpha(
                                                                                                                    (0.5 *
                                                                                                                            255)
                                                                                                                        .toInt(),
                                                                                                                  )
                                                                                                                : ThemingColors.black.withAlpha(
                                                                                                                    (0.5 *
                                                                                                                            255)
                                                                                                                        .toInt(),
                                                                                                                  ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 60,
                                                                                                      child: TextFormField(
                                                                                                        controller: controllers[index],
                                                                                                        keyboardType: TextInputType.number,
                                                                                                        textAlign: TextAlign.center,
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 13,
                                                                                                        ),
                                                                                                        onChanged:
                                                                                                            (
                                                                                                              text,
                                                                                                            ) {
                                                                                                              final int number =
                                                                                                                  int.tryParse(
                                                                                                                    text.toEnglishDigits(),
                                                                                                                  ) ??
                                                                                                                  0;
                                                                                                              if (number ==
                                                                                                                      shift.numberOfBatches[index] ||
                                                                                                                  text.isEmpty) {
                                                                                                                cubit.setNumberOfBatchUpdated(
                                                                                                                  false,
                                                                                                                );
                                                                                                              } else {
                                                                                                                cubit.setNumberOfBatchUpdated(
                                                                                                                  true,
                                                                                                                );
                                                                                                              }
                                                                                                            },
                                                                                                        decoration: InputDecoration(
                                                                                                          border: InputBorder.none,
                                                                                                          contentPadding: .symmetric(
                                                                                                            vertical: 2,
                                                                                                          ),
                                                                                                          focusedBorder: OutlineInputBorder(
                                                                                                            borderRadius: BorderRadius.circular(
                                                                                                              5,
                                                                                                            ),
                                                                                                            borderSide: BorderSide(
                                                                                                              color: context.isDark
                                                                                                                  ? ThemingColors.white
                                                                                                                  : ThemingColors.black,
                                                                                                              width: 0.1,
                                                                                                            ),
                                                                                                          ),
                                                                                                          enabledBorder: OutlineInputBorder(
                                                                                                            borderRadius: BorderRadius.circular(
                                                                                                              5,
                                                                                                            ),
                                                                                                            borderSide: BorderSide(
                                                                                                              color: context.isDark
                                                                                                                  ? ThemingColors.white
                                                                                                                  : ThemingColors.black,
                                                                                                              width: 0.1,
                                                                                                            ),
                                                                                                          ),
                                                                                                          errorBorder: InputBorder.none,
                                                                                                          disabledBorder: InputBorder.none,
                                                                                                          isDense: true,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                );
                                                                                              },
                                                                                        ),
                                                                                      ),
                                                                                      cubit.addingRole
                                                                                          ? Container(
                                                                                              height: 60,
                                                                                              margin: .only(
                                                                                                right: 15,
                                                                                                left: 20,
                                                                                                top: 15,
                                                                                              ),
                                                                                              padding: .only(
                                                                                                left: 5,
                                                                                                right: 15,
                                                                                              ),
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(
                                                                                                  15,
                                                                                                ),
                                                                                                color: context.isDark
                                                                                                    ? ThemingColors.black.withAlpha(
                                                                                                        (0.4 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      )
                                                                                                    : ThemingColors.white.withAlpha(
                                                                                                        (0.4 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      ),
                                                                                                border: .all(
                                                                                                  width: 0.3,
                                                                                                  color: context.isDark
                                                                                                      ? ThemingColors.white.withAlpha(
                                                                                                          (0.4 *
                                                                                                                  255)
                                                                                                              .toInt(),
                                                                                                        )
                                                                                                      : ThemingColors.black.withAlpha(
                                                                                                          (0.5 *
                                                                                                                  255)
                                                                                                              .toInt(),
                                                                                                        ),
                                                                                                ),
                                                                                              ),
                                                                                              child: Row(
                                                                                                mainAxisAlignment: .spaceBetween,
                                                                                                children: [
                                                                                                  SizedBox(
                                                                                                    width: 100,
                                                                                                    height: 55,
                                                                                                    child: Row(
                                                                                                      mainAxisAlignment: .spaceBetween,
                                                                                                      children: [
                                                                                                        Icon(
                                                                                                          Icons.arrow_right,
                                                                                                          size: 20,
                                                                                                          color: ThemingColors.primaryColor,
                                                                                                        ),
                                                                                                        Expanded(
                                                                                                          child: WheelPicker(
                                                                                                            controller: WheelPickerController(
                                                                                                              itemCount: rolesToAdd.length,
                                                                                                              initialIndex:
                                                                                                                  (rolesToAdd.length >
                                                                                                                      2)
                                                                                                                  ? 1
                                                                                                                  : 0,
                                                                                                            ),
                                                                                                            looping: false,
                                                                                                            style: WheelPickerStyle(
                                                                                                              itemExtent: 15,
                                                                                                              surroundingOpacity: 0.5,
                                                                                                              diameterRatio: 1,
                                                                                                            ),
                                                                                                            onIndexChanged:
                                                                                                                (
                                                                                                                  index,
                                                                                                                  _,
                                                                                                                ) {
                                                                                                                  newRole = rolesToAdd[index];
                                                                                                                },
                                                                                                            builder:
                                                                                                                (
                                                                                                                  context,
                                                                                                                  index,
                                                                                                                ) {
                                                                                                                  return Text(
                                                                                                                    rolesToAdd[index],
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 13,
                                                                                                                    ),
                                                                                                                  );
                                                                                                                },
                                                                                                          ),
                                                                                                        ),
                                                                                                        Icon(
                                                                                                          Icons.arrow_left,
                                                                                                          size: 20,
                                                                                                          color: ThemingColors.primaryColor,
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 60,
                                                                                                    child: TextFormField(
                                                                                                      controller: batchInputController,
                                                                                                      keyboardType: TextInputType.number,
                                                                                                      textAlign: TextAlign.center,
                                                                                                      style: const TextStyle(
                                                                                                        fontSize: 13,
                                                                                                      ),
                                                                                                      onTap: () {
                                                                                                        batchInputController.text = "";
                                                                                                      },
                                                                                                      onChanged:
                                                                                                          (
                                                                                                            text,
                                                                                                          ) {
                                                                                                            final number = int.tryParse(
                                                                                                              text.toEnglishDigits(),
                                                                                                            );
                                                                                                            final bool numberValid =
                                                                                                                number !=
                                                                                                                    null &&
                                                                                                                number >
                                                                                                                    0;

                                                                                                            if (numberValid) {
                                                                                                              cubit.setInputValidity(
                                                                                                                true,
                                                                                                              );
                                                                                                            } else {
                                                                                                              cubit.setInputValidity(
                                                                                                                false,
                                                                                                              );
                                                                                                            }
                                                                                                          },
                                                                                                      decoration: InputDecoration(
                                                                                                        border: InputBorder.none,
                                                                                                        contentPadding: .symmetric(
                                                                                                          vertical: 2,
                                                                                                        ),
                                                                                                        focusedBorder: OutlineInputBorder(
                                                                                                          borderRadius: BorderRadius.circular(
                                                                                                            5,
                                                                                                          ),
                                                                                                          borderSide: const BorderSide(
                                                                                                            color: ThemingColors.primaryColor,
                                                                                                            width: 0.2,
                                                                                                          ),
                                                                                                        ),
                                                                                                        enabledBorder: OutlineInputBorder(
                                                                                                          borderRadius: BorderRadius.circular(
                                                                                                            5,
                                                                                                          ),
                                                                                                          borderSide: const BorderSide(
                                                                                                            color: ThemingColors.primaryColor,
                                                                                                            width: 0.2,
                                                                                                          ),
                                                                                                        ),
                                                                                                        errorBorder: InputBorder.none,
                                                                                                        disabledBorder: InputBorder.none,
                                                                                                        isDense: true,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            )
                                                                                          : SizedBox(),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                          actions: [
                                                                            SizedBox(
                                                                              width:
                                                                                  .infinity,
                                                                              child:
                                                                                  dailyPayment
                                                                                  ? Row(
                                                                                      children: [
                                                                                        cubit.dailyPaymentShiftUpdated
                                                                                            ? InkWell(
                                                                                                hoverColor: Colors.transparent,
                                                                                                splashColor: Colors.transparent,
                                                                                                highlightColor: Colors.transparent,
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
                                                                                                      color: ThemingColors.primaryColor,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                        if (cubit.dailyPaymentShiftUpdated)
                                                                                          Expanded(
                                                                                            child: InkWell(
                                                                                              hoverColor: Colors.transparent,
                                                                                              splashColor: Colors.transparent,
                                                                                              highlightColor: Colors.transparent,
                                                                                              onTap: () {
                                                                                                cubit.editShiftOfDailyPayment(
                                                                                                  index: shiftIndex,
                                                                                                  role: role,
                                                                                                  rate: xrate!,
                                                                                                );
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
                                                                                                  Icons.done,
                                                                                                  size: 18,
                                                                                                  color: Colors.green,
                                                                                                ),
                                                                                              ),
                                                                                            ), //done
                                                                                          ),
                                                                                      ],
                                                                                    )
                                                                                  : Row(
                                                                                      mainAxisSize: .min,
                                                                                      children: [
                                                                                        (rolesToAdd.isEmpty &&
                                                                                                !cubit.numberOfBatchUpdated)
                                                                                            ? Expanded(
                                                                                                child: InkWell(
                                                                                                  hoverColor: Colors.transparent,
                                                                                                  splashColor: Colors.transparent,
                                                                                                  highlightColor: Colors.transparent,
                                                                                                  onTap: () {
                                                                                                    cubit.setInputValidity(
                                                                                                      false,
                                                                                                    );
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
                                                                                                      color: ThemingColors.primaryColor,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              )
                                                                                            : InkWell(
                                                                                                hoverColor: Colors.transparent,
                                                                                                splashColor: Colors.transparent,
                                                                                                highlightColor: Colors.transparent,
                                                                                                onTap: () {
                                                                                                  cubit.setInputValidity(
                                                                                                    false,
                                                                                                  );
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
                                                                                                    color: ThemingColors.primaryColor,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                        if (cubit.numberOfBatchUpdated ||
                                                                                            (cubit.addingRole &&
                                                                                                cubit.inputValidity))
                                                                                          Expanded(
                                                                                            child: InkWell(
                                                                                              hoverColor: Colors.transparent,
                                                                                              splashColor: Colors.transparent,
                                                                                              highlightColor: Colors.transparent,
                                                                                              onTap: () {
                                                                                                if (cubit.addingRole &&
                                                                                                    !cubit.inputValidity) {}
                                                                                                final List<
                                                                                                  int
                                                                                                >
                                                                                                updatedBatches = controllers
                                                                                                    .map(
                                                                                                      (
                                                                                                        c,
                                                                                                      ) =>
                                                                                                          int.tryParse(
                                                                                                            c.text.toEnglishDigits(),
                                                                                                          ) ??
                                                                                                          0,
                                                                                                    )
                                                                                                    .toList();
                                                                                                if (!cubit.addingRole) {
                                                                                                  cubit.updateWorkerBatches(
                                                                                                    workerId: shift.workerId,
                                                                                                    updatedBatches: updatedBatches,
                                                                                                    payroll: cubit.getPayroll(),
                                                                                                  );
                                                                                                }
                                                                                                if (cubit.addingRole &&
                                                                                                    cubit.inputValidity) {
                                                                                                  final newNumberOfBatches = int.tryParse(
                                                                                                    batchInputController.text.toEnglishDigits(),
                                                                                                  );
                                                                                                  if (batchInputController.text.isNotEmpty &&
                                                                                                      batchInputController.text.toEnglishDigits() !=
                                                                                                          0.toString() &&
                                                                                                      (newNumberOfBatches!) >
                                                                                                          0) {
                                                                                                    cubit.updateWorkerBatches(
                                                                                                      workerId: shift.workerId,
                                                                                                      updatedBatches: updatedBatches,
                                                                                                      payroll: cubit.getPayroll(),
                                                                                                    );
                                                                                                    cubit.addRoleToWorker(
                                                                                                      targetWorkerId: shift.workerId,
                                                                                                      newRole: newRole,
                                                                                                      newNumberOfBatches: newNumberOfBatches,
                                                                                                      payroll: cubit.getPayroll(),
                                                                                                    );
                                                                                                  }
                                                                                                }
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
                                                                                                  Icons.done,
                                                                                                  size: 18,
                                                                                                  color: Colors.green,
                                                                                                ),
                                                                                              ),
                                                                                            ), //done
                                                                                          ),
                                                                                        if (rolesToAdd.isNotEmpty)
                                                                                          cubit.numberOfBatchUpdated ||
                                                                                                  (cubit.addingRole &&
                                                                                                      cubit.inputValidity)
                                                                                              ? Row(
                                                                                                  mainAxisSize: .min,
                                                                                                  children: [
                                                                                                    cubit.addingRole
                                                                                                        ? InkWell(
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            splashColor: Colors.transparent,
                                                                                                            highlightColor: Colors.transparent,
                                                                                                            onTap: () {
                                                                                                              cubit.setInputValidity(
                                                                                                                false,
                                                                                                              );
                                                                                                              cubit.setAddingRole(
                                                                                                                false,
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
                                                                                                              child: Center(
                                                                                                                child: Icon(
                                                                                                                  Icons.close,
                                                                                                                  color: Colors.redAccent,
                                                                                                                  size: 18,
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ) // X
                                                                                                        : InkWell(
                                                                                                            hoverColor: Colors.transparent,
                                                                                                            splashColor: Colors.transparent,
                                                                                                            highlightColor: Colors.transparent,
                                                                                                            onTap: () {
                                                                                                              batchInputController.text = "0";
                                                                                                              cubit.setAddingRole(
                                                                                                                true,
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
                                                                                                                Icons.add,
                                                                                                                size: 18,
                                                                                                                color: ThemingColors.primaryColor,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                    // +
                                                                                                  ],
                                                                                                )
                                                                                              : Expanded(
                                                                                                  child: cubit.addingRole
                                                                                                      ? InkWell(
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          splashColor: Colors.transparent,
                                                                                                          highlightColor: Colors.transparent,
                                                                                                          onTap: () {
                                                                                                            cubit.setInputValidity(
                                                                                                              false,
                                                                                                            );
                                                                                                            cubit.setAddingRole(
                                                                                                              false,
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
                                                                                                            child: Center(
                                                                                                              child: Icon(
                                                                                                                Icons.close,
                                                                                                                color: Colors.redAccent,
                                                                                                                size: 18,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ) // X
                                                                                                      : InkWell(
                                                                                                          hoverColor: Colors.transparent,
                                                                                                          splashColor: Colors.transparent,
                                                                                                          highlightColor: Colors.transparent,
                                                                                                          onTap: () {
                                                                                                            batchInputController.text = "0";
                                                                                                            cubit.setAddingRole(
                                                                                                              true,
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
                                                                                                              Icons.add,
                                                                                                              size: 18,
                                                                                                              color: ThemingColors.primaryColor,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ), // +
                                                                                                ),
                                                                                      ],
                                                                                    ),
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
                                                  dailyPayment
                                                      ? "${(((shift.rate) ?? 0.5) * 100).toStringAsFixed(0)} %"
                                                      : "$totalBatches",
                                                  textDirection:
                                                      ui.TextDirection.ltr,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: cubit.editMode
                                                        ? ThemingColors
                                                              .primaryColor
                                                              .withAlpha(
                                                                ((changed
                                                                            ? 1
                                                                            : 0.5) *
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
                                                          ((changed ? 1 : 0.5) *
                                                                  255)
                                                              .toInt(),
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
                                              padding: .symmetric(vertical: 15),
                                              child: Directionality(
                                                textDirection: .ltr,
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      shift.wage.toStringAsFixed(
                                                        2,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: cubit.editMode
                                                            ? Colors.lightGreen
                                                                  .withAlpha(
                                                                    ((changed
                                                                                ? 1
                                                                                : 0.5) *
                                                                            255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.lightGreen,
                                                      ),
                                                    ),
                                                    Text(
                                                      " \$",
                                                      style: TextStyle(
                                                        color: cubit.editMode
                                                            ? context.isDark
                                                                  ? ThemingColors.white.withAlpha(
                                                                      ((changed
                                                                                  ? 1
                                                                                  : 0.5) *
                                                                              255)
                                                                          .toInt(),
                                                                    )
                                                                  : ThemingColors.black.withAlpha(
                                                                      ((changed
                                                                                  ? 1
                                                                                  : 0.5) *
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
                                    workersToAdd = getTheRestOfStaff(
                                      addedStaff:
                                          cubit.editableCurrentFilteredShifts,
                                      allStaff: cubit.getStaff(),
                                    );
                                    final activeRoles = getActiveRoles(
                                      cubit.getPayroll(),
                                    );
                                    role = activeRoles.length > 2
                                        ? activeRoles[1]
                                        : activeRoles[0];
                                    if (workersToAdd.isEmpty) {
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
                                                'No more staff to add',
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
                                    if (workersToAdd.isNotEmpty) {
                                      workerToAdd = workersToAdd.length > 2
                                          ? workersToAdd[1]
                                          : workersToAdd[0];
                                      double rate = 0.5;
                                      showDialog(
                                        barrierColor: Colors.transparent,
                                        context: context,
                                        builder: (dialogContext) {
                                          return BlocProvider.value(
                                            value: context
                                                .read<ShiftsFilterCubit>(),
                                            child: BlocBuilder<ShiftsFilterCubit, ShiftsFilterState>(
                                              builder: (context, workerDialoge) {
                                                return BackdropFilter(
                                                  filter: .blur(
                                                    sigmaX: context.isDark
                                                        ? 5
                                                        : 7,
                                                    sigmaY: context.isDark
                                                        ? 5
                                                        : 7,
                                                  ),
                                                  child: AlertDialog(
                                                    titlePadding: .only(
                                                      top: 25,
                                                      right: 25,
                                                      left: 25,
                                                    ),
                                                    contentPadding: .symmetric(
                                                      horizontal: 25,
                                                      vertical: 40,
                                                    ),
                                                    actionsPadding: .only(
                                                      bottom: 25,
                                                      right: 25,
                                                      left: 25,
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
                                                    backgroundColor:
                                                        context.isDark
                                                        ? ThemingColors.black
                                                              .withAlpha(
                                                                (0.2 * 255)
                                                                    .toInt(),
                                                              )
                                                        : ThemingColors.black
                                                              .withAlpha(
                                                                (0.05 * 255)
                                                                    .toInt(),
                                                              ),
                                                    title: Text(
                                                      "addWorker".tr(),
                                                      textAlign: .center,
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                    content: Column(
                                                      mainAxisSize: .min,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Flexible(
                                                              fit: .tight,
                                                              child: Container(
                                                                height: 100,
                                                                alignment:
                                                                    .center,
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
                                                                              (0.6 *
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
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding:
                                                                            context.locale.languageCode ==
                                                                                "ar"
                                                                            ? .only(
                                                                                left: 5,
                                                                              )
                                                                            : .only(
                                                                                right: 5,
                                                                              ),
                                                                        child: Icon(
                                                                          Icons
                                                                              .arrow_right,
                                                                          size:
                                                                              22,
                                                                          color: ThemingColors
                                                                              .primaryColor,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            140,
                                                                        child: WheelPicker(
                                                                          controller: WheelPickerController(
                                                                            itemCount:
                                                                                workersToAdd.length,
                                                                            initialIndex:
                                                                                workersToAdd.length >
                                                                                    2
                                                                                ? 1
                                                                                : 0,
                                                                          ),
                                                                          looping:
                                                                              false,
                                                                          style: WheelPickerStyle(
                                                                            itemExtent:
                                                                                32,
                                                                            surroundingOpacity:
                                                                                0.45,
                                                                            diameterRatio:
                                                                                10,
                                                                            magnification:
                                                                                1,
                                                                          ),
                                                                          onIndexChanged:
                                                                              (
                                                                                index,
                                                                                _,
                                                                              ) {
                                                                                workerToAdd = workersToAdd[index];
                                                                              },
                                                                          builder:
                                                                              (
                                                                                context,
                                                                                index,
                                                                              ) {
                                                                                return Center(
                                                                                  child: WorkerCell(
                                                                                    noPadding: true,
                                                                                    workerName: workersToAdd[index].workerName,
                                                                                    workerId: workersToAdd[index].workerId,
                                                                                  ),
                                                                                );
                                                                              },
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            context.locale.languageCode ==
                                                                                "ar"
                                                                            ? .only(
                                                                                left: 5,
                                                                              )
                                                                            : .only(
                                                                                right: 5,
                                                                              ),
                                                                        child: Icon(
                                                                          Icons
                                                                              .arrow_left,
                                                                          size:
                                                                              22,
                                                                          color: ThemingColors
                                                                              .primaryColor,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 15),
                                                        dailyPayment
                                                            ? Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.15,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            "role"
                                                                                .tr(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  context.locale.languageCode ==
                                                                                      "ar"
                                                                                  ? 13
                                                                                  : 11,
                                                                              color: ThemingColors.primaryColor.withAlpha(
                                                                                (0.7 *
                                                                                        255)
                                                                                    .toInt(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              100,
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                .center,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.arrow_right,
                                                                                size: 20,
                                                                                color: ThemingColors.primaryColor.withAlpha(
                                                                                  (0.5 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: 80,
                                                                                height: 100,
                                                                                child: WheelPicker(
                                                                                  controller: WheelPickerController(
                                                                                    itemCount: activeRoles.length,
                                                                                    initialIndex:
                                                                                        activeRoles.length >
                                                                                            2
                                                                                        ? 1
                                                                                        : 0,
                                                                                  ),
                                                                                  looping: false,
                                                                                  style: WheelPickerStyle(
                                                                                    itemExtent: 33,
                                                                                    surroundingOpacity: 0.4,
                                                                                    diameterRatio: 10,
                                                                                    magnification: 1,
                                                                                  ),
                                                                                  onIndexChanged:
                                                                                      (
                                                                                        index,
                                                                                        _,
                                                                                      ) {
                                                                                        role = activeRoles[index];
                                                                                      },
                                                                                  builder:
                                                                                      (
                                                                                        context,
                                                                                        index,
                                                                                      ) {
                                                                                        return Center(
                                                                                          child: Text(
                                                                                            activeRoles[index].tr(),
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                Icons.arrow_left,
                                                                                size: 20,
                                                                                color: ThemingColors.primaryColor.withAlpha(
                                                                                  (0.5 *
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
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              20,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.15,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            "hours"
                                                                                .tr(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  context.locale.languageCode ==
                                                                                      "ar"
                                                                                  ? 13
                                                                                  : 11,
                                                                              color: ThemingColors.primaryColor.withAlpha(
                                                                                (0.7 *
                                                                                        255)
                                                                                    .toInt(),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              100,
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Directionality(
                                                                            textDirection: ui
                                                                                .TextDirection
                                                                                .ltr,
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  .center,
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.arrow_right,
                                                                                  size: 20,
                                                                                  color: ThemingColors.primaryColor.withAlpha(
                                                                                    (0.5 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 70,
                                                                                  height: 100,
                                                                                  child: WheelPicker(
                                                                                    controller: WheelPickerController(
                                                                                      itemCount: rates.length,
                                                                                      initialIndex: 1,
                                                                                    ),
                                                                                    looping: false,
                                                                                    style: WheelPickerStyle(
                                                                                      itemExtent: 33,
                                                                                      surroundingOpacity: 0.4,
                                                                                      diameterRatio: 10,
                                                                                      magnification: 1,
                                                                                    ),
                                                                                    onIndexChanged:
                                                                                        (
                                                                                          index,
                                                                                          _,
                                                                                        ) {
                                                                                          if (index ==
                                                                                              0) {
                                                                                            rate = 1.0;
                                                                                          } else if (index ==
                                                                                              1) {
                                                                                            rate = 0.5;
                                                                                          } else {
                                                                                            rate = 0.25;
                                                                                          }
                                                                                        },
                                                                                    builder:
                                                                                        (
                                                                                          context,
                                                                                          index,
                                                                                        ) {
                                                                                          return Row(
                                                                                            mainAxisAlignment: .center,
                                                                                            children: [
                                                                                              Text(
                                                                                                rates[index],
                                                                                                style: TextStyle(
                                                                                                  fontSize: 12,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                "%",
                                                                                                style: TextStyle(
                                                                                                  fontSize: 9,
                                                                                                  fontWeight: .bold,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          );
                                                                                        },
                                                                                  ),
                                                                                ),
                                                                                Icon(
                                                                                  Icons.arrow_left,
                                                                                  size: 20,
                                                                                  color: ThemingColors.primaryColor.withAlpha(
                                                                                    (0.5 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                                  7,
                                                                                ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            "Role",
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  11,
                                                                              fontWeight:
                                                                                  .bold,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? Colors.amber
                                                                                  : Colors.orange,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              100,
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.arrow_right,
                                                                                size: 20,
                                                                                color: ThemingColors.primaryColor,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 80,
                                                                                height: 100,
                                                                                child: WheelPicker(
                                                                                  controller: WheelPickerController(
                                                                                    itemCount: activeRoles.length,
                                                                                    initialIndex: 1,
                                                                                  ),
                                                                                  looping: false,
                                                                                  style: WheelPickerStyle(
                                                                                    itemExtent: 33,
                                                                                    surroundingOpacity: 0.4,
                                                                                    diameterRatio: 10,
                                                                                    magnification: 1,
                                                                                  ),
                                                                                  onIndexChanged:
                                                                                      (
                                                                                        index,
                                                                                        _,
                                                                                      ) {
                                                                                        role = activeRoles[index];
                                                                                      },
                                                                                  builder:
                                                                                      (
                                                                                        context,
                                                                                        index,
                                                                                      ) {
                                                                                        return Center(
                                                                                          child: Text(
                                                                                            activeRoles[index],
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                ),
                                                                              ),
                                                                              Icon(
                                                                                Icons.arrow_left,
                                                                                size: 20,
                                                                                color: ThemingColors.primaryColor,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 20,
                                                                  ),
                                                                  Expanded(
                                                                    child: Column(
                                                                      children: [
                                                                        Container(
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                5,
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(
                                                                                  7,
                                                                                ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: Text(
                                                                            "Batches",
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  11,
                                                                              fontWeight:
                                                                                  .bold,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? Colors.amber
                                                                                  : Colors.orange,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              100,
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                5,
                                                                          ),
                                                                          alignment:
                                                                              .center,
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(
                                                                              10,
                                                                            ),
                                                                            color:
                                                                                context.isDark
                                                                                ? ThemingColors.black.withAlpha(
                                                                                    (0.6 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  )
                                                                                : ThemingColors.white.withAlpha(
                                                                                    (0.9 *
                                                                                            255)
                                                                                        .toInt(),
                                                                                  ),
                                                                            border: .all(
                                                                              width:
                                                                                  0.2,
                                                                              color:
                                                                                  context.isDark
                                                                                  ? ThemingColors.white
                                                                                  : ThemingColors.black,
                                                                            ),
                                                                          ),
                                                                          child: SizedBox(
                                                                            height:
                                                                                100,
                                                                            child: Center(
                                                                              child: TextFormField(
                                                                                controller: workerNumberOfBatchesController,
                                                                                keyboardType: TextInputType.number,
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                  fontSize: 13,
                                                                                ),
                                                                                onTap: () {
                                                                                  workerNumberOfBatchesController.text = "";
                                                                                  cubit.setInputValidity(
                                                                                    false,
                                                                                  );
                                                                                },
                                                                                onChanged:
                                                                                    (
                                                                                      text,
                                                                                    ) {
                                                                                      final input = int.tryParse(
                                                                                        text.toEnglishDigits(),
                                                                                      );
                                                                                      final bool validInput =
                                                                                          input !=
                                                                                              null &&
                                                                                          input >
                                                                                              0;
                                                                                      if (validInput) {
                                                                                        cubit.setInputValidity(
                                                                                          true,
                                                                                        );
                                                                                      } else {
                                                                                        cubit.setInputValidity(
                                                                                          false,
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                decoration: InputDecoration(
                                                                                  border: InputBorder.none,
                                                                                  contentPadding: .symmetric(
                                                                                    vertical: 4,
                                                                                  ),
                                                                                  focusedBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      5,
                                                                                    ),
                                                                                    borderSide: BorderSide(
                                                                                      color: context.isDark
                                                                                          ? ThemingColors.white
                                                                                          : ThemingColors.black,
                                                                                      width: 0.15,
                                                                                    ),
                                                                                  ),
                                                                                  enabledBorder: OutlineInputBorder(
                                                                                    borderRadius: BorderRadius.circular(
                                                                                      5,
                                                                                    ),
                                                                                    borderSide: BorderSide(
                                                                                      color: context.isDark
                                                                                          ? ThemingColors.white
                                                                                          : ThemingColors.black,
                                                                                      width: 0.15,
                                                                                    ),
                                                                                  ),
                                                                                  errorBorder: InputBorder.none,
                                                                                  disabledBorder: InputBorder.none,
                                                                                  isDense: true,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                      ],
                                                    ),
                                                    actions: [
                                                      dailyPayment
                                                          ? Row(
                                                              children: [
                                                                InkWell(
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
                                                                          vertical:
                                                                              2,
                                                                          horizontal:
                                                                              10,
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
                                                                Expanded(
                                                                  child: InkWell(
                                                                    hoverColor: Colors
                                                                        .transparent,
                                                                    splashColor:
                                                                        Colors
                                                                            .transparent,
                                                                    highlightColor:
                                                                        Colors
                                                                            .transparent,
                                                                    onTap: () {
                                                                      wageRate =
                                                                          cubit.getPayrollRate(
                                                                            role:
                                                                                role,
                                                                          ) ??
                                                                          0;
                                                                      final double
                                                                      wage =
                                                                          wageRate *
                                                                          rate;
                                                                      ShiftModel
                                                                      newWorker = ShiftModel(
                                                                        bakeryId:
                                                                            workerToAdd
                                                                                .bakeryId,
                                                                        workerId:
                                                                            workerToAdd
                                                                                .workerId,
                                                                        workerName:
                                                                            workerToAdd
                                                                                .workerName,
                                                                        branchId:workerToAdd.branchId,
                                                                        wage:
                                                                            wage,
                                                                        role: [
                                                                          role,
                                                                        ],
                                                                        rate:
                                                                            rate,
                                                                        numberOfBatches:
                                                                            [],
                                                                        date: cubit
                                                                            .selectedDate,
                                                                      );
                                                                      cubit.addWorker(
                                                                        newWorker:
                                                                            newWorker,
                                                                      );
                                                                      Navigator.pop(
                                                                        dialogContext,
                                                                      );
                                                                    },
                                                                    child: GlassCard(
                                                                      margin: .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                      ),
                                                                      padding:
                                                                          .symmetric(
                                                                            vertical:
                                                                                2,
                                                                          ),
                                                                      child: Icon(
                                                                        Icons
                                                                            .done,
                                                                        size: 18,
                                                                        color: Colors
                                                                            .green,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              children: [
                                                                cubit.inputValidity
                                                                    ? InkWell(
                                                                        hoverColor:
                                                                            Colors
                                                                                .transparent,
                                                                        splashColor:
                                                                            Colors
                                                                                .transparent,
                                                                        highlightColor:
                                                                            Colors
                                                                                .transparent,
                                                                        onTap: () {
                                                                          Navigator.pop(
                                                                            dialogContext,
                                                                          );
                                                                          cubit.setInputValidity(
                                                                            false,
                                                                          );
                                                                        },
                                                                        child: GlassCard(
                                                                          margin: .symmetric(
                                                                            horizontal:
                                                                                6,
                                                                          ),
                                                                          padding: .symmetric(
                                                                            vertical:
                                                                                2,
                                                                            horizontal:
                                                                                10,
                                                                          ),
                                                                          child: Icon(
                                                                            Icons
                                                                                .arrow_back,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Expanded(
                                                                        child: InkWell(
                                                                          hoverColor:
                                                                              Colors.transparent,
                                                                          splashColor:
                                                                              Colors.transparent,
                                                                          highlightColor:
                                                                              Colors.transparent,
                                                                          onTap: () =>
                                                                              Navigator.pop(
                                                                                dialogContext,
                                                                              ),
                                                                          child: GlassCard(
                                                                            margin: .symmetric(
                                                                              horizontal:
                                                                                  6,
                                                                            ),
                                                                            padding: .symmetric(
                                                                              vertical:
                                                                                  2,
                                                                            ),
                                                                            child: Icon(
                                                                              Icons.arrow_back,
                                                                              size:
                                                                                  18,
                                                                              color:
                                                                                  ThemingColors.primaryColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                if (cubit
                                                                    .inputValidity)
                                                                  Expanded(
                                                                    child: InkWell(
                                                                      hoverColor:
                                                                          Colors
                                                                              .transparent,
                                                                      splashColor:
                                                                          Colors
                                                                              .transparent,
                                                                      highlightColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap: () {
                                                                        final int
                                                                        numberOfBatches =
                                                                            int.tryParse(
                                                                              workerNumberOfBatchesController.text.toEnglishDigits(),
                                                                            ) ??
                                                                            0;
                                                                        wageRate =
                                                                            cubit.getPayrollRate(
                                                                              role:
                                                                                  role,
                                                                            ) ??
                                                                            0;
                                                                        ShiftModel
                                                                        newWorker = ShiftModel(
                                                                          bakeryId:
                                                                              workerToAdd.bakeryId,
                                                                          workerId:
                                                                              workerToAdd.workerId,
                                                                          workerName:
                                                                              workerToAdd.workerName,
                                                                          branchId:workerToAdd.branchId,
                                                                          wage:
                                                                              wageRate *
                                                                              numberOfBatches,
                                                                          role: [
                                                                            role,
                                                                          ],
                                                                          numberOfBatches: [
                                                                            numberOfBatches,
                                                                          ],
                                                                          date: context
                                                                              .read<
                                                                                ShiftsFilterCubit
                                                                              >()
                                                                              .selectedDate,
                                                                        );
                                                                        cubit.addWorker(
                                                                          newWorker:
                                                                              newWorker,
                                                                        );
                                                                        workerNumberOfBatchesController
                                                                                .text =
                                                                            "0";
                                                                        cubit.setInputValidity(
                                                                          false,
                                                                        );
                                                                        Navigator.pop(
                                                                          dialogContext,
                                                                        );
                                                                      },
                                                                      child: GlassCard(
                                                                        margin: .symmetric(
                                                                          horizontal:
                                                                              6,
                                                                        ),
                                                                        padding: .symmetric(
                                                                          vertical:
                                                                              2,
                                                                        ),
                                                                        child: Icon(
                                                                          Icons
                                                                              .done,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .green,
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
                                  icon: Icons.add,
                                  size: 18,
                                  verticalPadding: 2,
                                  buttonHorizontalPading: 0,
                                ),
                              ),
                          ],
                        ),
                      )
                    : (shiftsFilterState is ShiftsFilterLoading)
                    ? LoadingAnimationWidget.staggeredDotsWave(
                        color: ThemingColors.primaryColor,
                        size: 25,
                      )
                    : (shiftsFilterState is ShiftsFilterFailure)
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
