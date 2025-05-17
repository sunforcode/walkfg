/// 路线模型类，用于存储徒步路线的信息
///
/// 包含路线的基本信息、地理数据、难度评级和关键点等

import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'route_model.g.dart';

/// 难度级别
enum DifficultyLevel {
  easy,
  moderate,
  challenging,
  difficult,
  extreme
}

/// 路线类型
enum RouteType {
  loop,
  outAndBack,
  pointToPoint,
  network
}

/// 地形类型
enum TerrainType {
  flat,
  rolling,
  hilly,
  mountainous,
  rocky,
  sandy,
  muddy,
  snowy,
  icy,
  mixed
}

/// 路线模型
@JsonSerializable()
class RouteModel extends BaseModel {
  /// 路线ID
  final String id;

  /// 路线名称
  final String name;

  /// 路线描述
  final String description;

  /// 路线距离（公里）
  final double distance;

  /// 预计时间
  final String duration;

  /// 难度级别
  final String difficulty;

  /// 海拔增益（米）
  final int elevationGain;

  /// 海拔损失（米）
  final int elevationLoss;

  /// 最高点（米）
  final int highestPoint;

  /// 最低点（米）
  final int lowestPoint;

  /// 地形类型
  final List<String> terrainTypes;

  /// 适宜季节
  final List<String> seasons;

  /// 水源
  final List<String> waterSources;

  /// 营地
  final List<String> campingSites;

  /// 创建时间
  final DateTime? createdAt;

  /// 更新时间
  final DateTime? updatedAt;

  /// 构造函数
  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.duration,
    required this.difficulty,
    required this.elevationGain,
    required this.elevationLoss,
    required this.highestPoint,
    required this.lowestPoint,
    required this.terrainTypes,
    required this.seasons,
    required this.waterSources,
    required this.campingSites,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建路线模型
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      distance: (json['distance'] as num).toDouble(),
      duration: json['duration'] as String,
      difficulty: json['difficulty'] as String,
      elevationGain: json['elevation_gain'] as int,
      elevationLoss: json['elevation_loss'] as int,
      highestPoint: json['highest_point'] as int,
      lowestPoint: json['lowest_point'] as int,
      terrainTypes: (json['terrain_types'] as List<dynamic>).map((e) => e as String).toList(),
      seasons: (json['seasons'] as List<dynamic>).map((e) => e as String).toList(),
      waterSources: (json['water_sources'] as List<dynamic>).map((e) => e as String).toList(),
      campingSites: (json['camping_sites'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'distance': distance,
      'duration': duration,
      'difficulty': difficulty,
      'elevation_gain': elevationGain,
      'elevation_loss': elevationLoss,
      'highest_point': highestPoint,
      'lowest_point': lowestPoint,
      'terrain_types': terrainTypes,
      'seasons': seasons,
      'water_sources': waterSources,
      'camping_sites': campingSites,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// 创建副本并更新指定字段
  RouteModel copyWith({
    String? id,
    String? name,
    String? description,
    double? distance,
    String? duration,
    String? difficulty,
    int? elevationGain,
    int? elevationLoss,
    int? highestPoint,
    int? lowestPoint,
    List<String>? terrainTypes,
    List<String>? seasons,
    List<String>? waterSources,
    List<String>? campingSites,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      elevationGain: elevationGain ?? this.elevationGain,
      elevationLoss: elevationLoss ?? this.elevationLoss,
      highestPoint: highestPoint ?? this.highestPoint,
      lowestPoint: lowestPoint ?? this.lowestPoint,
      terrainTypes: terrainTypes ?? this.terrainTypes,
      seasons: seasons ?? this.seasons,
      waterSources: waterSources ?? this.waterSources,
      campingSites: campingSites ?? this.campingSites,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
