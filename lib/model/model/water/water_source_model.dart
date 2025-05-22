/// 水源模型
///
/// 用于表示户外活动中的水源点
///
/// WaterSourceModel记录了行程中可用的水源信息，包括位置、类型和水质等，
/// 帮助用户规划水源补给。

import '../../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'water_types.dart';

part 'water_source_model.g.dart';

/// 水源模型
@JsonSerializable()
class WaterSourceModel extends BaseModel {
  /// 水源名称
  final String name;

  /// 水源描述
  final String description;

  /// 水源类型
  @JsonKey(fromJson: _typeFromJson, toJson: _typeToJson)
  final WaterSourceType type;

  /// 位置描述
  final String location;

  /// 距离路线的偏移距离(米)
  final double distanceFromTrail;

  /// 预计水质
  @JsonKey(fromJson: _qualityFromJson, toJson: _qualityToJson)
  final WaterQuality quality;

  /// 可靠性评级(1-5)
  final int reliability;

  /// 预计可用水量(ml)
  final int estimatedVolume;

  /// 是否需要处理
  final bool needsTreatment;

  /// 构造函数
  WaterSourceModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.type,
    required this.location,
    this.distanceFromTrail = 0,
    required this.quality,
    required this.reliability,
    required this.estimatedVolume,
    required this.needsTreatment,
  });

  /// 从JSON创建
  factory WaterSourceModel.fromJson(Map<String, dynamic> json) =>
      _$WaterSourceModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WaterSourceModelToJson(this);

  /// 从字符串转换为水源类型枚举
  static WaterSourceType _typeFromJson(dynamic value) {
    if (value is int) {
      return WaterSourceType.values[value];
    } else if (value is String) {
      switch (value) {
        case 'river':
          return WaterSourceType.river;
        case 'stream':
          return WaterSourceType.stream;
        case 'lake':
          return WaterSourceType.lake;
        case 'spring':
          return WaterSourceType.spring;
        case 'tap':
          return WaterSourceType.tap;
        default:
          throw ArgumentError('$value is not a valid WaterSourceType');
      }
    }
    throw ArgumentError('Cannot convert $value to WaterSourceType');
  }

  /// 将水源类型枚举转换为字符串
  static String _typeToJson(WaterSourceType type) {
    switch (type) {
      case WaterSourceType.river:
        return 'river';
      case WaterSourceType.stream:
        return 'stream';
      case WaterSourceType.lake:
        return 'lake';
      case WaterSourceType.spring:
        return 'spring';
      case WaterSourceType.tap:
        return 'tap';
    }
  }

  /// 从字符串转换为水质枚举
  static WaterQuality _qualityFromJson(dynamic value) {
    if (value is int) {
      return WaterQuality.values[value];
    } else if (value is String) {
      switch (value) {
        case 'excellent':
          return WaterQuality.excellent;
        case 'good':
          return WaterQuality.good;
        case 'fair':
          return WaterQuality.fair;
        case 'poor':
          return WaterQuality.poor;
        default:
          throw ArgumentError('$value is not a valid WaterQuality');
      }
    }
    throw ArgumentError('Cannot convert $value to WaterQuality');
  }

  /// 将水质枚举转换为字符串
  static String _qualityToJson(WaterQuality quality) {
    switch (quality) {
      case WaterQuality.excellent:
        return 'excellent';
      case WaterQuality.good:
        return 'good';
      case WaterQuality.fair:
        return 'fair';
      case WaterQuality.poor:
        return 'poor';
    }
  }

  /// 获取水源类型名称
  String getTypeText() {
    switch (type) {
      case WaterSourceType.river:
        return '河流';
      case WaterSourceType.stream:
        return '溪流';
      case WaterSourceType.lake:
        return '湖泊';
      case WaterSourceType.spring:
        return '泉水';
      case WaterSourceType.tap:
        return '水龙头';
    }
  }

  /// 获取水质描述
  String getQualityText() {
    switch (quality) {
      case WaterQuality.excellent:
        return '优质';
      case WaterQuality.good:
        return '良好';
      case WaterQuality.fair:
        return '一般';
      case WaterQuality.poor:
        return '较差';
    }
  }

  /// 获取可靠性描述
  String getReliabilityText() {
    switch (reliability) {
      case 5:
        return '非常可靠';
      case 4:
        return '可靠';
      case 3:
        return '一般';
      case 2:
        return '不太可靠';
      case 1:
        return '不可靠';
      default:
        return '未知';
    }
  }

  /// 创建副本并更新指定字段
  WaterSourceModel copyWith({
    String? id,
    String? name,
    String? description,
    WaterSourceType? type,
    String? location,
    double? distanceFromTrail,
    WaterQuality? quality,
    int? reliability,
    int? estimatedVolume,
    bool? needsTreatment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterSourceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      location: location ?? this.location,
      distanceFromTrail: distanceFromTrail ?? this.distanceFromTrail,
      quality: quality ?? this.quality,
      reliability: reliability ?? this.reliability,
      estimatedVolume: estimatedVolume ?? this.estimatedVolume,
      needsTreatment: needsTreatment ?? this.needsTreatment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
