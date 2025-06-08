import 'package:json_annotation/json_annotation.dart';
import '../../service/transportation_service.dart';

part 'transport_route.g.dart';

/// 交通路线模型
@JsonSerializable()
class TransportRoute {
  /// 交通方式
  final TransportMode mode;
  
  /// 距离（米）
  final double distance;
  
  /// 预计时间（秒）
  final int duration;
  
  /// 费用（元）
  final double cost;
  
  /// 路线描述
  final String description;
  
  /// 路线步骤
  final List<String> steps;
  
  /// 构造函数
  TransportRoute({
    required this.mode,
    required this.distance,
    required this.duration,
    required this.cost,
    required this.description,
    required this.steps,
  });
  
  /// 从JSON创建
  factory TransportRoute.fromJson(Map<String, dynamic> json) =>
      _$TransportRouteFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TransportRouteToJson(this);
  
  /// 获取格式化的距离
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}米';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}公里';
    }
  }
  
  /// 获取格式化的时间
  String get formattedDuration {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }
  
  /// 获取格式化的费用
  String get formattedCost {
    if (cost == 0) {
      return '免费';
    } else {
      return '约${cost.toStringAsFixed(0)}元';
    }
  }
  
  /// 获取交通方式的中文名称
  String get modeDisplayName {
    switch (mode) {
      case TransportMode.driving:
        return '驾车';
      case TransportMode.transit:
        return '公共交通';
      case TransportMode.walking:
        return '步行';
    }
  }
  
  /// 获取交通方式的图标名称
  String get modeIconName {
    switch (mode) {
      case TransportMode.driving:
        return 'car.fill';
      case TransportMode.transit:
        return 'bus.fill';
      case TransportMode.walking:
        return 'figure.walk';
    }
  }
}