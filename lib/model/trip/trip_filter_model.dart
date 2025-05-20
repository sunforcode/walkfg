import 'package:flutter/foundation.dart';
import '../route/route_model.dart';

/// 行程筛选模型
class TripFilterModel {
  /// 搜索关键词
  final String? keyword;

  /// 地区
  final String? region;

  /// 难度
  final RouteDifficulty? difficulty;

  /// 最小天数
  final int? minDays;

  /// 最大天数
  final int? maxDays;

  /// 季节
  final String? season;

  /// 构造函数
  const TripFilterModel({
    this.keyword,
    this.region,
    this.difficulty,
    this.minDays,
    this.maxDays,
    this.season,
  });

  /// 创建副本
  TripFilterModel copyWith({
    String? keyword,
    String? region,
    RouteDifficulty? difficulty,
    int? minDays,
    int? maxDays,
    String? season,
  }) {
    return TripFilterModel(
      keyword: keyword ?? this.keyword,
      region: region ?? this.region,
      difficulty: difficulty ?? this.difficulty,
      minDays: minDays ?? this.minDays,
      maxDays: maxDays ?? this.maxDays,
      season: season ?? this.season,
    );
  }

  /// 从JSON创建
  factory TripFilterModel.fromJson(Map<String, dynamic> json) {
    return TripFilterModel(
      keyword: json['keyword'] as String?,
      region: json['region'] as String?,
      difficulty: json['difficulty'] != null
          ? RouteDifficulty.values[json['difficulty'] as int]
          : null,
      minDays: json['min_days'] as int?,
      maxDays: json['max_days'] as int?,
      season: json['season'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'region': region,
      'difficulty': difficulty?.index,
      'min_days': minDays,
      'max_days': maxDays,
      'season': season,
    };
  }

  /// 判断是否为空
  bool get isEmpty =>
      keyword == null &&
      region == null &&
      difficulty == null &&
      minDays == null &&
      maxDays == null &&
      season == null;

  /// 判断是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TripFilterModel &&
        other.keyword == keyword &&
        other.region == region &&
        other.difficulty == difficulty &&
        other.minDays == minDays &&
        other.maxDays == maxDays &&
        other.season == season;
  }

  @override
  int get hashCode => Object.hash(
        keyword,
        region,
        difficulty,
        minDays,
        maxDays,
        season,
      );
}