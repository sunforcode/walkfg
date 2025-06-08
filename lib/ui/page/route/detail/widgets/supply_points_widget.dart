import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/supply_point_model.dart';

/// 补给点资源Widget
class SupplyPointsWidget extends StatefulWidget {
  final List<SupplyPointModel> supplyPoints;

  const SupplyPointsWidget({
    super.key,
    required this.supplyPoints,
  });

  @override
  State<SupplyPointsWidget> createState() => _SupplyPointsWidgetState();
}

class _SupplyPointsWidgetState extends State<SupplyPointsWidget> {
  bool _showAll = false;
  static const int _maxDisplayCount = 3;

  @override
  Widget build(BuildContext context) {
    if (widget.supplyPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayPoints = _showAll
        ? widget.supplyPoints
        : widget.supplyPoints.take(_maxDisplayCount).toList();
    final hasMore = widget.supplyPoints.length > _maxDisplayCount;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.bag,
                size: 20,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 8),
              const Text(
                '补给点详解',
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
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.supplyPoints.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 补给点列表
          ...displayPoints.map((supplyPoint) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildSupplyPointCard(supplyPoint),
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
                      '查看更多补给点',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${widget.supplyPoints.length - _maxDisplayCount}个)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      size: 16,
                      color: CupertinoColors.systemOrange,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建补给点卡片
  Widget _buildSupplyPointCard(SupplyPointModel supplyPoint) {
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
                supplyPoint.typeIcon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  supplyPoint.name ?? '未命名补给点',
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
                  color: _getTypeColor(supplyPoint.supplyType).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  supplyPoint.typeText,
                  style: TextStyle(
                    fontSize: 12,
                    color: _getTypeColor(supplyPoint.supplyType),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          if (supplyPoint.description != null) ...[
            const SizedBox(height: 8),
            Text(
              supplyPoint.description!,
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
                '${supplyPoint.latitude.toStringAsFixed(4)}, ${supplyPoint.longitude.toStringAsFixed(4)}',
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
                '海拔${supplyPoint.elevation.toInt()}m',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGrey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 补给点特性
          Row(
            children: [
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.bag,
                    size: 14,
                    color: CupertinoColors.systemOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    supplyPoint.typeText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.label,
                    ),
                  ),
                ],
              ),
              if (supplyPoint.distanceFromStart != null &&
                  supplyPoint.distanceFromStart! > 0) ...[
                const SizedBox(width: 16),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.location,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${supplyPoint.distanceFromStart!.toStringAsFixed(1)}km处',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.label,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(SupplyPointType type) {
    switch (type) {
      case SupplyPointType.store:
        return CupertinoColors.systemBlue;
      case SupplyPointType.shop:
        return CupertinoColors.systemGreen;
      case SupplyPointType.restaurant:
        return CupertinoColors.systemOrange;
      case SupplyPointType.accommodation:
        return CupertinoColors.systemPurple;
      case SupplyPointType.gasStation:
        return CupertinoColors.systemRed;
      case SupplyPointType.medical:
        return CupertinoColors.systemPink;
      case SupplyPointType.other:
        return CupertinoColors.systemGrey;
    }
  }
}
