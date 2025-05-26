/// 装备清单状态
enum EquipmentListStatus {
  /// 规划中
  planning,

  /// 准备中
  preparing,

  /// 已完成准备
  ready,

  /// 使用中
  inUse,

  /// 已完成
  completed,

  /// 已归档
  archived
}

/// 获取装备清单状态名称
String getListStatusName(EquipmentListStatus status) {
  switch (status) {
    case EquipmentListStatus.planning:
      return '规划中';
    case EquipmentListStatus.preparing:
      return '准备中';
    case EquipmentListStatus.ready:
      return '已准备';
    case EquipmentListStatus.inUse:
      return '使用中';
    case EquipmentListStatus.completed:
      return '已完成';
    case EquipmentListStatus.archived:
      return '已归档';
  }
}

/// 从字符串解析装备清单状态
EquipmentListStatus parseListStatusFromString(String statusStr) {
  switch (statusStr.toLowerCase()) {
    case 'planning':
    case '规划中':
      return EquipmentListStatus.planning;
    case 'preparing':
    case '准备中':
      return EquipmentListStatus.preparing;
    case 'ready':
    case '已准备':
      return EquipmentListStatus.ready;
    case 'inuse':
    case 'in_use':
    case '使用中':
      return EquipmentListStatus.inUse;
    case 'completed':
    case '已完成':
      return EquipmentListStatus.completed;
    case 'archived':
    case '已归档':
      return EquipmentListStatus.archived;
    default:
      return EquipmentListStatus.planning;
  }
}
