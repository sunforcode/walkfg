import 'dart:async';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/map/marker_point_model.dart';
import 'package:walk/model/weather/weather_model.dart';
import 'package:walk/model/weather/weather_condition.dart';
import 'package:walk/service/location/location_service.dart';
import 'weather_api_service.dart';
import 'weather_cache_service.dart';
import 'weather_parser_service.dart';
import 'weather_config.dart';

/// 天气管理器 - 负责获取和管理标记点的天气预报
class WeatherManager {
  /// 天气API服务
  final WeatherApiService _apiService;

  /// 天气缓存服务
  final WeatherCacheService _cacheService;

  /// 天气解析服务
  final WeatherParserService _parserService;

  /// 位置服务实例
  final LocationService _locationService;

  /// 构造函数
  WeatherManager({
    WeatherApiService? apiService,
    WeatherCacheService? cacheService,
    WeatherParserService? parserService,
    LocationService? locationService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _cacheService = cacheService ?? WeatherCacheService.instance,
        _parserService = parserService ?? WeatherParserService(),
        _locationService = locationService ?? LocationService.instance;

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
    return _apiService.lookupCity(
      cityName: cityName,
      adm: adm,
      range: range,
    );
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
    return _apiService.lookupLocationByCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// 获取当前位置的天气
  ///
  /// [forceRefresh] 是否强制刷新缓存
  /// [forceLocationRefresh] 是否强制刷新位置信息
  /// 返回当前位置的天气模型
  Future<WeatherModel?> getCurrentLocationWeather({
    bool forceRefresh = false,
    bool forceLocationRefresh = false,
  }) async {
    try {
      // 使用LocationService获取当前位置
      final position = await _locationService.getCurrentPosition(
        forceRefresh: forceLocationRefresh,
      );

      if (position == null) {
        print('无法获取当前位置');
        return null;
      }

      print('获取当前位置天气: 纬度=${position.latitude}, 经度=${position.longitude}');

      // 使用坐标获取天气
      return getWeatherByLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        forceRefresh: forceRefresh,
      );
    } catch (e) {
      print('获取当前位置天气失败: $e');
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
    if (!forceRefresh && _cacheService.isWeatherCacheValid(cacheKey)) {
      return _cacheService.getCachedData<WeatherModel>(cacheKey);
    }

    try {
      // 并行调用天气API和地点查询API
      final futures = await Future.wait([
        _apiService.getWeatherData(latitude, longitude),
        _apiService.lookupLocationByCoordinates(
          latitude: latitude,
          longitude: longitude,
        ),
      ]);

      final weatherData = futures[0] as Map<String, dynamic>?;
      final locationData = futures[1] as Map<String, dynamic>?;

      if (weatherData == null) {
        print('获取天气数据失败');
        return _cacheService.getCachedData<WeatherModel>(cacheKey);
      }

      // 合并天气数据和地点数据
      final weatherModel = _parserService.parseHeWeatherResponseWithLocation(
        weatherData,
        locationData,
        latitude,
        longitude,
      );

      // 更新缓存
      if (weatherModel != null) {
        _cacheService.updateWeatherCache(cacheKey, weatherModel);
      }

      return weatherModel;
    } catch (e) {
      print('获取天气数据失败: $e');
    }

    // 如果获取失败但缓存存在，返回缓存数据
    return _cacheService.getCachedData<WeatherModel>(cacheKey);
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
    int days = WeatherConfig.defaultForecastDays,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${markerPoint.id}_forecast';

    // 检查缓存是否有效
    if (!forceRefresh && _cacheService.isWeatherCacheValid(cacheKey)) {
      final cachedData =
          _cacheService.getCachedData<List<WeatherModel>>(cacheKey);
      if (cachedData != null) {
        return cachedData;
      }
    }

    try {
      // 并行获取预报数据和地点信息
      final futures = await Future.wait([
        _apiService.getForecastData(
            markerPoint.latitude, markerPoint.longitude, days),
        _apiService.lookupLocationByCoordinates(
          latitude: markerPoint.latitude,
          longitude: markerPoint.longitude,
        ),
      ]);

      final forecastData = futures[0] as Map<String, dynamic>?;
      final locationData = futures[1] as Map<String, dynamic>?;

      if (forecastData == null) {
        print('获取天气预报数据失败');
        // 如果获取失败但缓存存在，返回缓存数据
        final cachedData =
            _cacheService.getCachedData<List<WeatherModel>>(cacheKey);
        return cachedData ?? [];
      }

      // 获取地点名称
      String locationName = markerPoint.name ?? '标记点';
      if (locationData != null) {
        locationName = locationData['name'] ?? locationName;
      }

      final forecasts = _parserService.parseHeWeatherForecastResponse(
        forecastData,
        markerPoint.latitude,
        markerPoint.longitude,
        locationName,
      );

      // 更新缓存
      _cacheService.updateWeatherCache(cacheKey, forecasts);

      return forecasts;
    } catch (e) {
      print('获取天气预报数据失败: $e');
    }

    // 如果获取失败但缓存存在，返回缓存数据
    final cachedData =
        _cacheService.getCachedData<List<WeatherModel>>(cacheKey);
    return cachedData ?? [];
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

  /// 清除所有缓存
  void clearCache() {
    _cacheService.clearCache();
  }

  /// 清除特定标记点的缓存
  ///
  /// [markerPointId] 标记点ID
  void clearMarkerPointCache(String markerPointId) {
    _cacheService.clearMarkerPointCache(markerPointId);
  }

  /// 释放资源
  void dispose() {
    _apiService.dispose();
  }
}
