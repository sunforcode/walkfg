import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'water_source_model.g.dart';

/// 水源点模型
@JsonSerializable()
class WaterSourceModel extends BaseModel {
  /// 水源名称
  final String name;

  /// 距离起点的距离(km)
  final double distance;

  /// 位置描述
  final String location;

  /// 水质等级（优/良/一般/差）
  final String quality;

  /// 可用性（全年/季节性/不定期）
  final String availability;

  /// 处理建议（可直接饮用/建议过滤/必须净化）
  final String treatment;

  /// 备注信息
  final String notes;

  /// 水源类型（山泉/人工/河流/湖泊）
  final String? sourceType;

  /// 流量（充足/一般/较少/微弱）
  final String? flowRate;

  /// 海拔高度
  final int? elevation;

  /// 经纬度
  final double? latitude;
  final double? longitude;

  /// 构造函数
  WaterSourceModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.distance,
    required this.location,
    required this.quality,
    required this.availability,
    required this.treatment,
    required this.notes,
    this.sourceType,
    this.flowRate,
    this.elevation,
    this.latitude,
    this.longitude,
  });

  /// 从JSON创建
  factory WaterSourceModel.fromJson(Map<String, dynamic> json) =>
      _$WaterSourceModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WaterSourceModelToJson(this);

  /// 简单构造函数（兼容原有的Map数据）
  factory WaterSourceModel.fromMap(Map<String, dynamic> map) {
    return WaterSourceModel(
      id: 'water_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      quality: map['quality'] ?? '',
      availability: map['availability'] ?? '',
      treatment: map['treatment'] ?? '',
      notes: map['notes'] ?? '',
      sourceType: map['sourceType'],
      flowRate: map['flowRate'],
      elevation: map['elevation'],
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  /// 获取水质颜色
  String get qualityColor {
    switch (quality) {
      case '优':
        return '#4CAF50'; // 绿色
      case '良':
        return '#8BC34A'; // 浅绿色
      case '一般':
        return '#FF9800'; // 橙色
      case '差':
        return '#F44336'; // 红色
      default:
        return '#9E9E9E'; // 灰色
    }
  }

  /// 获取处理建议图标
  String get treatmentIcon {
    if (treatment.contains('直接饮用')) {
      return '✅';
    } else if (treatment.contains('过滤')) {
      return '🔧';
    } else if (treatment.contains('净化')) {
      return '⚠️';
    }
    return '❓';
  }

  /// 是否可直接饮用
  bool get isSafeTodrink => treatment.contains('直接饮用');

  /// 获取距离显示文本
  String get distanceText {
    if (distance == 0) {
      return '起点';
    } else if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }
}