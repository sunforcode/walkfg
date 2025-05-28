import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/waypoint_model.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// 和风天气API配置
const String heWeatherApiBaseUrl = 'https://n42k5mjnnd.re.qweatherapi.com';
const String heWeatherApiKey =
    '4b2389c9c5bf47df91dcbb2671bc75c5'; // 替换为您的和风天气API密钥

/// 天气管理器 - 负责获取和管理关键点的天气预报
class WeatherManager {
  /// HTTP客户端
  final http.Client _httpClient;

  /// 天气数据缓存 - 使用关键点ID或坐标作为键
  final Map<String, dynamic> _weatherCache = {};

  /// 缓存时间戳 - 记录每个天气数据的获取时间
  final Map<String, int> _cacheTimestamps = {};

  /// 天气数据过期时间（毫秒）- 默认30分钟
  final int _cacheExpiryTime = 30 * 60 * 1000; // 30分钟

  /// 构造函数
  WeatherManager({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// 获取当前位置的天气
  ///
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回当前位置的天气模型
  Future<WeatherModel?> getCurrentLocationWeather({
    bool forceRefresh = false,
  }) async {
    try {
      // 获取当前位置
      final position = await getCurrentPosition();
      if (position == null) {
        debugPrint('无法获取当前位置');
        return null;
      }

      // 使用坐标获取天气
      return getWeatherByLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      debugPrint('获取当前位置天气失败: $e');
      return null;
    }
  }

  /// 根据坐标获取天气
  ///
  /// [latitude] 纬度
  /// [longitude] 经度
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回指定位置的天气模型
  Future<WeatherModel?> getWeatherByLocation({
    required double latitude,
    required double longitude,
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        '${latitude.toStringAsFixed(4)},${longitude.toStringAsFixed(4)}';

    // 检查缓存是否有效
    if (!forceRefresh && _isWeatherCacheValid(cacheKey)) {
      return _weatherCache[cacheKey] as WeatherModel?;
    }

    try {
      // 构建和风天气API请求URL
      final uri = Uri.parse('$heWeatherApiBaseUrl/v7/weather/now')
          .replace(queryParameters: {
        'location': '$longitude,$latitude',
        'key': heWeatherApiKey,
        'lang': 'zh',
        'unit': 'm', // 公制单位
      });

      // 发送请求
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        // 解析响应
        final data = json.decode(response.body);
        final weatherModel = _parseHeWeatherResponse(data, latitude, longitude);

        // 更新缓存
        if (weatherModel != null) {
          _updateWeatherCache(cacheKey, weatherModel);
        }

        return weatherModel;
      } else {
        debugPrint('和风天气API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('获取天气数据失败: $e');
    }

    // 如果获取失败但缓存存在，返回缓存数据
    return _weatherCache[cacheKey] as WeatherModel?;
  }

  /// 获取关键点的当前天气
  ///
  /// [waypoint] 关键点模型
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回关键点的天气模型
  Future<WeatherModel?> getWaypointWeather(
    WaypointModel waypoint, {
    bool forceRefresh = false,
  }) async {
    return getWeatherByLocation(
      latitude: waypoint.latitude,
      longitude: waypoint.longitude,
      forceRefresh: forceRefresh,
    );
  }

  /// 获取关键点的天气预报
  ///
  /// [waypoint] 关键点模型
  /// [days] 预报天数，默认为3天
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回关键点的天气预报列表
  Future<List<WeatherModel>> getWaypointForecast(
    WaypointModel waypoint, {
    int days = 3,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${waypoint.id}_forecast';

    // 检查缓存是否有效
    if (!forceRefresh && _isWeatherCacheValid(cacheKey)) {
      final cachedData = _weatherCache[cacheKey];
      if (cachedData is List<WeatherModel>) {
        return cachedData;
      }
    }

    try {
      // 构建和风天气API请求URL
      final uri = Uri.parse('$heWeatherApiBaseUrl/v7/weather/${days}d')
          .replace(queryParameters: {
        'location': '${waypoint.longitude},${waypoint.latitude}',
        'key': heWeatherApiKey,
        'lang': 'zh',
        'unit': 'm', // 公制单位
      });

      // 发送请求
      final response = await _httpClient.get(uri);

      if (response.statusCode == 200) {
        // 解析响应
        final data = json.decode(response.body);
        final forecasts = _parseHeWeatherForecastResponse(
          data,
          waypoint.latitude,
          waypoint.longitude,
          waypoint.name,
        );

        // 更新缓存
        _updateWeatherCache(cacheKey, forecasts);

        return forecasts;
      } else {
        debugPrint('和风天气API请求失败: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('获取天气预报数据失败: $e');
    }

    // 如果获取失败但缓存存在，返回缓存数据
    final cachedData = _weatherCache[cacheKey];
    if (cachedData is List<WeatherModel>) {
      return cachedData;
    }

    return [];
  }

  /// 批量获取多个关键点的天气数据
  ///
  /// [waypoints] 关键点列表
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回关键点ID到天气模型的映射
  Future<Map<String, WeatherModel>> getMultipleWaypointsWeather(
    List<WaypointModel> waypoints, {
    bool forceRefresh = false,
  }) async {
    final Map<String, WeatherModel> result = {};
    final List<Future<void>> futures = [];

    for (final waypoint in waypoints) {
      futures.add(
        getWaypointWeather(waypoint, forceRefresh: forceRefresh)
            .then((weather) {
          if (weather != null) {
            result[waypoint.id] = weather;
          }
        }),
      );
    }

    await Future.wait(futures);
    return result;
  }

  /// 获取路线所有关键点的天气数据
  ///
  /// [route] 路线模型
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回包含天气数据的路线模型
  Future<RouteModel> getRouteWeather(
    RouteModel route, {
    bool forceRefresh = false,
  }) async {
    final weatherData = await getMultipleWaypointsWeather(
      route.waypoints,
      forceRefresh: forceRefresh,
    );

    // 更新关键点的天气数据
    final updatedWaypoints = route.waypoints.map((waypoint) {
      if (weatherData.containsKey(waypoint.id)) {
        // 创建一个新的关键点，并设置天气数据
        return waypoint..weather = weatherData[waypoint.id];
      }
      return waypoint;
    }).toList();

    // 返回更新后的路线
    return route.copyWith(waypoints: updatedWaypoints);
  }

  /// 获取当前位置
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('位置服务未启用');
      return null;
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('位置权限被拒绝');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('位置权限被永久拒绝');
      return null;
    }

    // 获取当前位置
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint('获取当前位置失败: $e');
      return null;
    }
  }

  /// 检查天气缓存是否有效
  ///
  /// [key] 缓存键
  /// 返回缓存是否有效
  bool _isWeatherCacheValid(String key) {
    if (!_weatherCache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    final now = DateTime.now().millisecondsSinceEpoch;

    // 检查缓存是否过期
    return (now - timestamp) < _cacheExpiryTime;
  }

  /// 更新天气缓存
  ///
  /// [key] 缓存键
  /// [data] 天气数据
  void _updateWeatherCache(String key, dynamic data) {
    _weatherCache[key] = data;
    _cacheTimestamps[key] = DateTime.now().millisecondsSinceEpoch;
  }

  /// 清除所有缓存
  void clearCache() {
    _weatherCache.clear();
    _cacheTimestamps.clear();
  }

  /// 清除特定关键点的缓存
  ///
  /// [waypointId] 关键点ID
  void clearWaypointCache(String waypointId) {
    _weatherCache.remove(waypointId);
    _cacheTimestamps.remove(waypointId);

    // 同时清除预报缓存
    final forecastKey = '${waypointId}_forecast';
    _weatherCache.remove(forecastKey);
    _cacheTimestamps.remove(forecastKey);
  }

  /// 解析和风天气API响应
  WeatherModel? _parseHeWeatherResponse(
      Map<String, dynamic> data, double latitude, double longitude) {
    try {
      // 检查API响应状态码
      final code = data['code'];
      if (code != '200') {
        debugPrint('和风天气API错误: ${data['code']} - ${data['fxLink']}');
        return null;
      }

      // 获取实时天气数据
      final now = data['now'];
      debugPrint('和风天气API返回数据格式错误: 缺少now字段${data}');
      if (now == null) {
        debugPrint('和风天气API返回数据格式错误: 缺少now字段${data}');
        return null;
      }

      // 获取位置信息
      final location = data['location']?[0] ?? {'name': '未知位置'};
      final cityName = location['name'] ?? '未知位置';

      // 解析天气状况
      String weatherText = now['text'] ?? '';
      String temp = now['temp'];
      String windSpeed = now['windSpeed'] ?? '0';
      String humidity = now['humidity'] ?? '0';

      // 判断是否适合徒步（简单判断：晴天、多云、小雨且风速小于6级为适合）
      final isSuitable = _isWeatherSuitableForHiking(weatherText, windSpeed);

      return WeatherModel(
        city: cityName,
        condition: weatherText,
        suitability: isSuitable,
        temperature: double.parse(temp),
        windLevel: double.parse(windSpeed),
        humidity: double.parse(humidity),
      );
    } catch (e) {
      debugPrint('解析和风天气API响应失败: $e');
      return null;
    }
  }

  /// 解析和风天气API预报响应
  List<WeatherModel> _parseHeWeatherForecastResponse(
    Map<String, dynamic> data,
    double latitude,
    double longitude,
    String locationName,
  ) {
    final List<WeatherModel> forecasts = [];

    try {
      // 检查API响应状态码
      final code = data['code'];
      if (code != '200') {
        debugPrint('和风天气API错误: ${data['code']} - ${data['fxLink']}');
        return [];
      }

      // 获取天气预报数据
      final daily = data['daily'];
      if (daily == null || daily is! List) {
        debugPrint('和风天气API返回数据格式错误: 缺少daily字段或格式不正确');
        return [];
      }

      // 获取位置信息
      final location = data['location']?[0] ?? {'name': locationName};
      final cityName = location['name'] ?? locationName;

      // 解析每日预报
      for (final day in daily) {
        try {
          final date =
              DateTime.parse(day['fxDate'] ?? DateTime.now().toString());
          final weatherText = day['textDay'] ?? '';
          final tempMax = double.tryParse(day['tempMax'] ?? '0') ?? 0.0;
          final tempMin = double.tryParse(day['tempMin'] ?? '0') ?? 0.0;
          final avgTemp = (tempMax + tempMin) / 2;
          final windSpeed = day['windSpeedDay'] ?? '0';
          final humidity = day['humidity'] ?? '0';
          final precip = double.tryParse(day['precip'] ?? '0') ?? 0.0;

          // 计算降水概率（简单转换：降水量 > 0 时，按比例计算概率）
          final precipProb =
              precip > 0 ? (precip * 10).clamp(0, 100).toInt() : 0;

          // 判断是否适合徒步
          final isSuitable =
              _isWeatherSuitableForHiking(weatherText, windSpeed);

          forecasts.add(WeatherModel(
            city: cityName,
            condition: weatherText,
            suitability: isSuitable,
            temperature: avgTemp,
            windLevel: windSpeed,
            humidity: humidity,
            forecastDate: date,
            maxTemperature: tempMax,
            minTemperature: tempMin,
            precipitationProbability: precipProb,
          ));
        } catch (e) {
          debugPrint('解析单日预报数据失败: $e');
        }
      }
    } catch (e) {
      debugPrint('解析和风天气API预报响应失败: $e');
    }

    return forecasts;
  }

  /// 判断天气是否适合徒步
  bool _isWeatherSuitableForHiking(String weatherText, String windSpeed) {
    // 不适合徒步的天气状况关键词
    final badWeatherKeywords = [
      '雷',
      '暴',
      '大雨',
      '中雨',
      '冰雹',
      '雪',
      '霾',
      '沙尘',
      '雾',
      '台风',
      '飓风'
    ];

    // 检查天气状况是否包含不适合徒步的关键词
    final containsBadWeather =
        badWeatherKeywords.any((keyword) => weatherText.contains(keyword));

    // 检查风速是否过大（大于5级风不适合徒步）
    final windSpeedValue = int.tryParse(windSpeed) ?? 0;
    final windTooStrong = windSpeedValue > 5;

    // 如果不包含不良天气关键词且风速适中，则适合徒步
    return !containsBadWeather && !windTooStrong;
  }

  /// 释放资源
  void dispose() {
    _httpClient.close();
  }
}
