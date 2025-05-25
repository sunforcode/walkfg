import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:walk/model/model/map/map_bounds.dart';
import 'package:walk/model/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/unified_map_widget.dart';

/// 地图服务类，负责管理地图相关的状态和操作
class MapService extends ChangeNotifier {
  /// 单例实例
  static final MapService _instance = MapService._internal();

  /// 获取单例实例
  static MapService get instance => _instance;

  /// 私有构造函数
  MapService._internal();

  /// 当前地图类型
  MapType _currentMapType = MapType.standard;

  /// 当前地图提供商
  MapProviderType _currentMapProvider = MapProviderType.apple;

  /// 当前轨迹渲染模式
  TrackRenderMode _currentTrackRenderMode = TrackRenderMode.normal;

  /// 是否显示公里标记
  bool _showKilometerMarkers = false;

  /// 是否显示兴趣点
  bool _showPointsOfInterest = true;

  /// 是否显示海拔图表
  bool _showElevationChart = false;

  /// 是否支持离线地图
  bool _supportOfflineMap = true;

  /// 离线地图下载进度
  double _offlineMapDownloadProgress = 0.0;

  /// 是否正在下载离线地图
  bool _isDownloadingOfflineMap = false;

  /// 离线地图下载任务
  Timer? _downloadTimer;

  /// 获取当前地图类型
  MapType get currentMapType => _currentMapType;

  /// 获取当前地图提供商
  MapProviderType get currentMapProvider => _currentMapProvider;

  /// 获取当前轨迹渲染模式
  TrackRenderMode get currentTrackRenderMode => _currentTrackRenderMode;

  /// 是否显示公里标记
  bool get showKilometerMarkers => _showKilometerMarkers;

  /// 是否显示兴趣点
  bool get showPointsOfInterest => _showPointsOfInterest;

  /// 是否显示海拔图表
  bool get showElevationChart => _showElevationChart;

  /// 是否支持离线地图
  bool get supportOfflineMap => _supportOfflineMap;

  /// 离线地图下载进度
  double get offlineMapDownloadProgress => _offlineMapDownloadProgress;

  /// 是否正在下载离线地图
  bool get isDownloadingOfflineMap => _isDownloadingOfflineMap;

  /// 设置当前地图类型
  void setMapType(MapType mapType) {
    _currentMapType = mapType;
    notifyListeners();
  }

  /// 设置当前地图提供商
  void setMapProvider(MapProviderType provider) {
    _currentMapProvider = provider;
    notifyListeners();
  }

  /// 设置当前轨迹渲染模式
  void setTrackRenderMode(TrackRenderMode mode) {
    _currentTrackRenderMode = mode;
    notifyListeners();
  }

  /// 设置是否显示公里标记
  void setShowKilometerMarkers(bool show) {
    _showKilometerMarkers = show;
    notifyListeners();
  }

  /// 设置是否显示兴趣点
  void setShowPointsOfInterest(bool show) {
    _showPointsOfInterest = show;
    notifyListeners();
  }

  /// 设置是否显示海拔图表
  void setShowElevationChart(bool show) {
    _showElevationChart = show;
    notifyListeners();
  }

  /// 设置是否支持离线地图
  void setSupportOfflineMap(bool support) {
    _supportOfflineMap = support;
    notifyListeners();
  }

  /// 下载离线地图
  Future<void> downloadOfflineMap(
    MapBoundsVO bounds,
    MapType mapType,
    MapProviderType mapProvider,
    Function(String)? onSuccess,
    Function(String)? onError,
  ) async {
    if (_isDownloadingOfflineMap) {
      onError?.call('已有下载任务正在进行');
      return;
    }

    _isDownloadingOfflineMap = true;
    _offlineMapDownloadProgress = 0.0;
    notifyListeners();

    try {
      // 模拟下载进度
      _downloadTimer =
          Timer.periodic(const Duration(milliseconds: 500), (timer) {
        _offlineMapDownloadProgress += 0.1;
        if (_offlineMapDownloadProgress >= 1.0) {
          _isDownloadingOfflineMap = false;
          timer.cancel();
          _downloadTimer = null;
          onSuccess?.call('离线地图下载完成');
        }
        notifyListeners();
      });

      // 实际应用中，这里应该调用真正的离线地图下载API
      print('下载离线地图: ${bounds.toString()}, 类型: $mapType, 提供商: $mapProvider');
    } catch (e) {
      _isDownloadingOfflineMap = false;
      _downloadTimer?.cancel();
      _downloadTimer = null;
      onError?.call('下载失败: $e');
      notifyListeners();
    }
  }

  /// 取消下载离线地图
  void cancelDownloadOfflineMap() {
    if (_isDownloadingOfflineMap) {
      _downloadTimer?.cancel();
      _downloadTimer = null;
      _isDownloadingOfflineMap = false;
      notifyListeners();
    }
  }

  /// 计算轨迹统计信息
  Map<String, dynamic> calculateTrackStatistics(
      List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) {
      return {
        'totalDistance': 0.0,
        'totalElevationGain': 0.0,
        'totalElevationLoss': 0.0,
        'highestElevation': 0.0,
        'lowestElevation': 0.0,
      };
    }

    double totalDistance = 0.0;
    double totalElevationGain = 0.0;
    double totalElevationLoss = 0.0;
    double highestElevation = trackPoints[0].elevation;
    double lowestElevation = trackPoints[0].elevation;

    for (int i = 1; i < trackPoints.length; i++) {
      final prevPoint = trackPoints[i - 1];
      final currentPoint = trackPoints[i];

      // 计算距离
      final distance = _calculateDistance(
        prevPoint.latitude,
        prevPoint.longitude,
        currentPoint.latitude,
        currentPoint.longitude,
      );
      totalDistance += distance;

      // 计算高程变化
      final elevationDiff = currentPoint.elevation - prevPoint.elevation;
      if (elevationDiff > 0) {
        totalElevationGain += elevationDiff;
      } else {
        totalElevationLoss += -elevationDiff;
      }

      // 更新最高和最低高程
      if (currentPoint.elevation > highestElevation) {
        highestElevation = currentPoint.elevation;
      }
      if (currentPoint.elevation < lowestElevation) {
        lowestElevation = currentPoint.elevation;
      }
    }

    return {
      'totalDistance': totalDistance / 1000, // 转换为公里
      'totalElevationGain': totalElevationGain,
      'totalElevationLoss': totalElevationLoss,
      'highestElevation': highestElevation,
      'lowestElevation': lowestElevation,
    };
  }

  /// 计算两点之间的距离（米）
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * (3.141592653589793 / 180);
    final phi2 = lat2 * (3.141592653589793 / 180);
    final deltaPhi = (lat2 - lat1) * (3.141592653589793 / 180);
    final deltaLambda = (lon2 - lon1) * (3.141592653589793 / 180);

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// 计算地图边界
  MapBoundsVO calculateMapBounds(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) {
      // 默认边界（中国）
      return const MapBoundsVO(
        north: 53.55,
        south: 3.86,
        east: 135.05,
        west: 73.66,
      );
    }

    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (final point in trackPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    // 添加边距
    const padding = 0.01; // 约1公里
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    return MapBoundsVO(
      north: maxLat,
      south: minLat,
      east: maxLng,
      west: minLng,
    );
  }
}
