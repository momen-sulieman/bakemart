import 'dart:ui' as ui;
import 'dart:ui';

import 'package:bakemart/core/shared/models/shift_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/product_slider/product_slider.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/production_cubit/production_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/quantities_counter_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/window_sales_cubit/window_sales_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/logic/worker_cubit/worker_cubit.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/delivery_man_orders_screen.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/expenses_tile.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/shift_history_tile.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/worker_tab/ui/widgets/work_sheet_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../core/dependency_injection/dependency_injection.dart';
import '../../../../../../../core/shared/models/payroll_model.dart';
import '../../../../../../../core/shared/models/product_model.dart';
import '../../../../../../../core/shared/models/staff_model.dart';
import '../../../../../../../core/shared/widgets/faded_screen/faded_screen.dart';
import '../../../../../../../core/shared/widgets/qr_scanner/qr_scanner_screen.dart';
import '../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../core/shared/widgets/transparent_button/transparent_button.dart';
import '../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/enums/buckts.dart';
import '../../../../../../../core/utils/enums/payrolls_table_columns.dart';
import '../../../../../../../core/utils/extensions/context_extensions.dart';
import '../logic/delivery_sales_cubit/delivery_sales_cubit.dart';
import '../logic/history_filter_cubit/history_filter_cubit.dart';

class WorkerTabScreen extends StatelessWidget {
  const WorkerTabScreen({super.key});

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

  List<String> getActiveRoles(PayrollModel? payroll) {
    if (payroll == null) return [];

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
    TextEditingController numberOfBatchesController = TextEditingController(
      text: "0",
    );
    TextEditingController manufacturingWasteController = TextEditingController(
      text: "0",
    );
    TextEditingController workerNumberOfBatchesController =
        TextEditingController(text: "0");
    final cubit = context.read<WorkerCubit>();
    List<StaffModel> workersToAdd = [];
    StaffModel workerToAdd = StaffModel(
      workerName: "",
      workerId: "",
      bakeryId: "",
      branchId: "",
    );
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: context.isDark
            ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
            : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20),
          child: Container(
            height: 70,
            width: .infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: ThemingColors.primaryColor.withAlpha(
                    (0.15 * 255).toInt(),
                  ),
                  width: 5,
                ),
              ),
              borderRadius: .only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: BlocBuilder<WorkerCubit, WorkerState>(
              builder: (context, state) {
                if (state is UnEmployed) {
                  return Center(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          barrierColor: Colors.transparent,
                          builder: (dialogContext) {
                            return BackdropFilter(
                              filter: .blur(sigmaY: 5, sigmaX: 5),
                              child: Column(
                                mainAxisAlignment: .center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        context.locale.languageCode == "ar"
                                        ? .start
                                        : .end,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: TransparentButton(
                                          onTap: () =>
                                              Navigator.pop(dialogContext),
                                          buttonHorizontalPading: 40,
                                          icon: Icons.close,
                                          isCircle: true,
                                          size: 22,
                                          buttonSize: 25,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  AlertDialog(
                                    insetPadding: .zero,
                                    backgroundColor: context.isDark
                                        ? ThemingColors.darkGrey
                                        : ThemingColors.lightGrey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: context.isDark
                                            ? ThemingColors.lightGrey
                                            : ThemingColors.black,
                                        width: context.isDark ? 0.2 : 0.3,
                                      ),
                                    ),
                                    title: Column(
                                      children: [
                                        Container(
                                          height: 40,
                                          width: 40,
                                          margin: .only(bottom: 10),
                                          decoration: BoxDecoration(
                                            color: ThemingColors.primaryColor
                                                .withAlpha((0.3 * 255).toInt()),
                                            borderRadius: .circular(3),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: SupabaseImageProvider(
                                              filePath: Buckets.usersImages,
                                              fileName: cubit.user?.id ?? "",
                                              person: true,
                                              iconSize: 16,
                                              loadingIconSize: 14,
                                              cacheWidth: 120,
                                              cacheHeight: 120,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${cubit.user?.firstName ?? ""} ${cubit.user?.secondName ?? ""}",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            margin: .only(bottom: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: SizedBox(
                                              width: 200,
                                              height: 200,
                                              child: QrImageView(
                                                data: cubit.user?.id ?? "",
                                                version: QrVersions.auto,
                                                size: 200.0,
                                                eyeStyle: const QrEyeStyle(
                                                  eyeShape: QrEyeShape.square,
                                                  color: Colors.black,
                                                ),
                                                dataModuleStyle:
                                                    const QrDataModuleStyle(
                                                      dataModuleShape:
                                                          QrDataModuleShape
                                                              .square,
                                                      color: Colors.black,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "letTheBakeryOwnerScanHere".tr(),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize:
                                                  context.locale.languageCode ==
                                                      "ar"
                                                  ? 14
                                                  : 12,
                                              fontWeight: .bold,
                                              color: context.isDark
                                                  ? Colors.blueGrey
                                                  : Colors.grey,
                                            ),
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
                      },
                      child: GlassCard(
                        margin: .only(bottom: 20),
                        padding: .symmetric(horizontal: 20, vertical: 5),
                        otherRadius: 30,
                        child: Row(
                          mainAxisAlignment: .center,
                          mainAxisSize: .min,
                          children: [
                            Icon(
                              Icons.qr_code_scanner,
                              size: 20,
                              color: ThemingColors.primaryColor,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "joinABakery".tr(),
                              style: TextStyle(fontSize: 12, fontWeight: .bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is WorkerFailure || state is WorkerLoading) {
                  return SizedBox(height: 70, width: .infinity);
                }
                return SizedBox(
                  height: 70,
                  width: .infinity,
                  child: Directionality(
                    textDirection: context.locale.languageCode == "ar"
                        ? .rtl
                        : .ltr,
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Container(
                          height: 35,
                          width: 35,
                          margin: context.locale.languageCode == "ar"
                              ? .only(left: 10, right: 30)
                              : .only(right: 10, left: 30),
                          decoration: BoxDecoration(
                            borderRadius: context.locale.languageCode == "ar"
                                ? .only(
                                    topRight: .circular(15),
                                    topLeft: .circular(5),
                                    bottomLeft: .circular(15),
                                    bottomRight: .circular(5),
                                  )
                                : .only(
                                    topLeft: .circular(15),
                                    topRight: .circular(5),
                                    bottomRight: .circular(15),
                                    bottomLeft: .circular(5),
                                  ),
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.3 * 255).toInt(),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: context.locale.languageCode == "ar"
                                ? .only(
                                    topRight: .circular(15),
                                    topLeft: .circular(5),
                                    bottomLeft: .circular(15),
                                    bottomRight: .circular(5),
                                  )
                                : .only(
                              topLeft: .circular(15),
                              topRight: .circular(5),
                              bottomRight: .circular(15),
                              bottomLeft: .circular(5),
                            ),
                            child: SupabaseImageProvider(
                              filePath: Buckets.bakeriesImages,
                              fileName: cubit.bakery?.bakeryId,
                              iconSize: 14,
                              loadingIconSize: 14,
                              cacheWidth: 75,
                              cacheHeight: 75,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            cubit.bakery?.bakeryName ?? "!!",
                            maxLines: 1,
                            overflow: .ellipsis,
                            style: TextStyle(fontSize: 12, fontWeight: .bold),
                          ),
                        ),
                        SizedBox(
                          width: 130,
                          child: InkWell(
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () {
                              showDialog(
                                context: context,
                                barrierColor: Colors.transparent,
                                builder: (dialogContext) {
                                  return BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 5,
                                      sigmaY: 5,
                                    ),
                                    child: AlertDialog(
                                      titlePadding: .only(
                                        left: 15,
                                        right: 15,
                                        top: 15,
                                      ),
                                      contentPadding: .symmetric(
                                        horizontal: 10,
                                        vertical: 50,
                                      ),
                                      actionsPadding: .only(
                                        left: 20,
                                        right: 20,
                                        bottom: 20,
                                      ),
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
                                          ? ThemingColors.black.withAlpha(
                                              (0.4 * 255).toInt(),
                                            )
                                          : ThemingColors.white.withAlpha(
                                              (0.4 * 255).toInt(),
                                            ),
                                      title: Text(
                                        "confirmQuit".tr(),
                                        textAlign: .center,
                                        style: TextStyle(
                                          fontWeight: .bold,
                                          fontSize: 20,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                      content: Text(
                                        "quitWarning".tr(),
                                        textAlign: .center,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                      actions: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: InkWell(
                                                hoverColor: Colors.transparent,
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () => Navigator.pop(
                                                  dialogContext,
                                                ),
                                                child: GlassCard(
                                                  margin: .zero,
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
                                            SizedBox(width: 20),
                                            InkWell(
                                              hoverColor: Colors.transparent,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onTap: () {
                                                Navigator.pop(dialogContext);
                                                cubit.quit();
                                              },
                                              child: GlassCard(
                                                margin: .zero,
                                                padding: .symmetric(
                                                  vertical: 2,
                                                  horizontal: 15,
                                                ),
                                                green: true,
                                                child: Icon(
                                                  Icons.logout,
                                                  size: 18,
                                                  color: Colors.redAccent,
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
                            child: GlassCard(
                              margin: .symmetric(horizontal: 30),
                              padding: .symmetric(vertical: 3),
                              otherRadius: 30,
                              child: Text(
                                "quit".tr(),
                                textAlign: .center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: .bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              context.isDark
                  ? ConstantImages.darkBackground
                  : ConstantImages.lightBackground,
            ),
            fit: BoxFit.cover,
            opacity: context.isDark ? 0.35 : 0.25,
          ),
        ),
        child: Directionality(
          textDirection: context.locale.languageCode == 'ar'
              ? ui.TextDirection.rtl
              : ui.TextDirection.ltr,
          child: RefreshIndicator(
            edgeOffset: 180,
            strokeWidth: 2,
            displacement: 0,
            elevation: 0,
            color: ThemingColors.primaryColor,
            backgroundColor: Colors.transparent,
            onRefresh: () async {
              cubit.frame(withLoading: cubit.payroll == null);
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              padding: .only(top: 200, bottom: 175),
              child: BlocBuilder<WorkerCubit, WorkerState>(
                builder: (context, workerState) {
                  if (workerState is WorkerLoading) {
                    final availableHight = screenHeight - 365;
                    return SizedBox(
                      height: availableHight,
                      width: .infinity,
                      child: Column(
                        mainAxisAlignment: .center,
                        crossAxisAlignment: .center,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(
                            color: ThemingColors.primaryColor,
                            size: 25,
                          ),
                        ],
                      ),
                    );
                  } else if (workerState is UnEmployed ||
                      workerState is Employed) {
                    return Column(
                      children: [
                        if (cubit.shifts != null)
                          BlocProvider(
                            create: (_) =>
                                DependencyInjection.getIt<HistoryFilterCubit>(),
                            child: const ShiftHistoryTile(),
                          ),
                      ],
                    );
                  } else if (workerState is Supervisor) {
                    final productionCubit = context.read<ProductionCubit>();
                    final dailyPayment = cubit.payrollMethod;
                    final roles = getActiveRoles(cubit.payroll);
                    String role = roles.isNotEmpty
                        ? (roles.length > 2 ? roles[1] : roles[0])
                        : "";
                    return Column(
                      children: [
                        Theme(
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
                            title: Row(
                              mainAxisAlignment: .spaceBetween,
                              children: [
                                Text(
                                  "sellingAndProduction".tr(),
                                  style: TextStyle(
                                    fontWeight: .bold,
                                    fontSize: 18,
                                  ),
                                ),
                                InkWell(
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => QrScannerScreen(
                                          scanningLabel: "scanOrderScanningLabel"
                                              .tr(),
                                          onDetect: (code) {
                                            showDialog(
                                              context: context,
                                              barrierColor: Colors.transparent,
                                              builder: (dialogContext) {
                                                return MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider(
                                                      create: (_) =>
                                                          DependencyInjection.getIt<
                                                              DeliverySalesCubit
                                                            >()
                                                            ..scanOrders(
                                                              deliveryManId: code,
                                                              bakeryId: cubit
                                                                  .bakery!
                                                                  .bakeryId,
                                                              branchId: cubit
                                                                  .bakery!
                                                                  .branchId,
                                                            ),
                                                    ),
                                                    BlocProvider.value(
                                                      value: cubit,
                                                    ),
                                                  ],
                                                  child:
                                                      const DeliveryManOrdersScreen(),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: .symmetric(horizontal: 10),
                                        child: Text(
                                          "scanOrder".tr(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.qr_code_scanner_outlined,
                                        size: 27,
                                        color: ThemingColors.primaryColor,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(side: .none),
                            controlAffinity: ListTileControlAffinity.leading,
                            children: [
                              ListView.separated(
                                padding: .symmetric(horizontal: 40),
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final ProductModel product =
                                      workerState.products![index];
                                  return ProductSlider(
                                    rightAction: (controller) async {
                                      numberOfBatchesController.text = 0
                                          .toString();
                                      manufacturingWasteController.text = 0
                                          .toString();
                                      productionCubit.setInputValidity(false);
                                      productionCubit.setAddingWorker(false);
                                      productionCubit.emptyWorkersSheet();
                                      showModalBottomSheet(
                                        context: context,
                                        barrierColor: Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder: (modalBottomSheetContext) {
                                          final double keyboardHeight =
                                              MediaQuery.of(
                                                modalBottomSheetContext,
                                              ).viewInsets.bottom;
                                          return GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () {
                                              FocusScope.of(
                                                modalBottomSheetContext,
                                              ).unfocus();
                                            },
                                            child: AnimatedPadding(
                                              duration: const Duration(
                                                milliseconds: 100,
                                              ),
                                              curve: Curves.decelerate,
                                              padding: EdgeInsets.only(
                                                bottom: keyboardHeight,
                                              ),
                                              child: SingleChildScrollView(
                                                child: BackdropFilter(
                                                  filter: .blur(
                                                    sigmaY: 4,
                                                    sigmaX: 4,
                                                  ),
                                                  child: BlocProvider.value(
                                                    value: context
                                                        .read<ProductionCubit>(),
                                                    child:
                                                        BlocBuilder<
                                                          ProductionCubit,
                                                          ProductionState
                                                        >(
                                                          builder:
                                                              (
                                                                context,
                                                                productionDialogState,
                                                              ) {
                                                                return Container(
                                                                  width: double
                                                                      .infinity,
                                                                  padding: .only(
                                                                    bottom: 40,
                                                                    left: 20,
                                                                    right: 20,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        .circular(
                                                                          20,
                                                                        ),
                                                                    border: Border(
                                                                      top: BorderSide(
                                                                        color:
                                                                            context
                                                                                .isDark
                                                                            ? Colors.greenAccent.withAlpha(
                                                                                (0.2 *
                                                                                        255)
                                                                                    .toInt(),
                                                                              )
                                                                            : Colors.greenAccent.withAlpha(
                                                                                (0.4 *
                                                                                        255)
                                                                                    .toInt(),
                                                                              ),
                                                                        width: 4,
                                                                      ),
                                                                    ),
                                                                    color:
                                                                        context
                                                                            .isDark
                                                                        ? ThemingColors.black.withAlpha(
                                                                            (0.2 *
                                                                                    255)
                                                                                .toInt(),
                                                                          )
                                                                        : ThemingColors.white.withAlpha(
                                                                            (0.6 *
                                                                                    255)
                                                                                .toInt(),
                                                                          ),
                                                                  ),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        .min,
                                                                    children: [
                                                                      Container(
                                                                        width: 70,
                                                                        margin: .symmetric(
                                                                          vertical:
                                                                              15,
                                                                        ),
                                                                        padding:
                                                                            .only(
                                                                              top:
                                                                                  5,
                                                                            ),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              .circular(
                                                                                50,
                                                                              ),
                                                                          color:
                                                                              context.isDark
                                                                              ? Colors.greenAccent.withAlpha(
                                                                                  (0.2 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                )
                                                                              : Colors.greenAccent.withAlpha(
                                                                                  (0.4 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                ),
                                                                        ),
                                                                      ),
                                                                      CircleAvatar(
                                                                        radius:
                                                                            20,
                                                                        backgroundColor: ThemingColors
                                                                            .primaryColor
                                                                            .withAlpha(
                                                                              (0.3 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            ),
                                                                        child: ClipOval(
                                                                          child: SupabaseImageProvider(
                                                                            filePath:
                                                                                Buckets.productsImages,
                                                                            fileName:
                                                                                product.productId,
                                                                            iconSize:
                                                                                16,
                                                                            cacheWidth:
                                                                                120,
                                                                            cacheHeight:
                                                                                120,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      Text(
                                                                        product
                                                                            .productName,
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          fontWeight:
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            .infinity,
                                                                        child: GlassCard(
                                                                          margin:
                                                                              .zero,
                                                                          padding: .symmetric(
                                                                            horizontal:
                                                                                20,
                                                                            vertical:
                                                                                5,
                                                                          ),
                                                                          green:
                                                                              true,
                                                                          child: Text(
                                                                            "productionData"
                                                                                .tr(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        width: double
                                                                            .infinity,
                                                                        margin:
                                                                            .all(
                                                                              15,
                                                                            ),
                                                                        padding: .symmetric(
                                                                          horizontal:
                                                                              15,
                                                                          vertical:
                                                                              15,
                                                                        ),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(
                                                                                15,
                                                                              ),
                                                                          color:
                                                                              context.isDark
                                                                              ? ThemingColors.black.withAlpha(
                                                                                  (0.6 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                )
                                                                              : ThemingColors.white.withAlpha(
                                                                                  (0.6 *
                                                                                          255)
                                                                                      .toInt(),
                                                                                ),
                                                                          border: .all(
                                                                            width:
                                                                                0.3,
                                                                            color:
                                                                                context.isDark
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
                                                                        child: Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment:
                                                                                  .spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "numberOfBatches".tr(),
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 60,
                                                                                  child: TextFormField(
                                                                                    controller: numberOfBatchesController,
                                                                                    keyboardType: TextInputType.number,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      fontSize: 13,
                                                                                    ),
                                                                                    onTap: () {
                                                                                      numberOfBatchesController.text = "";
                                                                                      productionCubit.setInputValidity(
                                                                                        false,
                                                                                      );
                                                                                    },
                                                                                    onChanged:
                                                                                        (
                                                                                          text,
                                                                                        ) {
                                                                                          final input = int.tryParse(
                                                                                            text,
                                                                                          );
                                                                                          final inputValid =
                                                                                              input !=
                                                                                                  null &&
                                                                                              input >
                                                                                                  0;
                                                                                          if (inputValid) {
                                                                                            productionCubit.setInputValidity(
                                                                                              true,
                                                                                            );
                                                                                          } else {
                                                                                            productionCubit.setInputValidity(
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
                                                                            ),
                                                                            SizedBox(
                                                                              height:
                                                                                  10,
                                                                            ),
                                                                            Row(
                                                                              mainAxisAlignment:
                                                                                  .spaceBetween,
                                                                              children: [
                                                                                Text(
                                                                                  "manufacturingWaste".tr(),
                                                                                  style: TextStyle(
                                                                                    fontSize: 13,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 60,
                                                                                  child: TextFormField(
                                                                                    controller: manufacturingWasteController,
                                                                                    keyboardType: TextInputType.number,
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                      fontSize: 13,
                                                                                    ),
                                                                                    onTap: () {
                                                                                      manufacturingWasteController.text = "";
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
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      if (dailyPayment)
                                                                        SizedBox(
                                                                          height:
                                                                              40,
                                                                        ),
                                                                      if (!dailyPayment)
                                                                        Column(
                                                                          children: [
                                                                            GlassCard(
                                                                              margin:
                                                                                  .zero,
                                                                              padding:
                                                                                  .zero,
                                                                              green:
                                                                                  true,
                                                                              child: Row(
                                                                                mainAxisAlignment: .spaceBetween,
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: .symmetric(
                                                                                      horizontal: 20,
                                                                                      vertical: 10,
                                                                                    ),
                                                                                    child: Text(
                                                                                      "productionWorkers".tr(),
                                                                                    ),
                                                                                  ),
                                                                                  productionCubit.addingWorker
                                                                                      ? Container(
                                                                                          margin: .symmetric(
                                                                                            horizontal: 20,
                                                                                          ),
                                                                                          padding: .symmetric(
                                                                                            horizontal: productionCubit.workerInputValidity
                                                                                                ? 15
                                                                                                : 5,
                                                                                            vertical: 5,
                                                                                          ),
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: .circular(
                                                                                              50,
                                                                                            ),
                                                                                            border: Border.all(
                                                                                              color: context.isDark
                                                                                                  ? Colors.white.withAlpha(
                                                                                                      (0.2 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    )
                                                                                                  : ThemingColors.black.withAlpha(
                                                                                                      (0.2 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    ),
                                                                                              width: 0.7,
                                                                                            ),
                                                                                            boxShadow: [
                                                                                              BoxShadow(
                                                                                                color: context.isDark
                                                                                                    ? Colors.white.withAlpha(
                                                                                                        (0.1 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      )
                                                                                                    : Colors.black.withAlpha(
                                                                                                        (0.1 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      ),
                                                                                                blurRadius: 10,
                                                                                                spreadRadius: -2,
                                                                                                offset: Offset(
                                                                                                  5,
                                                                                                  -5,
                                                                                                ),
                                                                                              ),
                                                                                              BoxShadow(
                                                                                                color: context.isDark
                                                                                                    ? Colors.black.withAlpha(
                                                                                                        (0.4 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      )
                                                                                                    : Colors.white.withAlpha(
                                                                                                        (0.4 *
                                                                                                                255)
                                                                                                            .toInt(),
                                                                                                      ),
                                                                                                blurRadius: 20,
                                                                                                spreadRadius: 2,
                                                                                                offset: Offset(
                                                                                                  15,
                                                                                                  8,
                                                                                                ),
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
                                                                                                  productionCubit.setAddingWorker(
                                                                                                    false,
                                                                                                  );
                                                                                                },
                                                                                                child: Icon(
                                                                                                  Icons.close,
                                                                                                  size: 18,
                                                                                                  color: Colors.redAccent,
                                                                                                ),
                                                                                              ),
                                                                                              if (productionCubit.workerInputValidity)
                                                                                                SizedBox(
                                                                                                  height: 17,
                                                                                                  width: 35,
                                                                                                  child: Center(
                                                                                                    child: Container(
                                                                                                      width: 1,
                                                                                                      color: context.isDark
                                                                                                          ? ThemingColors.white.withAlpha(
                                                                                                              (0.4 *
                                                                                                                      255)
                                                                                                                  .toInt(),
                                                                                                            )
                                                                                                          : ThemingColors.black.withAlpha(
                                                                                                              (0.2 *
                                                                                                                      255)
                                                                                                                  .toInt(),
                                                                                                            ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              if (productionCubit.workerInputValidity)
                                                                                                InkWell(
                                                                                                  hoverColor: Colors.transparent,
                                                                                                  splashColor: Colors.transparent,
                                                                                                  highlightColor: Colors.transparent,
                                                                                                  onTap: () {
                                                                                                    ShiftModel newWorker = ShiftModel(
                                                                                                      bakeryId: workerToAdd.bakeryId,
                                                                                                      workerId: workerToAdd.workerId,
                                                                                                      branchId: workerToAdd.branchId,
                                                                                                      workerName: workerToAdd.workerName,
                                                                                                      wage: 0,
                                                                                                      role: [
                                                                                                        role,
                                                                                                      ],
                                                                                                      numberOfBatches: [
                                                                                                        int.tryParse(
                                                                                                              workerNumberOfBatchesController.text.toEnglishDigits(),
                                                                                                            ) ??
                                                                                                            0,
                                                                                                      ],
                                                                                                      date: DateTime.now(),
                                                                                                    );
                                                                                                    productionCubit.addWorkerToWorkersSheet(
                                                                                                      newWorker: newWorker,
                                                                                                    );
                                                                                                    productionCubit.setAddingWorker(
                                                                                                      false,
                                                                                                    );
                                                                                                    productionCubit.setWorkerInputValidity(
                                                                                                      false,
                                                                                                    );
                                                                                                    workerNumberOfBatchesController.text = 0.toString();
                                                                                                  },
                                                                                                  child: SizedBox(
                                                                                                    width: 18,
                                                                                                    child: Icon(
                                                                                                      Icons.done,
                                                                                                      size: 18,
                                                                                                      color: Colors.green,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      : Padding(
                                                                                          padding: .symmetric(
                                                                                            horizontal: 25,
                                                                                          ),
                                                                                          child: InkWell(
                                                                                            hoverColor: Colors.transparent,
                                                                                            splashColor: Colors.transparent,
                                                                                            highlightColor: Colors.transparent,
                                                                                            onTap: () {
                                                                                              workersToAdd = getTheRestOfStaff(
                                                                                                addedStaff: productionCubit.workersSheet,
                                                                                                allStaff: cubit.staff!,
                                                                                              );
                                                                                              workerToAdd =
                                                                                                  workersToAdd[workersToAdd.length >
                                                                                                          3
                                                                                                      ? 1
                                                                                                      : 0];
                                                                                              productionCubit.setAddingWorker(
                                                                                                true,
                                                                                              );
                                                                                            },
                                                                                            child: SizedBox(
                                                                                              child: Icon(
                                                                                                Icons.add,
                                                                                                size: 20,
                                                                                                color: ThemingColors.primaryColor,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            if (productionCubit
                                                                                .addingWorker)
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: 100,
                                                                                margin: .only(
                                                                                  right: 15,
                                                                                  left: 15,
                                                                                  top: 15,
                                                                                ),
                                                                                padding:
                                                                                    context.locale.languageCode ==
                                                                                        "ar"
                                                                                    ? .only(
                                                                                        left: 10,
                                                                                      )
                                                                                    : .only(
                                                                                        right: 10,
                                                                                      ),
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(
                                                                                    15,
                                                                                  ),
                                                                                  color: context.isDark
                                                                                      ? ThemingColors.black.withAlpha(
                                                                                          (0.6 *
                                                                                                  255)
                                                                                              .toInt(),
                                                                                        )
                                                                                      : ThemingColors.white.withAlpha(
                                                                                          (0.6 *
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
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: 170,
                                                                                      height: 100,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: .spaceBetween,
                                                                                        children: [
                                                                                          Icon(
                                                                                            Icons.arrow_right,
                                                                                            size: 22,
                                                                                            color: ThemingColors.primaryColor,
                                                                                          ),
                                                                                          Expanded(
                                                                                            child: WheelPicker(
                                                                                              controller: WheelPickerController(
                                                                                                itemCount: workersToAdd.length,
                                                                                                initialIndex:
                                                                                                    workersToAdd.length >
                                                                                                        3
                                                                                                    ? 1
                                                                                                    : 0,
                                                                                              ),
                                                                                              looping: false,
                                                                                              style: WheelPickerStyle(
                                                                                                itemExtent: 33,
                                                                                                surroundingOpacity: 0.2,
                                                                                                diameterRatio: 10,
                                                                                                magnification: 1,
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
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Padding(
                                                                                                            padding:
                                                                                                                context.locale.languageCode ==
                                                                                                                    "ar"
                                                                                                                ? .only(
                                                                                                                    left: 10,
                                                                                                                  )
                                                                                                                : .only(
                                                                                                                    right: 10,
                                                                                                                  ),
                                                                                                            child: CircleAvatar(
                                                                                                              radius: 13,
                                                                                                              backgroundColor: ThemingColors.primaryColor.withAlpha(
                                                                                                                (0.3 *
                                                                                                                        255)
                                                                                                                    .toInt(),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            width: 90,
                                                                                                            child: Text(
                                                                                                              workersToAdd[index].workerName,
                                                                                                              maxLines: 1,
                                                                                                              overflow: .ellipsis,
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 12,
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    );
                                                                                                  },
                                                                                            ),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.arrow_left,
                                                                                            size: 22,
                                                                                            color: ThemingColors.primaryColor,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 105,
                                                                                      height: 100,
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
                                                                                                itemCount: roles.length,
                                                                                                initialIndex:
                                                                                                    roles.length >
                                                                                                        2
                                                                                                    ? 1
                                                                                                    : 0,
                                                                                              ),
                                                                                              looping: false,
                                                                                              style: WheelPickerStyle(
                                                                                                itemExtent: 33,
                                                                                                surroundingOpacity: 0.2,
                                                                                                diameterRatio: 10,
                                                                                                magnification: 1,
                                                                                              ),
                                                                                              onIndexChanged:
                                                                                                  (
                                                                                                    index,
                                                                                                    _,
                                                                                                  ) {
                                                                                                    role = roles[index];
                                                                                                  },
                                                                                              builder:
                                                                                                  (
                                                                                                    context,
                                                                                                    index,
                                                                                                  ) {
                                                                                                    return Center(
                                                                                                      child: Text(
                                                                                                        roles[index],
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
                                                                                    Spacer(),
                                                                                    SizedBox(
                                                                                      width: 40,
                                                                                      child: TextFormField(
                                                                                        controller: workerNumberOfBatchesController,
                                                                                        keyboardType: TextInputType.number,
                                                                                        textAlign: TextAlign.center,
                                                                                        style: const TextStyle(
                                                                                          fontSize: 13,
                                                                                        ),
                                                                                        onTap: () {
                                                                                          workerNumberOfBatchesController.text = "";
                                                                                          productionCubit.setWorkerInputValidity(
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
                                                                                                productionCubit.setWorkerInputValidity(
                                                                                                  true,
                                                                                                );
                                                                                              } else {
                                                                                                productionCubit.setWorkerInputValidity(
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
                                                                                            borderSide: const BorderSide(
                                                                                              color: ThemingColors.primaryColor,
                                                                                              width: 0.15,
                                                                                            ),
                                                                                          ),
                                                                                          enabledBorder: OutlineInputBorder(
                                                                                            borderRadius: BorderRadius.circular(
                                                                                              5,
                                                                                            ),
                                                                                            borderSide: const BorderSide(
                                                                                              color: ThemingColors.primaryColor,
                                                                                              width: 0.15,
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
                                                                              ),
                                                                            Container(
                                                                              width:
                                                                                  double.infinity,
                                                                              height:
                                                                                  150,
                                                                              margin: .only(
                                                                                right: 15,
                                                                                left: 15,
                                                                                top: 15,
                                                                                bottom: productionCubit.addingWorker
                                                                                    ? 15
                                                                                    : 130,
                                                                              ),
                                                                              padding: .symmetric(
                                                                                horizontal: 10,
                                                                                vertical: 13,
                                                                              ),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(
                                                                                  15,
                                                                                ),
                                                                                color: context.isDark
                                                                                    ? ThemingColors.black.withAlpha(
                                                                                        (0.6 *
                                                                                                255)
                                                                                            .toInt(),
                                                                                      )
                                                                                    : ThemingColors.white.withAlpha(
                                                                                        (0.6 *
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
                                                                              child:
                                                                                  productionCubit.workersSheet.isEmpty
                                                                                  ? productionCubit.addingWorker
                                                                                        ? SizedBox()
                                                                                        : Center(
                                                                                            child: InkWell(
                                                                                              hoverColor: Colors.transparent,
                                                                                              splashColor: Colors.transparent,
                                                                                              highlightColor: Colors.transparent,
                                                                                              onTap: () {
                                                                                                workersToAdd = getTheRestOfStaff(
                                                                                                  addedStaff: productionCubit.workersSheet,
                                                                                                  allStaff: cubit.staff!,
                                                                                                );
                                                                                                workerToAdd =
                                                                                                    workersToAdd[workersToAdd.length >
                                                                                                            3
                                                                                                        ? 1
                                                                                                        : 0];
                                                                                                productionCubit.setAddingWorker(
                                                                                                  true,
                                                                                                );
                                                                                              },
                                                                                              child: Row(
                                                                                                mainAxisAlignment: .center,
                                                                                                children: [
                                                                                                  Padding(
                                                                                                    padding: .symmetric(
                                                                                                      horizontal: 10,
                                                                                                    ),
                                                                                                    child: Text(
                                                                                                      "+",
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 20,
                                                                                                        color: ThemingColors.primaryColor,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    "addWorkersData".tr(),
                                                                                                    style: TextStyle(
                                                                                                      color: context.isDark
                                                                                                          ? ThemingColors.white.withAlpha(
                                                                                                              (0.3 *
                                                                                                                      255)
                                                                                                                  .toInt(),
                                                                                                            )
                                                                                                          : ThemingColors.black.withAlpha(
                                                                                                              (0.35 *
                                                                                                                      255)
                                                                                                                  .toInt(),
                                                                                                            ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                  : ListView.separated(
                                                                                      shrinkWrap: true,
                                                                                      padding: .zero,
                                                                                      itemBuilder:
                                                                                          (
                                                                                            _,
                                                                                            index,
                                                                                          ) {
                                                                                            final ShiftModel worker = productionCubit.workersSheet[index];
                                                                                            return Row(
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
                                                                                                  child: InkWell(
                                                                                                    hoverColor: Colors.transparent,
                                                                                                    splashColor: Colors.transparent,
                                                                                                    highlightColor: Colors.transparent,
                                                                                                    onTap: () {
                                                                                                      productionCubit.removeWorkerFromWorkersSheet(
                                                                                                        index,
                                                                                                      );
                                                                                                    },
                                                                                                    child: Icon(
                                                                                                      Icons.delete_forever_outlined,
                                                                                                      size: 16,
                                                                                                      color: Colors.redAccent,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Padding(
                                                                                                  padding:
                                                                                                      context.locale.languageCode ==
                                                                                                          "ar"
                                                                                                      ? .only(
                                                                                                          left: 10,
                                                                                                        )
                                                                                                      : .only(
                                                                                                          right: 10,
                                                                                                        ),
                                                                                                  child: CircleAvatar(
                                                                                                    radius: 13,
                                                                                                    backgroundColor: ThemingColors.primaryColor.withAlpha(
                                                                                                      (0.3 *
                                                                                                              255)
                                                                                                          .toInt(),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 90,
                                                                                                  child: Text(
                                                                                                    worker.workerName,
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    style: const TextStyle(
                                                                                                      fontSize: 13,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 35,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: 60,
                                                                                                  child: Text(
                                                                                                    worker.role[0],
                                                                                                    maxLines: 1,
                                                                                                    overflow: .ellipsis,
                                                                                                    textAlign: .center,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 13,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Spacer(),
                                                                                                SizedBox(
                                                                                                  width: 40,
                                                                                                  child: Text(
                                                                                                    worker.numberOfBatches[0].toString(),
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 13,
                                                                                                    ),
                                                                                                    textAlign: .center,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            );
                                                                                          },
                                                                                      separatorBuilder:
                                                                                          (
                                                                                            _,
                                                                                            _,
                                                                                          ) {
                                                                                            return SizedBox(
                                                                                              height: 10,
                                                                                            );
                                                                                          },
                                                                                      itemCount: productionCubit.workersSheet.length,
                                                                                    ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      Row(
                                                                        children: [
                                                                          productionCubit.formValidity
                                                                              ? InkWell(
                                                                                  hoverColor: Colors.transparent,
                                                                                  splashColor: Colors.transparent,
                                                                                  highlightColor: Colors.transparent,
                                                                                  onTap: () {
                                                                                    numberOfBatchesController.text = "0";
                                                                                    manufacturingWasteController.text = "0";
                                                                                    productionCubit.emptyWorkersSheet();
                                                                                    productionCubit.setAddingWorker(
                                                                                      false,
                                                                                    );
                                                                                    productionCubit.setInputValidity(
                                                                                      false,
                                                                                    );
                                                                                    Navigator.pop(
                                                                                      modalBottomSheetContext,
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
                                                                                      Icons.arrow_downward,
                                                                                      size: 20,
                                                                                      color: Colors.redAccent,
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Expanded(
                                                                                  child: InkWell(
                                                                                    hoverColor: Colors.transparent,
                                                                                    splashColor: Colors.transparent,
                                                                                    highlightColor: Colors.transparent,
                                                                                    onTap: () {
                                                                                      numberOfBatchesController.text = "0";
                                                                                      manufacturingWasteController.text = "0";
                                                                                      productionCubit.emptyWorkersSheet();
                                                                                      productionCubit.setAddingWorker(
                                                                                        false,
                                                                                      );
                                                                                      productionCubit.setInputValidity(
                                                                                        false,
                                                                                      );
                                                                                      Navigator.pop(
                                                                                        modalBottomSheetContext,
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
                                                                                        Icons.arrow_downward,
                                                                                        size: 20,
                                                                                        color: Colors.redAccent,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                          if (productionCubit
                                                                              .formValidity)
                                                                            Expanded(
                                                                              child: InkWell(
                                                                                hoverColor: Colors.transparent,
                                                                                splashColor: Colors.transparent,
                                                                                highlightColor: Colors.transparent,
                                                                                onTap: () async {
                                                                                  Navigator.pop(
                                                                                    modalBottomSheetContext,
                                                                                  );
                                                                                  controller.loading();
                                                                                  await productionCubit.postProduction(
                                                                                    batchCounter:
                                                                                        int.tryParse(
                                                                                          numberOfBatchesController.text,
                                                                                        ) ??
                                                                                        0,
                                                                                    manufacturingWasteCounter:
                                                                                        int.tryParse(
                                                                                          manufacturingWasteController.text,
                                                                                        ) ??
                                                                                        0,
                                                                                    product: product,
                                                                                    currentStorage: cubit.storage!,
                                                                                  );
                                                                                  controller.success();
                                                                                  await Future.delayed(
                                                                                    Duration(
                                                                                      seconds: 2,
                                                                                    ),
                                                                                  );
                                                                                  controller.reset();
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
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    leftAction: (controller) async {
                                      showModalBottomSheet(
                                        context: context,
                                        barrierColor: Colors.transparent,
                                        backgroundColor: Colors.transparent,
                                        isScrollControlled: true,
                                        builder: (modalBottomSheetContext) {
                                          return BackdropFilter(
                                            filter: .blur(sigmaY: 4, sigmaX: 4),
                                            child: MultiBlocProvider(
                                              providers: [
                                                BlocProvider.value(
                                                  value: context
                                                      .read<WindowSalesCubit>(),
                                                ),
                                                BlocProvider(
                                                  create: (modalContext) =>
                                                      QuantitiesCounterCubit(),
                                                ),
                                              ],
                                              child: Container(
                                                width: double.infinity,
                                                padding: .only(
                                                  bottom: 40,
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius: .circular(20),
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: context.isDark
                                                          ? Colors.redAccent
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                )
                                                          : Colors.redAccent
                                                                .withAlpha(
                                                                  (0.4 * 255)
                                                                      .toInt(),
                                                                ),
                                                      width: 4,
                                                    ),
                                                  ),
                                                  color: context.isDark
                                                      ? ThemingColors.black
                                                            .withAlpha(
                                                              (0.2 * 255).toInt(),
                                                            )
                                                      : ThemingColors.white
                                                            .withAlpha(
                                                              (0.6 * 255).toInt(),
                                                            ),
                                                ),
                                                child: Column(
                                                  mainAxisSize: .min,
                                                  children: [
                                                    Container(
                                                      width: 70,
                                                      margin: .only(
                                                        top: 15,
                                                        bottom: 30,
                                                      ),
                                                      padding: .only(top: 5),
                                                      decoration: BoxDecoration(
                                                        borderRadius: .circular(
                                                          50,
                                                        ),
                                                        color: context.isDark
                                                            ? Colors.redAccent
                                                                  .withAlpha(
                                                                    (0.2 * 255)
                                                                        .toInt(),
                                                                  )
                                                            : Colors.redAccent
                                                                  .withAlpha(
                                                                    (0.4 * 255)
                                                                        .toInt(),
                                                                  ),
                                                      ),
                                                    ),
                                                    CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor:
                                                          ThemingColors
                                                              .primaryColor
                                                              .withAlpha(
                                                                (0.3 * 255)
                                                                    .toInt(),
                                                              ),
                                                      child: ClipOval(
                                                        child:
                                                            SupabaseImageProvider(
                                                              filePath: Buckets
                                                                  .productsImages,
                                                              fileName: product
                                                                  .productId,
                                                              iconSize: 16,
                                                              cacheWidth: 120,
                                                              cacheHeight: 120,
                                                            ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      product.productName,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: .bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 30),
                                                    BlocBuilder<
                                                      QuantitiesCounterCubit,
                                                      List<int>
                                                    >(
                                                      builder: (context, counter) {
                                                        final cubit = context
                                                            .read<
                                                              WindowSalesCubit
                                                            >();
                                                        return Directionality(
                                                          textDirection: ui
                                                              .TextDirection
                                                              .ltr,
                                                          child: Column(
                                                            children: [
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                margin: .only(
                                                                  bottom: 15,
                                                                ),
                                                                padding:
                                                                    .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          15,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        50,
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
                                                                              (0.6 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            ),
                                                                  border: .all(
                                                                    width: 0.3,
                                                                    color:
                                                                        context
                                                                            .isDark
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
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            right:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          if (counter[0] >=
                                                                              10) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .soldMinusTen();
                                                                          }
                                                                        },
                                                                        onLongPress: () {
                                                                          if (counter[0] >=
                                                                              100) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .soldMinusHundred();
                                                                          }
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "-10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        if (counter[0] >=
                                                                            1) {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .soldMinusOne();
                                                                        }
                                                                      },
                                                                      icon: Icons
                                                                          .remove,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            counter[0]
                                                                                .toString(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  30,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "sold"
                                                                                .tr(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  11,
                                                                              fontWeight:
                                                                                  .bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        context
                                                                            .read<
                                                                              QuantitiesCounterCubit
                                                                            >()
                                                                            .soldPlusOne();
                                                                      },
                                                                      icon: Icons
                                                                          .add,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            left:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .soldPlusTen();
                                                                        },
                                                                        onLongPress: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .soldPlusHundred();
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "+10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                margin: .only(
                                                                  bottom: 15,
                                                                ),
                                                                padding:
                                                                    .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          15,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        50,
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
                                                                              (0.6 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            ),
                                                                  border: .all(
                                                                    width: 0.3,
                                                                    color:
                                                                        context
                                                                            .isDark
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
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            right:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          if (counter[1] >=
                                                                              10) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .notSoldMinusTen();
                                                                          }
                                                                        },
                                                                        onLongPress: () {
                                                                          if (counter[1] >=
                                                                              100) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .notSoldMinusHundred();
                                                                          }
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "-10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        if (counter[1] >=
                                                                            1) {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .notSoldMinusOne();
                                                                        }
                                                                      },
                                                                      icon: Icons
                                                                          .remove,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            counter[1]
                                                                                .toString(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  30,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "notSold"
                                                                                .tr(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  11,
                                                                              fontWeight:
                                                                                  .bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        context
                                                                            .read<
                                                                              QuantitiesCounterCubit
                                                                            >()
                                                                            .notSoldPlusOne();
                                                                      },
                                                                      icon: Icons
                                                                          .add,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            left:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .notSoldPlusTen();
                                                                        },
                                                                        onLongPress: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .notSoldPlusHundred();
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "+10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                width: double
                                                                    .infinity,
                                                                margin: .only(
                                                                  bottom: 15,
                                                                ),
                                                                padding:
                                                                    .symmetric(
                                                                      horizontal:
                                                                          15,
                                                                      vertical:
                                                                          15,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        50,
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
                                                                              (0.6 *
                                                                                      255)
                                                                                  .toInt(),
                                                                            ),
                                                                  border: .all(
                                                                    width: 0.3,
                                                                    color:
                                                                        context
                                                                            .isDark
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
                                                                  children: [
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            right:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          if (counter[2] >=
                                                                              10) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .mealMinusTen();
                                                                          }
                                                                        },
                                                                        onLongPress: () {
                                                                          if (counter[2] >=
                                                                              100) {
                                                                            context
                                                                                .read<
                                                                                  QuantitiesCounterCubit
                                                                                >()
                                                                                .mealMinusHundred();
                                                                          }
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "-10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        if (counter[2] >=
                                                                            1) {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .mealMinusOne();
                                                                        }
                                                                      },
                                                                      icon: Icons
                                                                          .remove,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Expanded(
                                                                      child: Column(
                                                                        children: [
                                                                          Text(
                                                                            counter[2]
                                                                                .toString(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  30,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            "mealExhaustion"
                                                                                .tr(),
                                                                            style: TextStyle(
                                                                              fontSize:
                                                                                  11,
                                                                              fontWeight:
                                                                                  .bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    TransparentButton(
                                                                      onTap: () {
                                                                        context
                                                                            .read<
                                                                              QuantitiesCounterCubit
                                                                            >()
                                                                            .mealPlusOne();
                                                                      },
                                                                      icon: Icons
                                                                          .add,
                                                                      buttonHorizontalPading:
                                                                          0,
                                                                      isCircle:
                                                                          true,
                                                                      size: 14,
                                                                      buttonSize:
                                                                          16,
                                                                    ),
                                                                    Padding(
                                                                      padding:
                                                                          .only(
                                                                            left:
                                                                                30,
                                                                          ),
                                                                      child: TransparentButton(
                                                                        onTap: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .mealPlusTen();
                                                                        },
                                                                        onLongPress: () {
                                                                          context
                                                                              .read<
                                                                                QuantitiesCounterCubit
                                                                              >()
                                                                              .mealPlusHundred();
                                                                        },
                                                                        buttonWidget: Text(
                                                                          "+10",
                                                                          style: TextStyle(
                                                                            color:
                                                                                ThemingColors.primaryColor,
                                                                          ),
                                                                        ),
                                                                        buttonHorizontalPading:
                                                                            0,
                                                                        isCircle:
                                                                            true,
                                                                        size: 20,
                                                                        buttonSize:
                                                                            30,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding: .only(
                                                                  top: 15,
                                                                  bottom: 15,
                                                                ),
                                                                child: Directionality(
                                                                  textDirection:
                                                                      context
                                                                              .locale
                                                                              .languageCode ==
                                                                          'ar'
                                                                      ? ui
                                                                            .TextDirection
                                                                            .rtl
                                                                      : ui
                                                                            .TextDirection
                                                                            .ltr,
                                                                  child: Row(
                                                                    children: [
                                                                      (counter[0] !=
                                                                                  0 ||
                                                                              counter[1] !=
                                                                                  0 ||
                                                                              counter[2] !=
                                                                                  0)
                                                                          ? InkWell(
                                                                              hoverColor:
                                                                                  Colors.transparent,
                                                                              splashColor:
                                                                                  Colors.transparent,
                                                                              highlightColor:
                                                                                  Colors.transparent,
                                                                              onTap: () {
                                                                                Navigator.pop(
                                                                                  modalBottomSheetContext,
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
                                                                                  Icons.arrow_downward,
                                                                                  size: 18,
                                                                                  color: Colors.redAccent,
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
                                                                                    modalBottomSheetContext,
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
                                                                                    Icons.arrow_downward,
                                                                                    size: 18,
                                                                                    color: Colors.redAccent,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                      if (counter[0] !=
                                                                              0 ||
                                                                          counter[1] !=
                                                                              0 ||
                                                                          counter[2] !=
                                                                              0)
                                                                        Expanded(
                                                                          child: InkWell(
                                                                            hoverColor:
                                                                                Colors.transparent,
                                                                            splashColor:
                                                                                Colors.transparent,
                                                                            highlightColor:
                                                                                Colors.transparent,
                                                                            onTap: () async {
                                                                              Navigator.pop(
                                                                                modalBottomSheetContext,
                                                                              );
                                                                              controller.loading();
                                                                              await cubit.sell(
                                                                                soldQuantity:
                                                                                    counter[0] ==
                                                                                        0
                                                                                    ? null
                                                                                    : counter[0],
                                                                                notSoldQuantity:
                                                                                    counter[1] ==
                                                                                        0
                                                                                    ? null
                                                                                    : counter[1],
                                                                                mealWaste:
                                                                                    counter[2] ==
                                                                                        0
                                                                                    ? null
                                                                                    : counter[2],
                                                                                product: product,
                                                                              );
                                                                              controller.success();
                                                                              await Future.delayed(
                                                                                Duration(
                                                                                  seconds: 1,
                                                                                ),
                                                                              );
                                                                              controller.reset();
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
                                                                          ),
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    productName: product.productName,
                                    productId: product.productId ?? "",
                                    available: product.available,
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 17);
                                },
                                itemCount: workerState.products!.length,
                              ),
                            ],
                          ),
                        ),
                        WorkSheetTile(workerState: workerState),
                        ExpensesTile(workerState: workerState),
                      ],
                    );
                  }
                  return InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      cubit.frame();
                    },
                    child: Column(
                      mainAxisAlignment: .center,
                      children: [
                        FadedScreen(
                          size: 80,
                          icon: Icons.cell_tower,
                          text: "noInternet".tr(),
                        ),
                        Row(
                          mainAxisAlignment: .center,
                          mainAxisSize: .max,
                          children: [
                            Padding(
                              padding: context.locale.languageCode == "ar"
                                  ? .only(left: 5)
                                  : .only(right: 5),
                              child: Icon(
                                Icons.refresh,
                                size: 16,
                                color: ThemingColors.primaryColor,
                                fontWeight: .bold,
                              ),
                            ),
                            Text(
                              "tapToRetry".tr(),
                              style: TextStyle(fontSize: 10, fontWeight: .bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
