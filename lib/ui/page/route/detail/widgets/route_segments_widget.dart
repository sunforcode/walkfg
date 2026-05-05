import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/route/segment_model.dart';

/// 路况等级枚举
enum RoadCondition {
  excellent,
  good,
  fair,
  poor,
  dangerous,
}

/// 路线分段Widget（横向滑动）
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
        Row(
          children: [
            const Icon(
              CupertinoIcons.map,
              size: 16,
              color: CupertinoColors.systemTeal,
            ),
            const SizedBox(width: 6),
            const Text(
              '路线分段',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CupertinoColors.systemTeal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${segments.length}段',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemTeal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: segments.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _buildCard(segments[index], index + 1),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(SegmentModel segment, int segmentNumber) {
    final condition = _inferRoadCondition(segment);
    final conditionColor = _getConditionColor(condition);
    final segmentColor = _parseColor(segment.color);
    final isSelected = segment.isSelected;

    return GestureDetector(
      onTap: () => onSegmentTap?.call(segment),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: segmentColor ?? CupertinoColors.systemTeal,
                  width: 2.5,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(
                  isSelected ? 0.15 : 0.06),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: segmentColor ?? CupertinoColors.systemTeal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '第$segmentNumber段',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: conditionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getConditionText(condition),
                    style: TextStyle(
                      fontSize: 10,
                      color: conditionColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              segment.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(CupertinoIcons.location,
                    size: 11, color: CupertinoColors.systemGreen),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    segment.startWaypoint?.name ??
                        (segment.trackStartIndex != null
                            ? '点 ${segment.trackStartIndex}'
                            : '-'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(CupertinoIcons.arrow_right,
                    size: 10, color: CupertinoColors.systemGrey),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    segment.endWaypoint?.name ??
                        (segment.trackEndIndex != null
                            ? '点 ${segment.trackEndIndex}'
                            : '-'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: CupertinoColors.secondaryLabel,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            const Spacer(),

            Row(
              children: [
                _miniStat(
                  CupertinoIcons.location,
                  '${(segment.distance ?? 0.0).toStringAsFixed(1)}km',
                  CupertinoColors.systemBlue,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  CupertinoIcons.arrow_up,
                  '${segment.elevationGain?.toInt() ?? 0}m',
                  CupertinoColors.systemGreen,
                ),
                const SizedBox(width: 8),
                _miniStat(
                  CupertinoIcons.arrow_down,
                  '${segment.elevationLoss?.toInt() ?? 0}m',
                  CupertinoColors.systemOrange,
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

  Widget _miniStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
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

  String _getConditionText(RoadCondition condition) {
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

  Color _getConditionColor(RoadCondition condition) {
    switch (condition) {
      case RoadCondition.excellent:
        return CupertinoColors.systemGreen;
      case RoadCondition.good:
        return CupertinoColors.systemBlue;
      case RoadCondition.fair:
        return CupertinoColors.systemYellow;
      case RoadCondition.poor:
        return CupertinoColors.systemOrange;
      case RoadCondition.dangerous:
        return CupertinoColors.systemRed;
    }
  }
}
