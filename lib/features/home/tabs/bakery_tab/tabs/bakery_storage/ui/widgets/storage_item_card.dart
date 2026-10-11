import 'dart:ui' as ui;

import 'package:bakemart/core/utils/enums/storage_items.dart';
import 'package:bakemart/core/utils/extensions/string_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../../../../../../core/shared/models/storage_helper.dart';
import '../../../../../../../../core/shared/models/storage_model.dart';
import '../../../../../../../../core/shared/widgets/glass_card/glass_card.dart';
import '../../../../../../../../core/theming/theming_colors.dart';
import '../../../../../../../../core/utils/extensions/context_extensions.dart';
import '../../logic/storage_cubit/storage_cubit.dart';

class StorageItemCard extends StatelessWidget {
  final StorageModel storage;
  final String itemName;
  final String itemUnit;
  final double itemUnitFactor;

  const StorageItemCard({
    required this.storage,
    required this.itemName,
    required this.itemUnit,
    required this.itemUnitFactor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int itemValue = StorageHelper.getItemValue(storage, itemName);
    final bool wheat = StorageHelper.isWheat(itemName);
    final String imagePath = StorageHelper.getItemImage(itemName);

    final itemPicture = DecorationImage(
      image: AssetImage(imagePath),
      fit: BoxFit.cover,
    );

    final bool isGreen = wheat ? (itemValue > 100000) : (itemValue > 10000);
    final Color statusColor = (isGreen ? Colors.greenAccent : Colors.redAccent)
        .withAlpha(((context.isDark ? 0.2 : 0.3) * 255).toInt());

    return SizedBox(
      width: screenWidth * 0.43,
      child: GlassCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              height: 110,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: itemPicture,
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Directionality(
                textDirection: context.locale.languageCode == 'ar'
                    ? ui.TextDirection.rtl
                    : ui.TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      itemName == StorageItems.eggs
                          ? itemValue.toString()
                          : (itemValue / itemUnitFactor).toStringAsFixed(
                              itemUnit == "g" ? 0 : 1,
                            ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: itemValue < 1 ? Colors.red : null,
                      ),
                    ),
                    const Text("  "),
                    Text(
                      itemName == StorageItems.eggs ? "eggs".tr() : itemUnit,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.isDark ? Colors.amber : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            GlassCard(
              margin: EdgeInsets.zero,
              padding: .symmetric(vertical: 7, horizontal: 5),
              green: isGreen,
              orange: !isGreen,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: .symmetric(horizontal: 10),
                      child: Text(
                        itemName.tr(),
                        textAlign: .center,
                        maxLines: 1,
                        overflow: .ellipsis,
                        style: TextStyle(fontWeight: .bold),
                      ),
                    ),
                  ),
                  InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () => _showAddDialog(
                      context,
                      statusColor,
                      isGreen,
                      itemPicture,
                    ),
                    child: GlassCard(
                      margin: EdgeInsets.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      radius: 30,
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: ThemingColors.primaryColor,
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

  void _showAddDialog(
    BuildContext context,
    Color statusColor,
    bool isGreen,
    DecorationImage itemPicture,
  ) {
    final StorageCubit storageCubitInstance = context.read<StorageCubit>();
    storageCubitInstance.inputValidityFalse();
    final TextEditingController inputController = TextEditingController();
    double inputUnitFactor = 1000;
    final List<String> units = [
      "storageGram".tr(),
      "storageKilogram".tr(),
      "storagePounds".tr(),
    ];

    showModalBottomSheet(
      context: context,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        final double keyboardHeight = MediaQuery.of(
          modalContext,
        ).viewInsets.bottom;
        return BlocProvider.value(
          value: storageCubitInstance,
          child: BlocBuilder<StorageCubit, StorageState>(
            builder: (context, state) {
              final storageCubit = context.read<StorageCubit>();
              final bool isValid =
                  state is StorageSucces && state.inputValidity;
              return AnimatedPadding(
                duration: const Duration(milliseconds: 100),
                curve: Curves.decelerate,
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: SingleChildScrollView(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaY: 20, sigmaX: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                        bottom: 40,
                        left: 20,
                        right: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border(
                          top: BorderSide(color: statusColor, width: 4),
                        ),
                        color: context.isDark
                            ? ThemingColors.black.withAlpha((0.2 * 255).toInt())
                            : ThemingColors.white.withAlpha(
                                (0.2 * 255).toInt(),
                              ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(vertical: 15),
                            padding: const EdgeInsets.only(top: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: statusColor,
                            ),
                          ),
                          Container(
                            height: 110,
                            width: MediaQuery.of(context).size.width * 0.36,
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                bottomRight: Radius.circular(30),
                              ),
                              image: itemPicture,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: GlassCard(
                                  margin: EdgeInsets.zero,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 30,
                                  ),
                                  green: isGreen,
                                  orange: !isGreen,
                                  child: Text(
                                    itemName.tr(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Container(
                            padding: const EdgeInsets.all(15),
                            width: 250,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: context.isDark
                                  ? ThemingColors.black.withAlpha(
                                      (0.2 * 255).toInt(),
                                    )
                                  : ThemingColors.black.withAlpha(
                                      (0.07 * 255).toInt(),
                                    ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: inputController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                    onChanged: (text) {
                                      final input = double.tryParse(
                                        text.toEnglishDigits(),
                                      );
                                      if (input != null && input > 0) {
                                        storageCubit.inputValidityTrue();
                                      } else {
                                        storageCubit.inputValidityFalse();
                                      }
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 2,
                                          ),
                                      filled: true,
                                      fillColor: context.isDark
                                          ? ThemingColors.black.withAlpha(
                                              (0.5 * 255).toInt(),
                                            )
                                          : ThemingColors.white.withAlpha(
                                              (0.5 * 255).toInt(),
                                            ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          color: context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black,
                                          width: 0.3,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        borderSide: BorderSide(
                                          color: context.isDark
                                              ? ThemingColors.white
                                              : ThemingColors.black,
                                          width: 0.3,
                                        ),
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_right,
                                  size: 20,
                                  color: context.isDark
                                      ? ThemingColors.white
                                      : ThemingColors.black,
                                ),
                                Container(
                                  height: 65,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      width: 0.3,
                                      color: context.isDark
                                          ? ThemingColors.white
                                          : ThemingColors.black,
                                    ),
                                    color: context.isDark
                                        ? ThemingColors.black.withAlpha(
                                            (0.5 * 255).toInt(),
                                          )
                                        : ThemingColors.white.withAlpha(
                                            (0.5 * 255).toInt(),
                                          ),
                                  ),
                                  child: WheelPicker(
                                    looping: false,
                                    controller: WheelPickerController(
                                      itemCount: 3,
                                      initialIndex: 1,
                                    ),
                                    style: WheelPickerStyle(
                                      itemExtent: 20,
                                      surroundingOpacity: context.isDark
                                          ? 0.4
                                          : 0.35,
                                      diameterRatio: 20,
                                    ),
                                    onIndexChanged: (index, _) {
                                      if (index == 0) {
                                        inputUnitFactor = 1;
                                      } else if (index == 1) {
                                        inputUnitFactor = 1000;
                                      } else {
                                        inputUnitFactor = 453.59237;
                                      }
                                    },
                                    builder: (context, index) => Center(
                                      child: Text(
                                        units[index].tr(),
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_left,
                                  size: 20,
                                  color: context.isDark
                                      ? ThemingColors.white
                                      : ThemingColors.black,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 250,
                            child: Row(
                              children: [
                                isValid
                                    ? InkWell(
                                        onTap: () =>
                                            Navigator.pop(modalContext),
                                        child: const GlassCard(
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 2,
                                            horizontal: 10,
                                          ),
                                          child: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: Colors.redAccent,
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: InkWell(
                                          onTap: () =>
                                              Navigator.pop(modalContext),
                                          child: const GlassCard(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                            padding: EdgeInsets.symmetric(
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
                                if (isValid)
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        final int input =
                                            int.tryParse(
                                              inputController.text
                                                  .toEnglishDigits(),
                                            ) ??
                                            0;
                                        final int inputToBeAdded =
                                            (input * inputUnitFactor).round();
                                        final updatedStorage =
                                            StorageHelper.updateItemValue(
                                              storage,
                                              itemName,
                                              inputToBeAdded,
                                            );
                                        storageCubit.addToStorage(
                                          updatedStorage,
                                        );
                                        Navigator.pop(modalContext);
                                      },
                                      child: const GlassCard(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        padding: EdgeInsets.symmetric(
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
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
