import 'package:flutter/material.dart';
import '../../../model/equipment/equipment_model.dart';
import 'equipment_category_card.dart';

/// 装备分类列表组件
class EquipmentCategoryList extends StatelessWidget {
  /// 装备分类列表
  final List<EquipmentCategory> categories;

  /// 构造函数
  const EquipmentCategoryList({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return EquipmentCategoryCard(
          category: category,
        );
      },
    );
  }
}