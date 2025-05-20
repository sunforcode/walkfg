import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base/base_model.dart';
import 'route/route_model.dart';
import 'equipment/equipment_model.dart' as equipment;

part 'trip_plan_model.g.dart';

/// 行程计划状态枚举
enum TripPlanStatus {
  /// 草稿
  draft,

  /// 已确认
  confirmed,

  /// 进行中
  inProgress,

  /// 已完成
  completed,

  /// 已取消
  cancelled,
}

/// 途经点类型枚举
enum WaypointType {
  /// 起点
  start,

  /// 终点
  end,

  /// 休息点
  rest,

  /// 观景点
  viewpoint,

  /// 水源点
  waterSource,

  /// 营地
  campsite,

  /// 其他
  other,
}

/// 交通方式类型枚举
enum TransportationType {
  /// 公共交通
  publicTransport,

  /// 包车
  privateCar,

  /// 自驾
  selfDriving,

  /// 其他
  other,
}

/// 交通模型
@JsonSerializable()
class TransportModel extends BaseModel {
  /// 交通方式
  final TransportationType type;

  /// 出发地点
  final String departureLocation;

  /// 到达地点
  final String arrivalLocation;

  /// 出发时间
  final DateTime departureTime;

  /// 到达时间
  final DateTime arrivalTime;

  /// 费用
  final double cost;

  /// 备注
  final String? notes;

  /// 构造函数
  TransportModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.type,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureTime,
    required this.arrivalTime,
    this.cost = 0.0,
    this.notes,
  });

  /// 从JSON创建
  factory TransportModel.fromJson(Map<String, dynamic> json) =>
      _$TransportModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TransportModelToJson(this);
}

/// 行程计划模型
@JsonSerializable()
class TripPlanModel extends BaseModel {
  /// 用户ID
  @JsonKey(name: 'user_id')
  final String userId;

  /// 路线ID
  @JsonKey(name: 'route_id')
  final String routeId;

  /// 路线名称
  @JsonKey(name: 'route_name')
  final String routeName;

  /// 出发日期
  @JsonKey(name: 'start_date')
  DateTime? startDate;

  /// 参与人数
  @JsonKey(name: 'participant_count')
  int participantCount;

  /// 出发城市
  @JsonKey(name: 'departure_city')
  String departureCity;

  /// 每日行程列表
  @JsonKey(name: 'customized_itinerary')
  List<DailyItinerary> customizedItinerary;

  /// 交通方案列表
  @JsonKey(name: 'transportation_plans')
  List<TransportationPlanModel> transportationPlans;

  /// 装备清单
  @JsonKey(name: 'equipment_list')
  List<EquipmentItemModel> equipmentList;

  /// 计划状态
  @JsonKey(fromJson: _parseStatus, toJson: _statusToJson)
  TripPlanStatus status;

  /// 到起点的交通
  @JsonKey(name: 'transport_to_start')
  List<TransportModel> transportToStart;

  /// 从终点返回的交通
  @JsonKey(name: 'transport_to_end')
  List<TransportModel> transportToEnd;

  /// 构造函数
  TripPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.userId,
    required this.routeId,
    required this.routeName,
    this.startDate,
    this.participantCount = 1,
    this.departureCity = '',
    List<DailyItinerary>? customizedItinerary,
    List<TransportationPlanModel>? transportationPlans,
    List<EquipmentItemModel>? equipmentList,
    this.status = TripPlanStatus.draft,
    List<TransportModel>? transportToStart,
    List<TransportModel>? transportToEnd,
  })  : this.customizedItinerary = customizedItinerary ?? [],
        this.transportationPlans = transportationPlans ?? [],
        this.equipmentList = equipmentList ?? [],
        this.transportToStart = transportToStart ?? [],
        this.transportToEnd = transportToEnd ?? [];

  /// 从JSON创建
  factory TripPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TripPlanModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TripPlanModelToJson(this);

  /// 解析状态
  static TripPlanStatus _parseStatus(dynamic status) {
    if (status is int && status >= 0 && status < TripPlanStatus.values.length) {
      return TripPlanStatus.values[status];
    }
    return TripPlanStatus.draft;
  }

  /// 状态转JSON
  static int _statusToJson(TripPlanStatus status) {
    return status.index;
  }

  /// 创建副本
  TripPlanModel copyWith({
    String? id,
    String? userId,
    String? routeId,
    String? routeName,
    DateTime? startDate,
    int? participantCount,
    String? departureCity,
    List<DailyItinerary>? customizedItinerary,
    List<TransportationPlanModel>? transportationPlans,
    List<EquipmentItemModel>? equipmentList,
    DateTime? lastEdited,
    TripPlanStatus? status,
    List<TransportModel>? transportToStart,
    List<TransportModel>? transportToEnd,
  }) {
    return TripPlanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      startDate: startDate ?? this.startDate,
      participantCount: participantCount ?? this.participantCount,
      departureCity: departureCity ?? this.departureCity,
      customizedItinerary:
          customizedItinerary ?? List.from(this.customizedItinerary),
      transportationPlans:
          transportationPlans ?? List.from(this.transportationPlans),
      equipmentList: equipmentList ?? List.from(this.equipmentList),
      status: status ?? this.status,
      transportToStart: transportToStart ?? List.from(this.transportToStart),
      transportToEnd: transportToEnd ?? List.from(this.transportToEnd),
    );
  }
}

/// 每日行程模型
@JsonSerializable()
class DailyItinerary {
  /// 起点
  final String startPoint;

  /// 终点
  final String endPoint;

  /// 距离(公里)
  final double distance;

  /// 累计上升(米)
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 累计下降(米)
  @JsonKey(name: 'elevation_loss')
  final int elevationLoss;

  /// 预计用时(小时)
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 途经点列表
  final List<WaypointModel> waypoints;

  /// 推荐营地
  @JsonKey(name: 'recommended_campsite')
  final CampSiteModel? recommendedCampsite;

  /// 备选营地列表
  @JsonKey(name: 'alternate_campsites')
  final List<CampSiteModel> alternateCampsites;

  /// 构造函数
  DailyItinerary({
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.estimatedTime,
    List<WaypointModel>? waypoints,
    this.recommendedCampsite,
    List<CampSiteModel>? alternateCampsites,
  })  : this.waypoints = waypoints ?? [],
        this.alternateCampsites = alternateCampsites ?? [];

  /// 从JSON创建
  factory DailyItinerary.fromJson(Map<String, dynamic> json) =>
      _$DailyItineraryFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DailyItineraryToJson(this);
}

/// 途经点模型
@JsonSerializable()
class WaypointModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔(米)
  final int elevation;

  /// 类型
  @JsonKey(fromJson: _parseWaypointType, toJson: _waypointTypeToJson)
  final WaypointType type;

  /// 预计到达时间
  @JsonKey(name: 'estimated_arrival_time')
  final String estimatedArrivalTime;

  /// 距起点距离(公里)
  @JsonKey(name: 'distance_from_start')
  double distanceFromStart;

  /// 距起点预计时间(分钟)
  @JsonKey(name: 'estimated_time_from_start')
  int estimatedTimeFromStart;

  /// 构造函数
  WaypointModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.type = WaypointType.other,
    this.estimatedArrivalTime = '',
    this.distanceFromStart = 0,
    this.estimatedTimeFromStart = 0,
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) =>
      _$WaypointModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$WaypointModelToJson(this);

  /// 解析途经点类型
  static WaypointType _parseWaypointType(dynamic type) {
    if (type is int && type >= 0 && type < WaypointType.values.length) {
      return WaypointType.values[type];
    }
    return WaypointType.other;
  }

  /// 途经点类型转JSON
  static int _waypointTypeToJson(WaypointType type) {
    return type.index;
  }
}

/// 营地模型
@JsonSerializable()
class CampSiteModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔(米)
  final int elevation;

  /// 容量(帐篷数)
  final int capacity;

  /// 水源距离(米)
  @JsonKey(name: 'water_source_distance')
  final int waterSourceDistance;

  /// 设施列表
  final List<String> facilities;

  /// 特点列表
  final List<String> features;

  /// 构造函数
  CampSiteModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.latitude,
    required this.longitude,
    required this.elevation,
    this.capacity = 0,
    this.waterSourceDistance = 0,
    List<String>? facilities,
    List<String>? features,
  })  : this.facilities = facilities ?? [],
        this.features = features ?? [];

  /// 从JSON创建
  factory CampSiteModel.fromJson(Map<String, dynamic> json) =>
      _$CampSiteModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CampSiteModelToJson(this);
}

/// 交通方案模型
@JsonSerializable()
class TransportationPlanModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 类型
  @JsonKey(
      fromJson: _parseTransportationType, toJson: _transportationTypeToJson)
  final TransportationType type;

  /// 出发地
  @JsonKey(name: 'departure_location')
  final String departureLocation;

  /// 目的地
  @JsonKey(name: 'arrival_location')
  final String arrivalLocation;

  /// 出发时间
  @JsonKey(name: 'departure_time')
  final String departureTime;

  /// 到达时间
  @JsonKey(name: 'arrival_time')
  final String arrivalTime;

  /// 费用
  final double cost;

  /// 描述
  final String description;

  /// 构造函数
  TransportationPlanModel({
    required this.id,
    required this.name,
    this.type = TransportationType.publicTransport,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureTime,
    required this.arrivalTime,
    this.cost = 0.0,
    this.description = '',
  });

  /// 从JSON创建
  factory TransportationPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TransportationPlanModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TransportationPlanModelToJson(this);

  /// 解析交通方式类型
  static TransportationType _parseTransportationType(dynamic type) {
    if (type is int && type >= 0 && type < TransportationType.values.length) {
      return TransportationType.values[type];
    }
    return TransportationType.other;
  }

  /// 交通方式类型转JSON
  static int _transportationTypeToJson(TransportationType type) {
    return type.index;
  }
}

/// 装备项目模型
///
/// 注意：这是一个简化版的装备项目模型，用于行程计划中
/// 完整版请使用 equipment.EquipmentItem
@JsonSerializable()
class EquipmentItemModel {
  /// ID
  final String id;

  /// 名称
  final String name;

  /// 类别
  final String category;

  /// 是否必备
  @JsonKey(name: 'is_essential')
  final bool isEssential;

  /// 描述
  final String description;

  /// 是否已准备
  @JsonKey(name: 'is_prepared')
  bool isPrepared;

  /// 推荐信息
  final String recommendation;

  /// 构造函数
  EquipmentItemModel({
    required this.id,
    required this.name,
    required this.category,
    this.isEssential = false,
    this.description = '',
    this.isPrepared = false,
    this.recommendation = '',
  });

  /// 从完整版装备项目创建
  factory EquipmentItemModel.fromEquipmentItem(equipment.EquipmentItem item) {
    return EquipmentItemModel(
      id: item.name.hashCode.toString(),
      name: item.name,
      category: item.brand ?? '未分类',
      isEssential: item.necessity == equipment.EquipmentNecessity.essential,
      description: item.description ?? '',
      isPrepared: false,
      recommendation: '',
    );
  }

  /// 从JSON创建
  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemModelFromJson(json);

  /// 转换为完整版装备项目
  equipment.EquipmentItem toEquipmentItem() {
    return equipment.EquipmentItem(
      name: name,
      description: description,
      weight: 0.0, // 默认值
      quantity: 1, // 默认值
      necessity: isEssential
          ? equipment.EquipmentNecessity.essential
          : equipment.EquipmentNecessity.optional,
      brand: category,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$EquipmentItemModelToJson(this);
}
