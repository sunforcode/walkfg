/// 装备使用状态
enum EquipmentCondition {
  /// 全新
  nnew,

  /// 良好
  good,

  /// 一般
  fair,

  /// 较差
  poor,

  /// 损坏
  damaged
}

/// 获取装备状态名称
String getConditionName(EquipmentCondition condition) {
  switch (condition) {
    case EquipmentCondition.nnew:
      return '全新';
    case EquipmentCondition.good:
      return '良好';
    case EquipmentCondition.fair:
      return '一般';
    case EquipmentCondition.poor:
      return '较差';
    case EquipmentCondition.damaged:
      return '损坏';
  }
}

/// 从字符串解析装备状态
EquipmentCondition parseConditionFromString(String conditionStr) {
  switch (conditionStr.toLowerCase()) {
    case 'new':
    case '全新':
      return EquipmentCondition.nnew;
    case 'good':
    case '良好':
      return EquipmentCondition.good;
    case 'fair':
    case '一般':
      return EquipmentCondition.fair;
    case 'poor':
    case '较差':
      return EquipmentCondition.poor;
    case 'damaged':
    case '损坏':
      return EquipmentCondition.damaged;
    default:
      return EquipmentCondition.good;
  }
}
