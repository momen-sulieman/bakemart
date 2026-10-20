import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:bakemart/core/theming/theming_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class BranchPager extends StatelessWidget {
  final List<BakeryModel> branches;
  final String selectedBranchId;
  final ValueChanged<String> onBranchChanged;
  final Widget child;
  final bool storage;

  const BranchPager({
    required this.branches,
    required this.selectedBranchId,
    required this.onBranchChanged,
    required this.child,
    this.storage=false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (branches.isEmpty) return child;
    final int foundIndex = branches.indexWhere(
          (branch) => branch.branchId == selectedBranchId,
    );
    final int index = foundIndex < 0 ? 0 : foundIndex;
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragEnd: (details) {
        final double velocity = details.primaryVelocity ?? 0;
        if (velocity.abs() < 300) return;
        final bool forward = isRtl ? velocity > 0 : velocity < 0;
        final int target = forward ? index + 1 : index - 1;
        if (target < 0 || target >= branches.length) return;
        onBranchChanged(branches[target].branchId);
      },
      child: Column(
        children: [
          if(!storage)child,
          Padding(
            padding: .only(top:storage? 0:15),
            child: AnimatedSmoothIndicator(
              activeIndex: index,
              count: branches.length,
              effect: ExpandingDotsEffect(
                activeDotColor: Colors.blueGrey,
                dotColor: ThemingColors.primaryColor.withAlpha(
                  (0.3 * 255).toInt(),
                ),
                dotHeight: 4,
                dotWidth: 4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            child: Text(
              branches[index].branchName,
              style: GoogleFonts.audiowide(
                fontSize: 12,
                color: Colors.blueGrey,
              ),
            ),
          ),
          if(storage)SizedBox(height: 10,),
          if(storage)child
        ],
      ),
    );
  }
}