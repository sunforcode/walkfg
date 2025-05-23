import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Divider;
import 'package:walk/model/model/water/water_plan_model.dart';
import 'package:walk/model/model/water/water_source_model.dart';
import 'package:walk/model/model/water/day_water_plan_model.dart';
import 'package:walk/model/model/water/water_types.dart';

class TripWaterWidget extends StatefulWidget {
  final WaterPlanModel? waterPlan;

  const TripWaterWidget({
    super.key,
    required this.waterPlan,
  });

  @override
  State<TripWaterWidget> createState() => _TripWaterWidgetState();
}

class _TripWaterWidgetState extends State<TripWaterWidget> {
  bool _isExpanded = false;
  List<bool> _dayExpanded = [];

  @override
  void initState() {
    super.initState();
    _initDayExpandedState();
  }

  @override
  void didUpdateWidget(TripWaterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterPlan != widget.waterPlan) {
      _initDayExpandedState();
    }
  }

  void _initDayExpandedState() {
    if (widget.waterPlan != null) {
      _dayExpanded =
          List.generate(widget.waterPlan!.dayWaterPlans.length, (_) => false);
    } else {
      _dayExpanded = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.waterPlan == null || widget.waterPlan!.dayWaterPlans.isEmpty) {
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
        // 饮水计划概览卡片（始终显示）
        _buildWaterPlanOverview(),

        // 详细信息（根据展开状态显示）
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          ..._buildDetailedContent(),
        ],
      ],
    );
  }

  Widget _buildWaterPlanOverview() {
    final waterPlan = widget.waterPlan!;

    // 计算需要处理的水源数量
    final needTreatmentCount =
        waterPlan.waterSources.where((source) => source.needsTreatment).length;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.activeBlue.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Row(
              children: [
                Icon(
                  CupertinoIcons.drop_fill,
                  color: CupertinoColors.activeBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    waterPlan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  color: CupertinoColors.systemGrey,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 关键数据行
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKeyMetric(
                  label: '总需求',
                  value: _formatVolume(waterPlan.totalWaterNeed),
                  icon: CupertinoIcons.drop_fill,
                ),
                _buildKeyMetric(
                  label: '人均/天',
                  value: _formatVolume(waterPlan.waterPerPersonPerDay),
                  icon: CupertinoIcons.person_crop_circle_fill,
                ),
                _buildKeyMetric(
                  label: '水源点',
                  value: '${waterPlan.waterSources.length}个',
                  icon: CupertinoIcons.map_fill,
                ),
                _buildKeyMetric(
                  label: '需处理',
                  value: '${needTreatmentCount}个',
                  icon: CupertinoIcons.exclamationmark_triangle,
                  valueColor: needTreatmentCount > 0
                      ? CupertinoColors.systemOrange
                      : null,
                ),
              ],
            ),

            if (!_isExpanded) ...[
              const SizedBox(height: 12),
              // 简短描述
              Text(
                waterPlan.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 8),

            // 展开/折叠提示
            Center(
              child: Text(
                _isExpanded ? '点击收起详情' : '点击查看详情',
                style: TextStyle(
                  fontSize: 12,
                  color: CupertinoColors.activeBlue.withOpacity(0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetric({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? CupertinoColors.activeBlue,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailedContent() {
    final waterPlan = widget.waterPlan!;

    return [
      // 详细描述
      if (waterPlan.description.isNotEmpty) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            waterPlan.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],

      // 每日饮水计划
      ...List.generate(
        waterPlan.dayWaterPlans.length,
        (index) => _buildDayWaterPlanCollapsible(
          waterPlan.dayWaterPlans[index],
          index,
        ),
      ),
    ];
  }

  Widget _buildDayWaterPlanCollapsible(DayWaterPlanModel dayPlan, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 可点击的日期标题
        GestureDetector(
          onTap: () {
            setState(() {
              _dayExpanded[index] = !_dayExpanded[index];
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              children: [
                Text(
                  '第${dayPlan.dayNumber}天饮水计划',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // 饮水量概览
                Text(
                  _formatVolume(dayPlan.totalWaterNeed),
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _dayExpanded[index]
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ],
            ),
          ),
        ),

        // 展开时显示详情
        if (_dayExpanded[index]) ...[
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
              padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
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
        ],

        const Divider(height: 24, thickness: 0.5),
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
