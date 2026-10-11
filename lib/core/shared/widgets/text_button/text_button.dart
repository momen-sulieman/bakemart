import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:bakemart/core/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title, subTitle;

  const CustomTextButton({
    required this.title,
    required this.onTap,
    required this.subTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 12,
              color: context.isDark ? ThemingColors.white : ThemingColors.black,
            ),
          ),
          WidgetSpan(
            child: InkWell(
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: onTap,
              child: Text(
                subTitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  decoration: .underline,
                  decorationColor: Colors.blueAccent
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
