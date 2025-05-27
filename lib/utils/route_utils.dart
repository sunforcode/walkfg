import 'dart:math';
import '../model/route/route_model.dart';
import '../model/map/track_point_model.dart';

/// 路线相关工具类
class RouteUtils {
  /// 计算路线的总距离（公里）
  static double calculateTotalDistance(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0.0;
    }

    double totalDistance = 0.0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      totalDistance += _calculateDistance(
        trackPoints[i].latitude,
        trackPoints[i].longitude,
        trackPoints[i + 1].latitude,
        trackPoints[i + 1].longitude,
      );
    }

    return totalDistance;
  }

  /// 计算两点之间的距离（公里）
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371.0; // 地球半径（公里）
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2.0) * sin(dLat / 2.0) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2.0) *
            sin(dLon / 2.0);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// 角度转弧度
  static double _toRadians(double degree) {
    return degree * (pi / 180.0);
  }

  /// 计算路线的总爬升（米）
  static double calculateTotalElevationGain(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0;
    }

    double totalGain = 0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      final double elevationDiff =
          trackPoints[i + 1].elevation - trackPoints[i].elevation;
      if (elevationDiff > 0) {
        totalGain += elevationDiff;
      }
    }

    return totalGain;
  }

  /// 计算路线的总下降（米）
  static double calculateTotalElevationLoss(List<TrackPointVO> trackPoints) {
    if (trackPoints.isEmpty || trackPoints.length < 2) {
      return 0;
    }

    double totalLoss = 0;
    for (int i = 0; i < trackPoints.length - 1; i++) {
      final double elevationDiff =
          trackPoints[i].elevation - trackPoints[i + 1].elevation;
      if (elevationDiff > 0) {
        totalLoss += elevationDiff;
      }
    }

    return totalLoss;
  }

  /// 估算路线的徒步时间（小时）
  static double estimateHikingTime(
      double distance, int elevationGain, RouteDifficulty difficulty) {
    // 基础时间：每公里1小时
    double baseTime = distance;

    // 爬升时间：每100米爬升增加0.5小时
    double elevationTime = elevationGain / 100 * 0.5;

    // 难度系数
    double difficultyFactor = 1.0;
    switch (difficulty) {
      case RouteDifficulty.easy:
        difficultyFactor = 0.8;
        break;
      case RouteDifficulty.medium:
        difficultyFactor = 1.0;
        break;
      case RouteDifficulty.hard:
        difficultyFactor = 1.2;
        break;
      case RouteDifficulty.extreme:
        difficultyFactor = 1.5;
        break;
    }

    return (baseTime + elevationTime) * difficultyFactor;
  }

  /// 获取路线的难度描述
  static String getDifficultyDescription(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '适合初学者，路线平缓，无技术难度';
      case RouteDifficulty.medium:
        return '适合有一定经验的徒步者，有少量陡坡';
      case RouteDifficulty.hard:
        return '适合经验丰富的徒步者，有较多陡坡和技术难点';
      case RouteDifficulty.extreme:
        return '仅适合专业徒步者，包含高海拔、陡峭地形和技术难点';
    }
  }

  /// 获取路线的推荐装备列表
  static List<String> getRecommendedEquipment(
      RouteDifficulty difficulty, String season) {
    List<String> baseEquipment = [
      '徒步鞋',
      '背包',
      '水壶',
      '防晒霜',
      '急救包',
    ];

    List<String> additionalEquipment = [];

    // 根据难度添加装备
    switch (difficulty) {
      case RouteDifficulty.easy:
        // 基础装备足够
        break;
      case RouteDifficulty.medium:
        additionalEquipment.addAll(['登山杖', '雨衣']);
        break;
      case RouteDifficulty.hard:
        additionalEquipment.addAll(['登山杖', '雨衣', '头灯', 'GPS设备', '保暖衣物']);
        break;
      case RouteDifficulty.extreme:
        additionalEquipment.addAll([
          '登山杖',
          '雨衣',
          '头灯',
          'GPS设备',
          '保暖衣物',
          '帐篷',
          '睡袋',
          '炉具',
          '高能量食品',
        ]);
        break;
    }

    // 根据季节添加装备
    if (season.contains('春') || season.contains('秋')) {
      additionalEquipment.add('防风外套');
    }
    if (season.contains('夏')) {
      additionalEquipment.addAll(['防蚊液', '速干衣裤']);
    }
    if (season.contains('冬')) {
      additionalEquipment.addAll(['保暖内衣', '手套', '帽子', '防寒外套']);
    }

    return [...baseEquipment, ...additionalEquipment];
  }

  /// 获取路线的最佳季节描述
  static String getBestSeasonDescription(List<String> bestSeasons) {
    if (bestSeasons.isEmpty) {
      return '四季皆宜';
    }

    if (bestSeasons.length == 4 ||
        (bestSeasons.contains('春') &&
            bestSeasons.contains('夏') &&
            bestSeasons.contains('秋') &&
            bestSeasons.contains('冬'))) {
      return '四季皆宜';
    }

    return bestSeasons.join('、');
  }
}
