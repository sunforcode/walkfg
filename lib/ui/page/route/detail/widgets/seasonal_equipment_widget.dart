import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/gear_item_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 季节装备推荐组件 (PRD §3.3.8)
///
/// 段标题 "🎒 {season}装备推荐"；行列表：图标 + 装备名 + 优先级徽标
/// 行间 1px 分割线
class SeasonalEquipmentWidget extends StatelessWidget {
  /// 装备列表（从 route.seasonalGear 传入）
  final List<GearItemModel> gearList;

  /// 当前季节
  final String currentSeason;

  const SeasonalEquipmentWidget({
    super.key,
    required this.gearList,
    required this.currentSeason,
  });

  @override
  Widget build(BuildContext context) {
    if (gearList.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(season: currentSeason),
        const SizedBox(height: 12),
        _GearList(gearList: gearList),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🎒 {season}装备推荐"
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String season;
  const _SectionTitle({required this.season});

  @override
  Widget build(BuildContext context) {
    return Text(
      '🎒 $season装备推荐',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.sheetTextPrimary,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  装备列表（带行间分割线）
// ---------------------------------------------------------------------------

class _GearList extends StatelessWidget {
  final List<GearItemModel> gearList;
  const _GearList({required this.gearList});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(gearList.length, (index) {
          final item = gearList[index];
          return Column(
            children: [
              _GearRow(item: item),
              if (index < gearList.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Container(
                    height: 1,
                    color: AppColors.sheetDivider,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  装备行：图标 + 名称 + 优先级徽标
// ---------------------------------------------------------------------------

class _GearRow extends StatelessWidget {
  final GearItemModel item;
  const _GearRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 图标
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.sheetTagBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              CupertinoIcons.bag,
              size: 14,
              color: AppColors.sheetTextSecondary,
            ),
          ),
          const SizedBox(width: 12),

          // 装备名
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.sheetTextPrimary,
              ),
            ),
          ),

          // 优先级徽标
          _PriorityBadge(priority: item.priority), // GearPriority enum
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  优先级徽标：必备=红底 / 推荐=橙底 (PRD §7.1)
// ---------------------------------------------------------------------------

class _PriorityBadge extends StatelessWidget {
  final GearPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final isEssential = priority == GearPriority.required;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isEssential ? AppColors.badgeEssentialBg : AppColors.badgeRecommendedBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isEssential ? '必备' : '推荐',
        style: TextStyle(
          fontSize: 10,
          color: isEssential ? AppColors.badgeEssentialText : AppColors.badgeRecommendedText,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
