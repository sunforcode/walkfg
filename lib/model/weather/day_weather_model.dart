import 'package:json_annotation/json_annotation.dart';

part 'day_weather_model.g.dart';

/// 天气状况枚举
enum DayWeatherCondition {
  sunny,
  cloudy,
  overcast,
  lightRain,
  heavyRain,
  thunderstorm,
  snow,
  foggy,
  windy,
  unknown,
}

/// 逐日天气模型 - 单日天气预报
@JsonSerializable()
class DayWeatherModel {
  /// 日期
  final DateTime date;
  
  /// 天气状况
  @JsonKey(name: 'condition', fromJson: _parseCondition, toJson: _conditionToJson)
  final DayWeatherCondition condition;
  
  /// 天气状况中文描述
  @JsonKey(name: 'condition_text', defaultValue: '')
  final String conditionText;
  
  /// 最高温度（℃）
  @JsonKey(name: 'temp_high')
  final double? tempHigh;
  
  /// 最低温度（℃）
  @JsonKey(name: 'temp_low')
  final double? tempLow;
  
  /// 降雨概率（%）
  @JsonKey(name: 'rain_probability')
  final int? rainProbability;
  
  /// 风速（km/h）
  @JsonKey(name: 'wind_speed')
  final double? windSpeed;
  
  /// 风向
  @JsonKey(name: 'wind_direction', defaultValue: '')
  final String windDirection;
  
  /// 特别提醒
  @JsonKey(defaultValue: '')
  final String alert;
  
  DayWeatherModel({
    required this.date,
    this.condition = DayWeatherCondition.unknown,
    this.conditionText = '',
    this.tempHigh,
    this.tempLow,
    this.rainProbability,
    this.windSpeed,
    this.windDirection = '',
    this.alert = '',
  });
  
  factory DayWeatherModel.fromJson(Map<String, dynamic> json) =>
      _$DayWeatherModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$DayWeatherModelToJson(this);
  
  /// 获取天气状况图标
  String get conditionIcon {
    switch (condition) {
      case DayWeatherCondition.sunny: return '☀️';
      case DayWeatherCondition.cloudy: return '⛅';
      case DayWeatherCondition.overcast: return '☁️';
      case DayWeatherCondition.lightRain: return '🌧️';
      case DayWeatherCondition.heavyRain: return '🌧️';
      case DayWeatherCondition.thunderstorm: return '⛈️';
      case DayWeatherCondition.snow: return '❄️';
      case DayWeatherCondition.foggy: return '🌫️';
      case DayWeatherCondition.windy: return '💨';
      case DayWeatherCondition.unknown: return '🌤️';
    }
  }
  
  /// 获取天气状况显示文本
  String get conditionDisplayText {
    if (conditionText.isNotEmpty) return conditionText;
    switch (condition) {
      case DayWeatherCondition.sunny: return '晴';
      case DayWeatherCondition.cloudy: return '多云';
      case DayWeatherCondition.overcast: return '阴';
      case DayWeatherCondition.lightRain: return '小雨';
      case DayWeatherCondition.heavyRain: return '大雨';
      case DayWeatherCondition.thunderstorm: return '雷阵雨';
      case DayWeatherCondition.snow: return '雪';
      case DayWeatherCondition.foggy: return '雾';
      case DayWeatherCondition.windy: return '大风';
      case DayWeatherCondition.unknown: return '未知';
    }
  }
}

DayWeatherCondition _parseCondition(dynamic value) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'sunny': return DayWeatherCondition.sunny;
      case 'cloudy': return DayWeatherCondition.cloudy;
      case 'overcast': return DayWeatherCondition.overcast;
      case 'light_rain':
      case 'lightrain': return DayWeatherCondition.lightRain;
      case 'heavy_rain':
      case 'heavyrain': return DayWeatherCondition.heavyRain;
      case 'thunderstorm': return DayWeatherCondition.thunderstorm;
      case 'snow': return DayWeatherCondition.snow;
      case 'foggy': return DayWeatherCondition.foggy;
      case 'windy': return DayWeatherCondition.windy;
      default: return DayWeatherCondition.unknown;
    }
  }
  return DayWeatherCondition.unknown;
}

String _conditionToJson(DayWeatherCondition condition) {
  return condition.name;
}
