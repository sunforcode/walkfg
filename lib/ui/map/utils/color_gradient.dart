import 'dart:math';
import 'package:flutter/material.dart';
import 'package:walk/model/model/map/track_point_model.dart';

/// 颜色渐变工具类
class ColorGradient {
  /// 创建高程渐变色
  static List<Color> createElevationGradient(List<TrackPointVO> points) {
    // 获取最高和最低高程
    double minElevation = double.infinity;
    double maxElevation = -double.infinity;

    for (final point in points) {
      minElevation =
          point.elevation < minElevation ? point.elevation : minElevation;
      maxElevation =
          point.elevation > maxElevation ? point.elevation : maxElevation;
    }

    // 如果高程范围太小，使用默认颜色
    if (maxElevation - minElevation < 10) {
      return [Colors.blue];
    }

    // 创建颜色列表
    final colors = <Color>[];

    for (final point in points) {
      final elevation = point.elevation;
      final ratio = (elevation - minElevation) / (maxElevation - minElevation);

      // 从低到高：蓝色 -> 绿色 -> 黄色 -> 红色
      colors.add(_getColorForRatio(ratio));
    }

    return colors;
  }

  /// 根据比例获取颜色
  static Color _getColorForRatio(double ratio) {
    if (ratio < 0.25) {
      // 蓝色到青色
      return Color.lerp(
        Colors.blue,
        Colors.cyan,
        ratio * 4,
      )!;
    } else if (ratio < 0.5) {
      // 青色到绿色
      return Color.lerp(
        Colors.cyan,
        Colors.green,
        (ratio - 0.25) * 4,
      )!;
    } else if (ratio < 0.75) {
      // 绿色到黄色
      return Color.lerp(
        Colors.green,
        Colors.yellow,
        (ratio - 0.5) * 4,
      )!;
    } else {
      // 黄色到红色
      return Color.lerp(
        Colors.yellow,
        Colors.red,
        (ratio - 0.75) * 4,
      )!;
    }
  }

  /// 创建坡度渐变色
  static List<Color> createSlopeGradient(List<TrackPointVO> points) {
    // 计算每段的坡度
    final slopes = <double>[];

    for (var i = 1; i < points.length; i++) {
      // 计算两点间距离（米）
      final distance = _calculateDistance(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );

      if (distance > 0) {
        // 计算高度差
        final elevationDiff = points[i].elevation - points[i - 1].elevation;

        // 计算坡度（百分比）
        final slope = (elevationDiff / distance) * 100;
        slopes.add(slope);
      } else {
        slopes.add(0);
      }
    }

    // 添加第一个点的坡度（与第二个点相同）
    slopes.insert(0, slopes.isNotEmpty ? slopes.first : 0);

    // 获取最大和最小坡度
    double maxSlope = slopes.reduce((a, b) => a > b ? a : b);
    double minSlope = slopes.reduce((a, b) => a < b ? a : b);

    // 确保有一定的坡度范围
    if (maxSlope - minSlope < 5) {
      maxSlope = minSlope + 5;
    }

    // 创建颜色列表
    final colors = <Color>[];

    for (final slope in slopes) {
      // 归一化坡度
      final ratio = (slope - minSlope) / (maxSlope - minSlope);

      // 根据坡度获取颜色
      colors.add(_getSlopeColor(slope, ratio));
    }

    return colors;
  }

  /// 根据坡度获取颜色
  static Color _getSlopeColor(double slope, double ratio) {
    if (slope < -10) {
      // 陡峭下坡：深蓝
      return Colors.blue[900]!;
    } else if (slope < -5) {
      // 中等下坡：蓝色
      return Colors.blue;
    } else if (slope < -2) {
      // 轻微下坡：浅蓝
      return Colors.blue[300]!;
    } else if (slope < 2) {
      // 平缓：绿色
      return Colors.green;
    } else if (slope < 5) {
      // 轻微上坡：黄色
      return Colors.yellow;
    } else if (slope < 10) {
      // 中等上坡：橙色
      return Colors.orange;
    } else {
      // 陡峭上坡：红色
      return Colors.red;
    }
  }

  /// 计算两点间距离（米）
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
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
}
