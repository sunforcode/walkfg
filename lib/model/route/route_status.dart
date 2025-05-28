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
