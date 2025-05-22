import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

/// 天气数据模型
@JsonSerializable()
class WeatherModel {
  /// 城市名称
  final String city;

  /// 天气状况（晴、多云、雨等）
  final String condition;

  /// 适宜性描述
  @JsonKey(name: 'is_suitable_for_hiking')
  final String suitability;

  /// 温度（摄氏度）
  final double temperature;

  /// 风级
  @JsonKey(name: 'wind_speed')
  final String windLevel;

  /// 湿度
  final String humidity;

  /// 天气图标
  @JsonKey(ignore: true)
  final IconData weatherIcon;

  /// 预报日期（如果是天气预报）
  @JsonKey(name: 'forecast_date')
  final DateTime? forecastDate;

  /// 最高温度（如果是天气预报）
  @JsonKey(name: 'max_temperature')
  final double? maxTemperature;

  /// 最低温度（如果是天气预报）
  @JsonKey(name: 'min_temperature')
  final double? minTemperature;

  /// 降水概率（如果是天气预报）
  @JsonKey(name: 'precipitation_probability')
  final int? precipitationProbability;

  /// 是否是天气预报
  bool get isForecast => forecastDate != null;

  /// 天气建议
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

  /// 是否适合徒步
  bool get isSuitableForHiking => suitability.contains('适合');

  /// 风速（km/h）
  double get windSpeed {
    // 从风级提取数字
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(windLevel);
    if (match != null) {
      return double.tryParse(match.group(1) ?? '0') ?? 0.0;
    }
    return 0.0;
  }

  /// 湿度百分比
  int get humidityValue {
    // 从湿度字符串提取数字
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(humidity);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  /// 获取天气描述
  String getWeatherDescription() {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case '晴朗':
      case '晴':
        return '阳光明媚，适合户外活动';
      case 'cloudy':
      case '多云':
        return '多云天气，温度适宜';
      case 'partly_cloudy':
      case '局部多云':
        return '局部多云，适合徒步';
      case 'rainy':
      case '雨':
        return '下雨天气，请带好雨具';
      case 'thunderstorm':
      case '雷雨':
        return '雷雨天气，不建议户外活动';
      case 'snowy':
      case '雪':
        return '下雪天气，注意保暖';
      case 'windy':
      case '风':
        return '有风天气，注意防风';
      case 'foggy':
      case '雾':
        return '有雾天气，能见度低';
      default:
        return '天气情况未知';
    }
  }

  /// 获取天气状况文本
  String getWeatherConditionText() {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case '晴朗':
      case '晴':
        return '晴天';
      case 'cloudy':
      case '多云':
        return '多云';
      case 'partly_cloudy':
      case '局部多云':
        return '局部多云';
      case 'rainy':
      case '雨':
        return '雨天';
      case 'thunderstorm':
      case '雷雨':
        return '雷雨';
      case 'snowy':
      case '雪':
        return '雪天';
      case 'windy':
      case '风':
        return '大风';
      case 'foggy':
      case '雾':
        return '雾天';
      default:
        return condition;
    }
  }

  /// 获取天气对应的颜色
  Color getWeatherColor() {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case '晴朗':
      case '晴':
        return Colors.orange;
      case 'cloudy':
      case '多云':
        return Colors.blueGrey;
      case 'partly_cloudy':
      case '局部多云':
        return Colors.lightBlue;
      case 'rainy':
      case '雨':
        return Colors.blue;
      case 'thunderstorm':
      case '雷雨':
        return Colors.indigo;
      case 'snowy':
      case '雪':
        return Colors.lightBlue.shade100;
      case 'windy':
      case '风':
        return Colors.teal;
      case 'foggy':
      case '雾':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// 获取日期字符串（如果是天气预报）
  String? getDateString() {
    if (forecastDate == null) return null;
    return '${forecastDate!.month}月${forecastDate!.day}日';
  }

  /// 获取星期几（如果是天气预报）
  String? getWeekday() {
    if (forecastDate == null) return null;
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[forecastDate!.weekday - 1];
  }

  /// 获取温度范围字符串（如果是天气预报）
  String? getTemperatureRange() {
    if (minTemperature == null || maxTemperature == null) return null;
    return '${minTemperature!.toInt()}°~${maxTemperature!.toInt()}°';
  }

  /// 构造函数
  WeatherModel({
    required this.city,
    required this.condition,
    required this.suitability,
    required this.temperature,
    required this.windLevel,
    required this.humidity,
    IconData? weatherIcon,
    this.forecastDate,
    this.maxTemperature,
    this.minTemperature,
    this.precipitationProbability,
  }) : this.weatherIcon =
            weatherIcon ?? _getWeatherIconFromCondition(condition);

  /// 从API响应创建当前天气模型
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      city: json['city'] as String? ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? '',
      suitability: json['is_suitable_for_hiking'] == true ? '适合徒步' : '不适合徒步',
      humidity: '湿度${json['humidity'] ?? 0}%',
      windLevel: '${json['wind_speed'] ?? 0}级风',
    );
  }

  /// 从API响应创建天气预报模型
  factory WeatherModel.forecastFromJson(Map<String, dynamic> json) {
    final date = json['forecast_date'] is String
        ? DateTime.parse(json['forecast_date'] as String)
        : (json['forecast_date'] as DateTime? ?? DateTime.now());

    final maxTemp = (json['max_temperature'])?.toDouble() ?? 0.0;
    final minTemp = (json['min_temperature'])?.toDouble() ?? 0.0;
    final avgTemp = (maxTemp + minTemp) / 2;

    return WeatherModel(
      city: json['city'] as String? ?? '',
      temperature: avgTemp,
      condition: json['condition'] as String? ?? '',
      suitability: (json['precipitation_probability'] as int? ?? 0) < 50
          ? '适合徒步'
          : '不适合徒步',
      humidity: '湿度${json['humidity'] ?? 0}%',
      windLevel: '${json['wind_speed'] ?? 0}级风',
      forecastDate: date,
      maxTemperature: maxTemp,
      minTemperature: minTemp,
      precipitationProbability: json['precipitation_probability'] as int? ?? 0,
    );
  }

  /// 获取天气对应的图标
  static IconData _getWeatherIconFromCondition(String? condition) {
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
    final json = <String, dynamic>{
      'city': city,
      'temperature': temperature,
      'condition': condition,
      'is_suitable_for_hiking': isSuitableForHiking,
      'humidity': humidityValue,
      'wind_speed': windSpeed,
    };

    if (isForecast) {
      json['forecast_date'] = forecastDate?.toIso8601String();
      json['max_temperature'] = maxTemperature;
      json['min_temperature'] = minTemperature;
      json['precipitation_probability'] = precipitationProbability;
    }

    return json;
  }

  /// 创建副本并更新部分属性
  WeatherModel copyWith({
    String? city,
    String? condition,
    String? suitability,
    double? temperature,
    String? windLevel,
    String? humidity,
    IconData? weatherIcon,
    DateTime? forecastDate,
    double? maxTemperature,
    double? minTemperature,
    int? precipitationProbability,
  }) {
    return WeatherModel(
      city: city ?? this.city,
      condition: condition ?? this.condition,
      suitability: suitability ?? this.suitability,
      temperature: temperature ?? this.temperature,
      windLevel: windLevel ?? this.windLevel,
      humidity: humidity ?? this.humidity,
      weatherIcon: weatherIcon,
      forecastDate: forecastDate ?? this.forecastDate,
      maxTemperature: maxTemperature ?? this.maxTemperature,
      minTemperature: minTemperature ?? this.minTemperature,
      precipitationProbability:
          precipitationProbability ?? this.precipitationProbability,
    );
  }
}

/// 海拔数据模型
@JsonSerializable()
class AltitudeModel {
  final double altitude;
  final String unit;

  AltitudeModel({
    required this.altitude,
    required this.unit,
  });

  /// 从API响应创建模型
  factory AltitudeModel.fromJson(Map<String, dynamic> json) =>
      _$AltitudeModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AltitudeModelToJson(this);

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
