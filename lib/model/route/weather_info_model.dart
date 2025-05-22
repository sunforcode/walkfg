import 'package:json_annotation/json_annotation.dart';

part 'weather_info_model.g.dart';

/// 气候信息值对象模型
///
/// 作为路径模型的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class WeatherInfoVO {
  /// 月均温度
  final Map<String, TemperatureRangeVO> averageTemperature;

  /// 降雨概率
  final Map<String, double> rainfallProbability;

  /// 极端天气风险
  final Map<String, String> extremeWeatherRisks;

  /// 构造函数
  WeatherInfoVO({
    required this.averageTemperature,
    required this.rainfallProbability,
    required this.extremeWeatherRisks,
  });

  /// 从JSON创建
  factory WeatherInfoVO.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeatherInfoVOToJson(this);
}

/// 温度范围值对象模型
@JsonSerializable()
class TemperatureRangeVO {
  /// 最低温度(°C)
  final double min;

  /// 最高温度(°C)
  final double max;

  /// 构造函数
  TemperatureRangeVO({
    required this.min,
    required this.max,
  });

  /// 从JSON创建
  factory TemperatureRangeVO.fromJson(Map<String, dynamic> json) =>
      _$TemperatureRangeVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TemperatureRangeVOToJson(this);
}
