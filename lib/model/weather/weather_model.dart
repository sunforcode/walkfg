import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'weather_condition.dart';

part 'weather_model.g.dart';

/// 天气数据模型
@JsonSerializable()
class WeatherModel {
  //region 基础属性
  /// 城市名称
  final String city;

  /// 天气状况（使用枚举类型）
  @JsonKey(fromJson: _conditionFromJson, toJson: _conditionToJson)
  final WeatherCondition condition;

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

  /// 能见度（公里）
  final double? visibility;

  /// 紫外线指数
  @JsonKey(name: 'uv_index')
  final int? uvIndex;

  /// 气压（hPa）
  final double? pressure;

  /// 日出时间
  @JsonKey(name: 'sunrise_time')
  final DateTime? sunriseTime;

  /// 日落时间
  @JsonKey(name: 'sunset_time')
  final DateTime? sunsetTime;
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
    this.visibility,
    this.uvIndex,
    this.pressure,
    this.sunriseTime,
    this.sunsetTime,
  }) : this.weatherIcon =
            weatherIcon ?? _getWeatherIconFromCondition(condition);
  //endregion

  //region 工厂方法
  /// 从JSON创建模型
  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  /// JSON序列化辅助方法
  static WeatherCondition _conditionFromJson(dynamic json) {
    if (json is String) {
      return WeatherConditionExtension.fromString(json);
    }
    return WeatherCondition.cloudy; // 默认值
  }

  static String _conditionToJson(WeatherCondition condition) {
    return condition.description;
  }
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

  /// 获取WeatherCondition枚举（向后兼容）
  WeatherCondition get weatherCondition {
    return condition;
  }

  /// 获取天气状况的字符串描述（向后兼容）
  String get conditionString {
    return condition.description;
  }

  /// 获取日期（用于天气预报组件）
  DateTime get date {
    return forecastDate ?? DateTime.now();
  }
  //endregion

  //region 天气描述相关方法
  /// 天气建议
  String get advice {
    switch (condition) {
      case WeatherCondition.sunny:
        return '今天是个徒步的好日子！';
      case WeatherCondition.cloudy:
        return '今天天气不错，适合徒步活动。';
      case WeatherCondition.rainy:
        return '今天有雨，不适合徒步，建议改期。';
      case WeatherCondition.stormy:
        return '今天有雷雨，不适合户外活动，注意安全。';
      case WeatherCondition.snowy:
        return '今天下雪，注意保暖和防滑。';
      case WeatherCondition.foggy:
        return '今天有雾，能见度低，请谨慎出行。';
    }
  }

  /// 获取天气描述
  String getWeatherDescription() {
    switch (condition) {
      case WeatherCondition.sunny:
        return '阳光明媚，适合户外活动';
      case WeatherCondition.cloudy:
        return '多云天气，温度适宜';
      case WeatherCondition.rainy:
        return '下雨天气，请带好雨具';
      case WeatherCondition.stormy:
        return '雷雨天气，不建议户外活动';
      case WeatherCondition.snowy:
        return '下雪天气，注意保暖';
      case WeatherCondition.foggy:
        return '有雾天气，能见度低';
    }
  }

  /// 获取天气状况文本
  String getWeatherConditionText() {
    return condition.description;
  }

  /// 获取天气对应的颜色
  Color getWeatherColor() {
    switch (condition) {
      case WeatherCondition.sunny:
        return Colors.orange;
      case WeatherCondition.cloudy:
        return Colors.blueGrey;
      case WeatherCondition.rainy:
        return Colors.blue;
      case WeatherCondition.stormy:
        return Colors.indigo;
      case WeatherCondition.snowy:
        return Colors.lightBlue.shade100;
      case WeatherCondition.foggy:
        return Colors.grey;
    }
  }

  /// 获取户外活动适宜性评分（1-10分）
  int getOutdoorSuitabilityScore() {
    int baseScore = 5;

    // 根据天气状况调整分数
    switch (condition) {
      case WeatherCondition.sunny:
        baseScore = 9;
        break;
      case WeatherCondition.cloudy:
        baseScore = 7;
        break;
      case WeatherCondition.rainy:
        baseScore = 3;
        break;
      case WeatherCondition.snowy:
        baseScore = 4;
        break;
      case WeatherCondition.foggy:
        baseScore = 2;
        break;
      case WeatherCondition.stormy:
        baseScore = 1;
        break;
    }

    // 根据温度调整分数
    if (temperature < 0) {
      baseScore -= 2;
    } else if (temperature > 35) {
      baseScore -= 2;
    } else if (temperature >= 15 && temperature <= 25) {
      baseScore += 1;
    }

    // 根据风速调整分数
    if (windSpeed > 30) {
      baseScore -= 2;
    } else if (windSpeed > 20) {
      baseScore -= 1;
    }

    // 根据降水概率调整分数
    if (precipitationProbability != null) {
      if (precipitationProbability! > 70) {
        baseScore -= 2;
      } else if (precipitationProbability! > 40) {
        baseScore -= 1;
      }
    }

    return baseScore.clamp(1, 10);
  }

  /// 获取户外活动建议
  String getOutdoorAdvice() {
    final score = getOutdoorSuitabilityScore();

    if (score >= 8) {
      return '非常适合户外活动，是徒步的好时机！';
    } else if (score >= 6) {
      return '适合户外活动，注意防护措施。';
    } else if (score >= 4) {
      return '勉强适合户外活动，建议谨慎考虑。';
    } else {
      return '不建议进行户外活动，请选择其他时间。';
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

  /// 是否是今天
  bool get isToday {
    if (forecastDate == null) return true;
    final now = DateTime.now();
    return forecastDate!.year == now.year &&
        forecastDate!.month == now.month &&
        forecastDate!.day == now.day;
  }
  //endregion

  //region 工具方法
  /// 获取天气对应的图标
  static IconData _getWeatherIconFromCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return Icons.sunny;
      case WeatherCondition.cloudy:
        return Icons.cloud;
      case WeatherCondition.rainy:
        return Icons.water_drop;
      case WeatherCondition.stormy:
        return Icons.flash_on;
      case WeatherCondition.snowy:
        return Icons.ac_unit;
      case WeatherCondition.foggy:
        return Icons.cloud;
    }
  }
  //endregion

  //region 序列化与拷贝
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);

  /// 创建副本并更新部分属性
  WeatherModel copyWith({
    String? city,
    WeatherCondition? condition,
    bool? suitability,
    double? temperature,
    double? windLevel,
    double? humidity,
    IconData? weatherIcon,
    DateTime? forecastDate,
    double? maxTemperature,
    double? minTemperature,
    int? precipitationProbability,
    double? visibility,
    int? uvIndex,
    double? pressure,
    DateTime? sunriseTime,
    DateTime? sunsetTime,
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
      visibility: visibility ?? this.visibility,
      uvIndex: uvIndex ?? this.uvIndex,
      pressure: pressure ?? this.pressure,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      sunsetTime: sunsetTime ?? this.sunsetTime,
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
