import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 时间线数据项
class TimelineItem {
  /// 标题
  final String title;
  
  /// 子标题
  final String subtitle;
  
  /// 图标
  final IconData icon;
  
  /// 颜色
  final Color color;
  
  /// 构造函数
  TimelineItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.color = AppColors.primary,
  });
}

/// 时间线数据
class TimelineData {
  /// 时间线项目列表
  final List<TimelineItem> items;
  
  /// 构造函数
  TimelineData({
    required this.items,
  });
}

/// 行程时间线卡片
class TimelineCard extends StatelessWidget {
  /// 时间线数据
  final TimelineData timelineData;
  
  /// 出发日期
  final DateTime? startDate;
  
  /// 构造函数
  const TimelineCard({
    Key? key,
    required this.timelineData,
    this.startDate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '行程时间线',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildTimelineItems(),
      ),
    );
  }
  
  /// 构建时间线项目列表
  List<Widget> _buildTimelineItems() {
    final List<Widget> widgets = [];
    
    for (int i = 0; i < timelineData.items.length; i++) {
      final item = timelineData.items[i];
      
      // 添加时间线项目
      widgets.add(
        _buildTimelineItem(
          item,
          isFirst: i == 0,
          isLast: i == timelineData.items.length - 1,
          dayOffset: i,
        ),
      );
      
      // 如果不是最后一项，添加连接线
      if (i < timelineData.items.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Container(
              width: 2,
              height: 24,
              color: CupertinoColors.systemGrey4,
            ),
          ),
        );
      }
    }
    
    return widgets;
  }
  
  /// 构建时间线项目
  Widget _buildTimelineItem(TimelineItem item, {
    required bool isFirst,
    required bool isLast,
    required int dayOffset,
  }) {
    // 计算日期
    String dateText = '';
    if (startDate != null) {
      final date = startDate!.add(Duration(days: dayOffset));
      dateText = DateFormat('MM/dd\nE', 'zh_CN').format(date);
    }
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期和时间线节点
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  item.icon,
                  color: CupertinoColors.white,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // 内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 日期和标题
              Row(
                children: [
                  if (dateText.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        dateText,
                        style: const TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // 子标题
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}