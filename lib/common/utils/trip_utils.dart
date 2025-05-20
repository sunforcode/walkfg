import 'package:flutter/material.dart';
import '../../model/trip_plan_model.dart';
import '../../model/route/route_model.dart';

/// 行程相关工具类
class TripUtils {
  /// 获取行程状态名称
  static String getStatusName(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return '草稿';
      case TripPlanStatus.confirmed:
        return '已确认';
      case TripPlanStatus.inProgress:
        return '进行中';
      case TripPlanStatus.completed:
        return '已完成';
      case TripPlanStatus.cancelled:
        return '已取消';
    }
  }

  /// 获取行程状态颜色
  static Color getStatusColor(TripPlanStatus status) {
    switch (status) {
      case TripPlanStatus.draft:
        return Colors.orange;
      case TripPlanStatus.confirmed:
        return Colors.blue;
      case TripPlanStatus.inProgress:
        return Colors.green;
      case TripPlanStatus.completed:
        return Colors.purple;
      case TripPlanStatus.cancelled:
        return Colors.red;
    }
  }

  /// 判断行程是否进行中
  static bool isInProgress(TripPlanStatus status) {
    return status == TripPlanStatus.draft ||
        status == TripPlanStatus.confirmed ||
        status == TripPlanStatus.inProgress;
  }

  /// 判断行程是否已完成
  static bool isCompleted(TripPlanStatus status) {
    return status == TripPlanStatus.completed ||
        status == TripPlanStatus.cancelled;
  }

  /// 解析时长范围
  static Map<String, int> parseDurationRange(String duration) {
    final result = {'minDays': 0, 'maxDays': 0};

    switch (duration) {
      case '1-2天':
        result['minDays'] = 1;
        result['maxDays'] = 2;
        break;
      case '3-5天':
        result['minDays'] = 3;
        result['maxDays'] = 5;
        break;
      case '6-10天':
        result['minDays'] = 6;
        result['maxDays'] = 10;
        break;
      case '10天以上':
        result['minDays'] = 10;
        result['maxDays'] = 100;
        break;
    }

    return result;
  }

  /// 根据难度名称获取难度枚举
  static RouteDifficulty? getDifficultyFromName(String name) {
    switch (name) {
      case '初级':
        return RouteDifficulty.easy;
      case '中级':
        return RouteDifficulty.medium;
      case '高级':
        return RouteDifficulty.hard;
      case '专业级':
        return RouteDifficulty.extreme;
      default:
        return null;
    }
  }

  /// 获取难度名称
  static String getDifficultyName(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '初级';
      case RouteDifficulty.medium:
        return '中级';
      case RouteDifficulty.hard:
        return '高级';
      case RouteDifficulty.extreme:
        return '专业级';
    }
  }

  /// 获取难度颜色
  static Color getDifficultyColor(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return Colors.green;
      case RouteDifficulty.medium:
        return Colors.orange;
      case RouteDifficulty.hard:
        return Colors.red;
      case RouteDifficulty.extreme:
        return Colors.purple;
    }
  }
}
