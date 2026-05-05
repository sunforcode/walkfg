import 'package:flutter/cupertino.dart';
import 'package:walk/model/water/water_source_model.dart';

/// 水源点Widget（横向滑动）
class WaterSourcesWidget extends StatelessWidget {
  final List<WaterSourceModel> waterSources;

  const WaterSourcesWidget({
    super.key,
    required this.waterSources,
  });

  @override
  Widget build(BuildContext context) {
    if (waterSources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Row(
          children: [
            const Icon(
              CupertinoIcons.drop,
              size: 16,
              color: CupertinoColors.systemBlue,
            ),
            const SizedBox(width: 6),
            const Text(
              '水源点',
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
                color: CupertinoColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${waterSources.length}个',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 横向列表
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: waterSources.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _buildCard(waterSources[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(WaterSourceModel waterSource) {
    final qualityColor = _getQualityColor(waterSource.waterQuality);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标 + 名称 + 水质标签
          Row(
            children: [
              Text(waterSource.waterTypeIcon,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  waterSource.name ?? '未命名水源',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  waterSource.waterQualityText,
                  style: TextStyle(
                    fontSize: 10,
                    color: qualityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 描述
          if (waterSource.description != null)
            Text(
              waterSource.description!,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 类型 + 可靠性
          Row(
            children: [
              _tag(
                CupertinoIcons.drop,
                waterSource.waterTypeText,
                CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              _tag(
                CupertinoIcons.checkmark_shield,
                waterSource.reliabilityText,
                CupertinoColors.systemGreen,
              ),
            ],
          ),

          const SizedBox(height: 6),
          // 海拔
          Row(
            children: [
              const Icon(CupertinoIcons.arrow_up,
                  size: 11, color: CupertinoColors.systemGrey),
              const SizedBox(width: 2),
              Text(
                '海拔${waterSource.elevation.toInt()}m',
                style: const TextStyle(
                  fontSize: 11,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getQualityColor(WaterQuality quality) {
    switch (quality) {
      case WaterQuality.excellent:
        return CupertinoColors.systemGreen;
      case WaterQuality.good:
        return CupertinoColors.systemBlue;
      case WaterQuality.fair:
        return CupertinoColors.systemOrange;
      case WaterQuality.poor:
        return CupertinoColors.systemRed;
      case WaterQuality.unknown:
        return CupertinoColors.systemGrey;
    }
  }
}
