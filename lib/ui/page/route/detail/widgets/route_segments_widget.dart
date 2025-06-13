import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/segment_model.dart';

/// 路况等级枚举
enum RoadCondition {
  excellent, // 优秀
  good, // 良好
  fair, // 一般
  poor, // 较差
  dangerous, // 危险
}

/// 路线分段介绍Widget
class RouteSegmentsWidget extends StatefulWidget {
  final List<SegmentModel> segments;

  const RouteSegmentsWidget({
    super.key,
    required this.segments,
  });

  @override
  State<RouteSegmentsWidget> createState() => _RouteSegmentsWidgetState();
}

class _RouteSegmentsWidgetState extends State<RouteSegmentsWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) {
      return const SizedBox.shrink();
    }

    final displaySegments = _showAll
        ? widget.segments
        : widget.segments.take(_maxDisplayCount).toList();
    final hasMore = widget.segments.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.map,
                size: 20,
                color: CupertinoColors.systemTeal,
              ),
              const SizedBox(width: 8),
              const Text(
                '路线分段介绍',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.segments.length}段',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 分段列表
          ...displaySegments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSegmentCard(segment, index + 1),
            );
          }).toList(),

          // 更多按钮
          if (hasMore && !_showAll)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setState(() {
                  _showAll = true;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.separator,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '查看更多路段',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.segments.length - _maxDisplayCount}段)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: CupertinoColors.systemTeal,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建路段卡片
  Widget _buildSegmentCard(SegmentModel segment, int segmentNumber) {
    // 根据路段特征推断路况等级
    final condition = _inferRoadCondition(segment);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.separator,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemTeal,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '第${segmentNumber}段',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  segment.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConditionColor(condition).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getConditionText(condition),
                  style: TextStyle(
                    fontSize: 12,
                    color: _getConditionColor(condition),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            segment.name,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.secondaryLabel,
            ),
          ),

          const SizedBox(height: 12),

          // 统计信息
          Row(
            children: [
              // 距离
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.location,
                  label: '距离',
                  value: '${segment.distance.toStringAsFixed(1)}km',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              // 上升
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.arrow_up,
                  label: '上升',
                  value: '${segment.elevationGain}m',
                  color: CupertinoColors.systemGreen,
                ),
              ),
              // 下降
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.arrow_down,
                  label: '下降',
                  value: '${segment.elevationLoss?.toInt() ?? 0}m',
                  color: CupertinoColors.systemOrange,
                ),
              ),
              // 时间
              Expanded(
                child: _buildStatItem(
                  icon: CupertinoIcons.time,
                  label: '时间',
                  value: segment.duration.toString(),
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),

          // 路线信息
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // 起点
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location,
                            size: 14,
                            color: CupertinoColors.systemGreen,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '起点',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        segment.startWaypoint?.name ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                      ),
                    ],
                  ),
                ),

                // 箭头
                const Icon(
                  CupertinoIcons.arrow_right,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),

                // 终点
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text(
                            '终点',
                            style: TextStyle(
                              fontSize: 12,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            CupertinoIcons.location_fill,
                            size: 14,
                            color: CupertinoColors.systemRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        segment.endWaypoint?.name ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.label,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: CupertinoColors.systemGrey,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 根据路段特征推断路况等级
  RoadCondition _inferRoadCondition(SegmentModel segment) {
    // 根据爬升和距离推断路况
    final elevationGainPerKm = segment.elevationGain / segment.distance;

    if (elevationGainPerKm > 300) {
      return RoadCondition.poor; // 爬升很陡
    } else if (elevationGainPerKm > 200) {
      return RoadCondition.fair; // 爬升较陡
    } else if (elevationGainPerKm > 100) {
      return RoadCondition.good; // 适中爬升
    } else {
      return RoadCondition.excellent; // 平缓路段
    }
  }

  /// 获取路况文本
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

  /// 获取路况颜色
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
