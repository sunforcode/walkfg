import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/waypoint_model.dart';

part 'marker_point_model.g.dart';

/// 标记点类型枚举
enum MarkerPointType {
  /// 兴趣点
  poi,

  /// 地标
  landmark,

  /// 观景点
  viewpoint,

  /// 休息点
  restPoint,

  /// 危险点
  dangerPoint,

  /// 信息点
  infoPoint,

  /// 其他
  other,
}

/// 标记点模型 - 继承TrackPointVO，专门用于KML中的普通标记点
@JsonSerializable()
class MarkerPointModel extends TrackPointVO {
  /// 唯一标识
  final String id;

  /// 标记点名称
  final String? name;

  /// 标记点描述
  final String? description;

  /// 标记点类型
  @JsonKey(
      name: 'marker_type',
      fromJson: _parseMarkerType,
      toJson: _markerTypeToJson)
  final MarkerPointType markerType;

  /// 图标URL或图标名称
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  /// 颜色（十六进制字符串，如 "#FF0000"）
  final String? color;

  /// 构造函数
  MarkerPointModel({
    required this.id,
    required super.latitude,
    required super.longitude,
    required super.elevation,
    super.timestamp,
    super.distanceFromStart,
    this.name,
    this.description,
    this.markerType = MarkerPointType.other,
    this.iconUrl,
    this.color,
  });

  /// 从KML数据创建标记点
  factory MarkerPointModel.fromKml({
    required String id,
    required double latitude,
    required double longitude,
    double elevation = 0.0,
    DateTime? timestamp,
    String? name,
    String? description,
    MarkerPointType markerType = MarkerPointType.poi,
    String? iconUrl,
    String? color,
  }) {
    return MarkerPointModel(
      id: id,
      latitude: latitude,
      longitude: longitude,
      elevation: elevation,
      timestamp: timestamp,
      name: name,
      description: description,
      markerType: markerType,
      iconUrl: iconUrl,
      color: color,
    );
  }

  /// 从WaypointModel创建标记点
  factory MarkerPointModel.fromWaypoint(WaypointModel waypoint) {
    // 根据waypoint类型映射到MarkerPointType
    MarkerPointType markerType;
    switch (waypoint.type) {
      case 'attraction':
        markerType = MarkerPointType.poi;
        break;
      case 'rest':
        markerType = MarkerPointType.restPoint;
        break;
      case 'peak':
        markerType = MarkerPointType.landmark;
        break;
      case 'viewpoint':
        markerType = MarkerPointType.viewpoint;
        break;
      case 'danger':
        markerType = MarkerPointType.dangerPoint;
        break;
      case 'start':
      case 'end':
        markerType = MarkerPointType.infoPoint;
        break;
      default:
        markerType = MarkerPointType.other;
    }
    return MarkerPointModel(
      id: waypoint.id,
      latitude: waypoint.latitude,
      longitude: waypoint.longitude,
      elevation: waypoint.elevation,
      name: waypoint.name,
      description: waypoint.description,
      markerType: markerType,
      iconUrl: waypoint.iconUrl,
    );
  }

  /// 从JSON创建
  factory MarkerPointModel.fromJson(Map<String, dynamic> json) =>
      _$MarkerPointModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$MarkerPointModelToJson(this);

  /// 创建副本并更新指定字段
  @override
  MarkerPointModel copyWith({
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
    MarkerPointType? markerType,
    String? color,
  }) {
    return MarkerPointModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
      name: name ?? this.name,
      description: description ?? this.description,
      markerType: markerType ?? this.markerType,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
    );
  }

  // ========== 便捷访问方法 ==========

  /// 获取标记点类型显示文本
  String get markerTypeText {
    switch (markerType) {
      case MarkerPointType.poi:
        return '兴趣点';
      case MarkerPointType.landmark:
        return '地标';
      case MarkerPointType.viewpoint:
        return '观景点';
      case MarkerPointType.restPoint:
        return '休息点';
      case MarkerPointType.dangerPoint:
        return '危险点';
      case MarkerPointType.infoPoint:
        return '信息点';
      case MarkerPointType.other:
        return '其他';
    }
  }

  /// 获取标记点类型图标
  String get markerTypeIcon {
    switch (markerType) {
      case MarkerPointType.poi:
        return '📍';
      case MarkerPointType.landmark:
        return '🏛️';
      case MarkerPointType.viewpoint:
        return '👁️';
      case MarkerPointType.restPoint:
        return '🛑';
      case MarkerPointType.dangerPoint:
        return '⚠️';
      case MarkerPointType.infoPoint:
        return 'ℹ️';
      case MarkerPointType.other:
        return '📌';
    }
  }

  /// 获取默认颜色
  String get defaultColor {
    if (color != null) return color!;

    switch (markerType) {
      case MarkerPointType.poi:
        return '#2196F3'; // 蓝色
      case MarkerPointType.landmark:
        return '#4CAF50'; // 绿色
      case MarkerPointType.viewpoint:
        return '#FF9800'; // 橙色
      case MarkerPointType.restPoint:
        return '#9C27B0'; // 紫色
      case MarkerPointType.dangerPoint:
        return '#F44336'; // 红色
      case MarkerPointType.infoPoint:
        return '#00BCD4'; // 青色
      case MarkerPointType.other:
        return '#757575'; // 灰色
    }
  }

  /// 是否为重要标记点
  bool get isImportant {
    return markerType == MarkerPointType.dangerPoint ||
        markerType == MarkerPointType.landmark;
  }

  /// 是否可见（简化版，始终返回true）
  bool get isVisible => true;

  /// 优先级（简化版，根据类型返回）
  int get priority {
    switch (markerType) {
      case MarkerPointType.dangerPoint:
        return 10;
      case MarkerPointType.landmark:
        return 8;
      case MarkerPointType.viewpoint:
        return 6;
      case MarkerPointType.restPoint:
        return 4;
      case MarkerPointType.infoPoint:
        return 3;
      case MarkerPointType.poi:
        return 2;
      case MarkerPointType.other:
        return 1;
    }
  }

  /// 获取显示标题
  String get displayTitle {
    return name ?? markerTypeText;
  }

  /// 获取显示描述
  String get displayDescription {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }

    // 如果没有描述，生成基础信息
    final info = <String>[];
    info.add('海拔: ${elevation.toStringAsFixed(1)}m');
    info.add(
        '坐标: ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}');

    return info.join('\n');
  }

  @override
  String toString() {
    return 'MarkerPointModel(id: $id, name: $name, type: $markerTypeText, location: $latitude, $longitude)';
  }
}

/// 解析标记点类型
MarkerPointType _parseMarkerType(dynamic value) {
  if (value == null) return MarkerPointType.other;

  if (value is int) {
    // 从整数索引转换为枚举
    if (value >= 0 && value < MarkerPointType.values.length) {
      return MarkerPointType.values[value];
    }
    return MarkerPointType.other;
  }

  if (value is String) {
    // 从字符串名称转换为枚举
    return MarkerPointType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => MarkerPointType.other,
    );
  }

  return MarkerPointType.other;
}

/// 标记点类型转JSON
int _markerTypeToJson(MarkerPointType type) {
  return type.index;
}
