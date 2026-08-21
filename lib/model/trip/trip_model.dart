import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/food/meal_plan_model.dart';
import 'package:walk/model/route/daily_plan_model.dart';
import 'package:walk/model/user/user_model.dart';
import 'package:walk/model/water/water_plan_model.dart';
import '../base/base_model.dart';

part 'trip_model.g.dart';

/// 行程状态枚举
enum TripStatus {
  /// 计划中
  planning,

  /// 进行中
  inProgress,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
  confirmed,
}

/// 行程模型 - 具体行程的规划和执行实体
@JsonSerializable()
class TripModel extends BaseModel {
  /// 名称
  String name;

  /// 描述
  String description;

  /// 开始日期
  @JsonKey(name: 'start_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  DateTime startDate;

  /// 结束日期
  @JsonKey(name: 'end_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  DateTime endDate;

  /// 状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  final TripStatus status;

  /// 路线ID列表
  @JsonKey(name: 'route_ids')
  final List<String> routeIds;

  /// 主路线ID
  @JsonKey(name: 'primary_route_id')
  final String? primaryRouteId;

  /// 参与者列表
  final List<UserModel> participants;

  /// 参与者数量
  @JsonKey(name: 'participant_count')
  final int participantCount;

  /// 组织者ID
  @JsonKey(name: 'organizer_id')
  final String organizerId;

  /// 装备清单ID
  @JsonKey(name: 'equipment_list_id')
  final String? equipmentListId;

  /// 食物计划ID
  @JsonKey(name: 'meal_plan_id')
  final String? mealPlanId;

  /// 食物计划
  @JsonKey(name: 'meal_plan')
  final MealPlanModel? mealPlan;

  /// 饮水计划ID
  @JsonKey(name: 'water_plan_id')
  final String? waterPlanId;

  /// 饮水计划
  @JsonKey(name: 'water_plan')
  final WaterPlanModel? waterPlan;

  /// 行程安排
  final List<DailyPlanModel> itinerary;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String>? imageUrls;

  /// 预算（元）
  final double? budget;

  /// 实际花费（元）
  @JsonKey(name: 'actual_cost')
  final double? actualCost;

  /// 备注
  String? notes;

  /// 隐私设置（公开、私密等）
  @JsonKey(name: 'privacy_setting')
  final String privacySetting;

  /// 构造函数
  TripModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    List<String>? routeIds,
    this.primaryRouteId,
    List<UserModel>? participants,
    required this.participantCount,
    required this.organizerId,
    this.equipmentListId,
    this.mealPlanId,
    this.mealPlan,
    this.waterPlanId,
    this.waterPlan,
    List<DailyPlanModel>? itinerary,
    this.coverUrl,
    this.imageUrls,
    this.budget,
    this.actualCost,
    this.notes,
    required this.privacySetting,
  })  : routeIds = routeIds ?? const [],
        this.participants = participants ?? const [],
        this.itinerary = itinerary ?? const [];

  /// 从JSON创建
  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TripModelToJson(this);

  /// 解析状态
  static TripStatus _parseStatus(dynamic status) {
    if (status is int && status >= 0 && status < TripStatus.values.length) {
      return TripStatus.values[status];
    } else if (status is String) {
      switch (status.toLowerCase()) {
        case 'planning':
          return TripStatus.planning;
        case 'in_progress':
        case 'inprogress':
          return TripStatus.inProgress;
        case 'completed':
          return TripStatus.completed;
        case 'cancelled':
          return TripStatus.cancelled;
        case 'confirmed':
          return TripStatus.confirmed;
        default:
          return TripStatus.planning;
      }
    }
    return TripStatus.planning;
  }

  /// 状态转JSON
  static int _statusToJson(TripStatus status) {
    return status.index;
  }

  /// 获取状态名称
  String getStatusName() {
    switch (status) {
      case TripStatus.planning:
        return '计划中';
      case TripStatus.inProgress:
        return '进行中';
      case TripStatus.completed:
        return '已完成';
      case TripStatus.cancelled:
        return '已取消';
      case TripStatus.confirmed:
        return '已确认';
    }
  }

  /// 创建副本并更新部分属性
  TripModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    TripStatus? status,
    List<String>? routeIds,
    String? primaryRouteId,
    List<UserModel>? participants,
    int? participantCount,
    String? organizerId,
    String? equipmentListId,
    String? mealPlanId,
    MealPlanModel? mealPlan,
    String? waterPlanId,
    WaterPlanModel? waterPlan,
    List<DailyPlanModel>? itinerary,
    String? coverUrl,
    List<String>? imageUrls,
    double? budget,
    double? actualCost,
    String? notes,
    String? privacySetting,
  }) {
    return TripModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      routeIds: routeIds ?? this.routeIds,
      primaryRouteId: primaryRouteId ?? this.primaryRouteId,
      participants: participants ?? this.participants,
      participantCount: participantCount ?? this.participantCount,
      organizerId: organizerId ?? this.organizerId,
      equipmentListId: equipmentListId ?? this.equipmentListId,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlan: mealPlan ?? this.mealPlan,
      waterPlanId: waterPlanId ?? this.waterPlanId,
      waterPlan: waterPlan ?? this.waterPlan,
      itinerary: itinerary ?? this.itinerary,
      coverUrl: coverUrl ?? this.coverUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      notes: notes ?? this.notes,
      privacySetting: privacySetting ?? this.privacySetting,
    );
  }

  /// 获取食物计划（优先返回完整模型，如果不存在则返回null）
  MealPlanModel? getMealPlan() {
    return mealPlan;
  }

  /// 获取饮水计划（优先返回完整模型，如果不存在则返回null）
  WaterPlanModel? getWaterPlan() {
    return waterPlan;
  }

  /// 检查是否有完整的食物计划
  bool hasMealPlan() {
    return mealPlan != null;
  }

  /// 检查是否有完整的饮水计划
  bool hasWaterPlan() {
    return waterPlan != null;
  }
}
