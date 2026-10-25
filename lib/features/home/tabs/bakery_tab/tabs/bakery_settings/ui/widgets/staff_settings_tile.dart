import 'dart:async';

import 'package:bakemart/core/shared/widgets/branch_pager/branch_pager.dart';
import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/shared/models/staff_model.dart';
import 'package:collection/collection.dart';
import 'package:bakemart/core/shared/widgets/table_cells/worker_cell.dart';
import 'package:bakemart/core/shared/widgets/text_form_field/text_form_field.dart';
import 'package:bakemart/core/utils/form_keys/form_keys.dart';
import 'package:bakemart/features/home/tabs/bakery_tab/tabs/bakery_settings/logic/settings_update_cubit/settings_update_cubit.dart';
import 'package:bakemart/core/shared/widgets/qr_scanner/qr_scanner_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:popup_menu/popup_menu.dart';

import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/shared/widgets/table_cells/text_cell.dart';
import '../../../../../../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/settings_cubit/settings_cubit.dart';

final GlobalKey _addButtonKey = GlobalKey();

class StaffSettingsTile extends StatelessWidget {
  final List<StaffModel> staff;

  const StaffSettingsTile({required this.staff, super.key});

  void _showAddMenu(BuildContext context) {
    final settingsUpdateCubit = context.read<SettingsUpdateCubit>();
    final settingsCubit = context.read<SettingsCubit>();
    PopupMenu menu = PopupMenu(
      context: context,
      config: MenuConfig(
        backgroundColor: context.isDark
            ? ThemingColors.black
            : ThemingColors.white,
        arrowHeight: 15,
        itemWidth: 170,
        itemHeight: 40,
        type: .list,
      ),
      items: [
        MenuItem(
          title: 'virtually'.tr(),
          textStyle: const TextStyle(fontSize: 12),
          image: Padding(
            padding: const .symmetric(horizontal: 5),
            child: Icon(
              Icons.edit,
              size: 16,
              color: ThemingColors.primaryColor.withAlpha((0.6 * 255).toInt()),
            ),
          ),
          userInfo: 1,
        ),
        MenuItem(
          title: 'withAccount'.tr(),
          textStyle: const TextStyle(fontSize: 12),
          image: Padding(
            padding: const .symmetric(horizontal: 5),
            child: Icon(
              Icons.qr_code_scanner,
              size: 16,
              color: ThemingColors.primaryColor.withAlpha((0.6 * 255).toInt()),
            ),
          ),
          userInfo: 2,
        ),
      ],
      onClickMenu: (MenuItemProvider item) {
        if (item.menuUserInfo == 1) {
          final TextEditingController nameController = TextEditingController();
          showDialog(
            context: context,
            barrierColor: Colors.transparent,
            builder: (dialogContext) {
              return BlocProvider.value(
                value: settingsUpdateCubit,
                child: BackdropFilter(
                  filter: .blur(sigmaX: 5, sigmaY: 5),
                  child: Form(
                    key: newWorkerNameFormKey,
                    child: AlertDialog(
                      contentPadding: .only(right: 15, left: 15, top: 10),
                      actionsPadding: .all(15),
                      shape: RoundedRectangleBorder(
                        borderRadius: .circular(20),
                        side: BorderSide(
                          width: 0.3,
                          color: context.isDark
                              ? ThemingColors.white.withAlpha(
                            (0.4 * 255).toInt(),
                          )
                              : ThemingColors.black.withAlpha(
                            (0.2 * 255).toInt(),
                          ),
                        ),
                      ),
                      backgroundColor: context.isDark
                          ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
                          : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
                      titlePadding: .symmetric(vertical: 20),
                      title: Text("addWorker".tr(), textAlign: .center),
                      content: SizedBox(
                        height: 80,
                        child: CustomTextFormField(
                          "workerName".tr(),
                          controller: nameController,
                          validate: true,
                        ),
                      ),
                      actions: [
                        Row(
                          children: [
                            InkWell(
                              hoverColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () {
                                Navigator.pop(dialogContext);
                              },
                              child: GlassCard(
                                margin: .symmetric(horizontal: 6),
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
                            Expanded(
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  if (newWorkerNameFormKey.currentState!
                                      .validate()) {
                                    settingsUpdateCubit.addWorker(
                                      branchId: settingsCubit.staffsViewedBranch,
                                      workerName: nameController.text,
                                    );
                                    Navigator.pop(dialogContext);
                                  }
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
                  ),
                ),
              );
            },
          );
        } else if (item.menuUserInfo == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QrScannerScreen(
                scanningLabel: "addWorkerScanningLabel".tr(),
                onDetect: (code) {
                  settingsUpdateCubit.addWorker(
                    branchId: settingsCubit.staffsViewedBranch,
                    workerId: code,
                  );
                },
              ),
            ),
          );
        }
      },
    );
    menu.show(widgetKey: _addButtonKey);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    final updateCubit = context.read<SettingsUpdateCubit>();
    return _ErrorSnackbarListener(
      cubit: updateCubit,
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
            cubit.updateStaffTileExpansion(expanded);
          },
          title: SizedBox(
            height: 53,
            child: Row(
              mainAxisAlignment: .start,
              children: [
                Text(
                  "staff".tr(),
                  style: TextStyle(fontWeight: .bold, fontSize: 18),
                ),
                SizedBox(width: 10),
                Icon(Icons.star, size: 15, color: ThemingColors.primaryColor),
                SizedBox(width: 5),
                Text("supervisors".tr(), style: TextStyle(fontSize: 13)),
                Spacer(),
                cubit.isStaffEditing
                    ? InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    cubit.staffEditingMode(!cubit.isStaffEditing);
                  },
                  child: Container(
                    margin: .only(right: 10),
                    padding: .all(5),
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
                    child: Icon(Icons.done, size: 18, color: Colors.green),
                  ),
                )
                    : cubit.isStaffExpanded
                    ? Padding(
                  padding: .only(right: 10),
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      cubit.staffEditingMode(!cubit.isStaffEditing);
                    },
                    child: Icon(Icons.delete_forever_outlined),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          ),
          children: [
            BranchPager(
              branches: cubit.bakeries,
              selectedBranchId: cubit.staffsViewedBranch,
              onBranchChanged: cubit.staffBranchChanged,
              child: Padding(
                padding: .symmetric(horizontal: 25),
                child: Column(
                  children: [
                    Padding(
                      padding: .only(bottom: 20),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "twoSupervisors".tr(),
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    GlassCard(
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
                                  Padding(
                                    padding: .symmetric(vertical: 7),
                                    child: Icon(
                                      Icons.star,
                                      size: 20,
                                      color: context.isDark
                                          ? ThemingColors.white.withAlpha(
                                        (0.3 * 255).toInt(),
                                      )
                                          : ThemingColors.black.withAlpha(
                                        (0.3 * 255).toInt(),
                                      ),
                                    ),
                                  ),
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
                              if (staff.isEmpty)
                                TableRow(
                                  children: [
                                    TableCell(
                                      verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 10),
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
                                              "No data",
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
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                        child: Align(
                                          alignment: .centerLeft,
                                          child: Column(
                                            crossAxisAlignment: .center,
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
                                                "No data",
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
                                  ],
                                )
                              else
                                ...staff.asMap().entries.map((entry) {
                                  final StaffModel worker = entry.value;
                                  final BakeryModel? branch = cubit.bakeries
                                      .firstWhereOrNull(
                                        (item) => item.branchId == worker.branchId,
                                  );
                                  final bool supervisor =
                                      branch?.supervisorId.contains(
                                        worker.workerId,
                                      ) ??
                                          false;
                                  return TableRow(
                                    children: [
                                      TableCell(
                                        verticalAlignment: .middle,
                                        child:
                                        BlocBuilder<
                                            SettingsUpdateCubit,
                                            SettingsUpdateState
                                        >(
                                          builder: (context, updateState) {
                                            final bool isThisLoading =
                                                updateState
                                                is SettingsUpdateLoading &&
                                                    updateState.action ==
                                                        SettingsUpdateAction
                                                            .supervisor &&
                                                    updateState.targetId ==
                                                        worker.workerId;
                                            if (isThisLoading) {
                                              return SizedBox(
                                                child: Center(
                                                  child:
                                                  LoadingAnimationWidget.staggeredDotsWave(
                                                    color: ThemingColors
                                                        .primaryColor,
                                                    size: 16,
                                                  ),
                                                ),
                                              );
                                            }
                                            return InkWell(
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                              Colors.transparent,
                                              onTap: () {
                                                if (branch == null) return;
                                                if (branch
                                                    .supervisorId
                                                    .length <
                                                    2 &&
                                                    !branch.supervisorId
                                                        .contains(
                                                      worker.workerId,
                                                    )) {
                                                  final updatedBakery = branch
                                                      .copyWith(
                                                    supervisorId: [
                                                      ...branch
                                                          .supervisorId,
                                                      worker.workerId,
                                                    ],
                                                  );
                                                  updateCubit.changeBakerySupervisor(
                                                    updatedBakery:
                                                    updatedBakery,
                                                    targetId: worker.workerId,
                                                  );
                                                } else if (branch
                                                    .supervisorId
                                                    .contains(
                                                  worker.workerId,
                                                )) {
                                                  final updatedBakery = branch
                                                      .copyWith(
                                                    supervisorId: branch
                                                        .supervisorId
                                                        .where(
                                                          (id) =>
                                                      id !=
                                                          worker
                                                              .workerId,
                                                    )
                                                        .toList(),
                                                  );
                                                  updateCubit.changeBakerySupervisor(
                                                    updatedBakery:
                                                    updatedBakery,
                                                    targetId: worker.workerId,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      elevation: 0,
                                                      backgroundColor:
                                                      Colors.transparent,
                                                      duration: Duration(
                                                        seconds: 3,
                                                      ),
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
                                                            'twoSupervisors'
                                                                .tr(),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight: .bold,
                                                              color:
                                                              context.isDark
                                                                  ? ThemingColors
                                                                  .white
                                                                  : ThemingColors
                                                                  .black,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 10,
                                                ),
                                                child: Icon(
                                                  supervisor
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 22,
                                                  color: supervisor
                                                      ? ThemingColors
                                                      .primaryColor
                                                      : ThemingColors
                                                      .primaryColor
                                                      .withAlpha(
                                                    (0.4 * 255)
                                                        .toInt(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      TableCell(
                                        child: Padding(
                                          padding: .symmetric(
                                            vertical: 1,
                                            horizontal: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment: .spaceBetween,
                                            children: [
                                              Expanded(
                                                child: WorkerCell(
                                                  workerName: worker.workerName,
                                                  workerId: worker.workerId,
                                                ),
                                              ),
                                              if (cubit.isStaffEditing)
                                                BlocBuilder<
                                                    SettingsUpdateCubit,
                                                    SettingsUpdateState
                                                >(
                                                  builder: (context, updateState) {
                                                    final bool isThisDeleting =
                                                        updateState
                                                        is SettingsUpdateLoading &&
                                                            updateState.action ==
                                                                SettingsUpdateAction
                                                                    .deleteWorker &&
                                                            updateState.targetId ==
                                                                worker.workerId;
                                                    if (isThisDeleting) {
                                                      return SizedBox(
                                                        child: Center(
                                                          child:
                                                          LoadingAnimationWidget.staggeredDotsWave(
                                                            color: Colors
                                                                .redAccent,
                                                            size: 16,
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                    return InkWell(
                                                      hoverColor:
                                                      Colors.transparent,
                                                      splashColor:
                                                      Colors.transparent,
                                                      highlightColor:
                                                      Colors.transparent,
                                                      onTap: () {
                                                        updateCubit.deleteWorker(
                                                          worker: worker,
                                                        );
                                                      },
                                                      child: Icon(
                                                        Icons
                                                            .delete_forever_outlined,
                                                        size: 18,
                                                        color: Colors.redAccent,
                                                      ),
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                            ],
                          ),
                          Padding(
                            padding: .only(top: 10, bottom: 10),
                            child:
                            BlocBuilder<
                                SettingsUpdateCubit,
                                SettingsUpdateState
                            >(
                              builder: (context, state) {
                                final bool isAdding =
                                    state is SettingsUpdateLoading &&
                                        state.action ==
                                            SettingsUpdateAction.addWorker;
                                return TransparentButton(
                                  key: _addButtonKey,
                                  onTap: () => _showAddMenu(context),
                                  buttonWidget: isAdding
                                      ? LoadingAnimationWidget.staggeredDotsWave(
                                    color: ThemingColors.primaryColor,
                                    size: 20,
                                  )
                                      : Icon(
                                    Icons.add,
                                    size: 20,
                                    color: ThemingColors.primaryColor,
                                  ),
                                  size: 18,
                                  verticalPadding: 2,
                                  buttonHorizontalPading: 0,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSnackbarListener extends StatelessWidget {
  final SettingsUpdateCubit cubit;
  final Widget child;

  const _ErrorSnackbarListener({required this.cubit, required this.child});

  @override
  Widget build(BuildContext context) {
    return _StreamListener<String>(
      stream: cubit.errorMessages,
      onData: (_) => _showSnackBar(context),
      child: child,
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Center(
          child: GlassCard(
            margin: EdgeInsets.zero,
            padding: .symmetric(vertical: 7, horizontal: 20),
            otherRadius: 30,
            orange: true,
            child: Text(
              "failed".tr(),
              style: TextStyle(
                color: context.isDark
                    ? ThemingColors.white
                    : ThemingColors.black,
                fontWeight: .bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamListener<T> extends StatefulWidget {
  final Stream<T> stream;
  final ValueChanged<T> onData;
  final Widget child;

  const _StreamListener({
    required this.stream,
    required this.onData,
    required this.child,
  });

  @override
  State<_StreamListener<T>> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<_StreamListener<T>> {
  StreamSubscription<T>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.stream.listen(widget.onData);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}