import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

/// 天气数据模型
@JsonSerializable()
class WeatherModel {
  //region 基础属性
  /// 城市名称
  final String city;

  /// 天气状况（晴、多云、雨等）
  final String condition;

  /// 适宜性描述
  @JsonKey(name: 'suitability')
  final bool suitability;

  /// 温度（摄氏度）
  final double temperature;

  /// 风级
  @JsonKey(name: 'wind_speed')
  final double windLevel;

  /// 湿度
  final double humidity;

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
  //endregion

  //region 构造函数
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
  //endregion

  //region 工厂方法
  /// 从JSON创建模型
  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  //endregion

  //region 基础 Getter
  /// 是否是天气预报
  bool get isForecast => forecastDate != null;

  /// 风速（km/h）
  double get windSpeed {
    return windLevel;
  }

  /// 湿度百分比
  int get humidityValue {
    return humidity.toInt();
  }
  //endregion

  //region 天气描述相关方法
  /// 天气建议
  String get advice {
    final conditionLower = condition.toLowerCase();
    if (conditionLower == '晴' || conditionLower == '晴朗') {
      return '今天是个徒步的好日子！';
    } else if (conditionLower == '多云' || conditionLower == '局部多云') {
      return '今天天气不错，适合徒步活动。';
    } else if (conditionLower == '雨') {
      return '今天有雨，不适合徒步，建议改期。';
    } else if (conditionLower == '雷雨') {
      return '今天有雷雨，不适合户外活动，注意安全。';
    } else {
      return '请根据天气情况决定是否适合徒步。';
    }
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
  //endregion

  //region 天气预报相关方法
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
  //endregion

  //region 工具方法
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
  //endregion

  //region 序列化与拷贝
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);

  /// 创建副本并更新部分属性
  WeatherModel copyWith({
    String? city,
    String? condition,
    bool? suitability,
    double? temperature,
    double? windLevel,
    double? humidity,
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
  //endregion
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

  /// 从JSON创建模型
  factory AltitudeModel.fromJson(Map<String, dynamic> json) =>
      _$AltitudeModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AltitudeModelToJson(this);

  /// 格式化显示
  String get display => '${altitude.toInt()} $unit';
}
