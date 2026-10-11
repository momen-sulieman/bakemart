import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../theming/theming_colors.dart';
import '../../../utils/enums/buckts.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../glass_card/glass_card.dart';
import '../supabase_image/ui/supabase_image.dart';

class ValueChangingDialog extends StatelessWidget {
  final bool valueOfProduct, inputValidity, addingAMeal;
  final String title;
  final String? wasteType, productId;
  final num oldValue;
  final TextEditingController? inputController;
  final TextEditingController? manufController;
  final TextEditingController? notSoldController;
  final TextEditingController? mealController;
  final Widget? mealWheelPicker;
  final ValueChanged<String> onChanged;
  final VoidCallback onTapCancel, onTapDone;

  const ValueChangingDialog({
    this.valueOfProduct = false,
    this.addingAMeal = false,
    required this.title,
    this.wasteType,
    this.productId,
    required this.oldValue,
    this.inputController,
    this.manufController,
    this.notSoldController,
    this.mealController,
    this.mealWheelPicker,
    required this.onChanged,
    required this.inputValidity,
    required this.onTapCancel,
    required this.onTapDone,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: .blur(
        sigmaX: context.isDark ? 5 : 7,
        sigmaY: context.isDark ? 5 : 7,
      ),
      child: AlertDialog(
        contentPadding: .symmetric(vertical: 35, horizontal: 15),
        titlePadding: .zero,
        actionsPadding: .only(bottom: 15, right: 15, left: 15),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(20),
          side: BorderSide(
            width: 0.2,
            color: context.isDark ? ThemingColors.white : ThemingColors.black,
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
                ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
                : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
            border: .all(
              width: 0.2,
              color: context.isDark ? ThemingColors.white : ThemingColors.black,
            ),
          ),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              if (addingAMeal)
                Text(
                  "addAProduct".tr(),
                  style: TextStyle(fontWeight: .bold, fontSize: 16),
                ),
              if (!valueOfProduct && !addingAMeal)
                Text(title, style: TextStyle(fontSize: 18)),
              if (valueOfProduct && !addingAMeal)
                Column(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: ThemingColors.primaryColor.withAlpha(
                        (0.4 * 255).toInt(),
                      ),
                      child: ClipOval(
                        child: SupabaseImageProvider(
                          filePath: Buckets.productsImages,
                          fileName: productId,
                          iconSize: 14,
                          loadingIconSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      title,
                      textAlign: .center,
                      style: TextStyle(fontWeight: .bold, fontSize: 16),
                    ),
                  ],
                ),
            ],
          ),
        ),
        content: (addingAMeal && mealWheelPicker != null)
            ? SizedBox(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 110,
                            width: 150,
                            padding: .symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: .circular(15),
                              color: context.isDark
                                  ? ThemingColors.black.withAlpha(
                                      (0.4 * 255).toInt(),
                                    )
                                  : ThemingColors.white.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                              border: Border.all(
                                width: 0.2,
                                color: context.isDark
                                    ? ThemingColors.white
                                    : ThemingColors.black,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: .center,
                              children: [
                                Padding(
                                  padding:context.locale.languageCode == "ar"? .only(left: 5): .only(right: 5),
                                  child: Icon(
                                    Icons.arrow_right,
                                    size: 25,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                                SizedBox(width: 110, child: mealWheelPicker),
                                Padding(
                                  padding: context.locale.languageCode == "ar"
                                      ? .only(right: 5)
                                      : .only(left: 5),
                                  child: Icon(
                                    Icons.arrow_left,
                                    size: 25,
                                    color: ThemingColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 110,
                            margin: .zero,
                            padding: .all(5),
                            decoration: BoxDecoration(
                              borderRadius: .circular(15),
                              color: context.isDark
                                  ? ThemingColors.black.withAlpha(
                                      (0.4 * 255).toInt(),
                                    )
                                  : ThemingColors.white.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                              border: Border.all(
                                width: 0.2,
                                color: context.isDark
                                    ? ThemingColors.white
                                    : ThemingColors.black,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    "manuf".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == "ar"
                                          ? 14
                                          : 12,
                                      color: ThemingColors.primaryColor
                                          .withAlpha((0.6 * 255).toInt()),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                TextFormField(
                                  controller: manufController,
                                  keyboardType: TextInputType.number,
                                  textAlign: .center,
                                  onTap: () {
                                    manufController?.text = "";
                                  },
                                  onChanged: onChanged,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: .symmetric(vertical: 2),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: context.isDark
                                            ? ThemingColors.white
                                            : ThemingColors.black,
                                        width: 0.1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
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
                                Spacer(),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: 110,
                            margin: .zero,
                            padding: .all(5),
                            decoration: BoxDecoration(
                              borderRadius: .circular(15),
                              color: context.isDark
                                  ? ThemingColors.black.withAlpha(
                                      (0.4 * 255).toInt(),
                                    )
                                  : ThemingColors.white.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                              border: Border.all(
                                width: 0.2,
                                color: context.isDark
                                    ? ThemingColors.white
                                    : ThemingColors.black,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    "notSold".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == "ar"
                                          ? 14
                                          : 12,
                                      color: ThemingColors.primaryColor
                                          .withAlpha((0.6 * 255).toInt()),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                TextFormField(
                                  controller: notSoldController,
                                  keyboardType: TextInputType.number,
                                  textAlign: .center,
                                  onTap: () {
                                    notSoldController?.text = "";
                                  },
                                  onChanged: onChanged,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: .symmetric(vertical: 2),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: context.isDark
                                            ? ThemingColors.white
                                            : ThemingColors.black,
                                        width: 0.1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
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
                                Spacer(),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: 110,
                            margin: .zero,
                            padding: .all(5),
                            decoration: BoxDecoration(
                              borderRadius: .circular(15),
                              color: context.isDark
                                  ? ThemingColors.black.withAlpha(
                                      (0.4 * 255).toInt(),
                                    )
                                  : ThemingColors.white.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                              border: Border.all(
                                width: 0.2,
                                color: context.isDark
                                    ? ThemingColors.white
                                    : ThemingColors.black,
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 20,
                                  child: Text(
                                    "meals".tr(),
                                    style: TextStyle(
                                      fontSize:
                                          context.locale.languageCode == "ar"
                                          ? 14
                                          : 12,
                                      color: ThemingColors.primaryColor
                                          .withAlpha((0.6 * 255).toInt()),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                TextFormField(
                                  controller: mealController,
                                  keyboardType: TextInputType.number,
                                  textAlign: .center,
                                  onTap: () {
                                    mealController?.text = "";
                                  },
                                  onChanged: onChanged,
                                  style: TextStyle(fontSize: 13),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: .symmetric(vertical: 2),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: BorderSide(
                                        color: context.isDark
                                            ? ThemingColors.white
                                            : ThemingColors.black,
                                        width: 0.1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
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
                                Spacer(),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : UnconstrainedBox(
                child: Container(
                  height: 110,
                  width: 100,
                  margin: .zero,
                  padding: .all(5),
                  decoration: BoxDecoration(
                    borderRadius: .circular(15),
                    color: context.isDark
                        ? ThemingColors.black.withAlpha((0.4 * 255).toInt())
                        : ThemingColors.white.withAlpha((0.4 * 255).toInt()),
                    border: Border.all(
                      width: 0.2,
                      color: context.isDark
                          ? ThemingColors.white
                          : ThemingColors.black,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                        child: Text(
                          wasteType != null ? wasteType! : "",
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemingColors.primaryColor.withAlpha(
                              (0.6 * 255).toInt(),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      TextFormField(
                        controller: inputController,
                        keyboardType: TextInputType.number,
                        textAlign: .center,
                        onChanged: onChanged,
                        onTap: (){
                          inputController?.text="";
                        },
                        style: TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: .symmetric(vertical: 2),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(
                              color: context.isDark
                                  ? ThemingColors.white
                                  : ThemingColors.black,
                              width: 0.1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
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
                      Spacer(),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
        actions: [
          Row(
            children: [
              inputValidity
                  ? InkWell(
                      hoverColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: onTapCancel,
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
                        onTap: onTapCancel,
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
              if (inputValidity)
                Expanded(
                  child: InkWell(
                    onTap: onTapDone,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: GlassCard(
                      margin: .symmetric(horizontal: 6),
                      padding: .symmetric(vertical: 2),
                      child: Icon(Icons.done, size: 18, color: Colors.green),
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
