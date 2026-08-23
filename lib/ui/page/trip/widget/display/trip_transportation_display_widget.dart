import 'package:flutter/cupertino.dart';
import 'package:walk/model/trip/trip_model.dart';
import 'package:walk/theme/tokens/colors.dart';

/// 交通住宿展示组件
class TripTransportationDisplayWidget extends StatelessWidget {
  final TripModel trip;

  const TripTransportationDisplayWidget({
    super.key,
    required this.trip,
  });

  @override
  Widget build(BuildContext context) {
    // 这里可以根据实际的交通住宿数据来判断是否显示
    // 目前先显示占位内容

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          _buildSectionHeader(),
          const SizedBox(height: 16),

          // 交通住宿信息卡片
          _buildTransportationCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.car,
          size: 20,
          color: AppColors.statusPreparingText,
        ),
        const SizedBox(width: 8),
        const Text(
          '交通住宿',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusPreparingBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '待规划',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.statusPreparingText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransportationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sheetCardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.sheetDivider,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 交通信息
          _buildTransportSection(),
          const SizedBox(height: 16),

          // 住宿信息
          _buildAccommodationSection(),

          // 提醒信息
          const SizedBox(height: 12),
          _buildInfoTip(),
        ],
      ),
    );
  }

  Widget _buildTransportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.car_detailed,
              size: 16,
              color: AppColors.interactiveAccent,
            ),
            const SizedBox(width: 8),
            const Text(
              '交通方式',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.interactiveAccentBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '待确定',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.interactiveAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '交通方式详情展示区域',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildAccommodationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              CupertinoIcons.house,
              size: 16,
              color: AppColors.statusPlanningText,
            ),
            const SizedBox(width: 8),
            const Text(
              '住宿安排',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusPlanningBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '待确定',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.statusPlanningText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          '住宿安排详情展示区域',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTip() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.statusPlanningBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CupertinoIcons.info_circle,
            size: 14,
            color: AppColors.statusPlanningText,
          ),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '建议提前预订交通和住宿，特别是旺季出行',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
