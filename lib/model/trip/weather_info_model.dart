import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'weather_info_model.g.dart';

/// 天气信息模型
@JsonSerializable()
class WeatherInfoModel extends BaseModel {
  /// 日期
  final String day;
  
  /// 天气状况
  final String weather;
  
  /// 温度范围
  final String temperature;
  
  /// 天气图标代码
  @JsonKey(name: 'icon_code')
  final String iconCode;

  /// 湿度
  final int? humidity;

  /// 风速
  @JsonKey(name: 'wind_speed')
  final double? windSpeed;

  /// 降雨概率
  @JsonKey(name: 'rain_probability')
  final int? rainProbability;

  /// 建议
  final String? advice;
  
  /// 构造函数
  WeatherInfoModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.day,
    required this.weather,
    required this.temperature,
    required this.iconCode,
    this.humidity,
    this.windSpeed,
    this.rainProbability,
    this.advice,
  });

  /// 从JSON创建
  factory WeatherInfoModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WeatherInfoModelToJson(this);

  /// 简单构造函数（兼容原有的WeatherInfo）
  factory WeatherInfoModel.simple({
    required String day,
    required String weather,
    required String temperature,
    String iconCode = 'sunny',
    int? humidity,
    double? windSpeed,
    int? rainProbability,
    String? advice,
  }) {
    return WeatherInfoModel(
      id: 'weather_${DateTime.now().millisecondsSinceEpoch}',
      day: day,
      weather: weather,
      temperature: temperature,
      iconCode: iconCode,
      humidity: humidity,
      windSpeed: windSpeed,
      rainProbability: rainProbability,
      advice: advice,
    );
  }

  /// 获取天气图标
  IconData get icon {
    switch (iconCode.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.sunny;
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.umbrella;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      case 'stormy':
        return Icons.thunderstorm;
      case 'foggy':
        return Icons.foggy;
      default:
        return Icons.sunny;
    }
  }

  /// 是否适合徒步
  bool get isSuitableForHiking {
    return !weather.contains('雨') && 
           !weather.contains('雪') && 
           !weather.contains('暴');
  }

  /// 获取天气建议
  String get weatherAdvice {
    if (advice != null) return advice!;
    
    if (weather.contains('雨')) {
      return '建议携带雨具和防水装备';
    } else if (weather.contains('雪')) {
      return '注意保暖，携带防滑装备';
    } else if (weather.contains('晴')) {
      return '天气晴朗，适合徒步';
    } else {
      return '注意天气变化';
    }
  }
}