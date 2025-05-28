import 'package:json_annotation/json_annotation.dart';
import '../weather/weather_model.dart';

part 'waypoint_model.g.dart';

/// 路线关键点模型
@JsonSerializable()
class WaypointModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔
  final double? elevation;

  /// 类型
  final String type;

  /// 天气数据
  @JsonKey(ignore: true)
  WeatherModel? weather;

  /// 图标URL
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// 图片URL
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 序号
  @JsonKey(name: 'sequence_number')
  final int sequenceNumber;

  /// 构造函数
  WaypointModel({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.type,
    this.weather,
    this.iconUrl,
    this.imageUrl,
    required this.sequenceNumber,
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WaypointModelToJson(this);
  
  /// 创建副本并更新部分属性
  WaypointModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? elevation,
    String? type,
    WeatherModel? weather,
    String? iconUrl,
    String? imageUrl,
    int? sequenceNumber,
  }) {
    return WaypointModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      type: type ?? this.type,
      weather: weather ?? this.weather,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }
}