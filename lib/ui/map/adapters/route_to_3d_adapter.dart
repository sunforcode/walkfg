import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:walk/model/map/track_point_model.dart';
import 'package:walk/model/route/route_model.dart';
import 'package:walk/model/route/track_model.dart';
import 'package:walk/model/route/route_enums.dart';

/// RouteModel到3D地图数据的转换器
///
/// 提供将路线数据转换为 Mapbox 3D 地图所需轨迹点格式的工具方法
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

  /// 根据RouteModel推荐匹配 Mapbox 3D 地图的初始 pitch
  ///
  /// 返回建议的相机倾斜角（度）：山地 60°，长距离 45°，其他 30°
  static double recommendInitialPitch(RouteModel route) {
    final bool isHighAltitude = route.defaultMap?.maxElevation != null &&
        route.defaultMap!.maxElevation! > 2000;
    final bool isMountainRoute = route.region.contains('山') ||
        route.region.contains('峰') ||
        route.tags?.any((tag) => tag.contains('登山') || tag.contains('高海拔')) ==
            true;

    if (isMountainRoute || isHighAltitude) return 60.0;
    if (route.distance > 50) return 45.0;
    return 30.0;
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
  static Color getTrackColorByDifficulty(RouteDifficulty difficulty) {
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
  static double getTrackWidthByDistance(double distance) {
    if (distance < 10) return 2.5;
    if (distance < 30) return 3.0;
    if (distance < 50) return 3.5;
    return 4.0;
  }

  /// 从SegmentModel生成轨迹点（模拟实现）
  static List<TrackPointVO> _generateTrackPointsFromSegment(dynamic segment) {
    return [];
  }

  /// 生成基于路线信息的模拟轨迹点
  static List<TrackPointVO> _generateMockTrackPoints(RouteModel route) {
    final List<TrackPointVO> points = [];

    final int pointCount =
        (route.distance * 2).round().clamp(10, 100);
    final double startElevation = route.defaultMap?.minElevation ?? 1000.0;
    final double endElevation =
        route.defaultMap?.maxElevation ?? startElevation + route.elevationGain;

    double baseLat = 39.0;
    double baseLng = 116.0;

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

      final double lat =
          baseLat + (progress * 0.1) + (_random.nextDouble() - 0.5) * 0.02;
      final double lng =
          baseLng + (progress * 0.1) + (_random.nextDouble() - 0.5) * 0.02;

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
