/// 天气状况枚举
enum WeatherCondition {
  /// 晴朗
  sunny,
  
  /// 多云
  cloudy,
  
  /// 雨天
  rainy,
  
  /// 雪天
  snowy,
  
  /// 雾天
  foggy,
  
  /// 雷雨
  stormy,
}

/// WeatherCondition扩展方法
extension WeatherConditionExtension on WeatherCondition {
  /// 获取中文描述
  String get description {
    switch (this) {
      case WeatherCondition.sunny:
        return '晴朗';
      case WeatherCondition.cloudy:
        return '多云';
      case WeatherCondition.rainy:
        return '雨天';
      case WeatherCondition.snowy:
        return '雪天';
      case WeatherCondition.foggy:
        return '雾天';
      case WeatherCondition.stormy:
        return '雷雨';
    }
  }
  
  /// 从字符串转换为枚举
  static WeatherCondition fromString(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case '晴朗':
      case '晴':
        return WeatherCondition.sunny;
      case 'cloudy':
      case '多云':
        return WeatherCondition.cloudy;
      case 'rainy':
      case '雨':
        return WeatherCondition.rainy;
      case 'snowy':
      case '雪':
        return WeatherCondition.snowy;
      case 'foggy':
      case '雾':
        return WeatherCondition.foggy;
      case 'thunderstorm':
      case '雷雨':
      case 'stormy':
        return WeatherCondition.stormy;
      default:
        return WeatherCondition.cloudy;
    }
  }
}