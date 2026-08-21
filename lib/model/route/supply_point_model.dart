import 'package:json_annotation/json_annotation.dart';
import '../map/track_point_model.dart';
import 'package:walk/utils/json_utils.dart';

part 'supply_point_model.g.dart';

/// 补给点类型枚举
enum SupplyPointType {
  /// 综合商店
  store,

  /// 小卖部
  shop,

  /// 餐厅
  restaurant,

  /// 住宿
  accommodation,

  /// 加油站
  gasStation,

  /// 医疗点
  medical,

  /// 其他
  other,
}

/// 补给点模型 - 继承TrackPointVO并扩展补给点特有信息
@JsonSerializable()
class SupplyPointModel extends TrackPointVO {
  /// 唯一标识
  final String id;

  /// 补给点名称
  final String? name;

  /// 补给点描述
  final String? description;

  /// 创建时间
  @JsonKey(
      name: 'created_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(
      name: 'updated_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? updatedAt;

  /// 最后确认时间
  @JsonKey(name: 'last_verified')
  final String? lastVerified;

  /// 补给点类型
  @JsonKey(
      name: 'supply_type',
      fromJson: _parseSupplyType,
      toJson: _supplyTypeToJson)
  final SupplyPointType supplyType;

  /// 更新者ID
  @JsonKey(name: 'updated_by')
  final String? updatedBy;

  /// 构造函数
  SupplyPointModel({
    required this.id,
    required super.latitude,
    required super.longitude,
    super.elevation,
    super.timestamp,
    super.distanceFromStart,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.lastVerified,
    this.supplyType = SupplyPointType.other,
    this.updatedBy,
  });

  /// 从JSON创建
  factory SupplyPointModel.fromJson(Map<String, dynamic> json) =>
      _$SupplyPointModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$SupplyPointModelToJson(this);

  /// 创建副本并更新指定字段
  @override
  SupplyPointModel copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? elevation,
    String? name,
    String? description,
    String? type,
    int? sequenceNumber,
    String? iconUrl,
    String? imageUrl,
    DateTime? timestamp,
    double? distanceFromStart,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastVerified,
    SupplyPointType? supplyType,
    String? updatedBy,
  }) {
    return SupplyPointModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      elevation: elevation ?? this.elevation,
      timestamp: timestamp ?? this.timestamp,
      distanceFromStart: distanceFromStart ?? this.distanceFromStart,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastVerified: lastVerified ?? this.lastVerified,
      supplyType: supplyType ?? this.supplyType,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  // ========== 便捷访问方法 ==========

  /// 获取类型显示文本
  String get typeText {
    switch (supplyType) {
      case SupplyPointType.store:
        return '综合商店';
      case SupplyPointType.shop:
        return '小卖部';
      case SupplyPointType.restaurant:
        return '餐厅';
      case SupplyPointType.accommodation:
        return '住宿';
      case SupplyPointType.gasStation:
        return '加油站';
      case SupplyPointType.medical:
        return '医疗点';
      case SupplyPointType.other:
        return '其他';
    }
  }

  /// 获取类型图标
  String get typeIcon {
    switch (supplyType) {
      case SupplyPointType.store:
        return '🏪';
      case SupplyPointType.shop:
        return '🏬';
      case SupplyPointType.restaurant:
        return '🍽️';
      case SupplyPointType.accommodation:
        return '🏨';
      case SupplyPointType.gasStation:
        return '⛽';
      case SupplyPointType.medical:
        return '🏥';
      case SupplyPointType.other:
        return '📍';
    }
  }

  @override
  String toString() {
    return 'SupplyPointModel(id: $id, name: $name, type: $typeText, location: $latitude, $longitude)';
  }
}

/// 解析补给点类型
SupplyPointType _parseSupplyType(dynamic value) {
  if (value == null) return SupplyPointType.other;

  if (value is String) {
    switch (value.toLowerCase()) {
      case 'shop':
      case 'store':
        return SupplyPointType.store;
      case 'restaurant':
        return SupplyPointType.restaurant;
      case 'vending_machine':
        return SupplyPointType.shop;
      case 'emergency':
      case 'medical':
        return SupplyPointType.medical;
      case 'accommodation':
        return SupplyPointType.accommodation;
      case 'gas_station':
        return SupplyPointType.gasStation;
      case 'other':
      default:
        return SupplyPointType.other;
    }
  }

  if (value is int) {
    if (value >= 0 && value < SupplyPointType.values.length) {
      return SupplyPointType.values[value];
    }
    return SupplyPointType.other;
  }

  return SupplyPointType.other;
}

/// 补给点类型转JSON
String _supplyTypeToJson(SupplyPointType type) {
  switch (type) {
    case SupplyPointType.store:
      return 'store';
    case SupplyPointType.shop:
      return 'shop';
    case SupplyPointType.restaurant:
      return 'restaurant';
    case SupplyPointType.accommodation:
      return 'accommodation';
    case SupplyPointType.gasStation:
      return 'gas_station';
    case SupplyPointType.medical:
      return 'medical';
    case SupplyPointType.other:
      return 'other';
  }
}
