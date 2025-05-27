import 'dart:convert';
import 'package:flutter/services.dart';
import '../weather_service.dart';
import '../../model/weather/weather_model.dart';

/// Mock天气服务实现
class MockWeatherService implements WeatherService {
  /// 单例实例
  static final MockWeatherService _instance = MockWeatherService._internal();

  /// 工厂构造函数
  factory MockWeatherService() {
    return _instance;
  }

  /// 私有构造函数
  MockWeatherService._internal();

  /// 从JSON文件加载数据
  Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  @override
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    final weatherJson =
        await _loadJsonData('assets/mock_data/current_weather.json');
    if (weatherJson == null) {
      throw Exception('Failed to load weather data');
    }

    return WeatherModel.fromJson(weatherJson);
  }

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
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

  @override
  Future<List<WeatherModel>> getForecast(double latitude, double longitude,
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

  @override
  Future<double> getAltitude(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 模拟海拔数据
    return 1250.0; // 返回一个固定的海拔值，单位为米
  }

  Future<Map<String, dynamic>> getWeatherAlerts(
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

  Future<Map<String, dynamic>> getAirQuality(
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
