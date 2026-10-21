import 'package:bakemart/core/shared/models/bakery_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class _PagerDragState {
  final double offset;
  final bool animate;

  const _PagerDragState(this.offset, this.animate);
}

class _PagerDragCubit extends Cubit<_PagerDragState> {
  _PagerDragCubit() : super(const _PagerDragState(0, false));

  bool busy = false;

  void drag(double delta, {required bool canLeft, required bool canRight}) {
    if (busy) return;
    final double raw = state.offset + delta;
    final bool blocked = (raw < 0 && !canLeft) || (raw > 0 && !canRight);
    emit(_PagerDragState(blocked ? state.offset + delta * 0.3 : raw, false));
  }

  void animateTo(double value) => emit(_PagerDragState(value, true));

  void jumpTo(double value) => emit(_PagerDragState(value, false));
}

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
    this.storage = false,
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
    final double width = MediaQuery.of(context).size.width;
    final bool hasNext = index + 1 < branches.length;
    final bool hasPrevious = index - 1 >= 0;
    final bool canLeft = isRtl ? hasPrevious : hasNext;
    final bool canRight = isRtl ? hasNext : hasPrevious;

    return BlocProvider(
      create: (_) => _PagerDragCubit(),
      child: Builder(
        builder: (context) {
          final dragCubit = context.read<_PagerDragCubit>();

          final Widget content =
          BlocBuilder<_PagerDragCubit, _PagerDragState>(
            builder: (context, drag) {
              return ClipRect(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: drag.offset),
                  duration: drag.animate
                      ? const Duration(milliseconds: 100)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, widget) {
                    final double fade =
                        1 - (value.abs() / width).clamp(0.0, 1.0) * 0.6;
                    return Transform.translate(
                      offset: Offset(value, 0),
                      child: Opacity(opacity: fade, child: widget),
                    );
                  },
                  child: child,
                ),
              );
            },
          );

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              dragCubit.drag(
                details.delta.dx,
                canLeft: canLeft,
                canRight: canRight,
              );
            },
            onHorizontalDragEnd: (details) async {
              if (dragCubit.busy) return;
              final double velocity = details.primaryVelocity ?? 0;
              final double offset = dragCubit.state.offset;
              final bool leftward = offset < 0;
              final bool velocityAgrees =
                  velocity.abs() > 700 && (velocity < 0) == leftward;
              final bool passed =
                  offset.abs() > width * 0.3 || velocityAgrees;
              final bool allowed = leftward ? canLeft : canRight;
              if (offset == 0 || !passed || !allowed) {
                dragCubit.animateTo(0);
                return;
              }
              final int target = (leftward != isRtl) ? index + 1 : index - 1;
              dragCubit.busy = true;
              dragCubit.animateTo(leftward ? -width : width);
              await Future.delayed(const Duration(milliseconds: 250));
              if (dragCubit.isClosed) return;
              onBranchChanged(branches[target].branchId);
              dragCubit.jumpTo(leftward ? width : -width);
              await Future.delayed(const Duration(milliseconds: 30));
              if (dragCubit.isClosed) return;
              dragCubit.animateTo(0);
              await Future.delayed(const Duration(milliseconds: 250));
              if (!dragCubit.isClosed) dragCubit.busy = false;
            },
            child: Column(
              children: [
                if (!storage) content,
                Padding(
                  padding: .only(top: storage ? 0 : 15),
                  child: AnimatedSmoothIndicator(
                    activeIndex: index,
                    count: branches.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: Colors.blueGrey,
                      dotColor: Colors.blueGrey.withAlpha(
                        (0.3 * 255).toInt(),
                      ),
                      dotHeight: 4,
                      dotWidth: 8,
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
                if (storage) const SizedBox(height: 10),
                if (storage) content,
              ],
            ),
          );
        },
      ),
    );
  }
}