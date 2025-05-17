/// 天气数据模型
class WeatherModel {
  /// 温度（摄氏度）
  final String temperature;
  
  /// 天气状况（晴、多云、雨等）
  final String condition;
  
  /// 是否适合徒步
  final bool isSuitableForHiking;
  
  /// 天气图标代码
  final String iconCode;
  
  /// 湿度百分比
  final int humidity;
  
  /// 风速（km/h）
  final double windSpeed;
  
  /// 天气建议
  final String advice;

  /// 构造函数
  WeatherModel({
    required this.temperature,
    required this.condition,
    required this.isSuitableForHiking,
    required this.iconCode,
    required this.humidity,
    required this.windSpeed,
    required this.advice,
  });

  /// 从JSON创建模型
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temperature'] as String,
      condition: json['condition'] as String,
      isSuitableForHiking: json['is_suitable_for_hiking'] as bool,
      iconCode: json['icon_code'] as String,
      humidity: json['humidity'] as int,
      windSpeed: json['wind_speed'] as double,
      advice: json['advice'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'is_suitable_for_hiking': isSuitableForHiking,
      'icon_code': iconCode,
      'humidity': humidity,
      'wind_speed': windSpeed,
      'advice': advice,
    };
  }
}