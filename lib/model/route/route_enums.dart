import 'package:flutter/material.dart';

/// 路线类型枚举
enum RouteType {
  /// 环线
  circular,

  /// 单向
  oneWay,

  /// 往返
  roundTrip;

  /// 从整数解析路线类型
  static RouteType fromInt(int value) {
    if (value >= 0 && value < RouteType.values.length) {
      return RouteType.values[value];
    }
    return RouteType.circular; // 默认返回环线
  }

  /// 路线类型转整数
  int toInt() {
    return index;
  }
}

/// 路线方向枚举
enum RouteDirection {
  /// 顺时针
  clockwise,

  /// 逆时针
  counterClockwise;

  /// 从整数解析路线方向
  static RouteDirection fromInt(int value) {
    if (value >= 0 && value < RouteDirection.values.length) {
      return RouteDirection.values[value];
    }
    return RouteDirection.clockwise; // 默认返回顺时针
  }

  /// 路线方向转整数
  int toInt() {
    return index;
  }
}

/// 路线难度枚举
enum RouteDifficulty {
  /// 简单
  easy,

  /// 中等
  medium,

  /// 困难
  hard,

  /// 极限
  extreme;

  /// 获取难度名称
  String getName() {
    switch (this) {
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
  Color getColor() {
    switch (this) {
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

  /// 从整数解析难度
  static RouteDifficulty fromInt(int value) {
    if (value >= 0 && value < RouteDifficulty.values.length) {
      return RouteDifficulty.values[value];
    }
    return RouteDifficulty.medium; // 默认返回中等难度
  }

  /// 难度转整数
  int toInt() {
    return index;
  }
}

/// 路线状态枚举
///
/// 用于表示路线、路径和行程计划的状态
enum RouteStatus {
  /// 计划中
  planning,

  /// 进行中
  inProgress,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
}

/// 获取路线状态名称
String getRouteStatusName(RouteStatus status) {
  switch (status) {
    case RouteStatus.planning:
      return '计划中';
    case RouteStatus.inProgress:
      return '进行中';
    case RouteStatus.completed:
      return '已完成';
    case RouteStatus.cancelled:
      return '已取消';
  }
}

/// 从字符串解析状态
RouteStatus parseRouteStatus(String? statusStr) {
  if (statusStr == null) return RouteStatus.planning;

  switch (statusStr.toLowerCase()) {
    case 'planning':
      return RouteStatus.planning;
    case 'completed':
      return RouteStatus.completed;
    case 'cancelled':
      return RouteStatus.cancelled;
    default:
      return RouteStatus.planning;
  }
}

/// 将状态转换为字符串
String routeStatusToString(RouteStatus status) {
  return status.toString().split('.').last;
}
