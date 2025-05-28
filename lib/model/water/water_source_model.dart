/// 水源模型
///
/// 用于表示户外活动中的水源信息
///
/// WaterSourceModel是饮水模块的基础单元，代表一个具体的水源，如"山涧溪流"、"水井"等。
/// 它记录了水源的位置、水质、可靠性和预估水量等关键信息，用于：
///
/// 1. 记录水源的详细属性，帮助用户找到和评估水源
/// 2. 标记水源是否需要处理，提醒用户携带净水设备
/// 3. 计算可用水量，帮助规划饮水策略
/// 4. 评估水源的可靠性，减少饮水风险

import '../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'water_types.dart';

part 'water_source_model.g.dart';

/// 水源模型
@JsonSerializable()
class WaterSourceModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 类型
  final String type;

  /// 位置描述
  final String location;

  /// 距离路线的距离(m)
  @JsonKey(name: 'distance_from_trail')
  final double distanceFromTrail;

  /// 水质
  final String quality;

  /// 可靠性(1-5)
  final int reliability;

  /// 预估水量(ml)
  @JsonKey(name: 'estimated_volume')
  final int estimatedVolume;

  /// 是否需要处理
  @JsonKey(name: 'needs_treatment')
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
    required this.distanceFromTrail,
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

  /// 获取水源类型枚举
  WaterSourceType getSourceType() {
    switch (type.toLowerCase()) {
      case 'stream':
        return WaterSourceType.stream;
      case 'lake':
        return WaterSourceType.lake;
      case 'spring':
        return WaterSourceType.spring;
      case 'well':
        return WaterSourceType.well;
      case 'tap':
        return WaterSourceType.tap;
      case 'snow':
        return WaterSourceType.snow;
      case 'rain':
        return WaterSourceType.rain;
      default:
        return WaterSourceType.stream;
    }
  }

  /// 获取水质枚举
  WaterQuality getWaterQuality() {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return WaterQuality.excellent;
      case 'good':
        return WaterQuality.good;
      case 'fair':
        return WaterQuality.fair;
      case 'poor':
        return WaterQuality.poor;
      default:
        return WaterQuality.unknown;
    }
  }

  /// 获取水源类型文本
  String getSourceTypeText() {
    switch (getSourceType()) {
      case WaterSourceType.stream:
        return '溪流';
      case WaterSourceType.lake:
        return '湖泊';
      case WaterSourceType.spring:
        return '泉水';
      case WaterSourceType.well:
        return '水井';
      case WaterSourceType.tap:
        return '自来水';
      case WaterSourceType.snow:
        return '积雪';
      case WaterSourceType.rain:
        return '雨水';
    }
  }

  /// 获取水质文本
  String getQualityText() {
    switch (getWaterQuality()) {
      case WaterQuality.excellent:
        return '优质';
      case WaterQuality.good:
        return '良好';
      case WaterQuality.fair:
        return '一般';
      case WaterQuality.poor:
        return '较差';
      case WaterQuality.unknown:
        return '未知';
    }
  }

  /// 获取可靠性文本
  String getReliabilityText() {
    switch (reliability) {
      case 5:
        return '极高';
      case 4:
        return '高';
      case 3:
        return '中等';
      case 2:
        return '低';
      case 1:
        return '极低';
      default:
        return '未知';
    }
  }

  /// 创建副本并更新指定字段
  WaterSourceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? type,
    String? location,
    double? distanceFromTrail,
    String? quality,
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
