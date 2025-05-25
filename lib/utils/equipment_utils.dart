import 'package:flutter/material.dart';
import '../../model/equipment/equipment_item_model.dart';
import '../../model/equipment/equipment_necessity.dart';

/// 装备相关工具类
class EquipmentUtils {
  /// 获取装备必要性名称
  static String getNecessityName(EquipmentNecessity necessity) {
    switch (necessity) {
      case EquipmentNecessity.essential:
        return '必备';
      case EquipmentNecessity.recommended:
        return '推荐';
      case EquipmentNecessity.optional:
        return '可选';
    }
  }

  /// 获取装备必要性颜色
  static Color getNecessityColor(EquipmentNecessity necessity) {
    switch (necessity) {
      case EquipmentNecessity.essential:
        return Colors.red;
      case EquipmentNecessity.recommended:
        return Colors.orange;
      case EquipmentNecessity.optional:
        return Colors.blue;
    }
  }

  /// 获取装备类别图标
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case '服装':
        return Icons.checkroom;
      case '鞋类':
        return Icons.hiking;
      case '背包':
        return Icons.backpack;
      case '睡眠':
        return Icons.hotel;
      case '炊具':
        return Icons.restaurant;
      case '水具':
        return Icons.water_drop;
      case '电子':
        return Icons.devices;
      case '导航':
        return Icons.explore;
      case '急救':
        return Icons.medical_services;
      case '工具':
        return Icons.handyman;
      case '照明':
        return Icons.flashlight_on;
      case '防护':
        return Icons.security;
      default:
        return Icons.category;
    }
  }

  /// 获取装备重量描述
  static String getWeightDescription(double weight) {
    if (weight < 100) {
      return '超轻量';
    } else if (weight < 500) {
      return '轻量';
    } else if (weight < 1000) {
      return '中量';
    } else {
      return '重量';
    }
  }

  /// 计算装备清单总重量
  static double calculateTotalWeight(List<EquipmentItemModel> items) {
    double totalWeight = 0;
    for (var item in items) {
      totalWeight += item.weight * item.quantity;
    }
    return totalWeight;
  }

  /// 格式化重量显示
  static String formatWeight(double weight) {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
    }
  }

  /// 获取装备推荐建议
  static String getRecommendation(EquipmentItemModel item) {
    switch (item.name.toLowerCase()) {
      case '徒步鞋':
        return '选择防水、支撑性好的徒步鞋，确保合脚舒适';
      case '背包':
        return '根据行程长短选择合适容量，一般短途20-35L，长途45-65L';
      case '帐篷':
        return '考虑重量、季节适应性和容纳人数';
      case '睡袋':
        return '根据季节选择合适温标的睡袋';
      case '防潮垫':
        return '选择轻便、保暖性好的防潮垫';
      case '头灯':
        return '确保电池充足，建议携带备用电池';
      case '登山杖':
        return '可减轻膝盖负担，提高稳定性';
      case '水壶':
        return '确保容量足够，推荐保温或轻量材质';
      case '急救包':
        return '包含创可贴、绷带、消毒液等基本医疗用品';
      case '雨衣':
        return '选择透气防水材质，便于携带';
      default:
        if (item.necessity == EquipmentNecessity.essential) {
          return '必备装备，请确保携带';
        } else if (item.necessity == EquipmentNecessity.recommended) {
          return '推荐携带，可提升徒步体验';
        } else {
          return '根据个人需求和行程决定是否携带';
        }
    }
  }
}
