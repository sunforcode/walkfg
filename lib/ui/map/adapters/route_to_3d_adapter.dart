import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/route_enums.dart';
import 'package:walk/ui/map/widgets/map_3d_widget.dart';
import 'package:walk/ui/map/core/map_enum.dart';

/// RouteModel到3D地图数据的转换器
class RouteTo3DAdapter {
  static final math.Random _random = math.Random();

  /// 将RouteModel转换为3D地图所需的轨迹点数据
  static List<TrackPointVO> convertRouteToTrackPoints(RouteModel route) {
    final List<TrackPointVO> trackPoints = [];

    // 优先使用defaultMap中的轨迹点
    if (route.defaultMap != null && route.defaultMap!.trackPoints.isNotEmpty) {
      trackPoints.addAll(route.defaultMap!.trackPoints);
    }
    // 如果没有defaultMap，尝试从segments中提取
    else if (route.segments != null && route.segments!.isNotEmpty) {
      for (final segment in route.segments!) {
        // 这里需要根据SegmentModel的实际结构来提取轨迹点
        // 暂时使用模拟数据
        trackPoints.addAll(_generateTrackPointsFromSegment(segment));
      }
    }
    // 如果都没有，生成基于路线信息的模拟轨迹点
    else {
      trackPoints.addAll(_generateMockTrackPoints(route));
    }

    return trackPoints;
  }

  /// 将TrackModel转换为3D地图所需的轨迹点数据
  static List<TrackPointVO> convertTrackToTrackPoints(TrackModel track) {
    return track.trackPoints;
  }

  /// 根据RouteModel推荐最佳的3D地图配置
  static Map3DConfig recommendMap3DConfig(RouteModel route) {
    // 根据路线特征推荐配置
    final bool isHighAltitude = route.defaultMap?.maxElevation != null &&
        route.defaultMap!.maxElevation! > 2000;
    final bool isLongDistance = route.distance > 50;
    final bool isMountainRoute = route.region.contains('山') ||
        route.region.contains('峰') ||
        route.tags?.any((tag) => tag.contains('登山') || tag.contains('高海拔')) ==
            true;

    // 根据路线类型选择地图类型和配置
    MapType mapType;
    double initialPitch;
    bool enableTerrain;
    bool enable3DBuildings;

    if (isMountainRoute || isHighAltitude) {
      // 山地路线：使用地形图，高倾斜角度
      mapType = MapType.threeDTerrain;
      initialPitch = 60.0;
      enableTerrain = true;
      enable3DBuildings = false;
    } else if (isLongDistance) {
      // 长距离路线：使用卫星图，中等倾斜角度
      mapType = MapType.threeDSatellite;
      initialPitch = 45.0;
      enableTerrain = true;
      enable3DBuildings = true;
    } else {
      // 普通路线：使用标准3D地图
      mapType = MapType.threeD;
      initialPitch = 30.0;
      enableTerrain = false;
      enable3DBuildings = true;
    }

    return Map3DConfig(
      height: 400.0,
      mapType: mapType,
      initialPitch: initialPitch,
      initialBearing: 0.0,
      showTrack: true,
      trackColor: _getTrackColorByDifficulty(route.difficulty),
      trackWidth: _getTrackWidthByDistance(route.distance),
      enable3DBuildings: enable3DBuildings,
      enableTerrain: enableTerrain,
    );
  }

  /// 计算地图初始中心点
  static LatLng? calculateInitialCenter(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty) return null;

    double totalLat = 0;
    double totalLng = 0;
    for (final point in trackPoints) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(
      totalLat / trackPoints.length,
      totalLng / trackPoints.length,
    );
  }

  /// 根据难度获取轨迹颜色
  static Color _getTrackColorByDifficulty(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return const Color(0xFF4CAF50); // 绿色
      case RouteDifficulty.medium:
        return const Color(0xFF2196F3); // 蓝色
      case RouteDifficulty.hard:
        return const Color(0xFFFF9800); // 橙色
      case RouteDifficulty.extreme:
        return const Color(0xFFE91E63); // 红色
    }
  }

  /// 根据距离获取轨迹宽度
  static double _getTrackWidthByDistance(double distance) {
    if (distance < 10) return 2.5;
    if (distance < 30) return 3.0;
    if (distance < 50) return 3.5;
    return 4.0;
  }

  /// 从SegmentModel生成轨迹点（模拟实现）
  static List<TrackPointVO> _generateTrackPointsFromSegment(dynamic segment) {
    // 这里需要根据实际的SegmentModel结构来实现
    // 暂时返回空列表
    return [];
  }

  /// 生成基于路线信息的模拟轨迹点
  static List<TrackPointVO> _generateMockTrackPoints(RouteModel route) {
    final List<TrackPointVO> points = [];

    // 基于路线距离和海拔信息生成模拟轨迹
    final int pointCount =
        (route.distance * 2).round().clamp(10, 100); // 每0.5km一个点
    final double startElevation = route.defaultMap?.minElevation ?? 1000.0;
    final double endElevation =
        route.defaultMap?.maxElevation ?? startElevation + route.elevationGain;

    // 模拟起点坐标（这里需要根据实际情况调整）
    double baseLat = 39.0; // 默认纬度
    double baseLng = 116.0; // 默认经度

    // 根据地区调整基础坐标
    if (route.region.contains('川西')) {
      baseLat = 30.0;
      baseLng = 102.0;
    } else if (route.region.contains('云南')) {
      baseLat = 25.0;
      baseLng = 102.0;
    } else if (route.region.contains('西藏')) {
      baseLat = 29.0;
      baseLng = 91.0;
    }

    for (int i = 0; i < pointCount; i++) {
      final double progress = i / (pointCount - 1);

      // 模拟轨迹路径（简单的直线加随机偏移）
      final double lat =
          baseLat + (progress * 0.1) + (_random.nextDouble() - 0.5) * 0.02;
      final double lng =
          baseLng + (progress * 0.1) + (_random.nextDouble() - 0.5) * 0.02;

      // 模拟海拔变化（简单的线性插值加随机波动）
      final double elevation = startElevation +
          (endElevation - startElevation) * progress +
          (_random.nextDouble() - 0.5) * 100;

      points.add(TrackPointVO(
        latitude: lat,
        longitude: lng,
        elevation: elevation,
        timestamp: DateTime.now().add(Duration(minutes: i * 5)),
      ));
    }

    return points;
  }
}
