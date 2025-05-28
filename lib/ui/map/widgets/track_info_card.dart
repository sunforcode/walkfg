import 'package:flutter/material.dart';
import 'package:walk/model/map/map_data_model.dart';

/// 轨迹信息卡片
class TrackInfoCard extends StatelessWidget {
  final MapDataModel mapData;
  final VoidCallback? onClose;

  const TrackInfoCard({
    super.key,
    required this.mapData,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题和关闭按钮
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '轨迹信息',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: onClose,
                  ),
              ],
            ),
            const Divider(),

            // 轨迹信息
            _buildInfoRow(
                '距离', '${mapData.totalDistance.toStringAsFixed(1)} 公里'),
            const SizedBox(height: 8),
            _buildInfoRow(
                '累计上升', '${mapData.totalAscent.toStringAsFixed(0)} 米'),
            const SizedBox(height: 8),
            _buildInfoRow(
                '累计下降', '${mapData.totalDescent.toStringAsFixed(0)} 米'),
            const SizedBox(height: 8),
            _buildInfoRow('最高点',
                '${mapData.highestPoint.elevation.toStringAsFixed(0)} 米'),
            const SizedBox(height: 8),
            _buildInfoRow(
                '最低点', '${mapData.lowestPoint.elevation.toStringAsFixed(0)} 米'),
            const SizedBox(height: 8),
            _buildInfoRow('轨迹点数', '${mapData.pointCount}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
