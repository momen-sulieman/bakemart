import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../theming/theming_colors.dart';
import '../../../utils/extensions/context_extensions.dart';

class GlassCard extends StatelessWidget {
  final bool green;
  final bool orange;
  final bool dark,responsive;
  final Widget child;
  final double radius,otherRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    this.green = false,
    this.orange = false,
    this.dark = false,
    this.responsive = false,
    this.radius = 30,
    this.otherRadius = 0,
    required this.margin,
    required this.padding,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: .only(
          topRight:!responsive? .circular(otherRadius): .circular(context.locale.languageCode == 'en'? otherRadius:radius),
          bottomLeft:!responsive? .circular(otherRadius): .circular(context.locale.languageCode == 'en'? otherRadius:radius),
          topLeft:!responsive? .circular(radius): .circular(context.locale.languageCode == 'en'? radius:otherRadius),
          bottomRight:!responsive? .circular(radius): .circular(context.locale.languageCode == 'en'? radius:otherRadius)
        ),
        border: Border.all(
          color: context.isDark
              ? Colors.white.withAlpha((0.2 * 255).toInt())
              : ThemingColors.black.withAlpha((0.2 * 255).toInt()),
          width: 1,
        ),
        gradient: LinearGradient(
          end: (green||dark) ? Alignment.bottomRight : Alignment.topLeft,
          begin: (green||dark) ? Alignment.topLeft : Alignment.bottomRight,
          colors: [
            context.isDark
                ? green
                      ? Colors.greenAccent.withAlpha((0.2 * 255).toInt())
                      : orange
                      ? ThemingColors.primaryColor.withAlpha(
                          (0.01 * 255).toInt(),
                        )
                      : Colors.white.withAlpha(((dark?0.3:0.08) * 255).toInt())
                : green
                ? Colors.greenAccent.withAlpha((0.4 * 255).toInt())
                : orange
                ? ThemingColors.primaryColor.withAlpha((0.01 * 255).toInt())
                : Colors.black.withAlpha(((dark?0.2:0.03) * 255).toInt()),
            context.isDark
                ? green
                      ? Colors.greenAccent.withAlpha((0.02 * 255).toInt())
                      : orange
                      ? ThemingColors.primaryColor.withAlpha(
                          (0.3 * 255).toInt(),
                        )
                      : Colors.white.withAlpha((0.03 * 255).toInt())
                : green
                ? Colors.greenAccent.withAlpha((0.03 * 255).toInt())
                : orange
                ? ThemingColors.primaryColor.withAlpha((0.3 * 255).toInt())
                : Colors.black.withAlpha((0.04* 255).toInt()),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? Colors.white.withAlpha(((dark?0.2:0.1) * 255).toInt())
                : Colors.black.withAlpha(((dark?0.2:0.1) * 255).toInt()),
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(5, -5),
          ),
          BoxShadow(
            color: context.isDark
                ? Colors.black.withAlpha(((dark?0.6:0.4 )* 255).toInt())
                : Colors.white.withAlpha(((dark?0.6:0.4) * 255).toInt()),
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(15, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
