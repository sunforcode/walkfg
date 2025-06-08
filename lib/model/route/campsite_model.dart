import 'package:walk/model/map/track_point_model.dart';
import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'campsite_model.g.dart';

/// 营地类型枚举
enum CampsiteType {
  /// 山顶营地
  summit,

  /// 湖边营地
  lakeside,

  /// 森林营地
  forest,

  /// 草地营地
  meadow,

  /// 指定营地
  designated,

  /// 野营地
  wild,

  /// 其他
  other,
}

/// 营地设施等级枚举
enum CampsiteFacility {
  /// 完善 - 有厕所、水源、垃圾处理
  excellent,

  /// 良好 - 有基本设施
  good,

  /// 一般 - 设施简陋
  fair,

  /// 无设施 - 纯野营
  none,

  /// 未知
  unknown,
}

/// 营地容量等级枚举
enum CampsiteCapacity {
  /// 小型 - 1-3顶帐篷
  small,

  /// 中型 - 4-8顶帐篷
  medium,

  /// 大型 - 9-15顶帐篷
  large,

  /// 超大型 - 15顶以上帐篷
  xlarge,

  /// 未知
  unknown,
}

/// 营地模型 - 继承TrackPointVO的地理位置信息
@JsonSerializable()
class CampsiteModel extends TrackPointVO {
  /// 唯一标识
  final String id;

  /// 营地名称
  final String? name;

  /// 营地描述
  final String? description;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// 营地类型
  @JsonKey(
      name: 'campsite_type',
      fromJson: _parseCampsiteType,
      toJson: _campsiteTypeToJson)
  final CampsiteType campsiteType;

  /// 设施等级
  @JsonKey(
      name: 'facility_level',
      fromJson: _parseFacilityLevel,
      toJson: _facilityLevelToJson)
  final CampsiteFacility facilityLevel;

  /// 营地容量
  @JsonKey(name: 'capacity', fromJson: _parseCapacity, toJson: _capacityToJson)
  final CampsiteCapacity capacity;

  /// 是否需要预订
  @JsonKey(name: 'requires_booking')
  final bool requiresBooking;

  /// 是否允许篝火
  @JsonKey(name: 'allows_campfire')
  final bool allowsCampfire;

  /// 水源距离（米）
  @JsonKey(name: 'water_distance')
  final double? waterDistance;

  /// 营地备注（包含注意事项、规则等）
  final String notes;

  /// 最后确认时间
  @JsonKey(name: 'last_verified')
  final DateTime? lastVerified;

  /// 确认者ID
  @JsonKey(name: 'verified_by')
  final String? verifiedBy;

  /// 构造函数
  CampsiteModel({
    required this.id,
    required super.latitude,
    required super.longitude,
    required super.elevation,
    super.timestamp,
    super.distanceFromStart,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.campsiteType = CampsiteType.other,
    this.facilityLevel = CampsiteFacility.unknown,
    this.capacity = CampsiteCapacity.unknown,
    this.requiresBooking = false,
    this.allowsCampfire = false,
    this.waterDistance,
    this.notes = '',
    this.lastVerified,
    this.verifiedBy,
  });

  /// 从JSON创建
  factory CampsiteModel.fromJson(Map<String, dynamic> json) =>
      _$CampsiteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$CampsiteModelToJson(this);

  /// 创建副本并更新指定字段
  CampsiteModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? elevation,
    DateTime? timestamp,
    double? distanceFromStart,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    CampsiteType? campsiteType,
    CampsiteFacility? facilityLevel,
    CampsiteCapacity? capacity,
    bool? requiresBooking,
    bool? allowsCampfire,
    double? waterDistance,
    String? notes,
    DateTime? lastVerified,
    String? verifiedBy,
  }) {
    return CampsiteModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      campsiteType: campsiteType ?? this.campsiteType,
      facilityLevel: facilityLevel ?? this.facilityLevel,
      capacity: capacity ?? this.capacity,
      requiresBooking: requiresBooking ?? this.requiresBooking,
      allowsCampfire: allowsCampfire ?? this.allowsCampfire,
      waterDistance: waterDistance ?? this.waterDistance,
      notes: notes ?? this.notes,
      lastVerified: lastVerified ?? this.lastVerified,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  // ========== 便捷访问方法 ==========

  /// 获取营地类型显示文本
  String get campsiteTypeText {
    switch (campsiteType) {
      case CampsiteType.summit:
        return '山顶营地';
      case CampsiteType.lakeside:
        return '湖边营地';
      case CampsiteType.forest:
        return '森林营地';
      case CampsiteType.meadow:
        return '草地营地';
      case CampsiteType.designated:
        return '指定营地';
      case CampsiteType.wild:
        return '野营地';
      case CampsiteType.other:
        return '其他';
    }
  }

  /// 获取设施等级显示文本
  String get facilityLevelText {
    switch (facilityLevel) {
      case CampsiteFacility.excellent:
        return '完善';
      case CampsiteFacility.good:
        return '良好';
      case CampsiteFacility.fair:
        return '一般';
      case CampsiteFacility.none:
        return '无设施';
      case CampsiteFacility.unknown:
        return '未知';
    }
  }

  /// 获取容量等级显示文本
  String get capacityText {
    switch (capacity) {
      case CampsiteCapacity.small:
        return '小型(1-3顶)';
      case CampsiteCapacity.medium:
        return '中型(4-8顶)';
      case CampsiteCapacity.large:
        return '大型(9-15顶)';
      case CampsiteCapacity.xlarge:
        return '超大型(15+顶)';
      case CampsiteCapacity.unknown:
        return '未知';
    }
  }

  /// 获取营地类型图标
  String get campsiteTypeIcon {
    switch (campsiteType) {
      case CampsiteType.summit:
        return '⛰️';
      case CampsiteType.lakeside:
        return '🏞️';
      case CampsiteType.forest:
        return '🌲';
      case CampsiteType.meadow:
        return '🌾';
      case CampsiteType.designated:
        return '🏕️';
      case CampsiteType.wild:
        return '⛺';
      case CampsiteType.other:
        return '🏕️';
    }
  }

  /// 获取设施等级颜色（用于UI显示）
  String get facilityLevelColor {
    switch (facilityLevel) {
      case CampsiteFacility.excellent:
        return '#4CAF50'; // 绿色
      case CampsiteFacility.good:
        return '#8BC34A'; // 浅绿色
      case CampsiteFacility.fair:
        return '#FF9800'; // 橙色
      case CampsiteFacility.none:
        return '#F44336'; // 红色
      case CampsiteFacility.unknown:
        return '#9E9E9E'; // 灰色
    }
  }

  /// 是否推荐使用
  bool get isRecommended {
    return facilityLevel == CampsiteFacility.excellent ||
        facilityLevel == CampsiteFacility.good;
  }

  /// 获取水源距离文本
  String get waterDistanceText {
    if (waterDistance == null) return '未知';
    if (waterDistance! < 100) return '${waterDistance!.toInt()}米';
    if (waterDistance! < 1000)
      return '${(waterDistance! / 100).toStringAsFixed(1)}百米';
    return '${(waterDistance! / 1000).toStringAsFixed(1)}公里';
  }

  @override
  String toString() {
    return 'CampsiteModel(id: $id, name: $name, type: ${campsiteTypeText}, facility: ${facilityLevelText}, location: $latitude, $longitude)';
  }
}

/// 解析营地类型
CampsiteType _parseCampsiteType(dynamic value) {
  if (value == null) return CampsiteType.other;
  return CampsiteType.values.firstWhere((type) => type.name == value,
      orElse: () => CampsiteType.other);
}

/// 解析设施等级
CampsiteFacility _parseFacilityLevel(dynamic value) {
  if (value == null) return CampsiteFacility.unknown;
  return CampsiteFacility.values.firstWhere(
      (facility) => facility.name == value,
      orElse: () => CampsiteFacility.unknown);
}

/// 解析容量等级
CampsiteCapacity _parseCapacity(dynamic value) {
  if (value == null) return CampsiteCapacity.unknown;
  return CampsiteCapacity.values.firstWhere(
      (capacity) => capacity.name == value,
      orElse: () => CampsiteCapacity.unknown);
}

/// 营地类型转JSON
String _campsiteTypeToJson(CampsiteType type) {
  return type.name;
}

/// 设施等级转JSON
String _facilityLevelToJson(CampsiteFacility facility) {
  return facility.name;
}

/// 容量等级转JSON
String _capacityToJson(CampsiteCapacity capacity) {
  return capacity.name;
}
