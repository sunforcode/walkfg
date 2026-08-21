import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';

/// 路线统计卡片组件 - 显示路线名、距离、时间、爬升等关键数据
class RouteStatsCardWidget extends StatelessWidget {
  /// 路线数据
  final RouteModel route;

  /// 卡片高度，不传则自适应内容高度
  final double? height;

  const RouteStatsCardWidget({
    super.key,
    required this.route,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final track = route.defaultMap;
    
    // 获取统计数据
    final distance = track?.distance ?? route.distance;
    final duration = track?.getEstimatedTimeText() ?? route.durationText;
    final elevationGain = track?.elevationGain.toInt() ?? route.elevationGain.toInt();
    final elevationLoss = track?.elevationLoss.toInt() ?? route.elevationLoss.toInt();

    return SizedBox(
      height: height,
      child: Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动手柄
          Center(
            child: Container(
              width: 30,
              height: 4,
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // 路线名称
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.label,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // 地区 + 难度标签行
          Row(
            children: [
              const Icon(
                CupertinoIcons.location_solid,
                size: 12,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                route.region,
                style: const TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.systemGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: route.difficulty.getColor().withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  route.difficulty.getName(),
                  style: TextStyle(
                    fontSize: 11,
                    color: route.difficulty.getColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 第一行：距离
          _buildStatRow(
            label: '距离',
            value: '${distance.toStringAsFixed(2)} km',
          ),

          const SizedBox(height: 20),

          // 第二行：时间 | 爬升 | 下降
          Row(
            children: [
              Expanded(
                child: _buildStatColumn(
                  label: '时间',
                  value: duration,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatColumn(
                  label: '爬升',
                  value: '$elevationGain m',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatColumn(
                  label: '下降',
                  value: '$elevationLoss m',
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// 构建统计行（主要数据）
  Widget _buildStatRow({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  /// 构建统计列（副要数据）
  Widget _buildStatColumn({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.label,
          ),
        ),
        const SizedBox(height: 2),
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
}
