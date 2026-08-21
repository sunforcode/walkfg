import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 相关路线推荐组件 (PRD §3.3.10)
///
/// 段标题"🗺 相关路线"；横滑卡片：路线名、评分+区域、指标（天数·难度）
class RelatedRoutesWidget extends StatelessWidget {
  final List<RouteModel> relatedRoutes;
  final void Function(RouteModel route)? onRouteTap;

  const RelatedRoutesWidget({
    super.key,
    required this.relatedRoutes,
    this.onRouteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedRoutes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: relatedRoutes.length),
        const SizedBox(height: 12),
        SizedBox(
          height: 146,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: relatedRoutes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) =>
                _RouteCard(route: relatedRoutes[index], onRouteTap: onRouteTap),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🗺 相关路线"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '🗺 相关路线',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.sheetTextPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count条',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.badgeBlueText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  路线卡片：180px 宽，flat bg
// ---------------------------------------------------------------------------

class _RouteCard extends StatelessWidget {
  final RouteModel route;
  final void Function(RouteModel route)? onRouteTap;
  const _RouteCard({required this.route, this.onRouteTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onRouteTap?.call(route),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.sheetCardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 路线名
            Text(
              route.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.sheetTextPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // 评分 + 区域
            Row(
              children: [
                const Icon(CupertinoIcons.star_fill,
                    size: 12, color: AppColors.badgeRecommendedText),
                const SizedBox(width: 2),
                Text(
                  route.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.sheetTextPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    route.region,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.sheetTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Spacer(),

            // 指标行：天数 · 难度
            Row(
              children: [
                _MetricChip(
                  icon: CupertinoIcons.calendar,
                  value: '${route.dailyPlans?.length ?? 0}天',
                ),
                const SizedBox(width: 8),
                _MetricChip(
                  icon: CupertinoIcons.chart_bar,
                  value: route.difficulty.getName(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  指标标签
// ---------------------------------------------------------------------------

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetricChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sheetTextSecondary),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}
