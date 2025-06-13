/// 水源模型
///
/// 用于表示户外活动中的水源信息
///
/// WaterSourceModel是饮水模块的基础单元，代表一个具体的水源，如"山涧溪流"、"水井"等。
/// 它继承TrackPointVO的地理位置信息，并扩展水源特有的属性。
import 'package:walk/model/map/track_point_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/user/user_model.dart';

part 'water_source_model.g.dart';

/// 水源类型枚举
enum WaterSourceType {
  /// 山涧溪流
  stream,

  /// 泉水
  spring,

  /// 水井
  well,

  /// 湖泊
  lake,

  /// 人工水源
  artificial,

  /// 其他
  other,
}

/// 水质等级枚举
enum WaterQuality {
  /// 优质 - 可直接饮用
  excellent,

  /// 良好 - 建议过滤后饮用
  good,

  /// 一般 - 需要净化处理
  fair,

  /// 差 - 不建议饮用
  poor,

  /// 未知
  unknown,
}

/// 水源模型 - 继承TrackPointVO的地理位置信息
@JsonSerializable()
class WaterSourceModel extends TrackPointVO {
  /// 唯一标识
  final String id;

  /// 水源名称
  final String? name;

  /// 水源描述
  final String? description;

  /// 创建时间
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// 水源类型
  @JsonKey(
      name: 'water_type', fromJson: _parseWaterType, toJson: _waterTypeToJson)
  final WaterSourceType waterType;

  /// 水质等级
  @JsonKey(
      name: 'water_quality',
      fromJson: _parseWaterQuality,
      toJson: _waterQualityToJson)
  final WaterQuality waterQuality;

  /// 水源可靠性（0-1，1表示全年可靠）
  final double reliability;

  /// 是否需要处理（过滤、净化等）
  @JsonKey(name: 'requires_treatment')
  final bool requiresTreatment;

  /// 水源备注（包含取水方式、注意事项等）
  final String notes;

  /// 最后确认时间
  @JsonKey(name: 'last_verified')
  final DateTime? lastVerified;

  /// 确认者ID
  @JsonKey(name: 'verified_by')
  final UserModel? verifiedBy;

  /// 构造函数
  WaterSourceModel({
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
    this.waterType = WaterSourceType.other,
    this.waterQuality = WaterQuality.unknown,
    this.reliability = 0.5,
    this.requiresTreatment = true,
    this.notes = '',
    this.lastVerified,
    this.verifiedBy,
  });

  /// 从JSON创建
  factory WaterSourceModel.fromJson(Map<String, dynamic> json) =>
      _$WaterSourceModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WaterSourceModelToJson(this);

  /// 创建副本并更新指定字段
  WaterSourceModel copyWith({
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
    WaterSourceType? waterType,
    WaterQuality? waterQuality,
    double? reliability,
    bool? requiresTreatment,
    String? notes,
    DateTime? lastVerified,
    UserModel? verifiedBy,
  }) {
    return WaterSourceModel(
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
      waterType: waterType ?? this.waterType,
      waterQuality: waterQuality ?? this.waterQuality,
      reliability: reliability ?? this.reliability,
      requiresTreatment: requiresTreatment ?? this.requiresTreatment,
      notes: notes ?? this.notes,
      lastVerified: lastVerified ?? this.lastVerified,
      verifiedBy: verifiedBy ?? this.verifiedBy,
    );
  }

  // ========== 便捷访问方法 ==========

  /// 获取水源类型显示文本
  String get waterTypeText {
    switch (waterType) {
      case WaterSourceType.stream:
        return '山涧溪流';
      case WaterSourceType.spring:
        return '泉水';
      case WaterSourceType.well:
        return '水井';
      case WaterSourceType.lake:
        return '湖泊';
      case WaterSourceType.artificial:
        return '人工水源';
      case WaterSourceType.other:
        return '其他';
    }
  }

  /// 获取水质等级显示文本
  String get waterQualityText {
    switch (waterQuality) {
      case WaterQuality.excellent:
        return '优质';
      case WaterQuality.good:
        return '良好';
      case WaterQuality.fair:
        return '一般';
      case WaterQuality.poor:
        return '差';
      case WaterQuality.unknown:
        return '未知';
    }
  }

  /// 获取水源类型图标
  String get waterTypeIcon {
    switch (waterType) {
      case WaterSourceType.stream:
        return '🏞️';
      case WaterSourceType.spring:
        return '⛲';
      case WaterSourceType.well:
        return '🕳️';
      case WaterSourceType.lake:
        return '🏔️';
      case WaterSourceType.artificial:
        return '🚰';
      case WaterSourceType.other:
        return '💧';
    }
  }

  /// 获取水质等级颜色（用于UI显示）
  String get waterQualityColor {
    switch (waterQuality) {
      case WaterQuality.excellent:
        return '#4CAF50'; // 绿色
      case WaterQuality.good:
        return '#8BC34A'; // 浅绿色
      case WaterQuality.fair:
        return '#FF9800'; // 橙色
      case WaterQuality.poor:
        return '#F44336'; // 红色
      case WaterQuality.unknown:
        return '#9E9E9E'; // 灰色
    }
  }

  /// 是否推荐使用
  bool get isRecommended {
    return waterQuality == WaterQuality.excellent ||
        waterQuality == WaterQuality.good;
  }

  /// 获取可靠性等级文本
  String get reliabilityText {
    if (reliability >= 0.8) return '高';
    if (reliability >= 0.5) return '中';
    return '低';
  }

  @override
  String toString() {
    return 'WaterSourceModel(id: $id, name: $name, type: ${waterTypeText}, quality: ${waterQualityText}, location: $latitude, $longitude)';
  }
}

/// 解析水源类型
WaterSourceType _parseWaterType(dynamic value) {
  if (value == null) return WaterSourceType.other;
  return WaterSourceType.values.firstWhere((type) => type.name == value,
      orElse: () => WaterSourceType.other);
}

/// 解析水质等级
WaterQuality _parseWaterQuality(dynamic value) {
  if (value == null) return WaterQuality.unknown;
  return WaterQuality.values.firstWhere((quality) => quality.name == value,
      orElse: () => WaterQuality.unknown);
}

/// 水源类型转JSON
String _waterTypeToJson(WaterSourceType type) {
  return type.name;
}

/// 水质等级转JSON
String _waterQualityToJson(WaterQuality quality) {
  return quality.name;
}
