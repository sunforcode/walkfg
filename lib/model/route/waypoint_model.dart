import 'package:json_annotation/json_annotation.dart';

part 'waypoint_model.g.dart';

/// 路标点模型
@JsonSerializable()
class WaypointModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String? description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔高度（米）
  final double elevation;

  /// 类型（start, end, attraction, rest, peak等）
  final String type;

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
    this.description,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.type,
    this.iconUrl,
    this.imageUrl,
    required this.sequenceNumber,
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WaypointModelToJson(this);

  /// 获取类型显示名称
  String get typeDisplayName {
    switch (type) {
      case 'start':
        return '起点';
      case 'end':
        return '终点';
      case 'attraction':
        return '景点';
      case 'rest':
        return '休息点';
      case 'peak':
        return '山峰';
      case 'viewpoint':
        return '观景点';
      case 'danger':
        return '危险点';
      case 'supply':
        return '补给点';
      default:
        return '路标点';
    }
  }

  /// 获取类型图标
  String get typeIcon {
    switch (type) {
      case 'start':
        return '🚩';
      case 'end':
        return '🏁';
      case 'attraction':
        return '🏛️';
      case 'rest':
        return '🛑';
      case 'peak':
        return '⛰️';
      case 'viewpoint':
        return '👁️';
      case 'danger':
        return '⚠️';
      case 'supply':
        return '🏪';
      default:
        return '📍';
    }
  }

  /// 是否为重要路标点
  bool get isImportant {
    return type == 'start' ||
        type == 'end' ||
        type == 'peak' ||
        type == 'danger';
  }

  /// 创建副本
  WaypointModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    double? elevation,
    String? type,
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
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    );
  }

  @override
  String toString() {
    return 'WaypointModel(id: $id, name: $name, type: $type, sequence: $sequenceNumber)';
  }
}
