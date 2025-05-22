import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:walk/model/model/water/water_plan_model.dart';
import 'package:walk/model/model/water/water_source_model.dart';
import 'package:walk/model/model/water/day_water_plan_model.dart';
import 'package:walk/model/model/water/water_types.dart';

class TripWaterWidget extends StatelessWidget {
  final WaterPlanModel? waterPlan;

  const TripWaterWidget({
    super.key,
    required this.waterPlan,
  });

  @override
  Widget build(BuildContext context) {
    if (waterPlan == null || waterPlan!.dayWaterPlans.isEmpty) {
      return const Text(
        '暂无饮水计划',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 饮水计划基本信息
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                waterPlan!.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                waterPlan!.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.person_2_fill,
                    label: '${waterPlan!.personCount}人',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.calendar,
                    label: '${waterPlan!.tripDays}天',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.drop_fill,
                    label: '${_formatVolume(waterPlan!.totalWaterNeed)}/总需求',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.drop,
                    label:
                        '${_formatVolume(waterPlan!.totalWaterNeed / waterPlan!.tripDays)}/天',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.person_crop_circle_fill,
                    label:
                        '${_formatVolume(waterPlan!.totalWaterNeed / (waterPlan!.personCount * waterPlan!.tripDays))}/人/天',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 每日饮水计划
        ...waterPlan!.dayWaterPlans
            .map((dayPlan) => _buildDayWaterPlan(dayPlan))
            .toList(),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ],
    );
  }

  String _formatVolume(num volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}L';
    } else {
      return '${volume.toStringAsFixed(0)}ml';
    }
  }

  Widget _buildDayWaterPlan(DayWaterPlanModel dayPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '第${dayPlan.dayNumber}天饮水计划',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 饮水需求
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildWaterNeedItem(
                    label: '基础饮水',
                    volume: dayPlan.baseWaterIntake,
                    color: CupertinoColors.activeBlue,
                  ),
                  _buildWaterNeedItem(
                    label: '活动饮水',
                    volume: dayPlan.activityWaterIntake,
                    color: CupertinoColors.systemGreen,
                  ),
                  _buildWaterNeedItem(
                    label: '总需求',
                    volume: dayPlan.totalWaterNeed,
                    color: CupertinoColors.systemIndigo,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoItem(
                    icon: CupertinoIcons.thermometer,
                    label: '温度: ${dayPlan.temperature}°C',
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    icon: CupertinoIcons.speedometer,
                    label: '强度: ${dayPlan.getIntensityText()}',
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 可用水源
        if (dayPlan.availableSources.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              '可用水源',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.systemGrey.darkColor,
              ),
            ),
          ),
          ...dayPlan.availableSources
              .map((source) => _buildWaterSource(source))
              .toList(),
        ],

        const Divider(height: 32),
      ],
    );
  }

  Widget _buildWaterNeedItem({
    required String label,
    required int volume,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatVolume(volume),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWaterSource(WaterSourceModel source) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey5),
      ),
      child: Row(
        children: [
          // 水源图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getWaterSourceIcon(source.type),
              color: CupertinoColors.activeBlue,
            ),
          ),

          const SizedBox(width: 12),

          // 水源信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${source.getTypeText()} · ${source.getQualityText()} · ${_formatVolume(source.estimatedVolume)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (source.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    source.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.location,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      source.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.arrow_right_arrow_left,
                      size: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '距路线${source.distanceFromTrail}米',
                      style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                if (source.needsTreatment) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        size: 12,
                        color: CupertinoColors.systemOrange,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '需要净水处理',
                        style: TextStyle(
                          fontSize: 12,
                          color: CupertinoColors.systemOrange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWaterSourceIcon(WaterSourceType type) {
    switch (type) {
      case WaterSourceType.river:
        return CupertinoIcons.arrow_2_circlepath;
      case WaterSourceType.stream:
        return CupertinoIcons.arrow_swap;
      case WaterSourceType.lake:
        return CupertinoIcons.drop_fill;
      case WaterSourceType.spring:
        return CupertinoIcons.drop;
      case WaterSourceType.tap:
        return CupertinoIcons.house_fill;
    }
  }
}
