import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/theme/theme/app_colors.dart';
import 'package:walk/ui/page/trip_plan/components/trip_plan_card.dart';

/// 路线概览卡片
class RouteOverviewCard extends StatelessWidget {
  /// 路线数据
  final RouteModel route;
  
  /// 构造函数
  const RouteOverviewCard({
    Key? key,
    required this.route,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TripPlanCard(
      title: '路线概览',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线名称
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 路线描述
          Text(
            route.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 路线统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('距离', '${route.basicInfo.distance} 公里'),
              _buildStatItem('时长', '${route.basicInfo.duration} 天'),
              _buildStatItem('难度', route.getDifficultyName()),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建统计项
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}