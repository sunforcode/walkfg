import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/segment_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 路况等级枚举
enum RoadCondition {
  excellent,
  good,
  fair,
  poor,
  dangerous,
}

/// 路段信息组件 (PRD §3.3.7)
///
/// 横滑卡片：段序号徽标 + 路况徽标 + 段名 + 指标
/// 高亮段卡片加 2px 蓝色半透明边框
class RouteSegmentsWidget extends StatelessWidget {
  final List<SegmentModel> segments;
  final void Function(SegmentModel segment)? onSegmentTap;

  const RouteSegmentsWidget({
    super.key,
    required this.segments,
    this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: segments.length),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: segments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _SegmentCard(segment: segments[index], segmentNumber: index + 1, onSegmentTap: onSegmentTap),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🛤 路段信息"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '🛤 路段信息',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count段',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.badgeBlueText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  路段卡片：180px 宽，高亮时 2px 蓝色边框
// ---------------------------------------------------------------------------

class _SegmentCard extends StatelessWidget {
  final SegmentModel segment;
  final int segmentNumber;
  final void Function(SegmentModel segment)? onSegmentTap;
  const _SegmentCard({required this.segment, required this.segmentNumber, this.onSegmentTap});

  @override
  Widget build(BuildContext context) {
    final condition = _inferRoadCondition(segment);
    final conditionColor = _getConditionColor(condition);
    final segmentColor = _parseColor(segment.color);
    final isSelected = segment.isSelected;

    return GestureDetector(
      onTap: () => onSegmentTap?.call(segment),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.sheetCardBg,
          borderRadius: BorderRadius.circular(12),
          // PRD §3.3.7：高亮段 2px 蓝色半透明边框
          border: isSelected
              ? Border.all(
                  color: segmentColor ?? AppColors.badgeBlueText,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 段序号徽标 + 路况徽标
            Row(
              children: [
                _SegmentBadge(
                  number: segmentNumber,
                  color: segmentColor ?? AppColors.badgeBlueText,
                ),
                const Spacer(),
                _ConditionBadge(condition: condition, color: conditionColor),
              ],
            ),
            const SizedBox(height: 8),

            // 段名
            Text(
              segment.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.sheetTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 起终点
            Row(
              children: [
                const Icon(CupertinoIcons.location, size: 11, color: AppColors.sheetTextSecondary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    segment.startWaypoint?.name ??
                        (segment.trackStartIndex != null
                            ? '点 ${segment.trackStartIndex}'
                            : '-'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.sheetTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(CupertinoIcons.arrow_right, size: 10, color: AppColors.sheetTextWeak),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    segment.endWaypoint?.name ??
                        (segment.trackEndIndex != null
                            ? '点 ${segment.trackEndIndex}'
                            : '-'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.sheetTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 指标行
            Row(
              children: [
                _MetricChip(
                  icon: CupertinoIcons.location,
                  value: '${(segment.distance ?? 0.0).toStringAsFixed(1)}km',
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: CupertinoIcons.arrow_up,
                  value: '${segment.elevationGain?.toInt() ?? 0}m',
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: CupertinoIcons.arrow_down,
                  value: '${segment.elevationLoss?.toInt() ?? 0}m',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      final hexStr = colorStr.replaceAll('#', '');
      if (hexStr.length == 6) {
        return Color(int.parse('FF$hexStr', radix: 16));
      } else if (hexStr.length == 8) {
        return Color(int.parse(hexStr, radix: 16));
      }
    } catch (e) {
      // 忽略解析错误
    }
    return null;
  }

  RoadCondition _inferRoadCondition(SegmentModel segment) {
    final elevationGain = segment.elevationGain ?? 0.0;
    final distance = segment.distance ?? 0.0;
    if (distance <= 0) return RoadCondition.excellent;
    final elevationGainPerKm = elevationGain / distance;
    if (elevationGainPerKm > 300) return RoadCondition.poor;
    if (elevationGainPerKm > 200) return RoadCondition.fair;
    if (elevationGainPerKm > 100) return RoadCondition.good;
    return RoadCondition.excellent;
  }

  Color _getConditionColor(RoadCondition condition) {
    switch (condition) {
      case RoadCondition.excellent:
        return AppColors.badgeVerifiedText;
      case RoadCondition.good:
        return AppColors.badgeBlueText;
      case RoadCondition.fair:
        return AppColors.badgeRecommendedText;
      case RoadCondition.poor:
        return AppColors.badgeEssentialText;
      case RoadCondition.dangerous:
        return AppColors.badgeEssentialText;
    }
  }
}

// ---------------------------------------------------------------------------
//  段序号徽标 (蓝底圆角)
// ---------------------------------------------------------------------------

class _SegmentBadge extends StatelessWidget {
  final int number;
  final Color color;
  const _SegmentBadge({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '第$number段',
        style: const TextStyle(
          color: CupertinoColors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  路况徽标
// ---------------------------------------------------------------------------

class _ConditionBadge extends StatelessWidget {
  final RoadCondition condition;
  final Color color;
  const _ConditionBadge({required this.condition, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _text,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _text {
    switch (condition) {
      case RoadCondition.excellent:
        return '优秀';
      case RoadCondition.good:
        return '良好';
      case RoadCondition.fair:
        return '一般';
      case RoadCondition.poor:
        return '较差';
      case RoadCondition.dangerous:
        return '危险';
    }
  }
}

// ---------------------------------------------------------------------------
//  指标标签
// ---------------------------------------------------------------------------

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetricChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sheetTextSecondary),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}
