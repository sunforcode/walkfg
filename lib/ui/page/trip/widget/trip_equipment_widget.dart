import 'package:flutter/cupertino.dart';
import 'package:walk/model/equipment/equipment_model.dart';
import 'package:walk/model/equipment/equipment_item_model.dart';
import 'package:walk/model/equipment/equipment_necessity.dart';

class TripEquipmentWidget extends StatefulWidget {
  final EquipmentListModel listModel;

  const TripEquipmentWidget({
    super.key,
    required this.listModel,
  });

  @override
  State<TripEquipmentWidget> createState() => _TripEquipmentWidgetState();
}

class _TripEquipmentWidgetState extends State<TripEquipmentWidget> {
  bool _isExpanded = false;
  List<bool> _categoryExpanded = [];

  @override
  void initState() {
    super.initState();
    _initCategoryExpandedState();
  }

  @override
  void didUpdateWidget(TripEquipmentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listModel != widget.listModel) {
      _initCategoryExpandedState();
    }
  }

  void _initCategoryExpandedState() {
    _categoryExpanded =
        List.generate(widget.listModel.categories.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listModel.categories.isEmpty) {
      return const Text(
        '暂无装备清单',
        style: TextStyle(
          fontSize: 16,
          color: CupertinoColors.systemGrey,
        ),
      );
    }

    return _buildEquipmentCard();
  }

  Widget _buildEquipmentCard() {
    final listModel = widget.listModel;

    // 计算必备装备数量
    final essentialCount = listModel.categories
        .expand((category) => category.items)
        .where((item) => item.necessity == EquipmentNecessity.essential)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
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
          // 标题和展开/折叠按钮
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: _isExpanded
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      )
                    : BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          CupertinoIcons.bag_fill,
                          color: CupertinoColors.systemOrange,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          listModel.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey6,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _isExpanded
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          color: CupertinoColors.systemGrey,
                          size: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 关键数据行
                  Row(
                    children: [
                      Expanded(
                        child: _buildKeyMetric(
                          label: '总重量',
                          value:
                              '${(listModel.totalWeight / 1000).toStringAsFixed(1)}kg',
                          icon: CupertinoIcons.arrow_down_circle_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '装备数',
                          value: '${listModel.totalItems}件',
                          icon: CupertinoIcons.cube_box_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '分类',
                          value: '${listModel.categories.length}类',
                          icon: CupertinoIcons.square_grid_2x2_fill,
                        ),
                      ),
                      Expanded(
                        child: _buildKeyMetric(
                          label: '必备',
                          value: '${essentialCount}件',
                          icon: CupertinoIcons.exclamationmark_circle_fill,
                          valueColor: essentialCount > 0
                              ? CupertinoColors.systemRed
                              : null,
                        ),
                      ),
                    ],
                  ),

                  if (!_isExpanded) ...[
                    const SizedBox(height: 16),
                    // 简短描述
                    Text(
                      listModel.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // 展开的详细内容
          if (_isExpanded) ...[
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  // 详细内容
                  _buildDetailedContentContainer(),

                  // 收起按钮
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = false;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemGrey6,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '点击收起详情',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: CupertinoColors.systemOrange
                                      .withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                CupertinoIcons.chevron_up,
                                size: 12,
                                color: CupertinoColors.systemOrange
                                    .withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailedContentContainer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: _buildDetailedContent(),
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
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor ?? CupertinoColors.systemOrange,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDetailedContent() {
    final listModel = widget.listModel;

    return [
      // 详细描述
      if (listModel.description.isNotEmpty) ...[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.systemGrey6,
            border: Border(
              bottom: BorderSide(
                color: CupertinoColors.systemGrey5,
                width: 0.5,
              ),
            ),
          ),
          child: Text(
            listModel.description,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ),
      ],

      // 装备分类
      ...List.generate(
        listModel.categories.length,
        (index) => _buildCategoryCollapsible(
          listModel.categories[index],
          index,
        ),
      ),
    ];
  }

  Widget _buildCategoryCollapsible(EquipmentCategory category, int index) {
    final isLast = index == widget.listModel.categories.length - 1;

    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        border: !isLast
            ? Border(
                bottom: BorderSide(
                  color: CupertinoColors.systemGrey5,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 可点击的分类标题
          GestureDetector(
            onTap: () {
              setState(() {
                _categoryExpanded[index] = !_categoryExpanded[index];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      CupertinoIcons.cube_box_fill,
                      size: 16,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // 装备数量
                  Text(
                    '${category.items.length}件',
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.systemOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _categoryExpanded[index]
                          ? CupertinoIcons.chevron_up
                          : CupertinoIcons.chevron_down,
                      size: 14,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 展开时显示详情
          if (_categoryExpanded[index]) ...[
            // 装备列表
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Column(
                children: category.items
                    .map((item) => _buildEquipmentItem(item))
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(EquipmentItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.necessity == EquipmentNecessity.essential
              ? CupertinoColors.systemRed.withOpacity(0.3)
              : CupertinoColors.systemGrey5,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 装备图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEquipmentIcon(item),
              color: CupertinoColors.systemOrange,
            ),
          ),

          const SizedBox(width: 12),

          // 装备信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (item.necessity == EquipmentNecessity.essential)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: CupertinoColors.systemRed.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          '必备',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.brand} · ${item.model} · ${(item.weight / 1000).toStringAsFixed(2)}kg × ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEquipmentIcon(EquipmentItemModel item) {
    // 简单的图标选择逻辑，可以根据装备类型或名称选择不同图标
    if (item.name.contains('帐篷')) return CupertinoIcons.house_fill;
    if (item.name.contains('睡袋')) return CupertinoIcons.bed_double_fill;
    if (item.name.contains('背包')) return CupertinoIcons.bag_fill;
    if (item.name.contains('鞋')) return CupertinoIcons.sportscourt_fill;
    if (item.name.contains('衣')) return CupertinoIcons.shift_fill;
    if (item.name.contains('灯')) return CupertinoIcons.lightbulb_fill;
    if (item.name.contains('杖')) return CupertinoIcons.wand_stars;
    if (item.name.contains('刀')) return CupertinoIcons.scissors;
    if (item.name.contains('急救')) return CupertinoIcons.bandage_fill;
    if (item.name.contains('防晒')) return CupertinoIcons.sun_max_fill;
    if (item.name.contains('炉')) return CupertinoIcons.flame_fill;

    // 默认图标
    return CupertinoIcons.cube_box_fill;
  }
}
