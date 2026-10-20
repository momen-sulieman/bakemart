import 'dart:ui';

import 'package:bakemart/core/shared/models/product_model.dart';
import 'package:bakemart/core/shared/models/storage_model.dart';
import 'package:bakemart/core/shared/widgets/glass_card/glass_card.dart';
import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../../core/shared/cubits/location_cubit/location_cubit.dart';
import '../../../../../../../../core/shared/cubits/location_cubit/location_state.dart';
import '../../../../../../../../core/shared/models/bakery_model.dart';
import '../../../../../../../../core/shared/models/payroll_model.dart';
import '../../../../../../../../core/shared/widgets/location_picker_map/location_picker_map.dart';
import '../../../../../../../../core/shared/widgets/text_form_field/text_form_field.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/settings_cubit/settings_cubit.dart';
import '../../logic/settings_update_cubit/settings_update_cubit.dart';

class BranchesSettingsTile extends StatelessWidget {
  final List<BakeryModel> branches;

  const BranchesSettingsTile({required this.branches, super.key});

  void _showLocationDialog(BuildContext context, BakeryModel branch) {
    final SettingsUpdateCubit updateCubit = context.read<SettingsUpdateCubit>();
    final locationState = context.read<LocationCubit>().state;
    final double? liveLat = locationState is LocationUpdated
        ? locationState.lat
        : null;
    final double? liveLng = locationState is LocationUpdated
        ? locationState.lng
        : null;
    final double screenHeight = MediaQuery.of(context).size.height;
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              mainAxisAlignment: .center,
              children: [
                Text(
                  branch.branchName,
                  style: GoogleFonts.audiowide(
                    fontSize: 18,
                    fontWeight: .bold,
                    color: ThemingColors.primaryColor,
                  ),
                ),
                Container(
                  height: screenHeight * 0.6,
                  width: double.infinity,
                  margin: .symmetric(vertical: 30),
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.2 * 255).toInt(),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: LocationPickerMap.setter(
                    initialLat: branch.bakeryLat,
                    initialLng: branch.bakeryLng,
                    deviceLat: liveLat,
                    deviceLng: liveLng,
                    resetLat: branch.bakeryLat,
                    resetLng: branch.bakeryLng,
                    resetMarkerIcon: Icons.location_on_outlined,
                    alwaysShow: false,
                    hideWhenRecenter: false,
                    onSet: (lat, lng) {
                      updateCubit.changeBranchLocation(
                        branchId: branch.branchId,
                        lat: lat,
                        lng: lng,
                      );
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
                TransparentButton(
                  isCircle: true,
                  icon: Icons.done,
                  onTap: () {
                    Navigator.pop(dialogContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        return ExpansionTile(
          splashColor: Colors.transparent,
          initiallyExpanded: true,
          iconColor: ThemingColors.primaryColor,
          collapsedIconColor: ThemingColors.primaryColor,
          shape: RoundedRectangleBorder(side: .none),
          controlAffinity: ListTileControlAffinity.leading,
          onExpansionChanged: (expanded) {
            cubit.updateBranchesTileExpansion(expanded);
          },
          title: SizedBox(
            height: 53,
            child: Row(
              mainAxisAlignment: .start,
              children: [
                Text(
                  "branches".tr(),
                  style: TextStyle(fontWeight: .bold, fontSize: 18),
                ),
                Spacer(),
                cubit.isBranchesEditing
                    ? Container(
                        margin: .only(right: 10),
                        padding: .symmetric(horizontal: 5, vertical: 5),
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
                        child: InkWell(
                          hoverColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            cubit.branchesEditingMode(!cubit.isBranchesEditing);
                          },
                          child: Icon(
                            Icons.done,
                            size: 18,
                            color: Colors.green,
                          ),
                        ),
                      )
                    : cubit.isBranchesExpanded
                    ? Padding(
                        padding: .only(right: 10),
                        child: InkWell(
                          onTap: () {
                            cubit.branchesEditingMode(!cubit.isBranchesEditing);
                          },
                          child: Icon(Icons.edit),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
          children: [
            GlassCard(
              margin: .symmetric(horizontal: 25),
              padding: .symmetric(horizontal: 15, vertical: 5),
              radius: 20,
              otherRadius: 20,
              child: Column(
                children: [
                  ...branches.asMap().entries.map((entry) {
                    final int index = entry.key;
                    final BakeryModel branch = entry.value;
                    final bool isLast = index == branches.length - 1;
                    return Container(
                      padding: .symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : Border(
                                bottom: BorderSide(
                                  width: 0.5,
                                  color: ThemingColors.primaryColor.withAlpha(
                                    (0.2 * 255).toInt(),
                                  ),
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  branch.branchName,
                                  maxLines: 1,
                                  overflow: .ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: .bold,
                                  ),
                                ),
                                if (branch.branchNumber == 1)
                                  Padding(
                                    padding: .symmetric(horizontal: 7),
                                    child: Text(
                                      "main".tr(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.isDark
                                            ? Colors.cyanAccent
                                            : Colors.teal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          InkWell(
                            hoverColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              if (cubit.isBranchesEditing) {
                                _showLocationDialog(context, branch);
                              }
                            },
                            child: GlassCard(
                              margin: .zero,
                              padding: .symmetric(horizontal: 10, vertical: 3),
                              otherRadius: 30,
                              orange: cubit.isBranchesEditing,
                              dark: !cubit.isBranchesEditing,
                              child: Row(
                                mainAxisSize: .min,
                                mainAxisAlignment: .center,
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: ThemingColors.primaryColor,
                                    size: 18,
                                  ),
                                  Padding(
                                    padding: .symmetric(horizontal: 5),
                                    child: Text(
                                      "location".tr(),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: .bold,
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
                  }),
                  if (cubit.isBranchesEditing)
                    Padding(
                      padding: .only(top: 20, bottom: 10),
                      child: TransparentButton(
                        onTap: () {
                          final locationState = context
                              .read<LocationCubit>()
                              .state;
                          final double? liveLat =
                              locationState is LocationUpdated
                              ? locationState.lat
                              : null;
                          final double? liveLng =
                              locationState is LocationUpdated
                              ? locationState.lng
                              : null;
                          cubit.setNewBranchLocation(
                            lat: liveLat ?? cubit.bakeries[0].bakeryLat,
                            lng: liveLng ?? cubit.bakeries[0].bakeryLng,
                          );
                          showDialog(
                            barrierColor: Colors.transparent,
                            context: context,
                            builder: (dialogContext) {
                              final TextEditingController branchNameController =
                                  TextEditingController();
                              final double initialLat = cubit.newBranchLat;
                              final double initialLng = cubit.newBranchLng;
                              return BlocProvider.value(
                                value: context.read<SettingsCubit>(),
                                child: BlocBuilder<SettingsCubit, SettingsState>(
                                  builder: (context, workerDialoge) {
                                    return BackdropFilter(
                                      filter: .blur(
                                        sigmaX: context.isDark ? 5 : 7,
                                        sigmaY: context.isDark ? 5 : 7,
                                      ),
                                      child: AlertDialog(
                                        titlePadding: .only(
                                          top: 25,
                                          right: 25,
                                          left: 25,
                                        ),
                                        contentPadding: .symmetric(
                                          horizontal: 25,
                                          vertical: 20,
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
                                        backgroundColor: context.isDark
                                            ? ThemingColors.black.withAlpha(
                                                (0.2 * 255).toInt(),
                                              )
                                            : ThemingColors.black.withAlpha(
                                                (0.05 * 255).toInt(),
                                              ),
                                        title: Text(
                                          "addBranch".tr(),
                                          textAlign: .center,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        content: Column(
                                          mainAxisSize: .min,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: SizedBox(
                                                    height: 40,
                                                    child: CustomTextFormField(
                                                      "branchName".tr(),
                                                      controller:
                                                          branchNameController,
                                                      keyBoardType:
                                                          TextInputType.text,
                                                      onChanged: (text) {
                                                        cubit.setValidity(
                                                          newBranchFormValidityState:
                                                              text.isNotEmpty,
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Container(
                                                height: screenHeight * 0.4,
                                                width: double.infinity,
                                                margin: .only(
                                                  top: 20,
                                                  bottom: 20,
                                                ),
                                                clipBehavior: Clip.hardEdge,
                                                decoration: BoxDecoration(
                                                  color: ThemingColors
                                                      .primaryColor
                                                      .withAlpha(
                                                        (0.2 * 255).toInt(),
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: LocationPickerMap.setter(
                                                  initialLat: initialLat,
                                                  initialLng: initialLng,
                                                  deviceLat: liveLat,
                                                  deviceLng: liveLng,
                                                  alwaysShow: false,
                                                  alwaysShowPin: true,
                                                  independentButtons: true,
                                                  onSet: (lat, lng) {
                                                    cubit.setNewBranchLocation(
                                                      lat: lat,
                                                      lng: lng,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: "${"note".tr()}: ",
                                                    style:TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13,
                                                      color:context.isDark? Colors.amber:Colors.orange,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "newBranchNote".tr(),
                                                    style: TextStyle(
                                                      fontSize: 13
                                                    )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          Row(
                                            children: [
                                              cubit.newBranchFormValidity
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
                                                        cubit.setValidity(
                                                          newBranchFormValidityState:
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
                                              if (cubit.newBranchFormValidity)
                                                Expanded(
                                                  child: InkWell(
                                                    hoverColor:
                                                        Colors.transparent,
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      final BakeryModel
                                                      newBranchBakeryModel =
                                                          BakeryModel(
                                                            bakeryId: cubit
                                                                .bakeries[0]
                                                                .bakeryId,
                                                            bakeryName: cubit
                                                                .bakeries[0]
                                                                .bakeryName,
                                                            bakeryLat: cubit
                                                                .newBranchLat,
                                                            bakeryLng: cubit
                                                                .newBranchLng,
                                                            supervisorId: [],
                                                            branchId: "",
                                                            branchName:
                                                                branchNameController
                                                                    .text,
                                                            branchNumber:
                                                                cubit
                                                                    .bakeries
                                                                    .length +
                                                                1,
                                                          );
                                                      final String
                                                      mainBranchId = cubit
                                                          .bakeries[0]
                                                          .branchId;
                                                      final List<ProductModel>
                                                      newBranchProducts = cubit
                                                          .products
                                                          .where(
                                                            (product) =>
                                                                product
                                                                    .branchId ==
                                                                mainBranchId,
                                                          )
                                                          .toList();
                                                      final PayrollModel
                                                      newBranchPayroll =
                                                          cubit.payrolls[0];
                                                      final StorageModel
                                                      newBranchStorage =
                                                          StorageModel(
                                                            bakeryId: cubit
                                                                .bakeries[0]
                                                                .bakeryId,
                                                            branchId: "",
                                                          );
                                                      cubit.createNewBranch(
                                                        bakeryData:
                                                            newBranchBakeryModel,
                                                        products:
                                                            newBranchProducts,
                                                        payroll:
                                                            newBranchPayroll,
                                                        storage:
                                                            newBranchStorage,
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
        );
      },
    );
  }
}
