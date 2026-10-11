import 'dart:ui' as ui;

import 'package:action_slider/action_slider.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../theming/theming_colors.dart';
import '../../../utils/enums/buckts.dart';
import '../glass_card/glass_card.dart';
import '../supabase_image/ui/supabase_image.dart';

class ProductSlider extends StatelessWidget {
  final String productName,productId;
  final int available;
  final dynamic Function(ActionSliderController)? rightAction;
  final dynamic Function(ActionSliderController)? leftAction;

  const ProductSlider({
    required this.rightAction,
    required this.leftAction,
    required this.productName,
    required this.productId,
    required this.available,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: ActionSlider.dual(
        boxShadow: [],
        loadingIcon: Padding(
          padding: .only(left: 0),
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: ThemingColors.primaryColor,
            size: 20,
          ),
        ),
        successIcon: Icon(Icons.check_circle_outline, color: Colors.lightGreen),
        failureIcon: Icon(Icons.error_outline, color: Colors.redAccent),
        backgroundBorderRadius: .only(
          topLeft: .circular(30),
          bottomRight: .circular(30),
        ),
        foregroundBorderRadius: .only(
          topRight: .circular(30),
          bottomLeft: .circular(30),
        ),
        height: 45,
        toggleWidthCustom: 150,
        backgroundColor: context.isDark
            ? ThemingColors.white.withAlpha((0.1 * 255).toInt())
            : ThemingColors.black.withAlpha((0.07 * 255).toInt()),
        toggleColor: Colors.transparent,
        startChild: Padding(
          padding: .only(right: 50),
          child: Icon(
            Icons.remove,
            color: context.isDark
                ? Colors.redAccent.withAlpha((0.8 * 255).toInt())
                : Colors.redAccent.withAlpha((1 * 255).toInt()),
            size: 19,
            fontWeight: .bold,
          ),
        ),
        endChild: Padding(
          padding: .only(left: 50),
          child: Icon(
            Icons.add,
            color: context.isDark
                ? Colors.lightGreen.withAlpha((0.25 * 255).toInt())
                : Colors.lightGreen.withAlpha((1 * 255).toInt()),
            size: 19,
            fontWeight: .bold,
          ),
        ),
        borderWidth: 0,
        icon: SizedBox(
          width: double.infinity,
          child: GlassCard(
            margin: .zero,
            padding: .only(right: 10),
            child: Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  margin: .symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: ThemingColors.primaryColor.withAlpha(
                      (0.2 * 255).toInt(),
                    ),
                    borderRadius: .only(
                      topLeft: .circular(20),
                      bottomRight: .circular(10),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: .only(
                      topLeft: .circular(20),
                      bottomRight: .circular(10),
                    ),
                    child: SupabaseImageProvider(
                      filePath: Buckets.productsImages,
                      fileName: productId,
                      iconSize: 14,
                      loadingIconSize: 14,
                      cacheWidth: 75,
                      cacheHeight: 75,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: .center,
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                            productName,
                            style: TextStyle(fontSize: 11, fontWeight: .bold),
                            maxLines: 1,
                            overflow: .ellipsis,
                          ),
                    ),
                    Text(available.toString(),style: TextStyle(fontSize: 11, fontWeight: .bold))
                  ],
                )
                // Flexible(
                //   fit: .loose,
                //   child: Text(
                //     productName,
                //     style: TextStyle(fontSize: 11, fontWeight: .bold),
                //     maxLines: 1,
                //     textAlign: .center,
                //     overflow: .ellipsis,
                //   ),
                // ),
              ],
            ),
          ),
        ),
        startAction: leftAction,
        //     (controller) async {
        //   controller.loading(); //starts loading animation
        //   await Future.delayed(const Duration(seconds: 3));
        //   controller.success(); //starts success animation
        //   await Future.delayed(const Duration(seconds: 1));
        //   controller.reset(); //resets the slider
        // }
        endAction: rightAction,
        //     (controller) async {
        //   controller.loading(); //starts loading animation
        //   await Future.delayed(const Duration(seconds: 3));
        //   controller.failure(); //starts success animation
        //   await Future.delayed(const Duration(seconds: 1));
        //   controller.reset(); //resets the slider
        // },
      ),
    );
  }
}
