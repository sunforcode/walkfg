import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/daily_plan_model.dart';

/// 可折叠的行程安排组件
class CollapsibleItineraryWidget extends StatefulWidget {
  /// 每日计划列表
  final List<DailyPlanModel> dailyPlans;

  /// 点击日程回调
  final Function(int dayIndex)? onDayTap;

  const CollapsibleItineraryWidget({
    super.key,
    required this.dailyPlans,
    this.onDayTap,
  });

  @override
  State<CollapsibleItineraryWidget> createState() =>
      _CollapsibleItineraryWidgetState();
}

class _CollapsibleItineraryWidgetState
    extends State<CollapsibleItineraryWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.dailyPlans.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // 头部（一级视图）
          _buildHeader(),

          // 详细内容（可折叠）
          if (_isExpanded) _buildDetailedContent(),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    final totalDistance =
        widget.dailyPlans.fold(0.0, (sum, plan) => sum + plan.distance);
    final totalElevationGain =
        widget.dailyPlans.fold(0, (sum, plan) => sum + plan.elevationGain);
    final totalTime =
        widget.dailyPlans.fold(0.0, (sum, plan) => sum + plan.estimatedTime);

    final startPoint = widget.dailyPlans.isNotEmpty
        ? _getWaypointName(widget.dailyPlans.first.startWaypointId)
        : '未知';
    final endPoint = widget.dailyPlans.isNotEmpty
        ? _getWaypointName(widget.dailyPlans.last.endWaypointId)
        : '未知';

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 标题行
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 20,
                  color: CupertinoColors.activeBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  '行程安排',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
                const Spacer(),
                Text(
                  '共${widget.dailyPlans.length}天',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 起终点信息
            Row(
              children: [
                Expanded(
                  child: _buildEndpointInfo(
                    icon: CupertinoIcons.flag,
                    label: '起点',
                    value: startPoint,
                    color: CupertinoColors.systemGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEndpointInfo(
                    icon: CupertinoIcons.flag_fill,
                    label: '终点',
                    value: endPoint,
                    color: CupertinoColors.systemRed,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 统计信息
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: CupertinoIcons.location,
                    label: '总距离',
                    value: '${totalDistance.toStringAsFixed(1)}km',
                    color: CupertinoColors.systemBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: CupertinoIcons.arrow_up,
                    label: '总爬升',
                    value: '${totalElevationGain}m',
                    color: CupertinoColors.systemGreen,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: CupertinoIcons.time,
                    label: '总耗时',
                    value: '${totalTime.toStringAsFixed(0)}h',
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建端点信息
  Widget _buildEndpointInfo({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CupertinoColors.label,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.label,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 构建详细内容
  Widget _buildDetailedContent() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: widget.dailyPlans.asMap().entries.map((entry) {
          final index = entry.key;
          final plan = entry.value;
          return _buildDayDetail(index, plan);
        }).toList(),
      ),
    );
  }

  /// 构建每日详情
  Widget _buildDayDetail(int index, DailyPlanModel plan) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => widget.onDayTap?.call(index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: index < widget.dailyPlans.length - 1
                  ? CupertinoColors.separator
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日程标题
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.activeBlue,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.title.isNotEmpty ? plan.title : '第${index + 1}天',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.label,
                        ),
                      ),
                      if (plan.description.isNotEmpty)
                        Text(
                          plan.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Text(
                  '${plan.estimatedTime.toStringAsFixed(0)}h',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CupertinoColors.systemOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 路线信息
            Row(
              children: [
                _buildInfoChip(
                  icon: CupertinoIcons.location,
                  label: '${plan.distance.toStringAsFixed(1)}km',
                  color: CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: CupertinoIcons.arrow_up,
                  label: '+${plan.elevationGain}m',
                  color: CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  icon: CupertinoIcons.time,
                  label: plan.duration,
                  color: CupertinoColors.systemOrange,
                ),
              ],
            ),

            // 关键点信息
            if (plan.keyPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: plan.keyPoints.map((point) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.label,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // 住宿信息
            if (plan.accommodation != null &&
                plan.accommodation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.house_alt,
                    size: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '住宿：${plan.accommodation}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息标签
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.calendar,
              size: 32,
              color: CupertinoColors.systemGrey,
            ),
            SizedBox(height: 8),
            Text(
              '暂无行程安排',
              style: TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取路标点名称（简化版，实际应该从路标点数据中获取）
  String _getWaypointName(String waypointId) {
    // 这里应该根据waypointId从实际数据中获取名称
    // 目前返回简化的名称
    switch (waypointId) {
      case 'wp_001':
        return '云谷寺';
      case 'wp_006':
        return '慈光阁';
      default:
        return '路标点';
    }
  }
}
