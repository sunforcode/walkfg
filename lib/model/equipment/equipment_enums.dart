/// 装备模块相关枚举
///
/// 这些枚举的编码（index）必须与后端 `walkbg` 的 Int 编码严格一一对应，
/// 详见：
/// - `org.example.equipment.model.EquipmentItem`（category / weightUnit）
/// - `org.example.equipment.dto.EquipmentListResponse`（TYPE_NAMES / STATUS_NAMES）
///
/// 注意：不要照抄 `EquipmentList.kt` 文件末尾的 `EquipmentListType` /
/// `EquipmentListStatus` 这两个 Kotlin enum 的成员数量——它们与实际编码
/// 含义不完全对应，属于遗留设计，真实的合法取值以下方注释为准。

/// 装备分类（对应后端 `category` 字段，0-10）
enum EquipmentCategory {
  /// 0 - 住宿装备（帐篷、天幕等）
  shelter,

  /// 1 - 睡眠系统（睡袋、睡垫等）
  sleeping,

  /// 2 - 背负系统（背包等）
  backpack,

  /// 3 - 服装
  clothing,

  /// 4 - 厨具炊事
  cooking,

  /// 5 - 食物饮水
  foodWater,

  /// 6 - 导航定位
  navigation,

  /// 7 - 照明
  lighting,

  /// 8 - 安全急救
  safety,

  /// 9 - 电子设备
  electronics,

  /// 10 - 其他
  other,
}

/// 装备分类扩展方法：与后端 Int 编码互转、展示名称
extension EquipmentCategoryX on EquipmentCategory {
  /// 转换为后端 Int 编码
  int toCode() => index;

  /// 展示名称（与后端 `EquipmentItemResponse.categoryName` 保持一致的中文名）
  String get displayName {
    switch (this) {
      case EquipmentCategory.shelter:
        return '住宿装备';
      case EquipmentCategory.sleeping:
        return '睡眠系统';
      case EquipmentCategory.backpack:
        return '背负系统';
      case EquipmentCategory.clothing:
        return '服装';
      case EquipmentCategory.cooking:
        return '厨具炊事';
      case EquipmentCategory.foodWater:
        return '食物饮水';
      case EquipmentCategory.navigation:
        return '导航定位';
      case EquipmentCategory.lighting:
        return '照明';
      case EquipmentCategory.safety:
        return '安全急救';
      case EquipmentCategory.electronics:
        return '电子设备';
      case EquipmentCategory.other:
        return '其他';
    }
  }
}

/// 由后端 Int 编码解析装备分类，越界或非法值时回退为 [EquipmentCategory.other]
EquipmentCategory equipmentCategoryFromCode(dynamic code) {
  if (code is int && code >= 0 && code < EquipmentCategory.values.length) {
    return EquipmentCategory.values[code];
  }
  return EquipmentCategory.other;
}

/// 重量单位（对应后端 `weightUnit` 字段，0-3）
///
/// 参见 `org.example.equipment.util.EquipmentWeightUtils.WeightUnit`。
enum EquipmentWeightUnit {
  /// 0 - 克
  gram,

  /// 1 - 千克
  kilogram,

  /// 2 - 磅
  pound,

  /// 3 - 盎司
  ounce,
}

extension EquipmentWeightUnitX on EquipmentWeightUnit {
  /// 转换为后端 Int 编码
  int toCode() => index;

  /// 单位简写
  String get shortLabel {
    switch (this) {
      case EquipmentWeightUnit.gram:
        return 'g';
      case EquipmentWeightUnit.kilogram:
        return 'kg';
      case EquipmentWeightUnit.pound:
        return 'lb';
      case EquipmentWeightUnit.ounce:
        return 'oz';
    }
  }
}

/// 由后端 Int 编码解析重量单位，越界或非法值时回退为 [EquipmentWeightUnit.gram]
EquipmentWeightUnit equipmentWeightUnitFromCode(dynamic code) {
  if (code is int &&
      code >= 0 &&
      code < EquipmentWeightUnit.values.length) {
    return EquipmentWeightUnit.values[code];
  }
  return EquipmentWeightUnit.gram;
}

/// 装备清单类型（对应后端 `type` 字段，0-2）
///
/// 此前已知后端限制（已修复）：`POST /equipment-lists` 创建清单时，
/// controller 把 `type`（Int）透传给 service，但 service 用 `as? String`
/// 解析，类型不匹配导致解析永远失败，最终 `type` 始终落库为 0（个人装备）。
/// 现已在 `EquipmentServiceImpl.parseIntField` 中修复，客户端可以正常
/// 通过创建接口指定类型（模板装备 [template] 一般由"从模板创建"流程使用，
/// 手动创建表单通常只在个人/团队之间选择）。
enum EquipmentListType {
  /// 0 - 个人装备
  personal,

  /// 1 - 团队装备
  team,

  /// 2 - 模板装备
  template,
}

extension EquipmentListTypeX on EquipmentListType {
  int toCode() => index;

  String get displayName {
    switch (this) {
      case EquipmentListType.personal:
        return '个人装备';
      case EquipmentListType.team:
        return '团队装备';
      case EquipmentListType.template:
        return '模板装备';
    }
  }
}

EquipmentListType equipmentListTypeFromCode(dynamic code) {
  if (code is int && code >= 0 && code < EquipmentListType.values.length) {
    return EquipmentListType.values[code];
  }
  return EquipmentListType.personal;
}

/// 装备清单状态（对应后端 `status` 字段）
///
/// "已归档(3)"只是 `STATUS_NAMES` 里的历史展示态，正常业务流程不会主动
/// 写入该值，因此不作为用户可选的写入选项（见 [writableEquipmentListStatuses]）。
///
/// 状态修改推荐调用专用端点 `PATCH /equipment-lists/{id}/status`
/// （语义更清晰）。此前该端点是唯一能生效的方式（因为它在提交给 service 层前
/// 会先把 Int 转成 String 绕开了一个类型解析 bug）；该 bug 已在
/// `EquipmentServiceImpl.parseIntField` 中修复，现在通用的
/// `PUT /equipment-lists/{id}` 同样可以正确写入 status。
enum EquipmentListStatus {
  /// 0 - 规划中
  planning,

  /// 1 - 准备中
  preparing,

  /// 2 - 已完成
  completed,

  /// 3 - 已归档（仅展示，不可写入）
  archived,
}

extension EquipmentListStatusX on EquipmentListStatus {
  int toCode() => index;

  /// 是否为可写入状态（创建/更新时可选）
  bool get isWritable => index <= EquipmentListStatus.completed.index;

  String get displayName {
    switch (this) {
      case EquipmentListStatus.planning:
        return '规划中';
      case EquipmentListStatus.preparing:
        return '准备中';
      case EquipmentListStatus.completed:
        return '已完成';
      case EquipmentListStatus.archived:
        return '已归档';
    }
  }
}

EquipmentListStatus equipmentListStatusFromCode(dynamic code) {
  if (code is int &&
      code >= 0 &&
      code < EquipmentListStatus.values.length) {
    return EquipmentListStatus.values[code];
  }
  return EquipmentListStatus.planning;
}

/// 可写入的清单状态列表（不含"已归档"），供状态切换 UI 使用
const List<EquipmentListStatus> writableEquipmentListStatuses = [
  EquipmentListStatus.planning,
  EquipmentListStatus.preparing,
  EquipmentListStatus.completed,
];
