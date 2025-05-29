import 'package:flutter/cupertino.dart';

/// 相关规划组件 - 展示该路线别人的规划行程
class RelatedTripsWidget extends StatelessWidget {
  /// 路线ID
  final String routeId;
  
  /// 相关行程列表
  final List<Map<String, dynamic>> relatedTrips;
  
  /// 点击行程的回调
  final Function(Map<String, dynamic> trip)? onTripTap;

  const RelatedTripsWidget({
    super.key,
    required this.routeId,
    required this.relatedTrips,
    this.onTripTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedTrips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar_badge_plus,
                size: 20,
                color: CupertinoColors.systemIndigo,
              ),
              const SizedBox(width: 8),
              const Text(
                '相关规划',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.label,
                ),
              ),
              const Spacer(),
              Text(
                '${relatedTrips.length}个行程',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 行程列表
          ...relatedTrips.asMap().entries.map((entry) {
            final index = entry.key;
            final trip = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < relatedTrips.length - 1 ? 12 : 0),
              child: _buildTripCard(trip),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建行程卡片
  Widget _buildTripCard(Map<String, dynamic> trip) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => onTripTap?.call(trip),
      child: Container(
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
            // 行程标题和作者
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip['title'] ?? '未命名行程',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
                // 作者头像和名称
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          (trip['authorName'] ?? '用户')[0],
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      trip['authorName'] ?? '匿名用户',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 行程时间和天数
            Row(
              children: [
                Icon(
                  CupertinoIcons.calendar,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  trip['startDate'] ?? '待定',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  CupertinoIcons.time,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${trip['days'] ?? 0}天',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 行程亮点
            if (trip['highlights'] != null && (trip['highlights'] as List).isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (trip['highlights'] as List).take(3).map((highlight) => 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      highlight.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.systemIndigo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 8),
            ],
            
            // 行程描述
            if (trip['description'] != null) ...[
              Text(
                trip['description'].toString().length > 80 
                    ? '${trip['description'].toString().substring(0, 80)}...'
                    : trip['description'].toString(),
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.secondaryLabel,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // 行程统计信息
            Row(
              children: [
                // 参与人数
                if (trip['participantCount'] != null) ...[
                  _buildTripStat(
                    icon: CupertinoIcons.person_2,
                    value: '${trip['participantCount']}人',
                    color: CupertinoColors.systemBlue,
                  ),
                  const SizedBox(width: 16),
                ],
                
                // 预算
                if (trip['budget'] != null) ...[
                  _buildTripStat(
                    icon: CupertinoIcons.money_yen_circle,
                    value: '¥${trip['budget']}',
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 16),
                ],
                
                // 状态
                _buildTripStat(
                  icon: _getTripStatusIcon(trip['status']),
                  value: _getTripStatusText(trip['status']),
                  color: _getTripStatusColor(trip['status']),
                ),
                
                const Spacer(),
                
                // 查看详情
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建行程统计项
  Widget _buildTripStat({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  /// 获取行程状态图标
  IconData _getTripStatusIcon(String? status) {
    switch (status) {
      case 'planning':
        return CupertinoIcons.clock;
      case 'recruiting':
        return CupertinoIcons.person_add;
      case 'confirmed':
        return CupertinoIcons.checkmark_circle;
      case 'completed':
        return CupertinoIcons.checkmark_circle_fill;
      case 'cancelled':
        return CupertinoIcons.xmark_circle;
      default:
        return CupertinoIcons.clock;
    }
  }

  /// 获取行程状态文本
  String _getTripStatusText(String? status) {
    switch (status) {
      case 'planning':
        return '规划中';
      case 'recruiting':
        return '招募中';
      case 'confirmed':
        return '已确认';
      case 'completed':
        return '已完成';
      case 'cancelled':
        return '已取消';
      default:
        return '未知';
    }
  }

  /// 获取行程状态颜色
  Color _getTripStatusColor(String? status) {
    switch (status) {
      case 'planning':
        return CupertinoColors.systemOrange;
      case 'recruiting':
        return CupertinoColors.systemBlue;
      case 'confirmed':
        return CupertinoColors.systemGreen;
      case 'completed':
        return CupertinoColors.systemPurple;
      case 'cancelled':
        return CupertinoColors.systemRed;
      default:
        return CupertinoColors.systemGrey;
    }
  }
}