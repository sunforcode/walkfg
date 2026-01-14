import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/weather/weather_model.dart';

/// 天气服务
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class WeatherService {
  // 禁止实例化
  WeatherService._();

  /// 从JSON文件加载数据
  static Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  /// 获取指定位置的天气
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  static Future<WeatherModel> getWeather(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final weatherJson =
        await _loadJsonData('assets/mock_data/current_weather.json');
    if (weatherJson == null) {
      throw Exception('Failed to load weather data');
    }

    return WeatherModel.fromJson(weatherJson);
  }

  /// 获取指定城市的天气
  ///
  /// [city] 城市名称
  static Future<WeatherModel> getWeatherByCity(String city) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final weatherJson =
        await _loadJsonData('assets/mock_data/current_weather.json');
    if (weatherJson == null) {
      throw Exception('Failed to load weather data');
    }

    // 修改位置信息
    final modifiedJson = Map<String, dynamic>.from(weatherJson);
    modifiedJson['city'] = city;

    return WeatherModel.fromJson(modifiedJson);
  }

  /// 获取天气预报
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [days] 预报天数，默认7天
  static Future<List<WeatherModel>> getForecast(double latitude, double longitude,
      {int days = 7}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final forecastJson =
        await _loadJsonData('assets/mock_data/weather_forecast.json');
    if (forecastJson == null || !(forecastJson is List)) {
      return [];
    }

    // 将JSON数据转换为WeatherModel列表
    List<WeatherModel> forecasts = [];
    for (var item in forecastJson) {
      // 添加城市信息
      final itemWithCity = Map<String, dynamic>.from(item);
      itemWithCity['city'] = '黄山'; // 默认城市

      final forecast = WeatherModel.fromJson(itemWithCity);
      forecasts.add(forecast);
    }

    // 限制天数
    if (forecasts.length > days) {
      forecasts = forecasts.sublist(0, days);
    }

    return forecasts;
  }

  /// 获取海拔
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  static Future<double> getAltitude(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟海拔数据
    return 1250.0; // 返回一个固定的海拔值，单位为米
  }

  /// 获取天气预警
  static Future<Map<String, dynamic>> getWeatherAlerts(
      double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final alertsJson =
        await _loadJsonData('assets/mock_data/weather_alerts.json');
    if (alertsJson == null) {
      return {'alerts': []};
    }

    return alertsJson;
  }

  /// 获取空气质量
  static Future<Map<String, dynamic>> getAirQuality(
      double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final airQualityJson =
        await _loadJsonData('assets/mock_data/air_quality.json');
    if (airQualityJson == null) {
      return {
        'aqi': 50,
        'level': 'Good',
        'description': '空气质量良好，适合户外活动',
        'pollutants': {
          'pm25': 15,
          'pm10': 30,
          'o3': 40,
          'no2': 20,
          'so2': 10,
          'co': 0.5,
        },
      };
    }

    return airQualityJson;
  }
}
