/// 装备清单内的装备条目关联
///
/// 对应后端 `EquipmentListController` 的 `GET/POST/PUT /equipment-lists/{id}/items`
/// 系列端点。这些端点返回的是关联表的精简裸 Map（驼峰命名），**不包含**
/// 装备本身的名称/分类/重量等详情——如果需要展示这些信息，必须再用
/// [equipmentItemId] 单独调用 `GET /equipment/items/{id}` 查询。
class EquipmentListItemModel {
  /// 所属清单ID
  final String equipmentListId;

  /// 装备单品ID
  final String equipmentItemId;

  /// 数量
  final int quantity;

  /// 备注
  final String? notes;

  const EquipmentListItemModel({
    required this.equipmentListId,
    required this.equipmentItemId,
    required this.quantity,
    this.notes,
  });

  factory EquipmentListItemModel.fromJson(Map<String, dynamic> json) {
    return EquipmentListItemModel(
      equipmentListId: json['equipmentListId'] as String,
      equipmentItemId: json['equipmentItemId'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      notes: (json['notes'] as String?)?.isEmpty == true
          ? null
          : json['notes'] as String?,
    );
  }
}
