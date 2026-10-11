import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../theming/theming_colors.dart';
import '../../../utils/extensions/context_extensions.dart';

class TransparentButton extends StatelessWidget {
  final void Function()? onTap,onLongPress;
  final IconData? icon;
  final double? size,buttonSize;
  final Widget? buttonWidget;
  final double sigmaX,
      sigmaY,
      horizontalPadding,
      verticalPadding,
      buttonHorizontalPading,
      lightAlpha,
      darkAlpha;
  final Color color;
  final bool isCircle;

  const TransparentButton({
    required this.onTap,
    this.onLongPress,
    this.icon,
    this.buttonWidget,
    this.horizontalPadding = 15,
    this.verticalPadding = 7,
    this.buttonHorizontalPading = 20,
    this.size = 30,
    this.buttonSize = 30,
    this.sigmaX = 2,
    this.sigmaY = 2,
    this.lightAlpha = 0.08,
    this.darkAlpha = 0.1,
    this.color = ThemingColors.primaryColor,
    this.isCircle = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double diameter = (buttonSize ?? 30) + 10;
    return Padding(
      padding: .symmetric(horizontal: buttonHorizontalPading),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
            child: Container(
              width: isCircle ? diameter : null,
              height: isCircle ? diameter : null,
              padding: isCircle
                  ? .zero
                  : .symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding,
                    ),
              decoration: BoxDecoration(
                color: context.isDark
                    ? ThemingColors.white.withAlpha((darkAlpha * 255).toInt())
                    : ThemingColors.black.withAlpha((lightAlpha * 255).toInt()),
                borderRadius: isCircle ? null : BorderRadius.circular(25),
                border: Border.all(
                  color: (context.isDark ? Colors.white : Colors.black)
                      .withAlpha((0.1 * 255).toInt()),
                  width: 2,
                ),
                shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              ),
              alignment: .center,
              child: icon != null
                  ? Icon(icon, color: color, size: size)
                  : buttonWidget ?? SizedBox(),
            ),
          ),
        ),
      ),
    );
  }
}
