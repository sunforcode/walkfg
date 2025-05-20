import 'package:flutter/material.dart';

/// 天气数据模型
class WeatherModel {
  /// 城市名称
  final String city;

  /// 天气状况（晴、多云、雨等）
  final String condition;

  /// 适宜性描述
  final String suitability;

  /// 温度（摄氏度）
  final double temperature;

  /// 风级
  final String windLevel;

  /// 湿度
  final String humidity;

  /// 天气图标
  final IconData weatherIcon;

  /// 天气建议（兼容旧版本）
  String get advice {
    if (condition.toLowerCase() == '晴' || condition.toLowerCase() == '晴朗') {
      return '今天是个徒步的好日子！';
    } else if (condition.toLowerCase() == '多云' ||
        condition.toLowerCase() == '局部多云') {
      return '今天天气不错，适合徒步活动。';
    } else if (condition.toLowerCase() == '雨') {
      return '今天有雨，不适合徒步，建议改期。';
    } else if (condition.toLowerCase() == '雷雨') {
      return '今天有雷雨，不适合户外活动，注意安全。';
    } else {
      return '请根据天气情况决定是否适合徒步。';
    }
  }

  /// 是否适合徒步（兼容旧版本）
  bool get isSuitableForHiking => suitability.contains('适合');

  /// 风速（km/h）（兼容旧版本）
  double get windSpeed {
    // 从风级提取数字
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(windLevel);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  /// 湿度百分比（兼容旧版本）
  int get humidityValue {
    // 从湿度字符串提取数字
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(humidity);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  /// 构造函数
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
    print("ffffffff");
    return WeatherModel(
        city: json['city'] as String,
        temperature: (json['temperature'] as num).toDouble(),
        condition: json['condition'] as String,
        suitability: json['is_suitable_for_hiking'] == true ? '适合徒步' : '不适合徒步',
        humidity: '湿度${json['humidity']}%',
        windLevel: '${json['wind_speed']}级风',
        weatherIcon: _getWeatherIcon(json['condition']));
  }

  /// 获取天气对应的图标
  static IconData _getWeatherIcon(String? condition) {
    print("ffffffff");
    print(condition);
    switch (condition?.toLowerCase()) {
      case 'sunny':
      case '晴朗':
      case '晴':
        return Icons.sunny;
      case 'cloudy':
      case '多云':
        return Icons.cloud;
      case 'partly_cloudy':
      case '局部多云':
        return Icons.cloud_queue;
      case 'rainy':
      case '雨':
        return Icons.water_drop;
      case 'thunderstorm':
      case '雷雨':
        return Icons.flash_on;
      case 'snowy':
      case '雪':
        return Icons.ac_unit;
      case 'windy':
      case '风':
        return Icons.air;
      case 'foggy':
      case '雾':
        return Icons.cloud;
      default:
        return Icons.sunny;
    }
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'is_suitable_for_hiking': isSuitableForHiking,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'advice': advice,
    };
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
