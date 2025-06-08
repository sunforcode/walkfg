import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/weather/weather_condition.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// 和风天气API配置
const String heWeatherApiBaseUrl = 'https://n42k5mjnnd.re.qweatherapi.com';
const String heWeatherApiKey =
    '4b2389c9c5bf47df91dcbb2671bc75c5'; // 替换为您的和风天气API密钥

/// 天气管理器 - 负责获取和管理标记点的天气预报
class WeatherManager {
  /// HTTP客户端
  final http.Client _httpClient;

  /// 天气数据缓存 - 使用标记点ID或坐标作为键
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

  /// 获取标记点的当前天气
  ///
  /// [markerPoint] 标记点模型
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回标记点的天气模型
  Future<WeatherModel?> getMarkerPointWeather(
    MarkerPointModel markerPoint, {
    bool forceRefresh = false,
  }) async {
    return getWeatherByLocation(
      latitude: markerPoint.latitude,
      longitude: markerPoint.longitude,
      forceRefresh: forceRefresh,
    );
  }

  /// 获取标记点的天气预报
  ///
  /// [markerPoint] 标记点模型
  /// [days] 预报天数，默认为3天
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回标记点的天气预报列表
  Future<List<WeatherModel>> getMarkerPointForecast(
    MarkerPointModel markerPoint, {
    int days = 3,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${markerPoint.id}_forecast';

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
        'location': '${markerPoint.longitude},${markerPoint.latitude}',
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
          markerPoint.latitude,
          markerPoint.longitude,
          markerPoint.name ?? '标记点',
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

  /// 批量获取多个标记点的天气数据
  ///
  /// [markerPoints] 标记点列表
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回标记点ID到天气模型的映射
  Future<Map<String, WeatherModel>> getMultipleMarkerPointsWeather(
    List<MarkerPointModel> markerPoints, {
    bool forceRefresh = false,
  }) async {
    final Map<String, WeatherModel> result = {};
    final List<Future<void>> futures = [];

    for (final markerPoint in markerPoints) {
      futures.add(
        getMarkerPointWeather(markerPoint, forceRefresh: forceRefresh)
            .then((weather) {
          if (weather != null) {
            result[markerPoint.id] = weather;
          }
        }),
      );
    }

    await Future.wait(futures);
    return result;
  }

  /// 获取路线所有标记点的天气数据
  ///
  /// [route] 路线模型
  /// [forceRefresh] 是否强制刷新缓存
  /// 返回标记点ID到天气模型的映射
  Future<Map<String, WeatherModel>> getRouteWeather(
    RouteModel route, {
    bool forceRefresh = false,
  }) async {
    // 获取路线所有标记点的天气数据
    final weatherData = await getMultipleMarkerPointsWeather(
      route.markerPoints,
      forceRefresh: forceRefresh,
    );

    return weatherData;
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

  /// 清除特定标记点的缓存
  ///
  /// [markerPointId] 标记点ID
  void clearMarkerPointCache(String markerPointId) {
    _weatherCache.remove(markerPointId);
    _cacheTimestamps.remove(markerPointId);

    // 同时清除预报缓存
    final forecastKey = '${markerPointId}_forecast';
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
      if (now == null) {
        debugPrint('和风天气API返回数据格式错误: 缺少now字段${data}');
        return null;
      }

      // 获取位置信息
      final location = data['location']?[0] ?? {'name': '未知位置'};
      final cityName = location['name'] ?? '未知位置';

      // 解析天气状况
      String weatherText = now['text'] ?? '';
      String temp = now['temp'] ?? '0';
      String windSpeed = now['windSpeed'] ?? '0';
      String humidity = now['humidity'] ?? '0';

      // 判断是否适合徒步（简单判断：晴天、多云、小雨且风速小于6级为适合）
      final isSuitable = _isWeatherSuitableForHiking(weatherText, windSpeed);

      return WeatherModel(
        city: cityName,
        condition: WeatherCondition.cloudy,
        suitability: isSuitable,
        temperature: double.tryParse(temp) ?? 0.0,
        windLevel: double.tryParse(windSpeed) ?? 0.0,
        humidity: double.tryParse(humidity) ?? 0.0,
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
            condition: WeatherCondition.cloudy,
            suitability: isSuitable,
            temperature: avgTemp,
            windLevel: double.tryParse(windSpeed) ?? 0.0,
            humidity: double.tryParse(humidity) ?? 0.0,
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
