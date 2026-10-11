import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../theming/theming_colors.dart';

class Button extends StatelessWidget {
  final String title;
  final bool isLoading;
  final VoidCallback? onTap;

  const Button(this.title, this.onTap, {this.isLoading = false, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: .infinity,
        alignment: .center,
        padding: .all(12),
        margin: .symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: ThemingColors.primaryColor,
          borderRadius: .circular(30),
        ),
        child: isLoading
            ? LoadingAnimationWidget.staggeredDotsWave(
                color: ThemingColors.secondaryColor,
                size: 30,
              )
            : Text(
                title,
                style: GoogleFonts.coiny(
                  color: ThemingColors.secondaryColor,
                  fontSize: 20,
                  fontWeight: .bold,
                ),
              ),
      ),
    );
  }
}
