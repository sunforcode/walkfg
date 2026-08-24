import 'package:flutter/cupertino.dart';

import '../../../theme/tokens/colors.dart';
import '../../../theme/tokens/typography.dart';
import '../../../ui/routes/app_navigator.dart';
import '../common/utility_page_scaffold.dart';

/// P12 日历面板
///
/// PRD: prototypes/v1/specs/P12-calendar.md
/// 月视图日历，标注行程日期红点，点击行程日跳转 P6 行程详情。
/// v1 使用 mock 数据，后续替换为真实行程列表 API。
///
/// 形态：PRD 要求 bottom sheet overlay，v1 先以全屏实现，
/// 但保留下滑手势关闭（drag-down-to-close）。
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

// ──────────────────────────────────────────────
// Mock 行程数据 (v1)
// ──────────────────────────────────────────────

/// Mock 行程日期映射 — {year: {month: [day, ...]}}
/// 对应 PRD §6.1 tripDays 字段。
const Map<int, Map<int, List<int>>> _mockTripDays = {
  2025: {
    7: [15, 22],
    8: [3, 9, 16, 28],
    9: [6, 13],
  },
};

/// Mock 日期 → tripId 映射 (key: "year-month-day")
/// 对应 PRD §6.1 tripsByDate 字段。
const Map<String, String> _mockTripsByDate = {
  '2025-7-15': 'trip_0715',
  '2025-7-22': 'trip_0722',
  '2025-8-3': 'trip_0803',
  '2025-8-9': 'trip_0809',
  '2025-8-16': 'trip_0816',
  '2025-8-28': 'trip_0828',
  '2025-9-6': 'trip_0906',
  '2025-9-13': 'trip_0913',
};

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  double _dragOffset = 0;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  bool _hasTrip(int year, int month, int day) {
    final monthMap = _mockTripDays[year];
    if (monthMap == null) return false;
    final days = monthMap[month];
    if (days == null) return false;
    return days.contains(day);
  }

  String? _tripIdForDate(int year, int month, int day) {
    return _mockTripsByDate['$year-$month-$day'];
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  void _onTripDayTapped(int year, int month, int day) {
    final tripId = _tripIdForDate(year, month, day);
    Navigator.of(context).maybePop();
    if (tripId != null) {
      AppNavigator.pushTripDetail(context, tripId: tripId);
    }
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0) {
      setState(() {
        _dragOffset += details.delta.dy;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // PRD §5.5: 下滑超过 50px 阈值则关闭，否则回弹
    if (_dragOffset > 50) {
      _close();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return UtilityPageScaffold(
      title: '日历',
      body: GestureDetector(
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: const Cubic(0.32, 0.72, 0, 1),
          transform: Matrix4.translationValues(0, _dragOffset, 0),
          child: Column(
            children: [
              _DragHandle(),
              _MonthHeader(
                year: _currentMonth.year,
                month: _currentMonth.month,
                onPrevious: _previousMonth,
                onNext: _nextMonth,
              ),
              Expanded(
                child: _CalendarGrid(
                  year: _currentMonth.year,
                  month: _currentMonth.month,
                  hasTrip: _hasTrip,
                  onTripDayTapped: _onTripDayTapped,
                ),
              ),
              _CloseButton(onTap: _close),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Private widgets
// ──────────────────────────────────────────────

/// 顶部拖拽手柄 — 暗示可下滑关闭
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.textWeak,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// 月份切换头部 — PRD §3.3
class _MonthHeader extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MonthNavButton(icon: CupertinoIcons.chevron_left, onTap: onPrevious),
          Text(
            '$year年$month月',
            style: AppTypography.pageTitle,
          ),
          _MonthNavButton(icon: CupertinoIcons.chevron_right, onTap: onNext),
        ],
      ),
    );
  }
}

/// 月份切换按钮 — PRD §3.3 (‹ / ›)
class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onTap,
      child: Icon(
        icon,
        size: 20,
        color: AppColors.textWeak,
      ),
    );
  }
}

/// 日历网格 — PRD §3.4
class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final bool Function(int, int, int) hasTrip;
  final void Function(int, int, int) onTripDayTapped;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.hasTrip,
    required this.onTripDayTapped,
  });

  int get _daysInMonth => DateTime(year, month + 1, 0).day;
  int get _firstWeekday => DateTime(year, month, 1).weekday % 7;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _WeekLabelRow(),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: _firstWeekday + _daysInMonth,
              itemBuilder: (context, index) {
                if (index < _firstWeekday) {
                  return const SizedBox.shrink();
                }
                final day = index - _firstWeekday + 1;
                return _DayCell(
                  day: day,
                  isToday: _isToday(day),
                  hasTrip: hasTrip(year, month, day),
                  onTap: hasTrip(year, month, day)
                      ? () => onTripDayTapped(year, month, day)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return now.year == year && now.month == month && now.day == day;
  }
}

/// 周标签行 — PRD §3.4
class _WeekLabelRow extends StatelessWidget {
  static const _labels = ['日', '一', '二', '三', '四', '五', '六'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: _labels
            .map(
              (label) => Expanded(
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textWeak,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

/// 日期单元格 — PRD §3.4 + §4.2
class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool hasTrip;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasTrip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // PRD §4.2: 有行程 → 白色加粗文字 + 红点
    // PRD §4.2: 今日 → 白色加粗文字 + 亮蓝半透明背景 (rgba(100,200,255,.12))
    // PRD §4.2: 普通日期 → rgba(255,255,255,.6)
    final textColor =
        hasTrip || isToday ? AppColors.textPrimary : AppColors.textSecondary;
    final fontWeight = hasTrip || isToday ? FontWeight.w600 : FontWeight.w400;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? AppColors.interactiveAccentBg : null,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
            if (hasTrip)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 关闭日历按钮 — PRD §3.5
class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 40),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        onPressed: onTap,
        child: Text(
          '关闭日历',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textWeak,
          ),
        ),
      ),
    );
  }
}
