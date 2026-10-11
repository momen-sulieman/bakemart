
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../utils/enums/buckts.dart';
import '../supabase_image/ui/supabase_image.dart';

class WorkerCell extends StatelessWidget {
  final String workerName, workerId;
  final Color? textColor;
  final bool noPadding;
  final double opacity;

  const WorkerCell({
    required this.workerName,
    required this.workerId,
    this.textColor,
    this.noPadding = false,
    this.opacity = 1,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: noPadding ? .zero : .symmetric(vertical: 10),
      child: Row(
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
                borderRadius: .circular(3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SupabaseImageProvider(
                  filePath: Buckets.usersImages,
                  fileName: workerId,
                  person: true,
                  iconSize: 16,
                  loadingIconSize: 14,
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
                workerName,
                style: TextStyle(fontSize: 12, color: textColor),
                maxLines: 1,
                overflow: .ellipsis,
                textDirection: Bidi.detectRtlDirectionality(workerName)
                    ? .rtl
                    : .ltr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}