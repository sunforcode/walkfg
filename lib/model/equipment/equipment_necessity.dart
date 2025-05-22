/// 装备必要性枚举
/// 
/// 用于表示装备项目的必要程度
enum EquipmentNecessity { 
  /// 必需
  essential, 
  
  /// 推荐
  recommended, 
  
  /// 可选
  optional 
}

/// 获取必要性名称
String getNecessityName(EquipmentNecessity necessity) {
  switch (necessity) {
    case EquipmentNecessity.essential:
      return '必需';
    case EquipmentNecessity.recommended:
      return '推荐';
    case EquipmentNecessity.optional:
      return '可选';
  }
}

/// 获取必要性颜色代码
int getNecessityColor(EquipmentNecessity necessity) {
  switch (necessity) {
    case EquipmentNecessity.essential:
      return 0xFFF44336; // 红色
    case EquipmentNecessity.recommended:
      return 0xFFFF9800; // 橙色
    case EquipmentNecessity.optional:
      return 0xFF2196F3; // 蓝色
  }
}