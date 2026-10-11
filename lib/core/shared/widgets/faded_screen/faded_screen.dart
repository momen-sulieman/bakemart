import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class FadedScreen extends StatelessWidget {
  final bool colored;
  final Color iconColor, textColor;
  final IconData icon;
  final double size;
  final String text;
  final double padding,
      iconDarkFade,
      iconLightFade,
      textDarkFade,
      textLightFade;

  const FadedScreen({
    this.colored = true,
    required this.size,
    required this.icon,
    required this.text,
    this.padding = 0,
    this.iconDarkFade = 0.3,
    this.iconLightFade = 0.3,
    this.textDarkFade = 1,
    this.textLightFade = 1,
    this.iconColor = Colors.grey,
    this.textColor = Colors.grey,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: .symmetric(vertical: padding),
          child: Icon(
            icon,
            size: size,
            color: context.isDark
                ? iconColor.withAlpha((iconDarkFade * 255).toInt())
                : iconColor.withAlpha((iconLightFade * 255).toInt()),
          ),
        ),
        Padding(
          padding: .symmetric(horizontal: 50),
          child: Text(
            text,
            style: TextStyle(
              color:
              colored? context.isDark
                  ? textColor.withAlpha((textDarkFade * 255).toInt())
                  : textColor.withAlpha((textLightFade * 255).toInt()):null,
              fontWeight: .bold,
            ),
            textAlign: .center,
          ),
        ),
      ],
    );
  }
}
