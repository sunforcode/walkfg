import 'package:json_annotation/json_annotation.dart';

/// 用于表示户外装备的分类
enum EquipmentCategory {
  /// 住宿装备（帐篷、睡袋、睡垫等）
  shelter,

  /// 饮食装备（炉具、餐具、水壶等）
  food,

  /// 保暖装备（衣物、手套、帽子等）
  clothing,

  /// 背包装备（背包、防雨罩等）
  backpack,

  /// 导航装备（地图、指南针、GPS等）
  navigation,

  /// 照明装备（头灯、手电筒等）
  lighting,

  /// 急救装备（急救包、药品等）
  firstAid,

  /// 工具装备（刀具、绳索、修理工具等）
  tools,

  /// 电子装备（手机、相机、充电宝等）
  electronics,

  /// 个人护理（洗漱用品、防晒用品等）
  personalCare,

  /// 其他装备
  other
}

/// 获取装备分类名称
String getCategoryName(EquipmentCategory category) {
  switch (category) {
    case EquipmentCategory.shelter:
      return '住宿装备';
    case EquipmentCategory.food:
      return '饮食装备';
    case EquipmentCategory.clothing:
      return '保暖装备';
    case EquipmentCategory.backpack:
      return '背包装备';
    case EquipmentCategory.navigation:
      return '导航装备';
    case EquipmentCategory.lighting:
      return '照明装备';
    case EquipmentCategory.firstAid:
      return '急救装备';
    case EquipmentCategory.tools:
      return '工具装备';
    case EquipmentCategory.electronics:
      return '电子装备';
    case EquipmentCategory.personalCare:
      return '个人护理';
    case EquipmentCategory.other:
      return '其他装备';
  }
}

/// 获取装备分类图标
String getCategoryIcon(EquipmentCategory category) {
  switch (category) {
    case EquipmentCategory.shelter:
      return 'assets/icons/equipment/shelter.png';
    case EquipmentCategory.food:
      return 'assets/icons/equipment/food.png';
    case EquipmentCategory.clothing:
      return 'assets/icons/equipment/clothing.png';
    case EquipmentCategory.backpack:
      return 'assets/icons/equipment/backpack.png';
    case EquipmentCategory.navigation:
      return 'assets/icons/equipment/navigation.png';
    case EquipmentCategory.lighting:
      return 'assets/icons/equipment/lighting.png';
    case EquipmentCategory.firstAid:
      return 'assets/icons/equipment/first_aid.png';
    case EquipmentCategory.tools:
      return 'assets/icons/equipment/tools.png';
    case EquipmentCategory.electronics:
      return 'assets/icons/equipment/electronics.png';
    case EquipmentCategory.personalCare:
      return 'assets/icons/equipment/personal_care.png';
    case EquipmentCategory.other:
      return 'assets/icons/equipment/other.png';
  }
}

/// 获取装备分类描述
String getCategoryDescription(EquipmentCategory category) {
  switch (category) {
    case EquipmentCategory.shelter:
      return '帐篷、睡袋、睡垫等住宿相关装备';
    case EquipmentCategory.food:
      return '炉具、餐具、水壶等饮食相关装备';
    case EquipmentCategory.clothing:
      return '衣物、手套、帽子等保暖相关装备';
    case EquipmentCategory.backpack:
      return '背包、防雨罩等背包相关装备';
    case EquipmentCategory.navigation:
      return '地图、指南针、GPS等导航相关装备';
    case EquipmentCategory.lighting:
      return '头灯、手电筒等照明相关装备';
    case EquipmentCategory.firstAid:
      return '急救包、药品等急救相关装备';
    case EquipmentCategory.tools:
      return '刀具、绳索、修理工具等工具相关装备';
    case EquipmentCategory.electronics:
      return '手机、相机、充电宝等电子相关装备';
    case EquipmentCategory.personalCare:
      return '洗漱用品、防晒用品等个人护理相关装备';
    case EquipmentCategory.other:
      return '其他未分类装备';
  }
}

/// 从字符串解析装备分类
EquipmentCategory parseCategoryFromString(String categoryStr) {
  switch (categoryStr.toLowerCase()) {
    case 'shelter':
    case '住宿装备':
      return EquipmentCategory.shelter;
    case 'food':
    case '饮食装备':
      return EquipmentCategory.food;
    case 'clothing':
    case '保暖装备':
      return EquipmentCategory.clothing;
    case 'backpack':
    case '背包装备':
      return EquipmentCategory.backpack;
    case 'navigation':
    case '导航装备':
      return EquipmentCategory.navigation;
    case 'lighting':
    case '照明装备':
      return EquipmentCategory.lighting;
    case 'firstaid':
    case 'first_aid':
    case '急救装备':
      return EquipmentCategory.firstAid;
    case 'tools':
    case '工具装备':
      return EquipmentCategory.tools;
    case 'electronics':
    case '电子装备':
      return EquipmentCategory.electronics;
    case 'personalcare':
    case 'personal_care':
    case '个人护理':
      return EquipmentCategory.personalCare;
    default:
      return EquipmentCategory.other;
  }
}
