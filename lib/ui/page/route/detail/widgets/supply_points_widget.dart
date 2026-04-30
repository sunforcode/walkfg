import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/supply_point_model.dart';

/// 补给点Widget（横向滑动）
class SupplyPointsWidget extends StatelessWidget {
  final List<SupplyPointModel> supplyPoints;

  const SupplyPointsWidget({
    super.key,
    required this.supplyPoints,
  });

  @override
  Widget build(BuildContext context) {
    if (supplyPoints.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              const Icon(
                CupertinoIcons.bag,
                size: 16,
                color: CupertinoColors.systemOrange,
              ),
              const SizedBox(width: 6),
              const Text(
                '补给点',
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
                  color: CupertinoColors.systemOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${supplyPoints.length}个',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 横向列表
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: supplyPoints.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) => _buildCard(supplyPoints[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(SupplyPointModel supplyPoint) {
    final typeColor = _getTypeColor(supplyPoint.supplyType);

    return Container(
      width: 190,
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
          // 图标 + 名称 + 类型标签
          Row(
            children: [
              Text(supplyPoint.typeIcon,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  supplyPoint.name ?? '未命名补给点',
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
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  supplyPoint.typeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: typeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 描述
          if (supplyPoint.description != null)
            Text(
              supplyPoint.description!,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 距离（若有）
          if (supplyPoint.distanceFromStart != null &&
              supplyPoint.distanceFromStart! > 0)
            Row(
              children: [
                const Icon(CupertinoIcons.location,
                    size: 11, color: CupertinoColors.systemGrey),
                const SizedBox(width: 2),
                Text(
                  '距起点 ${supplyPoint.distanceFromStart!.toStringAsFixed(1)}km',
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
