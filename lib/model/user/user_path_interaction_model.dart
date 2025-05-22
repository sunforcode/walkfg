import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import '../model/route/route_model.dart';

part 'user_path_interaction_model.g.dart';

/// 用户路径交互状态枚举
enum PathInteractionStatus {
  /// 收藏
  favorite,
  
  /// 已完成
  completed,
  
  /// 计划中
  planned,
}

/// 用户路径交互模型
@JsonSerializable()
class UserPathInteractionModel extends BaseModel {
  /// 用户ID
  final String userId;
  
  /// 路径ID
  final String pathId;
  
  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final PathInteractionStatus status;
  
  /// 用户评分
  final double? rating;
  
  /// 评价
  final String? review;
  
  /// 完成日期
  final DateTime? completionDate;
  
  /// 照片URL
  final List<String> photos;
  
  /// 自定义路点
  final List<CustomWaypointModel> customWaypoints;
  
  /// 笔记
  final String? notes;
  
  /// 清单
  final ChecklistModel? checklist;
  
  /// 构造函数
  UserPathInteractionModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.userId,
    required this.pathId,
    required this.status,
    this.rating,
    this.review,
    this.completionDate,
    List<String>? photos,
    List<CustomWaypointModel>? customWaypoints,
    this.notes,
    this.checklist,
  })  : this.photos = photos ?? const [],
        this.customWaypoints = customWaypoints ?? const [];
  
  /// 从JSON创建
  factory UserPathInteractionModel.fromJson(Map<String, dynamic> json) => _$UserPathInteractionModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UserPathInteractionModelToJson(this);
  
  /// 解析状态
  static PathInteractionStatus _parseStatus(dynamic status) {
    if (status is int && status >= 0 && status < PathInteractionStatus.values.length) {
      return PathInteractionStatus.values[status];
    } else if (status is String) {
      switch (status.toLowerCase()) {
        case 'favorite':
          return PathInteractionStatus.favorite;
        case 'completed':
          return PathInteractionStatus.completed;
        case 'planned':
          return PathInteractionStatus.planned;
        default:
          return PathInteractionStatus.favorite;
      }
    }
    return PathInteractionStatus.favorite;
  }
  
  /// 状态转JSON
  static int _statusToJson(PathInteractionStatus status) {
    return status.index;
  }
  
  /// 获取状态名称
  String getStatusName() {
    switch (status) {
      case PathInteractionStatus.favorite:
        return '收藏';
      case PathInteractionStatus.completed:
        return '已完成';
      case PathInteractionStatus.planned:
        return '计划中';
    }
  }
  
  /// 获取完成日期文本
  String? getCompletionDateText() {
    if (completionDate == null) return null;
    return '${completionDate!.year}-${completionDate!.month.toString().padLeft(2, '0')}-${completionDate!.day.toString().padLeft(2, '0')}';
  }
}

/// 自定义路点模型
@JsonSerializable()
class CustomWaypointModel extends BaseModel {
  /// 名称
  final String name;
  
  /// 描述
  final String? description;
  
  /// 纬度
  final double latitude;
  
  /// 经度
  final double longitude;
  
  /// 海拔(米)
  final double? altitude;
  
  /// 类型
  final String type;
  
  /// 图片URL
  final List<String> photos;
  
  /// 构造函数
  CustomWaypointModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.type,
    List<String>? photos,
  }) : this.photos = photos ?? const [];
  
  /// 从JSON创建
  factory CustomWaypointModel.fromJson(Map<String, dynamic> json) => _$CustomWaypointModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$CustomWaypointModelToJson(this);
}

/// 清单模型
@JsonSerializable()
class ChecklistModel {
  /// 清单项
  final List<ChecklistItemModel> items;
  
  /// 完成进度
  final double progress;
  
  /// 构造函数
  ChecklistModel({
    List<ChecklistItemModel>? items,
    this.progress = 0.0,
  }) : this.items = items ?? const [];
  
  /// 从JSON创建
  factory ChecklistModel.fromJson(Map<String, dynamic> json) => _$ChecklistModelFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ChecklistModelToJson(this);
  
  /// 计算完成进度
  double calculateProgress() {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.completed).length;
    return completedCount / items.length;
  }
  
  /// 创建副本并更新进度
  ChecklistModel copyWithUpdatedProgress() {
    return ChecklistModel(
      items: items,
      progress: calculateProgress(),
    );
  }
}

/// 清单项模型
@JsonSerializable()
class ChecklistItemModel {
  /// 标题
  final String title;
  
  /// 描述
  final String? description;
  
  /// 是否完成
  final bool completed;
  
  /// 优先级(1-5)
  final int priority;
  
  /// 构造函数
  ChecklistItemModel({
    required this.title,
    this.description,
    this.completed = false,
    this.priority = 3,
  });
  
  /// 从JSON创建
  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) => _$ChecklistItemModelFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ChecklistItemModelToJson(this);
  
  /// 创建已完成副本
  ChecklistItemModel copyWithCompleted(bool completed) {
    return ChecklistItemModel(
      title: title,
      description: description,
      completed: completed,
      priority: priority,
    );
  }
}
