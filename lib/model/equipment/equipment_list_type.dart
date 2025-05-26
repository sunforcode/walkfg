/// 装备清单类型
enum EquipmentListType {
  /// 短途徒步
  shortHike,

  /// 长途徒步
  longHike,

  /// 露营
  camping,

  /// 登山
  mountaineering,

  /// 穿越
  trekking,

  /// 自定义
  custom,
}

/// 获取装备清单类型名称
String getListTypeName(EquipmentListType type) {
  switch (type) {
    case EquipmentListType.shortHike:
      return '短途徒步';
    case EquipmentListType.longHike:
      return '长途徒步';
    case EquipmentListType.camping:
      return '露营';
    case EquipmentListType.mountaineering:
      return '登山';
    case EquipmentListType.trekking:
      return '穿越';
    case EquipmentListType.custom:
      return '自定义';
  }
}

/// 从字符串解析装备清单类型
EquipmentListType parseListTypeFromString(String typeStr) {
  switch (typeStr.toLowerCase()) {
    case 'shorthike':
    case 'short_hike':
    case '短途徒步':
      return EquipmentListType.shortHike;
    case 'longhike':
    case 'long_hike':
    case '长途徒步':
      return EquipmentListType.longHike;
    case 'camping':
    case '露营':
      return EquipmentListType.camping;
    case 'mountaineering':
    case '登山':
      return EquipmentListType.mountaineering;
    case 'trekking':
    case '穿越':
      return EquipmentListType.trekking;
    case 'custom':
    case '自定义':
      return EquipmentListType.custom;
    default:
      return EquipmentListType.custom;
  }
}
