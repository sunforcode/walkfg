import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 相关行程组件 (PRD §3.3.11)
///
/// 段标题"👥 相关行程"；纵向卡片：行程名+右箭头、副行（组织者·日期·人数·费用）、描述行
/// v1 点击无响应
class RelatedTripsWidget extends StatelessWidget {
  final String routeId;
  final List<TripModel> relatedTrips;
  final void Function(TripModel trip)? onTripTap;

  const RelatedTripsWidget({
    super.key,
    required this.routeId,
    required this.relatedTrips,
    this.onTripTap,
  });

  @override
  Widget build(BuildContext context) {
    if (relatedTrips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(count: relatedTrips.length),
        const SizedBox(height: 12),
        ...relatedTrips.asMap().entries.map((entry) {
          final index = entry.key;
          final trip = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                bottom: index < relatedTrips.length - 1 ? 10 : 0),
            child: _TripCard(trip: trip),
          );
        }).toList(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  段标题："👥 相关行程"
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final int count;
  const _SectionHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '👥 相关行程',
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
//  行程卡片：纵向排列，圆角 12px 浅底
// ---------------------------------------------------------------------------

class _TripCard extends StatelessWidget {
  final TripModel trip;
  const _TripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 行程名 + 右箭头
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sheetTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(CupertinoIcons.chevron_right,
                  size: 14, color: AppColors.sheetTextWeak),
            ],
          ),
          const SizedBox(height: 6),

          // 副行：组织者 · 日期 · 人数 · 费用
          _MetaRow(trip: trip),

          // 描述行
          if (trip.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              trip.description.length > 80
                  ? '${trip.description.substring(0, 80)}...'
                  : trip.description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.sheetTextSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  副行：组织者 · 日期 · 人数 · 费用
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  final TripModel trip;
  const _MetaRow({required this.trip});

  @override
  Widget build(BuildContext context) {
    final days =
        trip.endDate.difference(trip.startDate).inDays + 1;

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      children: [
        // 组织者
        _MetaChip(
          icon: CupertinoIcons.person,
          value: trip.organizerId,
        ),
        // 日期
        _MetaChip(
          icon: CupertinoIcons.calendar,
          value: '${trip.startDate.month}/${trip.startDate.day}·$days天',
        ),
        // 人数
        _MetaChip(
          icon: CupertinoIcons.person_2,
          value: '${trip.participantCount}人',
        ),
        // 费用
        if (trip.budget != null)
          _MetaChip(
            icon: CupertinoIcons.money_yen_circle,
            value: '¥${trip.budget!.toInt()}',
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  副行标签
// ---------------------------------------------------------------------------

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String value;
  const _MetaChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.sheetTextWeak),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.sheetTextSecondary,
          ),
        ),
      ],
    );
  }
}
