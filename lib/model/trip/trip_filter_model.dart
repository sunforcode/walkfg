import 'package:json_annotation/json_annotation.dart';
part 'trip_filter_model.g.dart';

/// 行程筛选模型
@JsonSerializable()
class TripFilterModel {
  /// 关键词
  final String? keyword;

  /// 难度
  final String? difficulty;

  /// 季节
  final String? season;

  /// 时长
  final String? duration;

  /// 最小距离(km)
  final double? minDistance;

  /// 最大距离(km)
  final double? maxDistance;

  /// 最小海拔(m)
  final double? minElevation;

  /// 最大海拔(m)
  final double? maxElevation;

  /// 排序字段
  final String? sortBy;

  /// 是否升序
  final bool? ascending;

  /// 构造函数
  TripFilterModel({
    this.keyword,
    this.difficulty,
    this.season,
    this.duration,
    this.minDistance,
    this.maxDistance,
    this.minElevation,
    this.maxElevation,
    this.sortBy,
    this.ascending,
  });

  /// 从JSON创建
  factory TripFilterModel.fromJson(Map<String, dynamic> json) =>
      _$TripFilterModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TripFilterModelToJson(this);

  /// 创建副本并更新部分属性
  TripFilterModel copyWith({
    String? keyword,
    String? difficulty,
    String? season,
    String? duration,
    double? minDistance,
    double? maxDistance,
    double? minElevation,
    double? maxElevation,
    String? sortBy,
    bool? ascending,
  }) {
    return TripFilterModel(
      keyword: keyword ?? this.keyword,
      difficulty: difficulty ?? this.difficulty,
      season: season ?? this.season,
      duration: duration ?? this.duration,
      minDistance: minDistance ?? this.minDistance,
      maxDistance: maxDistance ?? this.maxDistance,
      minElevation: minElevation ?? this.minElevation,
      maxElevation: maxElevation ?? this.maxElevation,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}
