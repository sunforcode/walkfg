import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/network/api_exception.dart';
import '../model/weather/weather_model.dart';

/// 天气服务
///
/// 使用静态方法，无需实例化
class WeatherService {
  // 禁止实例化
  WeatherService._();


  /// 获取指定位置的天气
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  static Future<WeatherModel?> getWeather(double latitude, double longitude) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weather,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取天气数据失败',
          code: responseData['code']?.toString(),
        );
      }

      final weatherData = responseData['data'] as Map<String, dynamic>;
      return WeatherModel.fromJson(weatherData);
    } catch (e) {
      debugPrint('WeatherService: 获取天气数据失败: $e');
      return null;
    }
  }

  /// 获取指定城市的天气
  ///
  /// [city] 城市名称
  static Future<WeatherModel?> getWeatherByCity(String city) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weather,
        queryParameters: {
          'city': city,
        },
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取城市天气数据失败',
          code: responseData['code']?.toString(),
        );
      }

      final weatherData = responseData['data'] as Map<String, dynamic>;
      return WeatherModel.fromJson(weatherData);
    } catch (e) {
      debugPrint('WeatherService: 获取城市天气数据失败: $e');
      return null;
    }
  }

  /// 获取天气预报
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [days] 预报天数，默认7天
  static Future<List<WeatherModel>> getForecast(double latitude, double longitude,
      {int days = 7}) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weatherForecast,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'days': days,
        },
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        throw BusinessException(
          responseData['message'] ?? '获取天气预报失败',
          code: responseData['code']?.toString(),
        );
      }

      final forecastData = responseData['data'] as Map<String, dynamic>;
      final content = forecastData['content'] as List<dynamic>;
      
      return content.map((json) => WeatherModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('WeatherService: 获取天气预报失败: $e');
      return [];
    }
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
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weather,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'type': 'alerts',
        },
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
        return {'alerts': []};
      }

      return responseData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('WeatherService: 获取天气预警失败: $e');
      return {'alerts': []};
    }
  }

  /// 获取空气质量
  static Future<Map<String, dynamic>> getAirQuality(
      double latitude, double longitude) async {
    try {
      final response = await ApiClient.instance.get(
        ApiEndpoints.weather,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'type': 'air_quality',
        },
      );
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['code'] != 200) {
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

      return responseData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('WeatherService: 获取空气质量失败: $e');
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
  }
}
