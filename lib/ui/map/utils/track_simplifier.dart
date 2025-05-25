import 'dart:math';
import 'package:walk/model/map/track_point_model.dart';

/// 轨迹简化工具类
///
/// 使用 Douglas-Peucker 算法简化轨迹点，减少渲染点数量，提高性能
class TrackSimplifier {
  /// 根据缩放级别简化轨迹点
  ///
  /// [points] 原始轨迹点
  /// [zoom] 当前缩放级别
  /// 返回简化后的轨迹点
  static List<TrackPointVO> simplifyForZoom(
      List<TrackPointVO> points, double zoom) {
    if (points.length <= 2) {
      return List.from(points);
    }

    // 根据缩放级别计算容差
    // 缩放级别越小，容差越大，简化程度越高
    double tolerance = _calculateToleranceForZoom(zoom);

    return _simplify(points, tolerance);
  }

  /// 根据指定容差简化轨迹点
  ///
  /// [points] 原始轨迹点
  /// [tolerance] 简化容差（米）
  /// 返回简化后的轨迹点
  static List<TrackPointVO> simplify(
      List<TrackPointVO> points, double tolerance) {
    if (points.length <= 2) {
      return List.from(points);
    }

    return _simplify(points, tolerance);
  }

  /// 根据缩放级别计算容差
  static double _calculateToleranceForZoom(double zoom) {
    // 缩放级别与容差的对应关系
    // 缩放级别越小，容差越大
    if (zoom <= 5) return 1000; // 1000米
    if (zoom <= 8) return 500; // 500米
    if (zoom <= 10) return 200; // 200米
    if (zoom <= 12) return 100; // 100米
    if (zoom <= 14) return 50; // 50米
    if (zoom <= 16) return 20; // 20米
    if (zoom <= 18) return 10; // 10米
    return 5; // 5米
  }

  /// Douglas-Peucker 算法实现
  static List<TrackPointVO> _simplify(
      List<TrackPointVO> points, double tolerance) {
    if (points.length <= 2) {
      return List.from(points);
    }

    // 找出最大距离点
    double maxDistance = 0;
    int index = 0;

    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      double distance = _perpendicularDistance(points[i], start, end);
      if (distance > maxDistance) {
        maxDistance = distance;
        index = i;
      }
    }

    // 如果最大距离大于容差，则递归简化
    if (maxDistance > tolerance) {
      // 递归简化前半部分和后半部分
      final firstHalf = _simplify(points.sublist(0, index + 1), tolerance);
      final secondHalf = _simplify(points.sublist(index), tolerance);

      // 合并结果（去除重复点）
      return [...firstHalf.sublist(0, firstHalf.length - 1), ...secondHalf];
    } else {
      // 如果最大距离小于容差，则只保留起点和终点
      return [start, end];
    }
  }

  /// 计算点到线段的垂直距离
  static double _perpendicularDistance(
      TrackPointVO point, TrackPointVO lineStart, TrackPointVO lineEnd) {
    // 如果线段起点和终点重合，则返回点到起点的距离
    if (lineStart.latitude == lineEnd.latitude &&
        lineStart.longitude == lineEnd.longitude) {
      return _calculateDistance(
        point.latitude,
        point.longitude,
        lineStart.latitude,
        lineStart.longitude,
      );
    }

    // 计算线段长度的平方
    final lineLength = _calculateDistance(
      lineStart.latitude,
      lineStart.longitude,
      lineEnd.latitude,
      lineEnd.longitude,
    );

    // 计算叉积
    final area = _calculateArea(lineStart, lineEnd, point);

    // 点到线段的垂直距离 = 2 * 三角形面积 / 底边长度
    return (2 * area) / lineLength;
  }

  /// 计算三角形面积
  static double _calculateArea(TrackPointVO a, TrackPointVO b, TrackPointVO c) {
    return 0.5 *
        _calculateDistance(
          a.latitude,
          a.longitude,
          b.latitude,
          b.longitude,
        ) *
        _calculateDistance(
          c.latitude,
          c.longitude,
          b.latitude,
          b.longitude,
        );
  }

  /// 计算两点间距离（米）
  static double _calculateDistance(
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
}
