import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';

/// 路线信息部分组件
class RouteInfoSection extends StatelessWidget {
  /// 路线
  final RouteModel route;

  /// 构造函数
  const RouteInfoSection({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 路线名称
        Text(
          route.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // 路线描述
        if (route.description != null && route.description!.isNotEmpty)
          Text(
            route.description!,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
        const SizedBox(height: 16),

        // 路线基本信息
        _buildInfoRow(
            '距离', '${route.basicInfo.distance.toStringAsFixed(1)} 公里'),
        _buildInfoRow(
            '海拔增益', '${route.basicInfo.elevationGain.toStringAsFixed(0)} 米'),
        _buildInfoRow('预计时间', '${route.basicInfo.duration} 小时'),
        _buildInfoRow('难度', route.basicInfo.difficulty.getName()),

        // 路线标签
        if (route.tags != null && route.tags!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: route.tags!.map((tag) => _buildTag(tag)).toList(),
            ),
          ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建标签
  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey5,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 14,
          color: CupertinoColors.systemGrey,
        ),
      ),
    );
  }
}
