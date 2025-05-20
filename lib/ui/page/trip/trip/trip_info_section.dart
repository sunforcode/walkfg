import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../model/route/route_model.dart';
import '../../../../theme/theme/app_colors.dart';
import '../../../widgets/common/info_chip.dart';

/// 行程基本信息设置区组件
class TripInfoSection extends StatelessWidget {
  /// 路线
  final RouteModel route;
  
  /// 出发日期
  final DateTime? startDate;
  
  /// 参与人数
  final int participantCount;
  
  /// 出发城市
  final String departureCity;
  
  /// 出发日期选择回调
  final VoidCallback onSelectDate;
  
  /// 人数选择回调
  final VoidCallback onSelectParticipants;
  
  /// 城市变更回调
  final ValueChanged<String> onCityChanged;
  
  /// 构造函数
  const TripInfoSection({
    super.key,
    required this.route,
    this.startDate,
    required this.participantCount,
    required this.departureCity,
    required this.onSelectDate,
    required this.onSelectParticipants,
    required this.onCityChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线基本信息
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(
                CupertinoIcons.location,
                route.region,
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                CupertinoIcons.clock,
                '${route.durationDays}天',
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                CupertinoIcons.chart_bar,
                route.getDifficultyName(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 行程设置
          Row(
            children: [
              // 出发日期
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '出发日期',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: onSelectDate,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            startDate != null
                                ? '${startDate!.year}-${startDate!.month}-${startDate!.day}'
                                : '选择日期',
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.calendar,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 人数
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '人数',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 100,
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(8),
                      onPressed: onSelectParticipants,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$participantCount人',
                            style: const TextStyle(
                              color: CupertinoColors.label,
                              fontSize: 14,
                            ),
                          ),
                          const Icon(
                            CupertinoIcons.person_2,
                            size: 16,
                            color: CupertinoColors.systemGrey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 出发城市
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '出发城市',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              CupertinoTextField(
                placeholder: '输入出发城市',
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: onCityChanged,
                controller: TextEditingController(text: departureCity),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// 构建信息标签
  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.primary,
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
}