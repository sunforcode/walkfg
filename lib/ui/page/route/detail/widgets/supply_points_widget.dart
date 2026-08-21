import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/supply_point_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 补给点组件 (PRD §3.3.6)
///
/// 横滑卡片：名称 + 类型标签 + 描述 + 距起点
class SupplyPointsWidget extends StatelessWidget {
  final List<SupplyPointModel> supplyPoints;

  const SupplyPointsWidget({
    super.key,
    required this.supplyPoints,
  });

  @override
  Widget build(BuildContext context) {
    if (supplyPoints.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: supplyPoints.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _SupplyCard(supplyPoint: supplyPoints[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🏪 补给点"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Text(
          '🏪 补给点',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  补给点卡片：180px 宽，圆角 12px 浅底
// ---------------------------------------------------------------------------

class _SupplyCard extends StatelessWidget {
  final SupplyPointModel supplyPoint;
  const _SupplyCard({required this.supplyPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图标 + 名称 + 类型标签
          Row(
            children: [
              Text(supplyPoint.typeIcon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  supplyPoint.name ?? '未命名补给点',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sheetTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // 类型徽标
          _TypeBadge(type: supplyPoint.supplyType),
          const SizedBox(height: 6),

          // 描述
          if (supplyPoint.description != null)
            Text(
              supplyPoint.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 距起点
          if (supplyPoint.distanceFromStart != null &&
              supplyPoint.distanceFromStart! > 0)
            Row(
              children: [
                const Icon(CupertinoIcons.location, size: 11, color: AppColors.sheetTextWeak),
                const SizedBox(width: 2),
                Text(
                  '距起点 ${supplyPoint.distanceFromStart!.toStringAsFixed(1)}km',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.sheetTextWeak,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  类型徽标 (蓝色底)
// ---------------------------------------------------------------------------

class _TypeBadge extends StatelessWidget {
  final SupplyPointType type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _typeText,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.badgeBlueText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _typeText {
    switch (type) {
      case SupplyPointType.store:
        return '商店';
      case SupplyPointType.shop:
        return '小卖部';
      case SupplyPointType.restaurant:
        return '餐厅';
      case SupplyPointType.accommodation:
        return '住宿';
      case SupplyPointType.gasStation:
        return '加油站';
      case SupplyPointType.medical:
        return '医疗点';
      case SupplyPointType.other:
        return '其他';
    }
  }
}
