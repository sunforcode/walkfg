import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'weather_config.dart';

/// 天气API服务 - 负责与和风天气API的交互
class WeatherApiService {
  /// HTTP客户端
  final http.Client _httpClient;

  /// 构造函数
  WeatherApiService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// 通过城市名称查询地点信息
  ///
  /// [cityName] 城市名称
  /// [adm] 行政区划（可选）
  /// [range] 搜索范围，可选值：world(全球)、cn(中国)、us(美国)、overseas(海外)
  /// 返回地点信息列表
  Future<List<Map<String, dynamic>>> lookupCity({
    required String cityName,
    String? adm,
    String range = WeatherConfig.defaultSearchRange,
  }) async {
    try {
      // 构建和风天气地点查询API请求URL
      final queryParams = {
        'location': cityName,
        'key': WeatherConfig.apiKey,
        'range': range,
      };

      // 如果指定了行政区划，添加到查询参数中
      if (adm != null && adm.isNotEmpty) {
        queryParams['adm'] = adm;
      }

      final uri = Uri.parse('${WeatherConfig.apiBaseUrl}/geo/v2/city/lookup')
          .replace(queryParameters: queryParams);

      // 发送请求，添加支持Gzip压缩和正确字符编码的头部
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept-Encoding': 'gzip, deflate',
          'Accept': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
          'User-Agent': 'Walk-App/1.0',
        },
      );

      if (response.statusCode == 200) {
        // 解析响应，确保使用UTF-8编码
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 检查API响应状态码
        final code = data['code'];
        if (code != '200') {
          print('和风天气地点查询API错误: ${data['code']}');
          return [];
        }

        // 获取地点数据
        final locations = data['location'];
        if (locations == null || locations is! List) {
          print('和风天气地点查询API返回数据格式错误: 缺少location字段');
          return [];
        }

        print('成功查询到 ${locations.length} 个地点');
        return List<Map<String, dynamic>>.from(locations);
      } else {
        print('和风天气地点查询API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('查询地点信息失败: $e');
    }

    return [];
  }

  /// 通过坐标查询地点信息（逆地理编码）
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回地点信息
  Future<Map<String, dynamic>?> lookupLocationByCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 使用和风天气GeoAPI的逆地理编码接口
      // 注意：和风天气的city/lookup API支持坐标查询，但主要返回最近的城市
      final uri = Uri.parse('${WeatherConfig.apiBaseUrl}/geo/v2/city/lookup')
          .replace(queryParameters: {
        'location': '$longitude,$latitude',
        'key': WeatherConfig.apiKey,
        'number': '1', // 只返回1个结果
        'range': 'cn', // 限制在中国范围内搜索
      });

      // 发送请求，添加支持Gzip压缩和正确字符编码的头部
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept-Encoding': 'gzip, deflate',
          'Accept': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
          'User-Agent': 'Walk-App/1.0',
        },
      );

      if (response.statusCode == 200) {
        // 解析响应，确保使用UTF-8编码
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 检查API响应状态码
        final code = data['code'];
        if (code != '200') {
          print('和风天气逆地理编码API错误: ${data}');
          return null;
        }

        // 获取地点数据
        final locations = data['location'];
        if (locations == null || locations is! List || locations.isEmpty) {
          print('和风天气逆地理编码API返回数据格式错误或无数据');
          return null;
        }

        final location = locations[0];
        print('和风天气API原始返回数据: $location');
        print(
            '成功获取地点信息: ${location['name']} (${location['adm2']}, ${location['adm1']})');

        // 构造更完整的地点信息
        final result = {
          'name': location['name'] ?? '未知地点',
          'adm1': location['adm1'] ?? '', // 省/州
          'adm2': location['adm2'] ?? '', // 市
          'country': location['country'] ?? '中国',
          'lat': location['lat'] ?? latitude.toString(),
          'lon': location['lon'] ?? longitude.toString(),
          'tz': location['tz'] ?? '',
          'utcOffset': location['utcOffset'] ?? '',
          'isDst': location['isDst'] ?? '0',
          'type': location['type'] ?? '',
          'rank': location['rank'] ?? '',
          'fxLink': location['fxLink'] ?? '',
        };

        print('处理后的地点信息: $result');
        return result;
      } else {
        print('和风天气逆地理编码API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('通过坐标查询地点信息失败: $e');
    }

    return null;
  }

  /// 获取天气数据
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// 返回天气数据
  Future<Map<String, dynamic>?> getWeatherData(
      double latitude, double longitude) async {
    try {
      // 构建和风天气API请求URL
      final uri = Uri.parse('${WeatherConfig.apiBaseUrl}/v7/weather/now')
          .replace(queryParameters: {
        'location': '$longitude,$latitude',
        'key': WeatherConfig.apiKey,
        'lang': WeatherConfig.language,
        'unit': WeatherConfig.unit,
      });

      // 发送请求，添加支持Gzip压缩和正确字符编码的头部
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept-Encoding': 'gzip, deflate',
          'Accept': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
          'User-Agent': 'Walk-App/1.0',
        },
      );

      if (response.statusCode == 200) {
        // 解析响应，确保使用UTF-8编码
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 检查API响应状态码
        final code = data['code'];
        if (code != '200') {
          print('和风天气API错误: ${data['code']}');
          return null;
        }

        print('成功获取天气数据');
        return data;
      } else {
        print('和风天气API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('获取天气数据异常: $e');
    }
    return null;
  }

  /// 获取预报数据
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [days] 预报天数
  /// 返回预报数据
  Future<Map<String, dynamic>?> getForecastData(
      double latitude, double longitude, int days) async {
    try {
      // 构建和风天气API请求URL
      final uri = Uri.parse('${WeatherConfig.apiBaseUrl}/v7/weather/${days}d')
          .replace(queryParameters: {
        'location': '$longitude,$latitude',
        'key': WeatherConfig.apiKey,
        'lang': WeatherConfig.language,
        'unit': WeatherConfig.unit,
      });

      // 发送请求，添加支持Gzip压缩和正确字符编码的头部
      final response = await _httpClient.get(
        uri,
        headers: {
          'Accept-Encoding': 'gzip, deflate',
          'Accept': 'application/json; charset=utf-8',
          'Accept-Charset': 'utf-8',
          'User-Agent': 'Walk-App/1.0',
        },
      );

      if (response.statusCode == 200) {
        // 解析响应，确保使用UTF-8编码
        final data = json.decode(utf8.decode(response.bodyBytes));

        // 检查API响应状态码
        final code = data['code'];
        if (code != '200') {
          print('和风天气预报API错误: ${data['code']}');
          return null;
        }

        print('成功获取天气预报数据');
        return data;
      } else {
        print('和风天气预报API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('获取天气预报数据异常: $e');
    }
    return null;
  }

  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}
