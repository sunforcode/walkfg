import 'package:json_annotation/json_annotation.dart';

part 'track_point_model.g.dart';

/// 轨迹点模型
@JsonSerializable()
class TrackPointModel {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔（米）
  final double elevation;

  /// 时间戳
  final DateTime? time;

  /// 名称（途经点）
  final String? name;

  /// 描述（途经点）
  final String? description;

  /// 构造函数
  const TrackPointModel({
    required this.latitude,
    required this.longitude,
    this.elevation = 0.0,
    this.time,
    this.name,
    this.description,
  });

  /// 从JSON创建
  factory TrackPointModel.fromJson(Map<String, dynamic> json) =>
      _$TrackPointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TrackPointModelToJson(this);

  /// 创建副本
  TrackPointModel copyWith({
    double? latitude,
    double? longitude,
    double? elevation,
    DateTime? time,
    String? name,
    String? description,
  }) {
    return TrackPointModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      time: time ?? this.time,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
