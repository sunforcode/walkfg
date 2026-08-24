import 'package:flutter/cupertino.dart';

import '../../../../model/route/route_model.dart';
import '../../../../model/trip/trip_model.dart';
import '../../../../service/route_service.dart';
import '../../../../service/trip_service.dart';
import '../../../../theme/tokens/colors.dart';
import '../../../../utils/toast_utils.dart';

/// P5 创建行程 (PRD v1-product-spec §P5)
///
/// 从 P4 路线详情 "规划行程" 进入。
/// 选择出发时间（这周/下周）→ 确认创建 → 返回 P2 首页。
class TripCreateScreen extends StatefulWidget {
  /// 路线 ID
  final String routeId;

  const TripCreateScreen({super.key, required this.routeId});

  @override
  State<TripCreateScreen> createState() => _TripCreateScreenState();
}

class _TripCreateScreenState extends State<TripCreateScreen> {
  /// 选中的出发时段：0=这周, 1=下周, -1=未选
  int _selectedSlot = -1;

  /// 路线数据
  RouteModel? _route;

  /// 是否正在创建
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    try {
      final route = await RouteService.getRouteById(widget.routeId);
      if (mounted) {
        setState(() => _route = route);
      }
    } catch (_) {
      // 路线加载失败时仍可创建，路线名显示 routeId
    }
  }

  // ---- 计算出发日期 ----

  /// 获取本周剩余天数的下个周末起始日
  DateTime _thisWeekStartDate() {
    final now = DateTime.now();
    // 周六开始，如果今天是周六/周日则用今天
    final weekday = now.weekday;
    if (weekday >= 6) return DateTime(now.year, now.month, now.day);
    final daysUntilSat = 6 - weekday;
    return DateTime(now.year, now.month, now.day + daysUntilSat);
  }

  /// 获取下周周末起始日
  DateTime _nextWeekStartDate() {
    final thisWeek = _thisWeekStartDate();
    return thisWeek.add(const Duration(days: 7));
  }

  /// 获取选中时段对应的日期范围文字
  String _slotDateRange(int slot) {
    final start = slot == 0 ? _thisWeekStartDate() : _nextWeekStartDate();
    final end = start.add(const Duration(days: 1));
    return '${_fmtDate(start)} - ${_fmtDate(end)}';
  }

  String _fmtDate(DateTime d) {
    return '${d.month}/${d.day}';
  }

  // ---- 创建行程 ----

  Future<void> _createTrip() async {
    if (_selectedSlot < 0 || _creating) return;
    setState(() => _creating = true);

    final startDate =
        _selectedSlot == 0 ? _thisWeekStartDate() : _nextWeekStartDate();
    final endDate = startDate.add(const Duration(days: 1));

    final routeName = _route?.name ?? widget.routeId;
    // TODO: v2 补充 equipmentListId, mealPlan, waterPlan, coverUrl, imageUrls, budget, actualCost, notes
    final trip = TripModel(
      id: '',
      name: routeName,
      description: '',
      startDate: startDate,
      endDate: endDate,
      status: TripStatus.planning,
      routeIds: [widget.routeId],
      primaryRouteId: widget.routeId,
      participants: [],
      participantCount: 1,
      organizerId: 'current_user', // TODO: 替换为真实用户ID from AuthService
      itinerary: [],
      privacySetting: 'private',
    );

    try {
      await TripService.createTrip(trip);
      if (mounted) {
        ToastUtils.showToast(context, '行程创建成功');
        // 创建成功 → 返回到首页（P2）
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _creating = false);
        ToastUtils.showToast(context, '创建失败，请重试');
      }
    }
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bgBase,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('创建行程'),
        backgroundColor: AppColors.bgPanel.withValues(alpha: 0.9),
        border: null,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 路线名居中 (PRD: 居中显示)
              _RouteNameHeader(routeName: _route?.name ?? widget.routeId),

              const SizedBox(height: 48),

              // 时间选项标题
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '选择出发时间',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWeak,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // "这周" / "下周" 两个卡片
              _TimeSlotCards(
                selectedSlot: _selectedSlot,
                thisWeekRange: _slotDateRange(0),
                nextWeekRange: _slotDateRange(1),
                onSlotTap: (slot) => setState(() => _selectedSlot = slot),
              ),

              const Spacer(),

              // 确认按钮 (PRD: 选中后激活渐变色，未选灰色)
              _ConfirmButton(
                enabled: _selectedSlot >= 0,
                loading: _creating,
                onTap: _createTrip,
              ),

              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  路线名标题
// ---------------------------------------------------------------------------

class _RouteNameHeader extends StatelessWidget {
  final String routeName;
  const _RouteNameHeader({required this.routeName});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '🗺',
          style: TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 12),
        Text(
          routeName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        const Text(
          '确认出发时间即可创建行程',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  时间选项卡片
// ---------------------------------------------------------------------------

class _TimeSlotCards extends StatelessWidget {
  final int selectedSlot;
  final String thisWeekRange;
  final String nextWeekRange;
  final ValueChanged<int> onSlotTap;

  const _TimeSlotCards({
    required this.selectedSlot,
    required this.thisWeekRange,
    required this.nextWeekRange,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TimeSlotCard(
            label: '这周',
            dateRange: thisWeekRange,
            isSelected: selectedSlot == 0,
            onTap: () => onSlotTap(0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TimeSlotCard(
            label: '下周',
            dateRange: nextWeekRange,
            isSelected: selectedSlot == 1,
            onTap: () => onSlotTap(1),
          ),
        ),
      ],
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final String label;
  final String dateRange;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSlotCard({
    required this.label,
    required this.dateRange,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected
        ? AppColors.interactiveAccent.withValues(alpha: 0.12)
        : AppColors.bgPanel;
    final borderColor = isSelected
        ? AppColors.interactiveAccent.withValues(alpha: 0.5)
        : AppColors.border;
    final labelColor =
        isSelected ? AppColors.interactiveAccent : AppColors.textWeak;
    final dateColor = isSelected ? AppColors.textWeak : AppColors.textWeak;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateRange,
              style: TextStyle(
                fontSize: 13,
                color: dateColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  确认按钮
// ---------------------------------------------------------------------------

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // PRD: 选中后激活渐变色，未选灰色
    final Color bgColor;
    if (!enabled) {
      bgColor = AppColors.bgPanel;
    } else {
      bgColor = AppColors.interactiveAccent;
    }
    final textColor = enabled ? AppColors.bgLight : AppColors.textWeak;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: GestureDetector(
        onTap: enabled && !loading ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: loading
              ? const CupertinoActivityIndicator(color: AppColors.bgLight)
              : Text(
                  '确认创建',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
        ),
      ),
    );
  }
}
