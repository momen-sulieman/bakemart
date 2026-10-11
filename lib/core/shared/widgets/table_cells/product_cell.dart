import 'dart:io';

import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/enums/buckts.dart';
import '../supabase_image/ui/supabase_image.dart';

class ProductCell extends StatelessWidget {
  final String productName, productId;
  final Color? textColor;
  final double opacity;
  final File? pendingImage;

  const ProductCell({
    required this.productName,
    required this.productId,
    this.textColor,
    this.opacity = 1,
    this.pendingImage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Opacity(
          opacity: opacity,
          child: Container(
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              color: ThemingColors.primaryColor.withAlpha(
                (0.3 * 255).toInt(),
              ),
              shape: .circle,
            ),
            child: ClipOval(
              child: pendingImage != null
                  ? SizedBox.expand(
                child: Image.file(pendingImage!, fit: BoxFit.cover),
              )
                  : SupabaseImageProvider(
                filePath: Buckets.productsImages,
                fileName: productId,
                iconSize: 14,
                loadingIconSize: 12,
                cacheWidth: 75,
                cacheHeight: 75,
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: .symmetric(horizontal: 10),
            child: Text(
              productName,
              style: TextStyle(fontSize: 12, color: textColor),
              maxLines: 1,
              overflow: .ellipsis,
              textDirection: Bidi.detectRtlDirectionality(productName)
                  ? .rtl
                  : .ltr,
            ),
          ),
        ),
      ],
    );
  }
}