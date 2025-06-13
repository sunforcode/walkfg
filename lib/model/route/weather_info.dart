import 'package:json_annotation/json_annotation.dart';

part 'weather_info.g.dart';

/// 气候信息值对象
@JsonSerializable()
class WeatherInfoVO {
  /// 气候描述
  final String description;

  /// 季节性信息
  @JsonKey(name: 'seasonal_weather')
  final Map<String, String> seasonal;

  /// 最佳季节
  @JsonKey(name: 'best_seasons')
  final List<String> bestSeasons;

  /// 注意事项
  final String? precautions;

  /// 构造函数
  WeatherInfoVO({
    required this.description,
    required this.seasonal,
    required this.bestSeasons,
    this.precautions,
  });

  /// 从JSON创建
  factory WeatherInfoVO.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeatherInfoVOToJson(this);
}