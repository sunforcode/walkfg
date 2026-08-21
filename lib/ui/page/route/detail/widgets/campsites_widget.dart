import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/campsite_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 营地资源组件 (PRD §3.3.4)
///
/// 横滑卡片（180px 宽），营地名 + 设施描述 + 元信息
class CampsitesWidget extends StatelessWidget {
  final List<CampsiteModel> campsites;

  const CampsitesWidget({
    super.key,
    required this.campsites,
  });

  @override
  Widget build(BuildContext context) {
    if (campsites.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: campsites.length),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: campsites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _CampsiteCard(campsite: campsites[index]),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："🏕 营地资源"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '🏕 营地资源',
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
            '$count个',
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
//  营地卡片：180px 宽，圆角 12px 浅底
// ---------------------------------------------------------------------------

class _CampsiteCard extends StatelessWidget {
  final CampsiteModel campsite;
  const _CampsiteCard({required this.campsite});

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
          // 图标 + 名称
          Row(
            children: [
              Text(campsite.campsiteTypeIcon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  campsite.name ?? '未命名营地',
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
          const SizedBox(height: 6),

          // 描述
          if (campsite.description != null)
            Text(
              campsite.description!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 类型 + 容量
          Row(
            children: [
              _MetaChip(
                icon: CupertinoIcons.house,
                label: campsite.campsiteTypeText,
              ),
              const SizedBox(width: 8),
              _MetaChip(
                icon: CupertinoIcons.person_2,
                label: campsite.capacityText,
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
                '海拔${campsite.elevation.toInt()}m',
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
