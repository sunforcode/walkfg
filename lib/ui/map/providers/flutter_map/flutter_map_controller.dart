import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/map_data_model.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/ui/map/core/map_controller.dart' as app;
import 'package:walk/ui/map/core/map_enum.dart';
import 'package:walk/ui/map/core/map_provider.dart';
import 'package:walk/ui/map/utils/color_gradient.dart';
import 'package:walk/ui/map/utils/track_simplifier.dart';

/// Flutter Map控制器实现
class FlutterMapController implements app.MapController {
  /// 地图数据
  MapDataModel? _mapData;

  /// Flutter Map控制器
  final MapController mapController = MapController();

  /// 轨迹线
  final List<Polyline> polylines = [];

  /// 标记
  final List<Marker> markers = [];

  /// 当前地图类型
  MapType _mapType = MapType.standard;

  /// 是否跟随用户位置
  bool _followUserLocation = false;

  /// 用户位置
  LatLng? _userLocation;

  /// 地图类型变更监听器
  final List<void Function(MapType)> _mapTypeListeners = [];

  /// 构造函数
  FlutterMapController(this._mapData);

  @override
  MapDataModel? get mapData => _mapData;

  @override
  Future<void> setMapData(MapDataModel? data) async {
    _mapData = data;

    // 清除现有轨迹和标记
    polylines.clear();
    markers.clear();

    // 如果有新数据，显示轨迹
    if (data != null) {
      await showEntireTrack();
      await showTrack(useElevationGradient: true);
    }
  }

  @override
  Future<void> moveToLocation(double latitude, double longitude,
      {double? zoom}) async {
    // 使用 camera.zoom 替代 zoom
    final currentZoom = zoom ?? mapController.camera.zoom;
    mapController.move(LatLng(latitude, longitude), currentZoom);
  }

  @override
  Future<void> zoomIn() async {
    // 使用 camera.zoom 和 camera.center 替代 zoom 和 center
    mapController.move(
        mapController.camera.center, mapController.camera.zoom + 1);
  }

  @override
  Future<void> zoomOut() async {
    // 使用 camera.zoom 和 camera.center 替代 zoom 和 center
    mapController.move(
        mapController.camera.center, mapController.camera.zoom - 1);
  }

  @override
  Future<void> setZoom(double zoom) async {
    // 使用 camera.center 替代 center
    mapController.move(mapController.camera.center, zoom);
  }

  @override
  Future<void> setMapType(MapType mapType) async {
    if (_mapType != mapType) {
      _mapType = mapType;

      // 通知监听器地图类型已变更
      for (final listener in _mapTypeListeners) {
        listener(mapType);
      }

      debugPrint('地图类型已变更为: $mapType');
    }
  }

  /// 添加地图类型变更监听器
  void addMapTypeListener(void Function(MapType) listener) {
    _mapTypeListeners.add(listener);
  }

  /// 移除地图类型变更监听器
  void removeMapTypeListener(void Function(MapType) listener) {
    _mapTypeListeners.remove(listener);
  }

  @override
  MapType get currentMapType => _mapType;

  @override
  double get currentZoom => mapController.camera.zoom;

  @override
  Future<void> showEntireTrack({double padding = 50.0}) async {
    if (_mapData == null || _mapData!.trackPoints.isEmpty) {
      return;
    }

    try {
      // 获取轨迹边界
      final bounds = _mapData!.bounds;

      // 计算中心点
      final centerLat = (bounds.north + bounds.south) / 2;
      final centerLng = (bounds.east + bounds.west) / 2;

      // 计算适当的缩放级别
      final latDiff = bounds.north - bounds.south;
      final lngDiff = bounds.east - bounds.west;

      // 确保有最小差异，避免除以零
      final maxDiff = max(latDiff, lngDiff);
      final adjustedDiff = max(maxDiff, 0.01);

      // 计算缩放级别 (简化公式)
      final zoom = 14 - log(adjustedDiff * 111) / log(2);

      // 限制缩放级别在合理范围内
      final clampedZoom = zoom.clamp(1.0, 18.0);

      // 移动到中心点
      await moveToLocation(centerLat, centerLng, zoom: clampedZoom);

      debugPrint('显示整个轨迹: 中心点($centerLat, $centerLng), 缩放级别: $clampedZoom');
    } catch (e) {
      debugPrint('显示整个轨迹失败: $e');
    }
  }

  @override
  Future<void> showMyLocation() async {
    // 检查是否有用户位置
    if (_userLocation == null) {
      debugPrint('showMyLocation: 用户位置未知');
      return;
    }

    // 移动到用户位置
    await moveToLocation(_userLocation!.latitude, _userLocation!.longitude,
        zoom: 15);

    // 添加用户位置标记
    await addMarker(
      _userLocation!.latitude,
      _userLocation!.longitude,
      title: '当前位置',
      color: Colors.blue,
      icon: Icons.my_location,
    );
  }

  /// 设置用户位置（由定位服务调用）
  Future<void> setUserLocation(double latitude, double longitude) async {
    _userLocation = LatLng(latitude, longitude);

    // 如果开启了跟随用户位置，则移动地图
    if (_followUserLocation) {
      await moveToLocation(latitude, longitude);
    }
  }

  @override
  Future<void> followUserLocation(bool follow) async {
    _followUserLocation = follow;

    // 如果开启跟随且已知用户位置，则移动到用户位置
    if (follow && _userLocation != null) {
      await moveToLocation(_userLocation!.latitude, _userLocation!.longitude);
    }

    debugPrint('followUserLocation: $_followUserLocation');
  }

  @override
  Future<String> addMarker(double latitude, double longitude,
      {String? title, String? snippet, Color? color, IconData? icon}) async {
    final String markerId = 'marker_${DateTime.now().millisecondsSinceEpoch}';

    final marker = Marker(
      point: LatLng(latitude, longitude),
      width: 40,
      height: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.location_on,
            color: color ?? Colors.red,
            size: 30,
          ),
          if (title != null)
            Container(
              padding: const EdgeInsets.all(2),
              color: Colors.white.withAlpha(180), // 使用 withAlpha 替代 withOpacity
              child: Text(
                title,
                style: const TextStyle(fontSize: 10),
              ),
            ),
        ],
      ),
    );

    markers.add(marker);
    return markerId;
  }

  @override
  Future<void> removeMarker(String markerId) async {
    // 由于Flutter Map没有markerId概念，这里简化处理
    // 实际应用中可以扩展Marker类添加id属性
    debugPrint('removeMarker: $markerId - 未完全实现');
  }

  @override
  Future<void> clearMarkers() async {
    markers.clear();
  }

  @override
  Future<void> showTrack({
    Color? color,
    double? width,
    bool showStartMarker = true,
    bool showEndMarker = true,
    bool showHighestPoint = false,
    bool showLowestPoint = false,
    bool useElevationGradient = false,
  }) async {
    if (_mapData == null || _mapData!.trackPoints.isEmpty) {
      debugPrint('没有轨迹数据可显示');
      return;
    }

    try {
      // 清除现有轨迹
      polylines.clear();

      // 获取轨迹点
      final trackPoints = _mapData!.trackPoints;
      debugPrint('原始轨迹点数量: ${trackPoints.length}');

      // 简化轨迹点，提高性能
      final simplifiedPoints = TrackSimplifier.simplifyForZoom(
          trackPoints, mapController.camera.zoom);
      debugPrint('简化后轨迹点数量: ${simplifiedPoints.length}');

      // 转换为LatLng列表
      final points =
          simplifiedPoints.map((p) => LatLng(p.latitude, p.longitude)).toList();

      // 创建轨迹线
      if (useElevationGradient) {
        // 使用高程渐变色
        final gradientColors =
            ColorGradient.createElevationGradient(simplifiedPoints);

        // 创建渐变轨迹线
        for (int i = 1; i < points.length; i++) {
          final polyline = Polyline(
            points: [points[i - 1], points[i]],
            strokeWidth: width ?? 4.0,
            color: gradientColors[i - 1],
          );

          polylines.add(polyline);
        }
      } else {
        // 使用单一颜色
        final polyline = Polyline(
          points: points,
          strokeWidth: width ?? 4.0,
          color: color ?? Colors.blue,
        );

        polylines.add(polyline);
      }

      // 添加起点标记
      if (showStartMarker && trackPoints.isNotEmpty) {
        final startPoint = trackPoints.first;
        await addMarker(
          startPoint.latitude,
          startPoint.longitude,
          title: '起点',
          color: Colors.green,
          icon: Icons.play_arrow,
        );
      }

      // 添加终点标记
      if (showEndMarker && trackPoints.isNotEmpty) {
        final endPoint = trackPoints.last;
        await addMarker(
          endPoint.latitude,
          endPoint.longitude,
          title: '终点',
          color: Colors.red,
          icon: Icons.flag,
        );
      }

      // 添加最高点标记
      if (showHighestPoint && _mapData!.highestPoint != null) {
        final highestPoint = _mapData!.highestPoint!;
        final elevation = highestPoint.elevation;
        if (elevation != null) {
          await addMarker(
            highestPoint.latitude,
            highestPoint.longitude,
            title: '最高点 ${elevation.toStringAsFixed(0)}m',
            color: Colors.purple,
            icon: Icons.arrow_upward,
          );
        }
      }

      // 添加最低点标记
      if (showLowestPoint && _mapData!.lowestPoint != null) {
        final lowestPoint = _mapData!.lowestPoint!;
        final elevation = lowestPoint.elevation;
        if (elevation != null) {
          await addMarker(
            lowestPoint.latitude,
            lowestPoint.longitude,
            title: '最低点 ${elevation.toStringAsFixed(0)}m',
            color: Colors.blue,
            icon: Icons.arrow_downward,
          );
        }
      }

      debugPrint('轨迹显示完成');
    } catch (e) {
      debugPrint('显示轨迹失败: $e');
    }
  }

  @override
  Future<void> hideTrack() async {
    polylines.clear();
  }

  @override
  Future<void> highlightTrackSegment(int startIndex, int endIndex,
      {Color? color}) async {
    if (_mapData == null || _mapData!.trackPoints.isEmpty) {
      return;
    }

    try {
      // 确保索引在有效范围内
      final trackPoints = _mapData!.trackPoints;
      final validStartIndex = startIndex.clamp(0, trackPoints.length - 1);
      final validEndIndex = endIndex.clamp(0, trackPoints.length - 1);
      // 获取高亮段的点
      final highlightPoints = trackPoints
          .sublist(validStartIndex, validEndIndex + 1)
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();

      // 创建高亮线
      final highlightLine = Polyline(
        points: highlightPoints,
        strokeWidth: 6.0,
        color: color ?? Colors.red,
      );

      // 添加到轨迹线列表的最前面，确保显示在其他线的上面
      polylines.insert(0, highlightLine);
    } catch (e) {
      debugPrint('高亮轨迹段失败: $e');
    }
  }

  @override
  Future<void> clearHighlights() async {
    // 简单实现：重新显示轨迹
    await showTrack(useElevationGradient: true);
  }

  @override
  Future<double?> getElevationAt(double latitude, double longitude) async {
    if (_mapData == null || _mapData!.trackPoints.isEmpty) {
      return null;
    }
    // 找到最近的点
    TrackPointVO? nearestPoint;
    double minDistance = double.infinity;

    for (final point in _mapData!.trackPoints) {
      final distance = _calculateDistance(
        latitude,
        longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearestPoint = point;
      }
    }

    return nearestPoint?.elevation;
  }

  /// 计算两点间距离（米）
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371000.0; // 地球半径（米）
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  @override
  Future<Uint8List?> takeSnapshot() async {
    // Flutter Map目前不直接支持截图
    // 可以使用RenderRepaintBoundary实现
    return null;
  }

  @override
  void dispose() {
    // 释放资源
    _mapTypeListeners.clear();
  }
}
