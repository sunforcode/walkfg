import 'package:flutter/cupertino.dart';
import 'package:walk/model/water/water_source_model.dart';

/// 水源资源Widget
class WaterSourcesWidget extends StatefulWidget {
  final List<WaterSourceModel> waterSources;

  const WaterSourcesWidget({
    super.key,
    required this.waterSources,
  });

  @override
  State<WaterSourcesWidget> createState() => _WaterSourcesWidgetState();
}

class _WaterSourcesWidgetState extends State<WaterSourcesWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.waterSources.isEmpty) {
      return const SizedBox.shrink();
    }

    final displaySources = _showAll
        ? widget.waterSources
        : widget.waterSources.take(_maxDisplayCount).toList();
    final hasMore = widget.waterSources.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.drop,
                size: 20,
                color: CupertinoColors.systemBlue,
              ),
              const SizedBox(width: 8),
              const Text(
                '水源点详解',
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
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.waterSources.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 水源列表
          ...displaySources.map((waterSource) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildWaterSourceCard(waterSource),
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
                      '查看更多水源点',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.waterSources.length - _maxDisplayCount}个)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: CupertinoColors.systemBlue,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建水源卡片
  Widget _buildWaterSourceCard(WaterSourceModel waterSource) {
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
              Text(
                waterSource.waterTypeIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  waterSource.name ?? '未命名水源',
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
                  color: _getQualityColor(waterSource.waterQuality)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  waterSource.waterQualityText,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getQualityColor(waterSource.waterQuality),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          if (waterSource.description != null) ...[
            const SizedBox(height: 8),
            Text(
              waterSource.description!,
              style: const TextStyle(
                fontSize: 14,
                color: CupertinoColors.secondaryLabel,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // 位置和海拔信息
          Row(
            children: [
              const Icon(
                CupertinoIcons.location,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${waterSource.latitude.toStringAsFixed(4)}, ${waterSource.longitude.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const Spacer(),
              const Icon(
                CupertinoIcons.arrow_up,
                size: 14,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '海拔${waterSource.elevation.toInt()}m',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 水源特性
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.drop,
                    size: 14,
                    color: CupertinoColors.systemBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    waterSource.waterTypeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.checkmark_shield,
                    size: 14,
                    color: CupertinoColors.systemGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${waterSource.reliabilityText}可靠性',
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (waterSource.notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CupertinoColors.systemYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.info_circle,
                    size: 14,
                    color: CupertinoColors.systemYellow,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      waterSource.notes,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
