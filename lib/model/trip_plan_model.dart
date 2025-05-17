import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'route/route_model.dart';

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

class TransportModel {}

/// 行程计划模型
class TripPlanModel {
  /// ID
  final String id;

  List<TransportModel> transportToStart = [];

  List<TransportModel> transportToEnd = [];

  /// 用户ID
  final String userId;

  /// 路线ID
  final String routeId;

  /// 路线名称
  final String routeName;

  /// 出发日期
  DateTime? startDate;

  /// 参与人数
  int participantCount;

  /// 出发城市
  String departureCity;

  /// 每日行程列表
  List<DailyItinerary> customizedItinerary;

  /// 交通方案列表
  List<TransportationPlanModel> transportationPlans;

  /// 装备清单
  List<EquipmentItemModel> equipmentList;

  /// 最后编辑时间
  final DateTime lastEdited;

  /// 计划状态
  TripPlanStatus status;

  /// 构造函数
  TripPlanModel({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.routeName,
    this.startDate,
    this.participantCount = 1,
    this.departureCity = '',
    List<DailyItinerary>? customizedItinerary,
    List<TransportationPlanModel>? transportationPlans,
    List<EquipmentItemModel>? equipmentList,
    DateTime? lastEdited,
    this.status = TripPlanStatus.draft,
  })  : this.customizedItinerary = customizedItinerary ?? [],
        this.transportationPlans = transportationPlans ?? [],
        this.equipmentList = equipmentList ?? [],
        this.lastEdited = lastEdited ?? DateTime.now();

  /// 从JSON创建
  factory TripPlanModel.fromJson(Map<String, dynamic> json) {
    return TripPlanModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      routeId: json['routeId'] as String,
      routeName: json['routeName'] as String,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      participantCount: json['participantCount'] as int,
      departureCity: json['departureCity'] as String,
      customizedItinerary: (json['customizedItinerary'] as List?)
              ?.map((e) => DailyItinerary.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      transportationPlans: (json['transportationPlans'] as List?)
              ?.map((e) =>
                  TransportationPlanModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      equipmentList: (json['equipmentList'] as List?)
              ?.map(
                  (e) => EquipmentItemModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastEdited: DateTime.parse(json['lastEdited'] as String),
      status: TripPlanStatus.values[json['status'] as int],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'routeId': routeId,
      'routeName': routeName,
      'startDate': startDate?.toIso8601String(),
      'participantCount': participantCount,
      'departureCity': departureCity,
      'customizedItinerary':
          customizedItinerary.map((e) => e.toJson()).toList(),
      'transportationPlans':
          transportationPlans.map((e) => e.toJson()).toList(),
      'equipmentList': equipmentList.map((e) => e.toJson()).toList(),
      'lastEdited': lastEdited.toIso8601String(),
      'status': status.index,
    };
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
      lastEdited: lastEdited ?? DateTime.now(),
      status: status ?? this.status,
    );
  }
}

/// 每日行程模型
class DailyItinerary {
  /// 起点
  String startPoint;

  /// 终点
  String endPoint;

  /// 距离(公里)
  double distance;

  /// 累计上升(米)
  int elevationGain;

  /// 累计下降(米)
  int elevationLoss;

  /// 预计用时(小时)
  double estimatedTime;

  /// 途经点列表
  List<WaypointModel> waypoints;

  /// 推荐营地
  CampSiteModel? recommendedCampsite;

  /// 备选营地列表
  List<CampSiteModel> alternateCampsites;

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
  factory DailyItinerary.fromJson(Map<String, dynamic> json) {
    return DailyItinerary(
      startPoint: json['startPoint'] as String,
      endPoint: json['endPoint'] as String,
      distance: json['distance'] as double,
      elevationGain: json['elevationGain'] as int,
      elevationLoss: json['elevationLoss'] as int,
      estimatedTime: json['estimatedTime'] as double,
      waypoints: (json['waypoints'] as List?)
              ?.map((e) => WaypointModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedCampsite: json['recommendedCampsite'] != null
          ? CampSiteModel.fromJson(
              json['recommendedCampsite'] as Map<String, dynamic>)
          : null,
      alternateCampsites: (json['alternateCampsites'] as List?)
              ?.map((e) => CampSiteModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'startPoint': startPoint,
      'endPoint': endPoint,
      'distance': distance,
      'elevationGain': elevationGain,
      'elevationLoss': elevationLoss,
      'estimatedTime': estimatedTime,
      'waypoints': waypoints.map((e) => e.toJson()).toList(),
      'recommendedCampsite': recommendedCampsite?.toJson(),
      'alternateCampsites': alternateCampsites.map((e) => e.toJson()).toList(),
    };
  }
}

/// 途经点模型
class WaypointModel {
  /// ID
  final String id;

  /// 名称
  String name;

  /// 描述
  String description;

  /// 纬度
  double latitude;

  /// 经度
  double longitude;

  /// 海拔(米)
  int elevation;

  /// 类型
  WaypointType type;

  /// 预计到达时间
  String estimatedArrivalTime;

  double distanceFromStart = 0;

  int estimatedTimeFromStart = 0;

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
  });

  /// 从JSON创建
  factory WaypointModel.fromJson(Map<String, dynamic> json) {
    return WaypointModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      elevation: json['elevation'] as int,
      type: WaypointType.values[json['type'] as int],
      estimatedArrivalTime: json['estimatedArrivalTime'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'type': type.index,
      'estimatedArrivalTime': estimatedArrivalTime,
    };
  }
}

/// 营地模型
class CampSiteModel {
  /// ID
  final String id;

  /// 名称
  String name;

  /// 描述
  String description;

  /// 纬度
  double latitude;

  /// 经度
  double longitude;

  /// 海拔(米)
  int elevation;

  /// 容量(帐篷数)
  int capacity;

  /// 水源距离(米)
  int waterSourceDistance;

  /// 设施列表
  List<String> facilities;

  /// 特点列表
  List<String> features;

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
  factory CampSiteModel.fromJson(Map<String, dynamic> json) {
    return CampSiteModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      elevation: json['elevation'] as int,
      capacity: json['capacity'] as int,
      waterSourceDistance: json['waterSourceDistance'] as int,
      facilities:
          (json['facilities'] as List?)?.map((e) => e as String).toList() ?? [],
      features:
          (json['features'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'elevation': elevation,
      'capacity': capacity,
      'waterSourceDistance': waterSourceDistance,
      'facilities': facilities,
      'features': features,
    };
  }
}

/// 交通方案模型
class TransportationPlanModel {
  /// ID
  final String id;

  /// 名称
  String name;

  /// 类型
  TransportationType type;

  /// 出发地
  String departureLocation;

  /// 目的地
  String arrivalLocation;

  /// 出发时间
  String departureTime;

  /// 到达时间
  String arrivalTime;

  /// 费用
  double cost;

  /// 描述
  String description;

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
  factory TransportationPlanModel.fromJson(Map<String, dynamic> json) {
    return TransportationPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: TransportationType.values[json['type'] as int],
      departureLocation: json['departureLocation'] as String,
      arrivalLocation: json['arrivalLocation'] as String,
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
      cost: json['cost'] as double,
      description: json['description'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.index,
      'departureLocation': departureLocation,
      'arrivalLocation': arrivalLocation,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'cost': cost,
      'description': description,
    };
  }
}

/// 装备项模型
class EquipmentItemModel {
  /// ID
  final String id;

  /// 名称
  String name;

  /// 类别
  String category;

  /// 是否必备
  bool isEssential;

  /// 描述
  String description;

  /// 是否已准备
  bool isPrepared;

  String recommendation;

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

  /// 从JSON创建
  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) {
    return EquipmentItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      isEssential: json['isEssential'] as bool,
      description: json['description'] as String,
      isPrepared: json['isPrepared'] as bool,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'isEssential': isEssential,
      'description': description,
      'isPrepared': isPrepared,
    };
  }
}
