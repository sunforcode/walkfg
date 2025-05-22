import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/equipment/equipment_model.dart';
import 'package:walk/model/model/food/meal_plan_model.dart';
import 'package:walk/model/model/water/water_plan_model.dart';
import '../../base/base_model.dart';

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
}

/// 参与者模型
@JsonSerializable()
class ParticipantModel {
  /// ID
  final String id;

  /// 用户ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// 姓名
  final String name;

  /// 角色（组织者、参与者等）
  final String role;

  /// 状态（已确认、待确认等）
  final String status;

  /// 联系方式
  final String? contact;

  /// 备注
  final String? notes;

  /// 构造函数
  ParticipantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.role,
    required this.status,
    this.contact,
    this.notes,
  });

  /// 从JSON创建
  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ParticipantModelToJson(this);
}

/// 食物项模型

/// 行程日程项模型
@JsonSerializable()
class ItineraryDayModel {
  /// ID
  final String id;

  /// 天数
  @JsonKey(name: 'day_number')
  final int dayNumber;

  /// 日期
  final DateTime date;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 路线ID
  @JsonKey(name: 'route_id')
  final String? routeId;

  /// 路线每日计划ID
  @JsonKey(name: 'daily_plan_id')
  final String? dailyPlanId;

  /// 住宿
  final String? accommodation;

  /// 交通
  final String? transportation;

  /// 餐饮
  final String? meals;

  /// 活动
  final List<String>? activities;

  /// 备注
  final String? notes;

  /// 构造函数
  ItineraryDayModel({
    required this.id,
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.description,
    this.routeId,
    this.dailyPlanId,
    this.accommodation,
    this.transportation,
    this.meals,
    this.activities,
    this.notes,
  });

  /// 从JSON创建
  factory ItineraryDayModel.fromJson(Map<String, dynamic> json) =>
      _$ItineraryDayModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$ItineraryDayModelToJson(this);
}

/// 行程日志条目模型
@JsonSerializable()
class TripLogEntryModel {
  /// ID
  final String id;

  /// 时间戳
  final DateTime timestamp;

  /// 标题
  final String title;

  /// 内容
  final String content;

  /// 类型（日记、笔记、警告等）
  final String type;

  /// 位置
  final String? location;

  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String>? imageUrls;

  /// 构造函数
  TripLogEntryModel({
    required this.id,
    required this.timestamp,
    required this.title,
    required this.content,
    required this.type,
    this.location,
    this.imageUrls,
  });

  /// 从JSON创建
  factory TripLogEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TripLogEntryModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TripLogEntryModelToJson(this);
}

/// 行程模型 - 具体行程的规划和执行实体
@JsonSerializable()
class TripModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 开始日期
  @JsonKey(name: 'start_date')
  final DateTime startDate;

  /// 结束日期
  @JsonKey(name: 'end_date')
  final DateTime endDate;

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
  final List<ParticipantModel> participants;

  /// 参与者数量
  @JsonKey(name: 'participant_count')
  final int participantCount;

  /// 组织者ID
  @JsonKey(name: 'organizer_id')
  final String organizerId;

  /// 装备清单ID
  @JsonKey(name: 'equipment_list_id')
  final String? equipmentListId;

  /// 装备清单
  @JsonKey(name: 'equipment_list')
  final EquipmentListModel? equipmentList;

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
  final List<ItineraryDayModel> itinerary;

  /// 行程日志
  @JsonKey(name: 'log_entries')
  final List<TripLogEntryModel>? logEntries;

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
  final String? notes;

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
    List<ParticipantModel>? participants,
    required this.participantCount,
    required this.organizerId,
    this.equipmentListId,
    this.equipmentList,
    this.mealPlanId,
    this.mealPlan,
    this.waterPlanId,
    this.waterPlan,
    List<ItineraryDayModel>? itinerary,
    this.logEntries,
    this.coverUrl,
    this.imageUrls,
    this.budget,
    this.actualCost,
    this.notes,
    required this.privacySetting,
  })  : this.routeIds = routeIds ?? const [],
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
    List<ParticipantModel>? participants,
    int? participantCount,
    String? organizerId,
    String? equipmentListId,
    EquipmentListModel? equipmentList,
    String? mealPlanId,
    MealPlanModel? mealPlan,
    String? waterPlanId,
    WaterPlanModel? waterPlan,
    List<ItineraryDayModel>? itinerary,
    List<TripLogEntryModel>? logEntries,
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
      equipmentList: equipmentList ?? this.equipmentList,
      mealPlanId: mealPlanId ?? this.mealPlanId,
      mealPlan: mealPlan ?? this.mealPlan,
      waterPlanId: waterPlanId ?? this.waterPlanId,
      waterPlan: waterPlan ?? this.waterPlan,
      itinerary: itinerary ?? this.itinerary,
      logEntries: logEntries ?? this.logEntries,
      coverUrl: coverUrl ?? this.coverUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      notes: notes ?? this.notes,
      privacySetting: privacySetting ?? this.privacySetting,
    );
  }

  /// 获取装备清单（优先返回完整模型，如果不存在则返回null）
  EquipmentListModel? getEquipmentList() {
    return equipmentList;
  }

  /// 获取食物计划（优先返回完整模型，如果不存在则返回null）
  MealPlanModel? getMealPlan() {
    return mealPlan;
  }

  /// 获取饮水计划（优先返回完整模型，如果不存在则返回null）
  WaterPlanModel? getWaterPlan() {
    return waterPlan;
  }

  /// 检查是否有完整的装备清单
  bool hasEquipmentList() {
    return equipmentList != null;
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
