import 'package:bakemart/core/shared/widgets/transparent_button/transparent_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wheel_picker/wheel_picker.dart';

import '../../../theming/theming_colors.dart';
import '../../../utils/extensions/context_extensions.dart';

mixin DatePeriodFilterMixin {
  DateTime selectedDate = DateTime.now();
  bool useDay = true;
  bool useMonth = true;
  bool pendingUseDay = true;
  bool pendingUseMonth = true;

  List<DateTime> periodDates() {
    if (useDay) return [selectedDate];
    if (useMonth) {
      final count = DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
      return List.generate(
        count,
            (i) => DateTime(selectedDate.year, selectedDate.month, i + 1),
      );
    }
    final dates = <DateTime>[];
    for (int m = 1; m <= 12; m++) {
      final count = DateTime(selectedDate.year, m + 1, 0).day;
      for (int d = 1; d <= count; d++) {
        dates.add(DateTime(selectedDate.year, m, d));
      }
    }
    return dates;
  }
  void togglePendingDay() {
    if (!pendingUseMonth) {
      pendingUseMonth = true;
      pendingUseDay = true;
    } else {
      pendingUseDay = !pendingUseDay;
    }
  }

  void togglePendingMonth() {
    pendingUseMonth = !pendingUseMonth;
    if (!pendingUseMonth) pendingUseDay = false;
  }

  void resetPending() {
    pendingUseDay = useDay;
    pendingUseMonth = useMonth;
  }

  void commitPending() {
    useMonth = pendingUseMonth;
    useDay = pendingUseMonth && pendingUseDay;
  }
}

class DatePeriodWheels extends StatelessWidget {
  final DateTime selectedDate;
  final bool showDay;
  final bool showMonth;
  final void Function({int? year, int? month, int? day}) onChanged;

  const DatePeriodWheels({
    super.key,
    required this.selectedDate,
    required this.showDay,
    required this.showMonth,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final daysCount = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    ).day;
    final years = List.generate(11, (index) => 2026 + index);
    final yearIndex = years.indexOf(selectedDate.year);

    Widget separator() => Container(
      height: 20,
      width: 3,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: ThemingColors.primaryColor.withAlpha((0.4 * 255).toInt()),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showDay) ...[
          _WheelColumn(
            width: 50,
            wheelKey: ValueKey('day-$daysCount'),
            count: daysCount,
            index: selectedDate.day - 1,
            itemExtent: 30,
            diameterRatio: 20,
            squeeze: 1,
            label: (i) => '${i + 1}',
            onChanged: (i) => onChanged(day: i + 1),
          ),
          separator(),
        ],
        if (showMonth) ...[
          _WheelColumn(
            width: 50,
            wheelKey: const ValueKey('month'),
            count: 12,
            index: selectedDate.month - 1,
            itemExtent: 40,
            diameterRatio: 3,
            squeeze: 0.9,
            label: (i) => '${i + 1}',
            onChanged: (i) => onChanged(month: i + 1),
          ),
          separator(),
        ],
        _WheelColumn(
          width: 60,
          wheelKey: const ValueKey('year'),
          count: years.length,
          index: yearIndex != -1 ? yearIndex : 0,
          itemExtent: 40,
          diameterRatio: 3,
          squeeze: 0.9,
          label: (i) => '${years[i]}',
          onChanged: (i) => onChanged(year: years[i]),
        ),
      ],
    );
  }
}

class _WheelColumn extends StatelessWidget {
  final double width;
  final Key wheelKey;
  final int count;
  final int index;
  final double itemExtent;
  final double diameterRatio;
  final double squeeze;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  const _WheelColumn({
    required this.width,
    required this.wheelKey,
    required this.count,
    required this.index,
    required this.itemExtent,
    required this.diameterRatio,
    required this.squeeze,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final arrowColor = ThemingColors.primaryColor.withAlpha(
      (0.4 * 255).toInt(),
    );
    return SizedBox(
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_drop_up, size: 20, color: arrowColor),
          Expanded(
            child: WheelPicker(
              key: wheelKey,
              controller: WheelPickerController(
                itemCount: count,
                initialIndex: index >= 0 && index < count ? index : 0,
              ),
              style: WheelPickerStyle(
                itemExtent: itemExtent,
                surroundingOpacity: 0.25,
                squeeze: squeeze,
                diameterRatio: diameterRatio,
              ),
              onIndexChanged: (i, _) => onChanged(i),
              builder: (context, i) => Center(
                child: Text(
                  label(i),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Icon(Icons.arrow_drop_down, size: 20, color: arrowColor),
        ],
      ),
    );
  }
}

class DatePeriodFilterButton extends StatelessWidget {
  final DatePeriodFilterMixin filter;
  final VoidCallback onApply;

  const DatePeriodFilterButton({
    super.key,
    required this.filter,
    required this.onApply,
  });

  void _open(BuildContext context) {
    filter.resetPending();
    final box = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    showMenu<void>(
      context: context,
      position: position,
      color: context.isDark ? ThemingColors.black : ThemingColors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1,
          color: ThemingColors.white.withAlpha((0.2 * 255).toInt()),
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      items: [
        _FilterMenuEntry(
          child: _FilterMenuContent(filter: filter, onApply: onApply),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => _open(context),
      child: Icon(Icons.filter_alt, color: ThemingColors.primaryColor),
    );
  }
}

class _FilterMenuEntry extends PopupMenuEntry<void> {
  final Widget child;

  const _FilterMenuEntry({required this.child});

  @override
  double get height => 120;

  @override
  bool represents(void value) => false;

  @override
  State<_FilterMenuEntry> createState() => _FilterMenuEntryState();
}

class _FilterMenuEntryState extends State<_FilterMenuEntry> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class _FilterMenuContent extends StatefulWidget {
  final DatePeriodFilterMixin filter;
  final VoidCallback onApply;

  const _FilterMenuContent({required this.filter, required this.onApply});

  @override
  State<_FilterMenuContent> createState() => _FilterMenuContentState();
}

class _FilterMenuContentState extends State<_FilterMenuContent> {
  DatePeriodFilterMixin get f => widget.filter;

  Widget _label(String key, double width) => SizedBox(
    width: width,
    child: Text(
      key.tr(),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );

  Widget _bar() => Container(
    height: 16,
    width: 2,
    color: ThemingColors.primaryColor.withAlpha((0.4 * 255).toInt()),
  );

  Widget _toggle({
    required bool value,
    required bool enabled,
    required double width,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: width,
      child: InkWell(
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: enabled ? () => setState(onTap) : null,
        child: Icon(
          value ? Icons.toggle_on : Icons.toggle_off,
          size: 34,
          color: value
              ? ThemingColors.primaryColor
              : Colors.grey.withAlpha((0.3 * 255).toInt()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _label('day', 50),
                _bar(),
                _label('month', 65),
                _bar(),
                _label('year', 60),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _toggle(
                  width: 60,
                  value: f.pendingUseDay,
                  enabled: true,
                  onTap: f.togglePendingDay,
                ),
                const SizedBox(width: 2),
                _toggle(
                  width: 50,
                  value: f.pendingUseMonth,
                  enabled: true,
                  onTap: f.togglePendingMonth,
                ),
                const SizedBox(width: 2),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 20),
            TransparentButton(
              buttonWidget: Text(
                "Apply",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: .bold,
                  color: ThemingColors.primaryColor,
                ),
              ),
              buttonHorizontalPading: 0,
              verticalPadding: 3,
              onTap: () {
                Navigator.pop(context);
                widget.onApply();
              },
            ),
          ],
        ),
      ),
    );
  }
}
