import 'package:flutter/cupertino.dart';
import 'package:walk/model/route/campsite_model.dart';

/// 营地资源Widget（横向滑动）
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
        // 标题行
        Row(
          children: [
            const Icon(
              CupertinoIcons.house,
              size: 16,
              color: CupertinoColors.systemGreen,
            ),
            const SizedBox(width: 6),
            const Text(
              '营地资源',
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
                color: CupertinoColors.systemGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${campsites.length}个',
                style: const TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.systemGreen,
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
            itemCount: campsites.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _buildCard(campsites[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(CampsiteModel campsite) {
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
          // 图标 + 名称
          Row(
            children: [
              Text(campsite.campsiteTypeIcon,
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  campsite.name ?? '未命名营地',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.label,
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
                color: CupertinoColors.secondaryLabel,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

          const Spacer(),

          // 类型 + 容量
          Row(
            children: [
              _tag(
                CupertinoIcons.house,
                campsite.campsiteTypeText,
                CupertinoColors.systemGreen,
              ),
              const SizedBox(width: 8),
              _tag(
                CupertinoIcons.person_2,
                campsite.capacityText,
                CupertinoColors.systemPurple,
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
                '海拔${campsite.elevation.toInt()}m',
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
}
