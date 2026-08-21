import 'equipment_enums.dart';

/// 装备清单模型
///
/// 严格对齐后端 `org.example.equipment.dto.EquipmentListResponse`。
///
/// 重要提示：
/// - 字段命名同样是驼峰/蛇形混用：`typeName`/`statusName`/`type`/`status`
///   是驼峰或原名，而 `trip_id`/`creator_id`/`total_weight`/`person_count`/
///   `created_at`/`updated_at`/`item_count` 有 `@JsonProperty` 蛇形映射。
/// - `created_at`/`updated_at` 后端使用的是 **秒级** epochSecond，
///   不是本项目其它模块常见的毫秒时间戳，解析时需要 `* 1000`。
/// - `description` 字段后端 `fromEntity` 里硬编码为 `null`，即使创建时
///   传了描述也不会被持久化和回显，这里仍保留该字段以便未来后端修复后可用，
///   但 UI 不应依赖它有值。
/// - 清单响应体本身**不包含**装备条目详情，只有 [itemCount] 数量；
///   要获取清单内的装备，需要另外调用 `GET /equipment-lists/{id}/items`。
class EquipmentListModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述（后端目前恒为 null，见类注释）
  final String? description;

  /// 类型（0-2）
  final EquipmentListType type;

  /// 类型展示名称（后端直接返回）
  final String typeName;

  /// 关联的行程ID（可能为 null）
  final String? tripId;

  /// 创建者用户ID（由后端认证态自动决定，不需要客户端传递）
  final String? creatorId;

  /// 总重量（后端 SQL 计算，混合单位清单场景下可能不准确，见下方说明）
  ///
  /// 已知后端限制：`total_weight` 的计算 SQL 是
  /// `SUM(ei.weight * eli.quantity)`，并未按 `weightUnit` 做单位换算，
  /// 如果清单内装备的重量单位不一致，这个值会失真。客户端只能如实展示。
  final double totalWeight;

  /// 人数
  final int personCount;

  /// 状态（0-3，但只有 0-2 可写入，见 [EquipmentListStatus]）
  final EquipmentListStatus status;

  /// 状态展示名称（后端直接返回）
  final String statusName;

  /// 创建时间
  final DateTime createdAt;

  /// 更新时间
  final DateTime updatedAt;

  /// 清单内装备条目数量（不含具体装备详情）
  final int itemCount;

  const EquipmentListModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.typeName,
    this.tripId,
    this.creatorId,
    required this.totalWeight,
    required this.personCount,
    required this.status,
    required this.statusName,
    required this.createdAt,
    required this.updatedAt,
    this.itemCount = 0,
  });

  factory EquipmentListModel.fromJson(Map<String, dynamic> json) {
    return EquipmentListModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: equipmentListTypeFromCode(json['type']),
      typeName: json['typeName'] as String? ?? '',
      tripId: json['trip_id'] as String?,
      creatorId: json['creator_id'] as String?,
      totalWeight: _parseDouble(json['total_weight']),
      personCount: (json['person_count'] as num?)?.toInt() ?? 1,
      status: equipmentListStatusFromCode(json['status']),
      statusName: json['statusName'] as String? ?? '',
      createdAt: _parseEpochSeconds(json['created_at']),
      updatedAt: _parseEpochSeconds(json['updated_at']),
      itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  /// 解析秒级或毫秒级时间戳
  static DateTime _parseEpochSeconds(dynamic value) {
    if (value is int) {
      // 与 BaseModel.parseTimestamp 保持一致的秒/毫秒自动探测
      if (value > 9999999999) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return _parseEpochSeconds(parsed);
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// 获取总重量展示文本（克/千克自动换算）
  String get totalWeightText {
    if (totalWeight >= 1000) {
      return '${(totalWeight / 1000).toStringAsFixed(1)}kg';
    }
    return '${totalWeight.toStringAsFixed(0)}g';
  }
}

/// 创建装备清单的请求体
///
/// 对齐后端 `org.example.equipment.dto.EquipmentListCreateRequest`。
///
/// 后端 `type` 字段的 Int/String 解析 bug 已在 `EquipmentServiceImpl`
/// 中修复（新增了同时兼容 Int/Number/String 来源的 `parseIntField`），
/// 因此这里已可正常传递并持久化清单类型。
///
/// `tripId` 字段（关联行程）已通过 `trip-equipment-link` change 修复：
/// `EquipmentListController.createEquipmentList` 现在会将其透传到
/// 服务层并持久化。
///
/// 仍然保留的已知后端限制：
/// - `description` 字段无法持久化（`EquipmentList` 实体没有该列）。
/// 该字段本请求体仍不包含，避免用户填写了却发现无效。
class EquipmentListCreateRequestModel {
  /// 清单名称（必填，非空）
  final String name;

  /// 清单类型
  final EquipmentListType type;

  /// 人数
  final int personCount;

  /// 关联的行程ID（可选）
  final String? tripId;

  const EquipmentListCreateRequestModel({
    required this.name,
    this.type = EquipmentListType.personal,
    this.personCount = 1,
    this.tripId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type.toCode(),
        'personCount': personCount,
        if (tripId != null) 'tripId': tripId,
      };
}
