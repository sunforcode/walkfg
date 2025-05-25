import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk/model/route/daily_itinerary_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 每日行程卡片
class DailyItineraryCard extends StatelessWidget {
  /// 每日行程列表
  final List<DailyItinerary> dailyItineraries;

  /// 编辑回调
  final VoidCallback onEdit;

  /// 添加行程日回调
  final VoidCallback onAddDay;

  /// 构造函数
  const DailyItineraryCard({
    Key? key,
    required this.dailyItineraries,
    required this.onEdit,
    required this.onAddDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '每日行程',
      onEdit: onEdit,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 每日行程列表
          ...dailyItineraries.asMap().entries.map((entry) {
            final index = entry.key;
            final itinerary = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 行程日标题
                Text(
                  '第${index + 1}天 · ${_formatDate(itinerary.date)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // 行程卡片
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 行程标题
                      Text(
                        '${itinerary.startPoint} → ${itinerary.endPoint}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 行程详情
                      Row(
                        children: [
                          _buildDetailItem(
                            CupertinoIcons.map,
                            '路线',
                            _buildRouteText(itinerary),
                          ),
                          const SizedBox(width: 16),
                          _buildDetailItem(
                            CupertinoIcons.arrow_right,
                            '距离',
                            '${itinerary.distance}公里',
                          ),
                          const SizedBox(width: 16),
                          _buildDetailItem(
                            CupertinoIcons.time,
                            '时间',
                            '${itinerary.duration}小时',
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // 住宿和餐饮
                      Row(
                        children: [
                          _buildDetailItem(
                            CupertinoIcons.house,
                            '住宿',
                            itinerary.accommodation,
                          ),
                          const SizedBox(width: 16),
                          _buildDetailItem(
                            CupertinoIcons.cart,
                            '餐饮',
                            itinerary.meals,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 如果不是最后一个行程日，添加间隔
                if (index < dailyItineraries.length - 1)
                  const SizedBox(height: 16),
              ],
            );
          }).toList(),

          // 添加行程日按钮
          if (dailyItineraries.isEmpty)
            const Center(
              child: Text('暂无行程安排'),
            ),

          const SizedBox(height: 16),

          // 添加行程日按钮
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: onAddDay,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  '+ 添加行程日',
                  style: TextStyle(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建详情项
  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标签
          Row(
            children: [
              Icon(
                icon,
                size: 12,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // 值
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return DateFormat('MM月dd日 EEE', 'zh_CN').format(date);
  }

  /// 构建路线文本
  String _buildRouteText(DailyItinerary itinerary) {
    if (itinerary.waypoints.isEmpty) {
      return '${itinerary.startPoint} → ${itinerary.endPoint}';
    } else {
      final waypointNames =
          itinerary.waypoints.map((wp) => wp.name).join(' → ');
      return '${itinerary.startPoint} → $waypointNames → ${itinerary.endPoint}';
    }
  }
}
