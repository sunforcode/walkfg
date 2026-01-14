/// 装备清单详情页面
///
/// 显示装备清单的详细统计信息和分析

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../model/equipment/equipment_list_model.dart';
import '../../../model/equipment/equipment_item_model.dart';
import '../../../model/equipment/equipment_category.dart';
import '../../../model/equipment/equipment_necessity.dart';
import '../../../service/equipment_service.dart';
import '../common/loading_view.dart';
import '../common/error_view.dart';

/// 装备清单详情页面
class EquipmentDetailScreen extends ConsumerStatefulWidget {
  /// 装备清单ID
  final String equipmentId;

  /// 构造函数
  const EquipmentDetailScreen({
    super.key,
    required this.equipmentId,
  });

  @override
  ConsumerState<EquipmentDetailScreen> createState() =>
      _EquipmentListDetailScreenState();
}

class _EquipmentListDetailScreenState
    extends ConsumerState<EquipmentDetailScreen> {
  bool _isLoading = true;
  String? _error;
  EquipmentListModel? _equipmentList;

  @override
  void initState() {
    super.initState();
    _loadEquipmentList();
  }

  /// 加载装备清单
  Future<void> _loadEquipmentList() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 使用EquipmentService加载装备清单
      final equipmentList =
          await EquipmentService.getEquipmentListById(widget.equipmentId);

      setState(() {
        _equipmentList = equipmentList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备清单详情')),
        body: const LoadingView(message: '加载装备清单...'),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备清单详情')),
        body: ErrorView(
          message: _error!,
          title: '加载失败',
          onRetry: _loadEquipmentList,
        ),
      );
    }

    if (_equipmentList == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('装备清单详情')),
        body: const Center(child: Text('装备清单不存在')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${_equipmentList!.name} - 详情分析'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息卡片
            _buildBasicInfoCard(),

            const SizedBox(height: 16),

            // 重量分析卡片
            _buildWeightAnalysisCard(),

            const SizedBox(height: 16),

            // 分类分布卡片
            _buildCategoryDistributionCard(),

            const SizedBox(height: 16),

            // 必要性分布卡片
            _buildNecessityDistributionCard(),

            const SizedBox(height: 16),

            // 重量最重的装备卡片
            _buildHeaviestItemsCard(),

            const SizedBox(height: 16),

            // 装备准备状态卡片
            _buildPreparationStatusCard(),
          ],
        ),
      ),
    );
  }

  /// 构建基本信息卡片
  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '基本信息',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('清单名称', _equipmentList!.name),
            _buildInfoRow('行程天数', '${_equipmentList!.tripDays}天'),
            _buildInfoRow('适用季节', _equipmentList!.getSeasonNames().join('、')),
            _buildInfoRow('装备总数', '${_equipmentList!.totalItems}件'),
            _buildInfoRow('总重量',
                '${(_equipmentList!.totalWeight / 1000).toStringAsFixed(2)}kg'),
            _buildInfoRow('每人每日平均重量',
                '${(_equipmentList!.weightPerPersonPerDay / 1000).toStringAsFixed(2)}kg/人/天'),
          ],
        ),
      ),
    );
  }

  /// 构建重量分析卡片
  Widget _buildWeightAnalysisCard() {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '重量分析',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 重量饼图
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: _equipmentList!.baseWeight,
                      title:
                          '基础重量\n${(_equipmentList!.baseWeight / 1000).toStringAsFixed(1)}kg',
                      color: theme.colorScheme.primary,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _equipmentList!.consumableWeight,
                      title:
                          '消耗品重量\n${(_equipmentList!.consumableWeight / 1000).toStringAsFixed(1)}kg',
                      color: theme.colorScheme.secondary,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: _equipmentList!.wornWeight,
                      title:
                          '穿着重量\n${(_equipmentList!.wornWeight / 1000).toStringAsFixed(1)}kg',
                      color: theme.colorScheme.tertiary,
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 重量详情
            _buildInfoRow(
              '基础重量',
              '${(_equipmentList!.baseWeight / 1000).toStringAsFixed(2)}kg (${(_equipmentList!.baseWeight / _equipmentList!.totalWeight * 100).toStringAsFixed(1)}%)',
              color: theme.colorScheme.primary,
            ),
            _buildInfoRow(
              '消耗品重量',
              '${(_equipmentList!.consumableWeight / 1000).toStringAsFixed(2)}kg (${(_equipmentList!.consumableWeight / _equipmentList!.totalWeight * 100).toStringAsFixed(1)}%)',
              color: theme.colorScheme.secondary,
            ),
            _buildInfoRow(
              '穿着重量',
              '${(_equipmentList!.wornWeight / 1000).toStringAsFixed(2)}kg (${(_equipmentList!.wornWeight / _equipmentList!.totalWeight * 100).toStringAsFixed(1)}%)',
              color: theme.colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类分布卡片
  Widget _buildCategoryDistributionCard() {
    final theme = Theme.of(context);

    // 按分类对装备进行分组
    final Map<EquipmentCategory, List<EquipmentItemModel>> categoryMap = {};
    for (final item in _equipmentList!.equipments) {
      if (!categoryMap.containsKey(item.category)) {
        categoryMap[item.category] = [];
      }
      categoryMap[item.category]!.add(item);
    }

    // 计算每个分类的重量和数量
    final List<MapEntry<EquipmentCategory, double>> categoryWeights = [];
    final List<MapEntry<EquipmentCategory, int>> categoryCounts = [];

    categoryMap.forEach((category, items) {
      final weight = items.fold<double>(
        0,
        (sum, item) => sum + item.totalWeight,
      );
      categoryWeights.add(MapEntry(category, weight));
      categoryCounts.add(MapEntry(category, items.length));
    });

    // 按重量排序
    categoryWeights.sort((a, b) => b.value.compareTo(a.value));

    // 生成饼图数据
    final pieChartSections = <PieChartSectionData>[];
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      Colors.amber,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.lime,
      Colors.brown,
      Colors.cyan,
    ];

    for (int i = 0; i < categoryWeights.length; i++) {
      final entry = categoryWeights[i];
      final color = i < colors.length ? colors[i] : Colors.grey;

      pieChartSections.add(
        PieChartSectionData(
          value: entry.value,
          title: getCategoryName(entry.key),
          color: color,
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '分类分布',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 分类饼图
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 分类详情
            ...List.generate(categoryWeights.length, (index) {
              final entry = categoryWeights[index];
              final category = entry.key;
              final weight = entry.value;
              final count =
                  categoryCounts.firstWhere((e) => e.key == category).value;
              final color = index < colors.length ? colors[index] : Colors.grey;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        getCategoryName(category),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$count件 · ${(weight / 1000).toStringAsFixed(2)}kg',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 构建必要性分布卡片
  Widget _buildNecessityDistributionCard() {
    final theme = Theme.of(context);

    // 计算必要性分布
    final essentialCount = _equipmentList!.essentialItems;
    final recommendedCount = _equipmentList!.recommendedItems;
    final optionalCount = _equipmentList!.optionalItems;

    // 计算必要性重量
    double essentialWeight = 0;
    double recommendedWeight = 0;
    double optionalWeight = 0;

    for (final item in _equipmentList!.equipments) {
      switch (item.necessity) {
        case EquipmentNecessity.essential:
          essentialWeight += item.totalWeight;
          break;
        case EquipmentNecessity.recommended:
          recommendedWeight += item.totalWeight;
          break;
        case EquipmentNecessity.optional:
          optionalWeight += item.totalWeight;
          break;
      }
    }

    // 生成饼图数据
    final pieChartSections = [
      PieChartSectionData(
        value: essentialCount.toDouble(),
        title: '必需\n$essentialCount件',
        color: Color(getNecessityColor(EquipmentNecessity.essential)),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: recommendedCount.toDouble(),
        title: '推荐\n$recommendedCount件',
        color: Color(getNecessityColor(EquipmentNecessity.recommended)),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      PieChartSectionData(
        value: optionalCount.toDouble(),
        title: '可选\n$optionalCount件',
        color: Color(getNecessityColor(EquipmentNecessity.optional)),
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '必要性分布',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 必要性饼图
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: pieChartSections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 必要性详情
            _buildInfoRow(
              '必需装备',
              '$essentialCount件 · ${(essentialWeight / 1000).toStringAsFixed(2)}kg',
              color: Color(getNecessityColor(EquipmentNecessity.essential)),
            ),
            _buildInfoRow(
              '推荐装备',
              '$recommendedCount件 · ${(recommendedWeight / 1000).toStringAsFixed(2)}kg',
              color: Color(getNecessityColor(EquipmentNecessity.recommended)),
            ),
            _buildInfoRow(
              '可选装备',
              '$optionalCount件 · ${(optionalWeight / 1000).toStringAsFixed(2)}kg',
              color: Color(getNecessityColor(EquipmentNecessity.optional)),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建最重装备卡片
  Widget _buildHeaviestItemsCard() {
    final theme = Theme.of(context);

    // 按重量排序装备
    final sortedItems = List.from(_equipmentList!.equipments);
    sortedItems.sort((a, b) => b.totalWeight.compareTo(a.totalWeight));

    // 取前5个最重的装备
    final heaviestItems = sortedItems.take(5).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '最重装备',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 最重装备列表
            ...heaviestItems.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${item.getCategoryText()} · ${item.getNecessityText()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        item.getTotalWeightText(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// 构建准备状态卡片
  Widget _buildPreparationStatusCard() {
    final theme = Theme.of(context);

    // 计算准备状态
    final preparedItems =
        _equipmentList!.equipments.where((item) => item.prepared).length;
    final totalItems = _equipmentList!.equipments.length;
    final progress = totalItems > 0 ? preparedItems / totalItems : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '准备状态',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 进度条
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceVariant,
              color: theme.colorScheme.primary,
              minHeight: 8,
            ),

            const SizedBox(height: 8),

            // 进度文本
            Text(
              '已准备 $preparedItems / $totalItems 件装备 (${(progress * 100).toStringAsFixed(0)}%)',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // 准备状态详情
            Row(
              children: [
                Expanded(
                  child: _buildPreparationStatusItem(
                    '已准备',
                    preparedItems,
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildPreparationStatusItem(
                    '未准备',
                    totalItems - preparedItems,
                    theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建准备状态项
  Widget _buildPreparationStatusItem(String label, int count, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: color != null ? FontWeight.bold : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
