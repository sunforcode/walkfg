import 'package:flutter/material.dart';

/// 天气数据模型
class WeatherModel {
  final String city;
  final String condition;
  final String suitability;
  final double temperature;
  final String windLevel;
  final String humidity;
  final IconData weatherIcon;

  WeatherModel({
    required this.city,
    required this.condition,
    required this.suitability,
    required this.temperature,
    required this.windLevel,
    required this.humidity,
    required this.weatherIcon,
  });

  /// 从API响应创建模型
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'] ?? '未知城市',
      condition: json['condition'] ?? '未知',
      suitability: json['suitability'] ?? '',
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      windLevel: json['windLevel'] ?? '未知',
      humidity: json['humidity'] ?? '未知',
      weatherIcon: _getWeatherIcon(json['condition']),
    );
  }

  /// 获取天气对应的图标
  static IconData _getWeatherIcon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'sunny':
      case '晴朗':
        return Icons.wb_sunny;
      case 'cloudy':
      case '多云':
        return Icons.cloud;
      case 'rainy':
      case '雨':
        return Icons.water_drop;
      case 'snowy':
      case '雪':
        return Icons.ac_unit;
      case 'windy':
      case '风':
        return Icons.air;
      default:
        return Icons.wb_sunny_outlined;
    }
  }

  /// 创建模拟数据
  static WeatherModel mock() {
    return WeatherModel(
      city: '北京市',
      condition: '晴朗',
      suitability: '适合徒步',
      temperature: 22.0,
      windLevel: '3级风',
      humidity: '湿度30%',
      weatherIcon: Icons.wb_sunny,
    );
  }
}

/// 海拔数据模型
class AltitudeModel {
  final double altitude;
  final String unit;

  AltitudeModel({
    required this.altitude,
    required this.unit,
  });

  /// 从API响应创建模型
  factory AltitudeModel.fromJson(Map<String, dynamic> json) {
    return AltitudeModel(
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'm',
    );
  }

  /// 创建模拟数据
  static AltitudeModel mock() {
    return AltitudeModel(
      altitude: 43.0,
      unit: '米',
    );
  }

  /// 格式化显示
  String get display => '${altitude.toInt()} $unit';
}