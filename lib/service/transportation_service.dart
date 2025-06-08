import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/transportation/transport_route.dart';

/// 交通服务类
class TransportationService {
  final Dio _dio = Dio();
  
  // 高德地图API密钥 - 需要在实际使用时配置
  static const String _amapApiKey = 'YOUR_AMAP_API_KEY';
  
  /// 获取到徒步起点的路线规划
  Future<List<TransportRoute>> getRouteToTrailhead({
    required LatLng from,
    required LatLng to,
    TransportMode mode = TransportMode.driving,
  }) async {
    try {
      final routes = <TransportRoute>[];
      
      // 根据交通方式调用不同的API
      switch (mode) {
        case TransportMode.driving:
          routes.addAll(await _getDrivingRoute(from, to));
          break;
        case TransportMode.transit:
          routes.addAll(await _getTransitRoute(from, to));
          break;
        case TransportMode.walking:
          routes.addAll(await _getWalkingRoute(from, to));
          break;
      }
      
      return routes;
    } catch (e) {
      print('获取路线失败: $e');
      return [];
    }
  }
  
  /// 获取驾车路线
  Future<List<TransportRoute>> _getDrivingRoute(LatLng from, LatLng to) async {
    final response = await _dio.get(
      'https://restapi.amap.com/v3/direction/driving',
      queryParameters: {
        'key': _amapApiKey,
        'origin': '${from.longitude},${from.latitude}',
        'destination': '${to.longitude},${to.latitude}',
        'extensions': 'all',
        'output': 'json',
      },
    );
    
    return _parseDrivingResponse(response.data);
  }
  
  /// 获取公共交通路线
  Future<List<TransportRoute>> _getTransitRoute(LatLng from, LatLng to) async {
    final response = await _dio.get(
      'https://restapi.amap.com/v3/direction/transit/integrated',
      queryParameters: {
        'key': _amapApiKey,
        'origin': '${from.longitude},${from.latitude}',
        'destination': '${to.longitude},${to.latitude}',
        'city': '北京', // 需要根据实际位置确定城市
        'output': 'json',
      },
    );
    
    return _parseTransitResponse(response.data);
  }
  
  /// 获取步行路线
  Future<List<TransportRoute>> _getWalkingRoute(LatLng from, LatLng to) async {
    final response = await _dio.get(
      'https://restapi.amap.com/v3/direction/walking',
      queryParameters: {
        'key': _amapApiKey,
        'origin': '${from.longitude},${from.latitude}',
        'destination': '${to.longitude},${to.latitude}',
        'output': 'json',
      },
    );
    
    return _parseWalkingResponse(response.data);
  }
  
  /// 解析驾车路线响应
  List<TransportRoute> _parseDrivingResponse(Map<String, dynamic> data) {
    final routes = <TransportRoute>[];
    
    if (data['status'] == '1' && data['route'] != null) {
      final routeData = data['route'];
      final paths = routeData['paths'] as List;
      
      for (final path in paths) {
        routes.add(TransportRoute(
          mode: TransportMode.driving,
          distance: double.tryParse(path['distance'].toString()) ?? 0,
          duration: int.tryParse(path['duration'].toString()) ?? 0,
          cost: double.tryParse(path['tolls'].toString()) ?? 0,
          description: '驾车路线',
          steps: _parseSteps(path['steps']),
        ));
      }
    }
    
    return routes;
  }
  
  /// 解析公共交通路线响应
  List<TransportRoute> _parseTransitResponse(Map<String, dynamic> data) {
    final routes = <TransportRoute>[];
    
    if (data['status'] == '1' && data['route'] != null) {
      final routeData = data['route'];
      final transits = routeData['transits'] as List;
      
      for (final transit in transits) {
        routes.add(TransportRoute(
          mode: TransportMode.transit,
          distance: double.tryParse(transit['distance'].toString()) ?? 0,
          duration: int.tryParse(transit['duration'].toString()) ?? 0,
          cost: double.tryParse(transit['cost'].toString()) ?? 0,
          description: '公共交通',
          steps: _parseTransitSegments(transit['segments']),
        ));
      }
    }
    
    return routes;
  }
  
  /// 解析步行路线响应
  List<TransportRoute> _parseWalkingResponse(Map<String, dynamic> data) {
    final routes = <TransportRoute>[];
    
    if (data['status'] == '1' && data['route'] != null) {
      final routeData = data['route'];
      final paths = routeData['paths'] as List;
      
      for (final path in paths) {
        routes.add(TransportRoute(
          mode: TransportMode.walking,
          distance: double.tryParse(path['distance'].toString()) ?? 0,
          duration: int.tryParse(path['duration'].toString()) ?? 0,
          cost: 0,
          description: '步行路线',
          steps: _parseSteps(path['steps']),
        ));
      }
    }
    
    return routes;
  }
  
  /// 解析路线步骤
  List<String> _parseSteps(List steps) {
    return steps.map((step) => step['instruction'].toString()).toList();
  }
  
  /// 解析公交路段
  List<String> _parseTransitSegments(List segments) {
    final steps = <String>[];
    for (final segment in segments) {
      if (segment['bus'] != null) {
        final buslines = segment['bus']['buslines'] as List;
        for (final busline in buslines) {
          steps.add('乘坐${busline['name']}');
        }
      } else if (segment['walking'] != null) {
        steps.add('步行${segment['walking']['distance']}米');
      }
    }
    return steps;
  }
  
  /// 跳转到第三方地图应用导航
  Future<void> navigateWithThirdPartyApp({
    required LatLng destination,
    required String destinationName,
    MapApp preferredApp = MapApp.amap,
  }) async {
    String url;
    
    switch (preferredApp) {
      case MapApp.amap:
        // 高德地图
        url = 'amapuri://route/plan/?dlat=${destination.latitude}&dlon=${destination.longitude}&dname=$destinationName&dev=0&t=0';
        break;
      case MapApp.baidu:
        // 百度地图
        url = 'baidumap://map/direction?destination=latlng:${destination.latitude},${destination.longitude}|name:$destinationName&mode=driving';
        break;
      case MapApp.tencent:
        // 腾讯地图
        url = 'qqmap://map/routeplan?type=drive&to=$destinationName&tocoord=${destination.latitude},${destination.longitude}';
        break;
      case MapApp.apple:
        // 苹果地图
        url = 'http://maps.apple.com/?daddr=${destination.latitude},${destination.longitude}';
        break;
    }
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // 如果无法打开指定应用，尝试打开网页版
        await _launchWebMap(destination, destinationName);
      }
    } catch (e) {
      print('打开地图应用失败: $e');
      await _launchWebMap(destination, destinationName);
    }
  }
  
  /// 打开网页版地图
  Future<void> _launchWebMap(LatLng destination, String destinationName) async {
    final url = 'https://uri.amap.com/marker?position=${destination.longitude},${destination.latitude}&name=$destinationName';
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  
  /// 获取多种交通方式的综合建议
  Future<TransportationSuggestion> getTransportationSuggestion({
    required LatLng from,
    required LatLng to,
  }) async {
    final suggestions = <TransportMode, List<TransportRoute>>{};
    
    // 并行获取多种交通方式的路线
    final futures = [
      getRouteToTrailhead(from: from, to: to, mode: TransportMode.driving),
      getRouteToTrailhead(from: from, to: to, mode: TransportMode.transit),
      getRouteToTrailhead(from: from, to: to, mode: TransportMode.walking),
    ];
    
    final results = await Future.wait(futures);
    suggestions[TransportMode.driving] = results[0];
    suggestions[TransportMode.transit] = results[1];
    suggestions[TransportMode.walking] = results[2];
    
    return TransportationSuggestion(
      routes: suggestions,
      recommendation: _getRecommendation(suggestions),
    );
  }
  
  /// 获取推荐的交通方式
  TransportMode _getRecommendation(Map<TransportMode, List<TransportRoute>> routes) {
    // 简单的推荐逻辑：优先推荐时间最短的方式
    TransportMode? bestMode;
    int minDuration = double.maxFinite.toInt();
    
    routes.forEach((mode, routeList) {
      if (routeList.isNotEmpty) {
        final duration = routeList.first.duration;
        if (duration < minDuration) {
          minDuration = duration;
          bestMode = mode;
        }
      }
    });
    
    return bestMode ?? TransportMode.driving;
  }
}

/// 交通方式枚举
enum TransportMode {
  driving,  // 驾车
  transit,  // 公共交通
  walking,  // 步行
}

/// 地图应用枚举
enum MapApp {
  amap,     // 高德地图
  baidu,    // 百度地图
  tencent,  // 腾讯地图
  apple,    // 苹果地图
}

/// 交通建议类
class TransportationSuggestion {
  final Map<TransportMode, List<TransportRoute>> routes;
  final TransportMode recommendation;
  
  TransportationSuggestion({
    required this.routes,
    required this.recommendation,
  });
}