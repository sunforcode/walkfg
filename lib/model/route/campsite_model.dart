import 'package:walk/model/map/track_point_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walk/utils/json_utils.dart';

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
  /// 完善 - 有完整设施
  excellent,

  /// 良好 - 有基本设施
  good,

  /// 一般 - 设施简陋
  fair,

  /// 无设施
  none,

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
  @JsonKey(
      name: 'created_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(
      name: 'updated_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? updatedAt;

  /// 营地类型
  @JsonKey(
      name: 'campsite_type',
      fromJson: _parseCampsiteType,
      toJson: _campsiteTypeToJson)
  final CampsiteType campsiteType;

  /// 营地备注（包含注意事项、规则等）
  final String notes;

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
    this.notes = '',
    this.verifiedBy,
  });

  /// 从JSON创建
  factory CampsiteModel.fromJson(Map<String, dynamic> json) =>
      _$CampsiteModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$CampsiteModelToJson(this);

  /// 创建副本并更新指定字段
  @override
  CampsiteModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? elevation,
    String? name,
    String? description,
    String? type,
    int? sequenceNumber,
    String? iconUrl,
    String? imageUrl,
    DateTime? timestamp,
    double? distanceFromStart,
    DateTime? createdAt,
    DateTime? updatedAt,
    CampsiteType? campsiteType,
    String? notes,
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
      notes: notes ?? this.notes,
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
    return '未知'; // 默认返回未知
  }

  /// 获取容量等级显示文本
  String get capacityText {
    return '未知'; // 默认返回未知
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
    return '#9E9E9E'; // 默认灰色
  }

  /// 是否推荐使用
  bool get isRecommended {
    return false; // 默认不推荐
  }

  /// 获取水源距离文本
  String get waterDistanceText {
    return '未知'; // 默认未知
  }

  @override
  String toString() {
    return 'CampsiteModel(id: $id, name: $name, type: $campsiteTypeText, facility: $facilityLevelText, location: $latitude, $longitude)';
  }
}

/// 解析营地类型
CampsiteType _parseCampsiteType(dynamic value) {
  if (value == null) return CampsiteType.other;

  if (value is int) {
    // 从整数索引转换为枚举
    if (value >= 0 && value < CampsiteType.values.length) {
      return CampsiteType.values[value];
    }
    return CampsiteType.other;
  }

  if (value is String) {
    return CampsiteType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => CampsiteType.other,
    );
  }

  return CampsiteType.other;
}

/// 解析设施等级

/// 营地类型转JSON
int _campsiteTypeToJson(CampsiteType type) {
  return type.index;
}
