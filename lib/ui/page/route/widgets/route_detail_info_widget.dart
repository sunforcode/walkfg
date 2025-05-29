import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/map/track_point_model.dart';

/// 路线详细信息组件
class RouteDetailInfoWidget extends StatelessWidget {
  /// 当前轨迹
  final TrackModel currentTrack;

  /// 轨迹点列表（用于计算最高海拔）
  final List<TrackPointVO> trackPoints;

  /// 构造函数
  const RouteDetailInfoWidget({
    super.key,
    required this.currentTrack,
    required this.trackPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '路线详细信息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.label,
            ),
          ),
          const SizedBox(height: 12),

          // 第一行：距离和爬升
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.location,
                  label: '总距离',
                  value: '${currentTrack.distance.toStringAsFixed(1)} km',
                  color: CupertinoColors.systemBlue,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.arrow_up,
                  label: '总爬升',
                  value: '${currentTrack.elevationGain} m',
                  color: CupertinoColors.systemGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 第二行：下降和耗时
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.arrow_down,
                  label: '总下降',
                  value: '${currentTrack.elevationLoss} m',
                  color: CupertinoColors.systemOrange,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.time,
                  label: '预计耗时',
                  value: currentTrack.getEstimatedTimeText(),
                  color: CupertinoColors.systemPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 第三行：最高海拔和难度
          Row(
            children: [
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.triangle,
                  label: '最高海拔',
                  value: '${_getMaxElevation()} m',
                  color: CupertinoColors.systemTeal,
                ),
              ),
              Expanded(
                child: _buildDetailInfoItem(
                  icon: CupertinoIcons.chart_bar,
                  label: '难度等级',
                  value: currentTrack.getDifficultyName(),
                  color: CupertinoColors.systemRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建详细信息项
  Widget _buildDetailInfoItem({
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
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.label,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 获取最高海拔
  int _getMaxElevation() {
    if (trackPoints.isEmpty) return 0;
    return trackPoints
        .map((point) => point.elevation?.toInt() ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }
}