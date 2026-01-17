import 'package:json_annotation/json_annotation.dart';
part 'track_point_model.g.dart';

/// 轨迹点值对象模型 - 对应后端API返回的track_points
@JsonSerializable()
class TrackPointVO {
  /// 唯一标识
  final String? id;

  /// 纬度
  final double latitude;

  /// 名称
  final String? name;

  /// 经度
  final double longitude;

  /// 海拔高度（米）
  final double elevation;

  /// 描述
  final String? description;

  /// 类型（如：景点、起点、终点等）
  final String? type;

  /// 序列号 - 表示在路线中的顺序
  @JsonKey(name: 'sequence_number')
  final int? sequenceNumber;

  /// 图标URL
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// 图片URL
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  /// 时间戳（运行时设置）
  @JsonKey(ignore: true)
  final DateTime? timestamp;

  /// 距离起点的累计距离（米）（运行时设置）
  @JsonKey(ignore: true)
  final double? distanceFromStart;

  /// 构造函数
  TrackPointVO({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.name,
    this.description,
    this.type,
    this.sequenceNumber,
    this.iconUrl,
    this.imageUrl,
    this.timestamp,
    this.distanceFromStart,
  });

  /// 从KML格式创建轨迹点
  factory TrackPointVO.fromKml({
    required double latitude,
    required double longitude,
    double elevation = 0.0,
    DateTime? timestamp,
    String? name,
    String? description,
    String? type,
    String? iconUrl,
    String? imageUrl,
    Map<String, dynamic>? rawData,
  }) {
    return TrackPointVO(
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      timestamp: timestamp,
      name: name,
      description: description,
      type: type,
      iconUrl: iconUrl,
      imageUrl: imageUrl,
    );
  }

  /// 从JSON创建
  factory TrackPointVO.fromJson(Map<String, dynamic> json) =>
      _$TrackPointVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TrackPointVOToJson(this);

  /// 创建副本并更新属性
  TrackPointVO copyWith({
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
  }) {
    return TrackPointVO(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
    );
  }

  @override
  String toString() {
    return 'TrackPointVO(id: $id, name: $name, lat: $latitude, lon: $longitude, elevation: $elevation, type: $type, sequence: $sequenceNumber)';
  }
}
