/// 路线难度枚举
enum RouteDifficulty {
  /// 简单
  easy,
  
  /// 中等
  medium,
  
  /// 困难
  hard,
  
  /// 极难
  extreme
}

/// 路线状态枚举
enum RouteStatus {
  /// 准备中
  planning,
  
  /// 进行中
  inProgress,
  
  /// 已完成
  completed,
  
  /// 已取消
  cancelled
}

/// 路线数据模型
class RouteModel {
  /// 路线ID
  final String id;
  
  /// 路线名称
  final String name;
  
  /// 路线描述
  final String description;
  
  /// 路线距离（公里）
  final double distance;
  
  /// 预计时长
  final String duration;
  
  /// 路线难度
  final RouteDifficulty difficulty;
  
  /// 最佳季节
  final String bestSeason;
  
  /// 海拔增益（米）
  final int elevationGain;
  
  /// 海拔损失（米）
  final int elevationLoss;
  
  /// 最高点（米）
  final int highestPoint;
  
  /// 最低点（米）
  final int lowestPoint;
  
  /// 路线图片URL列表
  final List<String> imageUrls;
  
  /// 路线GPX轨迹URL
  final String? gpxUrl;

  /// 构造函数
  RouteModel({
    required this.id,
    required this.name,
    required this.description,
    required this.distance,
    required this.duration,
    required this.difficulty,
    required this.bestSeason,
    required this.elevationGain,
    required this.elevationLoss,
    required this.highestPoint,
    required this.lowestPoint,
    required this.imageUrls,
    this.gpxUrl,
  });

  /// 从JSON创建模型
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      distance: json['distance'] as double,
      duration: json['duration'] as String,
      difficulty: _difficultyFromString(json['difficulty'] as String),
      bestSeason: json['best_season'] as String,
      elevationGain: json['elevation_gain'] as int,
      elevationLoss: json['elevation_loss'] as int,
      highestPoint: json['highest_point'] as int,
      lowestPoint: json['lowest_point'] as int,
      imageUrls: (json['image_urls'] as List<dynamic>).map((e) => e as String).toList(),
      gpxUrl: json['gpx_url'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'distance': distance,
      'duration': duration,
      'difficulty': _difficultyToString(difficulty),
      'best_season': bestSeason,
      'elevation_gain': elevationGain,
      'elevation_loss': elevationLoss,
      'highest_point': highestPoint,
      'lowest_point': lowestPoint,
      'image_urls': imageUrls,
      'gpx_url': gpxUrl,
    };
  }

  /// 将字符串转换为难度枚举
  static RouteDifficulty _difficultyFromString(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return RouteDifficulty.easy;
      case 'medium':
        return RouteDifficulty.medium;
      case 'hard':
        return RouteDifficulty.hard;
      case 'extreme':
        return RouteDifficulty.extreme;
      default:
        return RouteDifficulty.medium;
    }
  }

  /// 将难度枚举转换为字符串
  static String _difficultyToString(RouteDifficulty difficulty) {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return 'easy';
      case RouteDifficulty.medium:
        return 'medium';
      case RouteDifficulty.hard:
        return 'hard';
      case RouteDifficulty.extreme:
        return 'extreme';
    }
  }
  
  /// 获取难度的中文名称
  String getDifficultyName() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '简单';
      case RouteDifficulty.medium:
        return '中等';
      case RouteDifficulty.hard:
        return '困难';
      case RouteDifficulty.extreme:
        return '极难';
    }
  }
}

/// 计划路线模型
class PlannedRouteModel {
  /// 计划ID
  final String id;
  
  /// 路线ID
  final String routeId;
  
  /// 路线名称
  final String name;
  
  /// 计划日期
  final DateTime date;
  
  /// 计划天数
  final int days;
  
  /// 路线状态
  final RouteStatus status;
  
  /// 备注
  final String? notes;

  /// 构造函数
  PlannedRouteModel({
    required this.id,
    required this.routeId,
    required this.name,
    required this.date,
    required this.days,
    required this.status,
    this.notes,
  });

  /// 从JSON创建模型
  factory PlannedRouteModel.fromJson(Map<String, dynamic> json) {
    return PlannedRouteModel(
      id: json['id'] as String,
      routeId: json['route_id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      days: json['days'] as int,
      status: _statusFromString(json['status'] as String),
      notes: json['notes'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_id': routeId,
      'name': name,
      'date': date.toIso8601String(),
      'days': days,
      'status': _statusToString(status),
      'notes': notes,
    };
  }

  /// 将字符串转换为状态枚举
  static RouteStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return RouteStatus.planning;
      case 'in_progress':
        return RouteStatus.inProgress;
      case 'completed':
        return RouteStatus.completed;
      case 'cancelled':
        return RouteStatus.cancelled;
      default:
        return RouteStatus.planning;
    }
  }

  /// 将状态枚举转换为字符串
  static String _statusToString(RouteStatus status) {
    switch (status) {
      case RouteStatus.planning:
        return 'planning';
      case RouteStatus.inProgress:
        return 'in_progress';
      case RouteStatus.completed:
        return 'completed';
      case RouteStatus.cancelled:
        return 'cancelled';
    }
  }
  
  /// 获取状态的中文名称
  String getStatusName() {
    switch (status) {
      case RouteStatus.planning:
        return '准备中';
      case RouteStatus.inProgress:
        return '进行中';
      case RouteStatus.completed:
        return '已完成';
      case RouteStatus.cancelled:
        return '已取消';
    }
  }
  
  /// 格式化日期为字符串
  String getFormattedDate() {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}