import 'package:flutter/cupertino.dart';

/// 多日轨迹的日期选择器
class DaySelectorWidget extends StatelessWidget {
  final int? selectedDay;
  final int dayCount;
  final bool showElevationChart;
  final ValueChanged<int?> onDayChanged;

  const DaySelectorWidget({
    super.key,
    required this.selectedDay,
    required this.dayCount,
    required this.showElevationChart,
    required this.onDayChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: showElevationChart ? 180 : 16,
      left: 16,
      right: 16,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            _buildDayChip(null, '全部'),
            ...List.generate(dayCount, (index) {
              return _buildDayChip(index, '第${index + 1}天');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayChip(int? day, String label) {
    final isSelected = selectedDay == day;
    return Expanded(
      child: GestureDetector(
        onTap: () => onDayChanged(day),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected
                ? CupertinoColors.activeBlue
                : CupertinoColors.systemGrey5,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.label,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
