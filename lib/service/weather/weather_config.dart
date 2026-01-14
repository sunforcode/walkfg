/// 和风天气API配置
class WeatherConfig {
  /// 和风天气API基础URL
  static const String apiBaseUrl = 'https://n42k5mjnnd.re.qweatherapi.com';

  /// 和风天气API密钥
  static const String apiKey = '4b2389c9c5bf47df91dcbb2671bc75c5';

  /// 天气数据过期时间（毫秒）- 默认30分钟
  static const int cacheExpiryTime = 30 * 60 * 1000;

  /// API请求语言
  static const String language = 'zh';

  /// API请求单位制
  static const String unit = 'm'; // 公制单位

  /// 默认预报天数
  static const int defaultForecastDays = 3;

  /// 默认搜索范围
  static const String defaultSearchRange = 'cn';
}
