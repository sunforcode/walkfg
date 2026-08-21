import 'package:flutter/cupertino.dart';
import 'package:walk/model/water/water_source_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 水源信息组件 (PRD §3.3.5)
///
/// 横滑卡片：水源名 + 水质标签 + 元信息
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
        const _SectionHeader(),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: waterSources.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _WaterCard(waterSource: waterSources[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："💧 水源信息"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '💧 水源信息',
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
//  水源卡片：180px 宽，圆角 12px 浅底
// ---------------------------------------------------------------------------

class _WaterCard extends StatelessWidget {
  final WaterSourceModel waterSource;
  const _WaterCard({required this.waterSource});

  @override
  Widget build(BuildContext context) {
    final qualityColor = _getQualityColor(waterSource.waterQuality);

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
          // 图标 + 名称 + 水质标签
          Row(
            children: [
              Text(waterSource.waterTypeIcon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  waterSource.name ?? '未命名水源',
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

          // 水质徽标
          const SizedBox(height: 6),
          _QualityBadge(quality: waterSource.waterQuality, color: qualityColor),

          // 描述
          if (waterSource.description != null) ...[
            const SizedBox(height: 6),
            Text(
              waterSource.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const Spacer(),

          // 类型 + 可靠性
          Row(
            children: [
              _MetaChip(
                icon: CupertinoIcons.drop,
                label: waterSource.waterTypeText,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                icon: CupertinoIcons.checkmark_shield,
                label: waterSource.reliabilityText,
              ),
            ],
          ),

          const SizedBox(height: 6),
          // 海拔
          Row(
            children: [
              const Icon(CupertinoIcons.arrow_up, size: 11, color: AppColors.sheetTextWeak),
              const SizedBox(width: 2),
              Text(
                '海拔${waterSource.elevation.toInt()}m',
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

  Color _getQualityColor(WaterQuality quality) {
    switch (quality) {
      case WaterQuality.excellent:
        return AppColors.badgeVerifiedText; // 绿
      case WaterQuality.good:
        return AppColors.badgeBlueText; // 蓝
      case WaterQuality.fair:
        return AppColors.badgeRecommendedText; // 橙
      case WaterQuality.poor:
        return AppColors.badgeEssentialText; // 红
      case WaterQuality.unknown:
        return AppColors.sheetTextWeak; // 灰
    }
  }
}

// ---------------------------------------------------------------------------
//  水质徽标 (优=绿 / 良=蓝 / 一般=橙 / 差=红)
// ---------------------------------------------------------------------------

class _QualityBadge extends StatelessWidget {
  final WaterQuality quality;
  final Color color;
  const _QualityBadge({required this.quality, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _qualityText,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String get _qualityText {
    switch (quality) {
      case WaterQuality.excellent:
        return '优';
      case WaterQuality.good:
        return '良';
      case WaterQuality.fair:
        return '一般';
      case WaterQuality.poor:
        return '差';
      case WaterQuality.unknown:
        return '未知';
    }
  }
}

// ---------------------------------------------------------------------------
//  元信息标签
// ---------------------------------------------------------------------------

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sheetTextSecondary),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.sheetTextSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
