import 'package:flutter/material.dart';
import 'package:walk/service/weather_service.dart';
import '../../model/weather/weather_model.dart';

/// 模拟天气服务实现
class MockWeatherService implements WeatherService {
  @override
  Future<WeatherModel> getWeather(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟天气数据
    return WeatherModel(
      city: '北京市',
      condition: '晴朗',
      suitability: '适合徒步',
      temperature: 22.0,
      windLevel: '3级风',
      humidity: '湿度30%',
      weatherIcon: Icons.sunny,
    );
  }

  @override
  Future<WeatherModel> getWeatherByCity(String city) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 模拟天气数据
    return WeatherModel(
      city: city,
      condition: '多云',
      suitability: '适合徒步',
      temperature: 20.0,
      windLevel: '2级风',
      humidity: '湿度45%',
      weatherIcon: _getWeatherIcon('cloudy'),
    );
  }

  @override
  Future<double> getAltitude(double latitude, double longitude) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 模拟海拔数据 (根据经纬度生成一个随机但合理的海拔值)
    final random = DateTime.now().millisecondsSinceEpoch % 3000;
    return random.toDouble();
  }

  @override
  Future<List<WeatherModel>> getForecast(double latitude, double longitude,
      {int days = 7}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 800));

    // 生成未来几天的天气预报
    final List<WeatherModel> forecast = [];
    final conditions = [
      'sunny',
      'cloudy',
      'partly_cloudy',
      'rainy',
      'thunderstorm'
    ];

    for (int i = 0; i < days; i++) {
      final condition =
          conditions[(i + DateTime.now().day) % conditions.length];
      final temp = 15.0 + (i % 3) * 5; // 温度在15-25之间波动

      forecast.add(WeatherModel(
        city: '北京市',
        condition: _getConditionName(condition),
        suitability: condition == 'rainy' || condition == 'thunderstorm'
            ? '不适合徒步'
            : '适合徒步',
        temperature: temp,
        windLevel: '${1 + (i % 4)}级风',
        humidity: '湿度${30 + (i * 5) % 40}%',
        weatherIcon: _getWeatherIcon(condition),
      ));
    }

    return forecast;
  }

  /// 获取天气图标
  dynamic _getWeatherIcon(String condition) {
    // 这里返回一个占位符，实际应用中应返回适当的图标
    return condition;
  }

  /// 获取天气状况名称
  String _getConditionName(String condition) {
    switch (condition) {
      case 'sunny':
        return '晴朗';
      case 'cloudy':
        return '多云';
      case 'partly_cloudy':
        return '局部多云';
      case 'rainy':
        return '雨';
      case 'thunderstorm':
        return '雷雨';
      default:
        return '未知';
    }
  }
}
