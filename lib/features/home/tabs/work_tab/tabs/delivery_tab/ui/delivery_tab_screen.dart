import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:bakemart/core/shared/functions/distance_calculator.dart';
import 'package:bakemart/core/shared/widgets/faded_screen/faded_screen.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/accepted_orders_list_tile.dart';
import 'package:bakemart/features/home/tabs/work_tab/tabs/delivery_tab/ui/widgets/orders_list_tile.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../core/services/location_services.dart';
import '../../../../../../../core/shared/widgets/supabase_image/ui/supabase_image.dart';
import '../../../../../../../core/utils/constants/constant_images.dart';
import '../../../../../../../core/utils/enums/buckts.dart';
import '../logic/delivery_cubit/delivery_cubit.dart';

class DeliveryTabScreen extends StatelessWidget {
  const DeliveryTabScreen({super.key});

  String _locationIssueMessage(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return "locationServicesOff".tr();
      case LocationFailureReason.permissionDeniedForever:
        return "locationPermissionBlocked".tr();
      case LocationFailureReason.permissionDenied:
        return "locationPermissionNeeded".tr();
      case LocationFailureReason.timedOut:
      case LocationFailureReason.unknown:
        return "waitingForLocation".tr();
    }
  }

  String _locationIssueActionText(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return "openLocationSettings".tr();
      case LocationFailureReason.permissionDeniedForever:
        return "openAppSettings".tr();
      case LocationFailureReason.permissionDenied:
        return "grantPermission".tr();
      case LocationFailureReason.timedOut:
      case LocationFailureReason.unknown:
        return "retry".tr();
    }
  }

  IconData _locationIssueIcon(LocationFailureReason reason) {
    switch (reason) {
      case LocationFailureReason.serviceDisabled:
        return Icons.location_off;
      case LocationFailureReason.permissionDeniedForever:
        return Icons.settings;
      case LocationFailureReason.permissionDenied:
        return Icons.location_disabled;
      case LocationFailureReason.timedOut:
      case LocationFailureReason.unknown:
        return Icons.location_searching;
    }
  }

  void _handleReceivingToggle(
    BuildContext context,
    DeliveryCubit cubit,
    bool value,
  ) {
    if (!value || cubit.user.verified) {
      cubit.toggleReceiving();
      return;
    }

    if (cubit.user.pending) {
      _showPendingDialog(context);
      return;
    }

    _showVerifyPromptDialog(context, cubit);
  }

  void _showPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          titlePadding: .only(left: 15, right: 15, top: 15),
          contentPadding: .symmetric(horizontal: 15, vertical: 50),
          actionsPadding: .only(left: 20, right: 20, bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: .circular(20),
            side: BorderSide(
              width: 0.3,
              color: context.isDark
                  ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
                  : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          backgroundColor: context.isDark
              ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
              : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
          title: Text("pending".tr(),textAlign: .center,),
          content: Text("verificationPendingMessage".tr(),textAlign: .center,),
          actions: [
            SizedBox(
              width: double.infinity,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () => Navigator.pop(context),
                child: GlassCard(
                  margin: .zero,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: ThemingColors.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showVerifyPromptDialog(BuildContext context, DeliveryCubit cubit) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          titlePadding: .only(left: 15, right: 15, top: 15),
          contentPadding: .symmetric(horizontal: 15, vertical: 50),
          actionsPadding: .only(left: 20, right: 20, bottom: 20),
          shape: RoundedRectangleBorder(
            borderRadius: .circular(20),
            side: BorderSide(
              width: 0.3,
              color: context.isDark
                  ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
                  : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
            ),
          ),
          backgroundColor: context.isDark
              ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
              : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
          title: Text("verifyYourselfTitle".tr(), textAlign: .center),
          content: Text("verifyYourselfMessage".tr(), textAlign: .center),
          actions: [
            Row(
              children: [
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () => Navigator.pop(dialogContext),
                  child: SizedBox(
                    height: 25,
                    child: GlassCard(
                      margin: .zero,
                      padding: .symmetric(vertical: 2, horizontal: 15),
                      child: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: ThemingColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      Navigator.pop(dialogContext);
                      _showCaptureDialog(context, cubit);
                    },
                    child: SizedBox(
                      height: 25,
                      child: GlassCard(
                        margin: .zero,
                        padding: .zero,
                        child: Center(
                          child: Text(
                            "verify".tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: .bold,
                              color: context.isDark
                                  ? Colors.greenAccent
                                  : Colors.green,
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
        ),
      ),
    );
  }

  void _showCaptureDialog(BuildContext context, DeliveryCubit cubit) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => _VerificationCaptureDialog(cubit: cubit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final List<int> rangeOptions = List.generate(20, (index) => index + 1);
    final cubit = context.read<DeliveryCubit>();
    return _ActionSnackbarListener(
      cubit: cubit,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: context.isDark
              ? ThemingColors.black.withAlpha((0.7 * 255).toInt())
              : ThemingColors.white.withAlpha((0.8 * 255).toInt()),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(20),
            child: Container(
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
              child: BlocBuilder<DeliveryCubit, DeliveryState>(
                builder: (context, state) {
                  final cubit = context.read<DeliveryCubit>();
                  return Container(
                    height: 70,
                    padding: .only(bottom: 10),
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Directionality(
                      textDirection: context.locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: context.locale.languageCode == 'ar'
                                    ? .only(right: 25, left: 10)
                                    : .only(left: 25, right: 10),
                                child: Text(
                                  "receiveOrders".tr(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: .bold,
                                  ),
                                ),
                              ),
                              Switch(
                                activeThumbColor: context.isDark
                                    ? ThemingColors.darkGrey
                                    : ThemingColors.lightGrey,
                                activeTrackColor: ThemingColors.primaryColor,
                                inactiveThumbColor: context.isDark
                                    ? ThemingColors.darkGrey
                                    : ThemingColors.darkGrey.withAlpha(
                                        (0.2 * 255).toInt(),
                                      ),
                                inactiveTrackColor: context.isDark
                                    ? ThemingColors.lightGrey.withAlpha(
                                        (0.4 * 255).toInt(),
                                      )
                                    : ThemingColors.darkGrey.withAlpha(
                                        (0.02 * 255).toInt(),
                                      ),
                                value: context
                                    .watch<DeliveryCubit>()
                                    .isReceiving,
                                onChanged: (value) {
                                  _handleReceivingToggle(context, cubit, value);
                                },
                              ),
                            ],
                          ),
                          if (context.watch<DeliveryCubit>().isReceiving)
                            Row(
                              spacing: 5,
                              children: [
                                Text(
                                  "range".tr(),
                                  style: TextStyle(
                                    fontSize:
                                        context.locale.languageCode == 'ar'
                                        ? 13
                                        : 12,
                                    fontWeight: .bold,
                                  ),
                                ),
                                SizedBox(
                                  width: 35,
                                  child: WheelPicker(
                                    controller: WheelPickerController(
                                      itemCount: rangeOptions.length,
                                      initialIndex: rangeOptions
                                          .indexOf(cubit.range)
                                          .clamp(0, rangeOptions.length - 1),
                                    ),
                                    looping: false,
                                    style: WheelPickerStyle(
                                      itemExtent: 22,
                                      surroundingOpacity: 0.5,
                                      magnification: 1.4,
                                      squeeze: 0.9,
                                      diameterRatio: 3,
                                    ),
                                    onIndexChanged: (index, _) {
                                      cubit.updateRange(rangeOptions[index]);
                                    },
                                    builder: (context, index) {
                                      return Center(
                                        child: Text(
                                          "${rangeOptions[index]}",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: ThemingColors.primaryColor,
                                            fontWeight: .bold,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: context.locale.languageCode == 'ar'
                                      ? .only(left: 30)
                                      : .only(right: 30),
                                  child: Text(
                                    "km".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == 'ar'
                                          ? 13
                                          : 12,
                                      fontWeight: .bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Padding(
                              padding: .symmetric(horizontal: 25),
                              child: Row(
                                children: [
                                  Text(
                                    cubit.user.pending
                                        ? "pending".tr()
                                        : cubit.user.verified
                                        ? "verified".tr()
                                        : "notVerified".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == "ar"
                                          ? 12
                                          : 11,
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
                                  SizedBox(width: 10),
                                  Icon(
                                    cubit.user.pending
                                        ? Icons.hourglass_top
                                        : cubit.user.verified
                                        ? Icons.verified
                                        : Icons.verified,
                                    size: 15,
                                    color: cubit.user.pending
                                        ? context.isDark
                                              ? Colors.blueGrey
                                              : Colors.grey
                                        : cubit.user.verified
                                        ? context.isDark
                                              ? Colors.greenAccent
                                              : Colors.green
                                        : Colors.redAccent,
                                  ),
                                ],
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
          height: screenHeight + 100,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                context.isDark
                    ? ConstantImages.darkBackground
                    : ConstantImages.lightBackground,
              ),
              fit: BoxFit.cover,
              opacity: context.isDark ? 0.4 : 0.3,
            ),
          ),
          clipBehavior: Clip.hardEdge,
          child: Directionality(
            textDirection: context.locale.languageCode == 'ar'
                ? ui.TextDirection.rtl
                : ui.TextDirection.ltr,
            child: BlocBuilder<DeliveryCubit, DeliveryState>(
              builder: (context, deliveryState) {
                if (deliveryState is Failure) {
                  return Center(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        cubit.initCubit(loading: true);
                      },
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          FadedScreen(
                            size: 90,
                            icon: Icons.error_outline,
                            text: deliveryState.error,
                          ),
                          Row(
                            mainAxisAlignment: .center,
                            children: [
                              Padding(
                                padding: .symmetric(horizontal: 5),
                                child: Icon(
                                  Icons.refresh,
                                  color: ThemingColors.primaryColor,
                                ),
                              ),
                              Text(
                                "tapToRetry".tr(),
                                style: TextStyle(
                                  color: ThemingColors.primaryColor,
                                  fontWeight: .bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (deliveryState is WaitingForLocation) {
                  final reason = deliveryState.reason;
                  return Center(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () => cubit.fixLocationIssue(reason),
                      child: Column(
                        mainAxisAlignment: .center,
                        children: [
                          FadedScreen(
                            size: 90,
                            icon: _locationIssueIcon(reason),
                            text: _locationIssueMessage(reason),
                          ),
                          Row(
                            mainAxisAlignment: .center,
                            children: [
                              Padding(
                                padding: .symmetric(horizontal: 5),
                                child: Icon(
                                  Icons.build_outlined,
                                  color: ThemingColors.primaryColor,
                                ),
                              ),
                              Text(
                                _locationIssueActionText(reason),
                                style: TextStyle(
                                  color: ThemingColors.primaryColor,
                                  fontWeight: .bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (deliveryState is NotReceiving) {
                  return Padding(
                    padding: .only(top: 195, bottom: 130),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (cubit.acceptedOrders.isNotEmpty)
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 15,
                                        bottom: 15,
                                      ),
                                      child: Text(
                                        "acceptedOrders".tr(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 15,
                                        left: 15,
                                        top: 15,
                                        bottom: 10,
                                      ),
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
                                                filter: .blur(
                                                  sigmaY: 5,
                                                  sigmaX: 5,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment: .center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: .end,
                                                      children: [
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: TransparentButton(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                  dialogContext,
                                                                ),
                                                            buttonHorizontalPading:
                                                                40,
                                                            icon: Icons.close,
                                                            isCircle: true,
                                                            size: 22,
                                                            buttonSize: 25,
                                                            color: Colors
                                                                .redAccent,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    AlertDialog(
                                                      insetPadding: .zero,
                                                      backgroundColor:
                                                          context.isDark
                                                          ? ThemingColors
                                                                .darkGrey
                                                          : ThemingColors
                                                                .lightGrey,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        side: BorderSide(
                                                          color: context.isDark
                                                              ? ThemingColors
                                                                    .lightGrey
                                                              : ThemingColors
                                                                    .black,
                                                          width: context.isDark
                                                              ? 0.2
                                                              : 0.3,
                                                        ),
                                                      ),
                                                      title: Column(
                                                        children: [
                                                          Container(
                                                            height: 40,
                                                            width: 40,
                                                            margin: .only(
                                                              bottom: 10,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: ThemingColors
                                                                  .primaryColor
                                                                  .withAlpha(
                                                                    (0.3 * 255)
                                                                        .toInt(),
                                                                  ),
                                                              borderRadius:
                                                                  .circular(3),
                                                            ),
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: SupabaseImageProvider(
                                                                filePath: Buckets
                                                                    .usersImages,
                                                                fileName: cubit
                                                                    .user
                                                                    .id,
                                                                person: true,
                                                                iconSize: 16,
                                                                loadingIconSize:
                                                                    14,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            "${cubit.user.firstName} ${cubit.user.secondName}",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    10,
                                                                  ),
                                                              margin: .only(
                                                                bottom: 10,
                                                              ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          15,
                                                                        ),
                                                                  ),
                                                              child: SizedBox(
                                                                width: 200,
                                                                height: 200,
                                                                child: QrImageView(
                                                                  data:
                                                                      cubit
                                                                          .user
                                                                          .id ??
                                                                      "",
                                                                  version:
                                                                      QrVersions
                                                                          .auto,
                                                                  size: 200.0,
                                                                  eyeStyle: const QrEyeStyle(
                                                                    eyeShape:
                                                                        QrEyeShape
                                                                            .square,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                  dataModuleStyle: const QrDataModuleStyle(
                                                                    dataModuleShape:
                                                                        QrDataModuleShape
                                                                            .square,
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                              "deliveryScanningLabel"
                                                                  .tr(),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    .bold,
                                                                color:
                                                                    context
                                                                        .isDark
                                                                    ? Colors
                                                                          .blueGrey
                                                                    : Colors
                                                                          .grey,
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
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: .symmetric(
                                                horizontal: 10,
                                              ),
                                              child: Text(
                                                "pickupAnOrder".tr(),
                                                style: TextStyle(
                                                  fontSize:
                                                      context
                                                              .locale
                                                              .languageCode ==
                                                          "ar"
                                                      ? 11
                                                      : 10,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.qr_code_2,
                                              size: 27,
                                              color: ThemingColors.primaryColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (_, index) {
                                    final order = cubit.acceptedOrders[index];
                                    if (cubit.driverLat == null ||
                                        cubit.driverLng == null) {
                                      return const SizedBox();
                                    }
                                    final routeDistance =
                                        calculateOptimizedDeliveryRouteDistance(
                                          order: order,
                                          deliveryManLat: cubit.driverLat!,
                                          deliveryManLng: cubit.driverLng!,
                                        ) /
                                        1000;
                                    return AcceptedOrdersListTile(
                                      order: order,
                                      routeDistance: routeDistance,
                                      onCancel: () => cubit.changeOrderStatus(
                                        orderId: order.orderId!,
                                        delivered: false,
                                      ),
                                      onDelivered: () =>
                                          cubit.changeOrderStatus(
                                            orderId: order.orderId!,
                                            delivered: true,
                                          ),
                                    );
                                  },
                                  separatorBuilder: (_, _) => const SizedBox(),
                                  itemCount: cubit.acceptedOrders.length,
                                ),
                              ],
                            ),
                          Center(
                            child: Padding(
                              padding: .only(
                                top: cubit.acceptedOrders.isNotEmpty
                                    ? 10
                                    : screenHeight * 0.2,
                              ),
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  _handleReceivingToggle(context, cubit, true);
                                },
                                child: FadedScreen(
                                  size: 90,
                                  icon: Icons.toggle_off_outlined,
                                  text: "receivingOff".tr(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (deliveryState is Loading) {
                  return Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: ThemingColors.primaryColor,
                      size: 25,
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: .only(top: 195, bottom: 130),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisSize: .max,
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Padding(
                            padding: .only(
                              left: 15,
                              right: 15,
                              top: 15,
                              bottom: 15,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "acceptedOrders".tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: .bold,
                                  ),
                                ),
                                Padding(
                                  padding: .only(left: 10, right: 10),
                                  child: Text(
                                    "${cubit.acceptedOrders.length}/5",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: .only(
                              right: 15,
                              left: 15,
                              top: 15,
                              bottom: 10,
                            ),
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
                                      child: Directionality(
                                        textDirection: ui.TextDirection.ltr,
                                        child: Column(
                                          mainAxisAlignment: .center,
                                          children: [
                                            Row(
                                              mainAxisAlignment: .end,
                                              children: [
                                                Material(
                                                  color: Colors.transparent,
                                                  child: TransparentButton(
                                                    onTap: () => Navigator.pop(
                                                      dialogContext,
                                                    ),
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
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: context.isDark
                                                      ? ThemingColors.lightGrey
                                                      : ThemingColors.black,
                                                  width: context.isDark
                                                      ? 0.2
                                                      : 0.3,
                                                ),
                                              ),
                                              title: Column(
                                                children: [
                                                  Container(
                                                    height: 40,
                                                    width: 40,
                                                    margin: .only(bottom: 10),
                                                    decoration: BoxDecoration(
                                                      color: ThemingColors
                                                          .primaryColor
                                                          .withAlpha(
                                                            (0.3 * 255).toInt(),
                                                          ),
                                                      borderRadius: .circular(
                                                        3,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      child:
                                                          SupabaseImageProvider(
                                                            filePath: Buckets
                                                                .usersImages,
                                                            fileName:
                                                                cubit.user.id,
                                                            person: true,
                                                            iconSize: 16,
                                                            loadingIconSize: 14,
                                                            cacheWidth: 120,
                                                            cacheHeight: 120,
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                    "${cubit.user.firstName} ${cubit.user.secondName}",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            10,
                                                          ),
                                                      margin: .only(bottom: 10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              15,
                                                            ),
                                                      ),
                                                      child: SizedBox(
                                                        width: 200,
                                                        height: 200,
                                                        child: QrImageView(
                                                          data:
                                                              cubit.user.id ??
                                                              "",
                                                          version:
                                                              QrVersions.auto,
                                                          size: 200.0,
                                                          eyeStyle:
                                                              const QrEyeStyle(
                                                                eyeShape:
                                                                    QrEyeShape
                                                                        .square,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                          dataModuleStyle:
                                                              const QrDataModuleStyle(
                                                                dataModuleShape:
                                                                    QrDataModuleShape
                                                                        .square,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      "deliveryScanningLabel"
                                                          .tr(),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: 12,
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
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  Padding(
                                    padding: .symmetric(horizontal: 10),
                                    child: Text(
                                      "pickupAnOrder".tr(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.qr_code_2,
                                    size: 27,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (deliveryState is Loading)
                        GlassCard(
                          green: true,
                          margin: .all(30),
                          padding: .symmetric(vertical: 15),
                          child: SizedBox(
                            width: double.infinity,
                            child: Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: ThemingColors.primaryColor,
                                size: 25,
                              ),
                            ),
                          ),
                        ),
                      if (deliveryState is Receiving)
                        cubit.acceptedOrders.isEmpty
                            ? Center(
                                child: SizedBox(
                                  width: 300,
                                  child: GlassCard(
                                    margin: .zero,
                                    padding: .symmetric(vertical: 20),
                                    otherRadius: 20,
                                    radius: 100,
                                    child: Text(
                                      "noAcceptedOrder".tr(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: context.isDark
                                            ? Colors.green.withAlpha(
                                                (0.4 * 255).toInt(),
                                              )
                                            : Colors.green.withAlpha(
                                                (0.8 * 255).toInt(),
                                              ),
                                        fontWeight: .bold,
                                      ),
                                      textAlign: .center,
                                    ),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: .zero,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (_, index) {
                                  if (cubit.driverLat == null ||
                                      cubit.driverLng == null) {
                                    return SizedBox();
                                  }
                                  final order = cubit.acceptedOrders[index];
                                  final routeDistance =
                                      calculateOptimizedDeliveryRouteDistance(
                                        order: order,
                                        deliveryManLat: cubit.driverLat!,
                                        deliveryManLng: cubit.driverLng!,
                                      ) /
                                      1000;
                                  return AcceptedOrdersListTile(
                                    order: order,
                                    routeDistance: routeDistance,
                                    onCancel: () => cubit.changeOrderStatus(
                                      orderId: order.orderId!,
                                      delivered: false,
                                    ),
                                    onDelivered: () => cubit.changeOrderStatus(
                                      orderId: order.orderId!,
                                      delivered: true,
                                    ),
                                  );
                                },
                                separatorBuilder: (_, _) {
                                  return SizedBox();
                                },
                                itemCount: cubit.acceptedOrders.length,
                              ),
                      Padding(
                        padding: .symmetric(horizontal: 15, vertical: 15),
                        child: Text(
                          "nearbyOrders".tr(),
                          style: TextStyle(fontSize: 18, fontWeight: .bold),
                        ),
                      ),
                      (deliveryState is Loading)
                          ? Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: ThemingColors.primaryColor,
                                size: 25,
                              ),
                            )
                          : cubit.acceptedOrders.length >= 5
                          ? Center(
                              child: Column(
                                children: [
                                  FadedScreen(
                                    size: 30,
                                    icon: Icons.pan_tool_outlined,
                                    text: "limitReached".tr(),
                                    padding: 10,
                                    iconColor: Colors.redAccent,
                                    textColor: Colors.redAccent,
                                    iconDarkFade: 1,
                                    iconLightFade: 1,
                                  ),
                                  Text(
                                    "deliverAnOrder".tr(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.isDark
                                          ? ThemingColors.white
                                          : ThemingColors.black,
                                    ),
                                  ),
                                  SizedBox(height: 40),
                                ],
                              ),
                            )
                          : StreamBuilder(
                              stream: cubit.liveNearbyOrders,
                              builder: (context, asyncSnapshot) {
                                final ordersSnapshot = asyncSnapshot.data;
                                if (ordersSnapshot == null) {
                                  return Center(
                                    child:
                                        LoadingAnimationWidget.staggeredDotsWave(
                                          color: ThemingColors.primaryColor,
                                          size: 25,
                                        ),
                                  );
                                }
                                if (ordersSnapshot.isEmpty) {
                                  return Center(
                                    child: SizedBox(
                                      width: 300,
                                      child: GlassCard(
                                        margin: .zero,
                                        padding: .symmetric(vertical: 20),
                                        radius: 100,
                                        otherRadius: 20,
                                        child: Text(
                                          "noNearbyOrder".tr(),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: context.isDark
                                                ? ThemingColors.white.withAlpha(
                                                    (0.4 * 255).toInt(),
                                                  )
                                                : ThemingColors.black.withAlpha(
                                                    (0.4 * 255).toInt(),
                                                  ),
                                            fontWeight: .bold,
                                          ),
                                          textAlign: .center,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return ListView.separated(
                                  shrinkWrap: true,
                                  padding: .zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: ordersSnapshot.length,
                                  itemBuilder: (_, index) {
                                    if (cubit.driverLat == null ||
                                        cubit.driverLng == null) {
                                      return SizedBox();
                                    }
                                    final order = ordersSnapshot[index];
                                    final routeDistance =
                                        calculateOptimizedDeliveryRouteDistance(
                                          order: order,
                                          deliveryManLat: cubit.driverLat!,
                                          deliveryManLng: cubit.driverLng!,
                                        ) /
                                        1000;
                                    return OrdersListTile(
                                      order: order,
                                      routeDistance: routeDistance,
                                      onAccept: () => cubit.acceptOrder(
                                        orderId: order.orderId!,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (_, _) {
                                    return SizedBox();
                                  },
                                );
                              },
                            ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSnackbarListener extends StatelessWidget {
  final DeliveryCubit cubit;
  final Widget child;

  const _ActionSnackbarListener({required this.cubit, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamListener<DeliveryActionResult>(
      stream: cubit.actionResults,
      onData: (result) => _showSnackBar(context, result),
      child: child,
    );
  }

  void _showSnackBar(BuildContext context, DeliveryActionResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GlassCard(
              margin: EdgeInsets.zero,
              padding: context.locale.languageCode == "ar"
                  ? .only(top: 3, bottom: 3, right: 3, left: 20)
                  : .only(top: 3, bottom: 3, left: 3, right: 20),
              otherRadius: 30,
              green: result.success,
              orange: !result.success,
              child: Row(
                children: [
                  Padding(
                    padding: context.locale.languageCode == "ar"
                        ? .only(left: 10)
                        : .only(right: 10),
                    child: SizedBox(
                      height: 30,
                      width: 30,
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        otherRadius: 30,
                        dark: true,
                        child: Icon(
                          (result.type == DeliveryActionType.accept)
                              ? Icons.done
                              : (result.type == DeliveryActionType.deliver)
                              ? Icons.done_all
                              : (result.type == DeliveryActionType.verify)
                              ? Icons.verified
                              : Icons.close,
                          size: 16,
                          fontWeight: (result.type == DeliveryActionType.accept)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: (result.type == DeliveryActionType.accept)
                              ? Colors.greenAccent
                              : (result.type == DeliveryActionType.deliver)
                              ? Colors.blue
                              : (result.type == DeliveryActionType.verify)
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  result.success
                      ? Text(
                          result.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: context.isDark
                                ? ThemingColors.white
                                : ThemingColors.black,
                          ),
                        )
                      : SizedBox(
                          width: 150,
                          child: Text(
                            result.message,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: context.isDark
                                  ? ThemingColors.white
                                  : ThemingColors.black,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreamListener<T> extends StatefulWidget {
  final Stream<T> stream;
  final ValueChanged<T> onData;
  final Widget child;

  const StreamListener({
    super.key,
    required this.stream,
    required this.onData,
    required this.child,
  });

  @override
  State<StreamListener<T>> createState() => _StreamListenerState<T>();
}

class _StreamListenerState<T> extends State<StreamListener<T>> {
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

class _VerificationCaptureDialog extends StatefulWidget {
  final DeliveryCubit cubit;

  const _VerificationCaptureDialog({required this.cubit});

  @override
  State<_VerificationCaptureDialog> createState() =>
      _VerificationCaptureDialogState();
}

class _VerificationCaptureDialogState
    extends State<_VerificationCaptureDialog> {
  File? _faceImage;
  File? _idImage;
  bool _submitting = false;

  bool get _bothCaptured => _faceImage != null && _idImage != null;

  Future<void> _capture({required bool isFace}) async {
    final XFile? picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: isFace ? CameraDevice.front : CameraDevice.rear,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      if (isFace) {
        _faceImage = File(picked.path);
      } else {
        _idImage = File(picked.path);
      }
    });
  }

  Future<void> _onDone() async {
    if (_faceImage == null || _idImage == null || _submitting) return;
    setState(() => _submitting = true);

    final success = await widget.cubit.submitVerification(
      faceImage: _faceImage!,
      idImage: _idImage!,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
    }
  }

  Widget _captureButton({
    required bool isFace,
    required File? image,
    required String label,
  }) {
    final captured = image != null;
    return Expanded(
      child: InkWell(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: _submitting ? null : () => _capture(isFace: isFace),
        child: GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          otherRadius: 5,
          orange: !captured,
          green: captured,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                (isFace ? Icons.face_retouching_natural : Icons.badge),
                color: ThemingColors.primaryColor,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: AlertDialog(
        titlePadding: .only(left: 15, right: 15, top: 15),
        contentPadding: .symmetric(horizontal: 10, vertical: 40),
        actionsPadding: .only(left: 20, right: 20, bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(20),
          side: BorderSide(
            width: 0.3,
            color: context.isDark
                ? ThemingColors.white.withAlpha((0.4 * 255).toInt())
                : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
          ),
        ),
        backgroundColor: context.isDark
            ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
            : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
        title: Text("verificationPhotosTitle".tr(), textAlign: .center),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "verificationPhotosMessage".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _captureButton(
                    isFace: true,
                    image: _faceImage,
                    label: "captureFacePhoto".tr(),
                  ),
                  _captureButton(
                    isFace: false,
                    image: _idImage,
                    label: "captureIdPhoto".tr(),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          if (!_bothCaptured)
            SizedBox(
              width: double.infinity,
              height: 25,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: _submitting ? null : () => Navigator.pop(context),
                child: GlassCard(
                  margin: .zero,
                  padding:.zero,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      size: 18,
                      color: ThemingColors.primaryColor,
                    ),
                  ),
                ),
              ),
            )
          else
            Row(
              children: [
                InkWell(
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: _submitting ? null : () => Navigator.pop(context),
                  child: SizedBox(
                    height: 25,
                    child: GlassCard(
                      margin: .zero,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          size: 18,
                          color: ThemingColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: _submitting ? null : _onDone,
                    child: SizedBox(
                      height: 25,
                      child: GlassCard(
                        margin: EdgeInsets.zero,
                        padding: .zero,
                        child: Center(
                          child: _submitting
                              ? LoadingAnimationWidget.staggeredDotsWave(
                                color: context.isDark
                                    ? Colors.greenAccent
                                    : Colors.green,
                                size: 16,
                              )
                              : Icon(
                                  Icons.done,
                                  size: 18,
                                  color: context.isDark
                                      ? Colors.greenAccent
                                      : Colors.green,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
