import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';
import 'package:walk/model/model/route/route_model.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/service/trip_plan_service.dart';
import 'package:walk/ui/page/trip_plan/components/section_title_widget.dart';
import 'package:walk/ui/page/trip_plan/components/equipment_card.dart';
import 'package:walk/ui/widgets/common/cupertino_card.dart';
import 'package:walk/theme/theme/app_colors.dart';

/// 装备部分
class EquipmentSection extends StatefulWidget {
  /// 路线
  final RouteModel route;

  /// 参与人数
  final int participantCount;

  /// 行程规划服务
  final TripPlanService tripPlanService;

  /// 构造函数
  const EquipmentSection({
    Key? key,
    required this.route,
    required this.participantCount,
    required this.tripPlanService,
  }) : super(key: key);

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
  /// 当前装备分类
  int _currentCategory = 0; // 0: 全部, 1: 必备, 2: 推荐, 3: 可选

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 装备分类切换控制器
        _buildCardSegmentControl(),

        const SizedBox(height: 16),

        // 装备清单内容
        Expanded(
          child: _buildEquipmentContent(),
        ),
      ],
    );
  }

  /// 构建卡片式分段控制器
  Widget _buildCardSegmentControl() {
    final segments = [
      {'icon': CupertinoIcons.square_grid_2x2, 'label': '全部'},
      {'icon': CupertinoIcons.exclamationmark_shield, 'label': '必备'},
      {'icon': CupertinoIcons.star, 'label': '推荐'},
      {'icon': CupertinoIcons.plus_circle, 'label': '可选'},
    ];

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(segments.length, (index) {
          final isSelected = _currentCategory == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentCategory = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      segments[index]['icon'] as IconData,
                      color: isSelected
                          ? CupertinoColors.white
                          : CupertinoColors.systemGrey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      segments[index]['label'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建装备清单内容
  Widget _buildEquipmentContent() {
    return FutureBuilder<List<EquipmentItemModel>>(
      future: widget.tripPlanService.getEquipmentList(
        widget.route.id,
        widget.participantCount,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(
            child: Text('无法加载装备清单'),
          );
        }

        // 根据当前分类筛选装备
        final filteredEquipment = _filterEquipmentByCategory(snapshot.data!);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 装备准备进度卡片
              _buildEquipmentProgressCard(snapshot.data!),

              const SizedBox(height: 16),

              // 装备清单卡片
              Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题栏
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.bag_fill,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '装备清单',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '编辑',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            onPressed: () {
                              // TODO: 打开装备清单编辑器
                            },
                          ),
                        ],
                      ),
                    ),

                    // 内容
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: EquipmentCard(
                        equipmentList: filteredEquipment,
                        onEdit: () {
                          // TODO: 打开装备清单编辑器
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 装备重量分析卡片
              _buildWeightAnalysisCard(snapshot.data!),
            ],
          ),
        );
      },
    );
  }

  /// 根据分类筛选装备
  List<EquipmentItemModel> _filterEquipmentByCategory(
      List<EquipmentItemModel> equipment) {
    if (_currentCategory == 0) {
      return equipment;
    }

    // 根据必要性筛选
    return equipment.where((item) {
      switch (_currentCategory) {
        case 1: // 必备
          return item.necessity == EquipmentNecessity.essential;
        case 2: // 推荐
          return item.necessity == EquipmentNecessity.recommended;
        case 3: // 可选
          return item.necessity == EquipmentNecessity.optional;
        default:
          return true;
      }
    }).toList();
  }

  /// 构建装备准备进度卡片
  Widget _buildEquipmentProgressCard(List<EquipmentItemModel> equipment) {
    // 计算已准备的装备数量
    final preparedCount = equipment.where((item) => item.prepared).length;
    final totalCount = equipment.length;
    final progressPercentage =
        totalCount > 0 ? preparedCount / totalCount : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.chart_bar_fill,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '装备准备进度',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 进度文本
                Text(
                  '已准备: $preparedCount/$totalCount (${(progressPercentage * 100).toInt()}%)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 12),

                // 进度条
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width *
                            0.8 *
                            progressPercentage,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 分类进度
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryProgress(
                      '必备',
                      equipment
                          .where((item) =>
                              item.necessity == EquipmentNecessity.essential)
                          .toList(),
                      CupertinoColors.systemRed,
                    ),
                    _buildCategoryProgress(
                      '推荐',
                      equipment
                          .where((item) =>
                              item.necessity == EquipmentNecessity.recommended)
                          .toList(),
                      CupertinoColors.activeOrange,
                    ),
                    _buildCategoryProgress(
                      '可选',
                      equipment
                          .where((item) =>
                              item.necessity == EquipmentNecessity.optional)
                          .toList(),
                      CupertinoColors.systemGrey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建分类进度
  Widget _buildCategoryProgress(
      String name, List<EquipmentItemModel> items, Color color) {
    final preparedCount = items.where((item) => item.prepared).length;
    final totalCount = items.length;
    final progressPercentage =
        totalCount > 0 ? preparedCount / totalCount : 0.0;

    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$preparedCount/$totalCount',
          style: TextStyle(
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 4,
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: CupertinoColors.systemGrey5,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  /// 构建重量分析卡片
  Widget _buildWeightAnalysisCard(List<EquipmentItemModel> equipment) {
    // 计算总重量
    final totalWeight = equipment.fold(
        0.0, (sum, item) => sum + (item.weight ?? 0) * (item.quantity ?? 1));

    // 按类别计算重量
    final clothingWeight = equipment
        .where((item) => item.category == 'clothing')
        .fold(0.0,
            (sum, item) => sum + (item.weight ?? 0) * (item.quantity ?? 1));

    final gearWeight = equipment.where((item) => item.category == 'gear').fold(
        0.0, (sum, item) => sum + (item.weight ?? 0) * (item.quantity ?? 1));

    final foodWeight = equipment.where((item) => item.category == 'food').fold(
        0.0, (sum, item) => sum + (item.weight ?? 0) * (item.quantity ?? 1));

    final otherWeight = totalWeight - clothingWeight - gearWeight - foodWeight;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.gauge,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '重量分析',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          // 内容
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 总重量
                Text(
                  '总重量: ${totalWeight.toStringAsFixed(1)}kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 16),

                // 重量分布
                Row(
                  children: [
                    Expanded(
                      child: _buildWeightBar(
                        [
                          WeightItem(
                              '服装', clothingWeight, CupertinoColors.systemBlue),
                          WeightItem(
                              '装备', gearWeight, CupertinoColors.systemOrange),
                          WeightItem(
                              '食物', foodWeight, CupertinoColors.systemGreen),
                          WeightItem(
                              '其他', otherWeight, CupertinoColors.systemGrey),
                        ],
                        totalWeight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 重量图例
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildWeightLegend(
                        '服装', clothingWeight, CupertinoColors.systemBlue),
                    _buildWeightLegend(
                        '装备', gearWeight, CupertinoColors.systemOrange),
                    _buildWeightLegend(
                        '食物', foodWeight, CupertinoColors.systemGreen),
                    _buildWeightLegend(
                        '其他', otherWeight, CupertinoColors.systemGrey),
                  ],
                ),

                const SizedBox(height: 16),

                // 重量建议
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.info_circle,
                        color: CupertinoColors.systemBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '建议背包总重量不超过${(widget.participantCount > 1 ? 15 : 12).toString()}kg，可以考虑减轻一些非必要装备',
                          style: const TextStyle(
                            color: CupertinoColors.systemBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建重量条
  Widget _buildWeightBar(List<WeightItem> items, double totalWeight) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: items.map((item) {
          final percentage = totalWeight > 0 ? item.weight / totalWeight : 0.0;
          return Container(
            width: MediaQuery.of(context).size.width * 0.8 * percentage,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 构建重量图例
  Widget _buildWeightLegend(String name, double weight, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$name: ${weight.toStringAsFixed(1)}kg',
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// 重量项
class WeightItem {
  final String name;
  final double weight;
  final Color color;

  WeightItem(this.name, this.weight, this.color);
}
