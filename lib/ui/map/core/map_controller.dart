import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:walk/model/model/map/map_data_model.dart';
import 'map_provider.dart';

/// 地图控制器接口
abstract class MapController {
  /// 获取地图数据
  MapDataModel? get mapData;

  /// 设置地图数据
  Future<void> setMapData(MapDataModel? data);

  /// 移动到指定位置
  Future<void> moveToLocation(double latitude, double longitude,
      {double? zoom});

  /// 放大地图
  Future<void> zoomIn();

  /// 缩小地图
  Future<void> zoomOut();

  /// 设置缩放级别
  Future<void> setZoom(double zoom);

  /// 获取当前缩放级别
  double get currentZoom;

  /// 显示整个轨迹
  Future<void> showEntireTrack({double padding = 50.0});

  /// 显示用户位置
  Future<void> showMyLocation();

  /// 跟随用户位置
  Future<void> followUserLocation(bool follow);

  /// 设置地图类型
  Future<void> setMapType(MapType mapType);

  /// 获取当前地图类型
  MapType get currentMapType;

  /// 添加标记
  Future<String> addMarker(double latitude, double longitude,
      {String? title, String? snippet, Color? color, IconData? icon});

  /// 移除标记
  Future<void> removeMarker(String markerId);

  /// 清除所有标记
  Future<void> clearMarkers();

  /// 显示轨迹
  Future<void> showTrack({
    Color? color,
    double? width,
    bool showStartMarker = true,
    bool showEndMarker = true,
    bool showHighestPoint = false,
    bool showLowestPoint = false,
    bool useElevationGradient = false,
  });

  /// 隐藏轨迹
  Future<void> hideTrack();

  /// 高亮轨迹段
  Future<void> highlightTrackSegment(int startIndex, int endIndex,
      {Color? color});

  /// 清除高亮
  Future<void> clearHighlights();

  /// 获取指定位置的高程
  Future<double?> getElevationAt(double latitude, double longitude);

  /// 截图
  Future<Uint8List?> takeSnapshot();

  /// 释放资源
  void dispose();
}
