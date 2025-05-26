/// 装备模型类
///
/// 用于存储装备清单、分类和项目信息

import '../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'equipment_item_model.dart';
import 'equipment_necessity.dart';
import 'equipment_list_type.dart';
import 'equipment_list_status.dart';

part 'equipment_list_model.g.dart';

/// 装备季节适用性
enum SeasonSuitability { spring, summer, autumn, winter, allSeasons }

/// 装备清单模型
@JsonSerializable(fieldRename: FieldRename.snake)
class EquipmentListModel extends BaseModel {
  /// 清单名称
  final String name;

  /// 清单描述
  final String description;

  /// 清单类型
  @JsonKey(fromJson: _listTypeFromJson, toJson: _listTypeToJson)
  final EquipmentListType type;

  /// 路线ID
  final String? routeId;

  /// 路线名称
  final String? routeName;

  /// 行程ID
  final String? tripId;

  /// 行程天数
  final int tripDays;

  /// 适用人数
  final int personCount;

  /// 季节
  @JsonKey(fromJson: _seasonsFromJson, toJson: _seasonsToJson)
  final List<SeasonSuitability> seasons;

  /// 装备列表
  @JsonKey(fromJson: _equipmentsFromJson, toJson: _equipmentsToJson)
  final List<EquipmentItemModel> equipments;

  /// 总重量(g)
  final double totalWeight;

  /// 基础重量(g)
  final double baseWeight;

  /// 消耗品重量(g)
  final double consumableWeight;

  /// 穿着重量(g)
  final double wornWeight;

  /// 创建者ID
  final String creatorId;

  /// 创建者名称
  final String creatorName;

  /// 标签
  final List<String> tags;

  /// 是否官方推荐
  final bool isOfficial;

  /// 是否为模板
  final bool isTemplate;

  /// 模板ID (如果是从模板创建)
  final String? templateId;

  /// 状态
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final EquipmentListStatus status;

  /// 最后使用时间
  final DateTime? lastUsedAt;

  /// 构造函数
  EquipmentListModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    this.type = EquipmentListType.custom,
    this.routeId,
    this.routeName,
    this.tripId,
    required this.tripDays,
    this.personCount = 1,
    required this.seasons,
    required this.equipments,
    required this.totalWeight,
    required this.baseWeight,
    required this.consumableWeight,
    required this.wornWeight,
    required this.creatorId,
    required this.creatorName,
    required this.tags,
    this.isOfficial = false,
    this.isTemplate = false,
    this.templateId,
    this.status = EquipmentListStatus.planning,
    this.lastUsedAt,
  });

  /// 从JSON创建
  factory EquipmentListModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentListModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentListModelToJson(this);

  /// 季节列表从JSON转换
  static List<SeasonSuitability> _seasonsFromJson(List<dynamic> list) {
    return list.map((i) => SeasonSuitability.values[i as int]).toList();
  }

  /// 季节列表转JSON
  static List<int> _seasonsToJson(List<SeasonSuitability> seasons) {
    return seasons.map((e) => e.index).toList();
  }

  /// 装备列表从JSON转换
  static List<EquipmentItemModel> _equipmentsFromJson(List<dynamic> list) {
    return list
        .map((i) => EquipmentItemModel.fromJson(i as Map<String, dynamic>))
        .toList();
  }

  /// 装备列表转JSON
  static List<Map<String, dynamic>> _equipmentsToJson(
      List<EquipmentItemModel> equipments) {
    return equipments.map((e) => e.toJson()).toList();
  }

  /// 清单类型从JSON转换
  static EquipmentListType _listTypeFromJson(dynamic type) {
    if (type is String) {
      return parseListTypeFromString(type);
    } else if (type is int &&
        type >= 0 &&
        type < EquipmentListType.values.length) {
      return EquipmentListType.values[type];
    }
    return EquipmentListType.custom;
  }

  /// 清单类型转JSON
  static String _listTypeToJson(EquipmentListType type) {
    return getListTypeName(type);
  }

  /// 清单状态从JSON转换
  static EquipmentListStatus _statusFromJson(dynamic status) {
    if (status is String) {
      return parseListStatusFromString(status);
    } else if (status is int &&
        status >= 0 &&
        status < EquipmentListStatus.values.length) {
      return EquipmentListStatus.values[status];
    }
    return EquipmentListStatus.planning;
  }

  /// 清单状态转JSON
  static String _statusToJson(EquipmentListStatus status) {
    return getListStatusName(status);
  }

  /// 获取每人每日平均重量
  double get weightPerPersonPerDay => totalWeight / (tripDays * personCount);

  /// 获取总装备数
  int get totalItems => equipments.length;

  /// 获取必需装备数
  int get essentialItems => equipments
      .where((item) => item.necessity == EquipmentNecessity.essential)
      .length;

  /// 获取推荐装备数
  int get recommendedItems => equipments
      .where((item) => item.necessity == EquipmentNecessity.recommended)
      .length;

  /// 获取可选装备数
  int get optionalItems => equipments
      .where((item) => item.necessity == EquipmentNecessity.optional)
      .length;

  /// 获取已准备装备数
  int get preparedItems => equipments.where((item) => item.prepared).length;

  /// 获取装备准备进度百分比
  double get preparationPercentage =>
      equipments.isEmpty ? 0 : (preparedItems / totalItems) * 100;

  /// 获取所有装备项目列表
  List<EquipmentItemModel> get allItems => List.from(equipments);

  /// 获取季节名称列表
  List<String> getSeasonNames() {
    final seasonNames = <String>[];
    for (final season in seasons) {
      switch (season) {
        case SeasonSuitability.spring:
          seasonNames.add('春季');
          break;
        case SeasonSuitability.summer:
          seasonNames.add('夏季');
          break;
        case SeasonSuitability.autumn:
          seasonNames.add('秋季');
          break;
        case SeasonSuitability.winter:
          seasonNames.add('冬季');
          break;
        case SeasonSuitability.allSeasons:
          seasonNames.add('四季');
          break;
      }
    }
    return seasonNames;
  }

  /// 获取装备总价值
  double get totalValue => equipments.fold(
      0, (sum, item) => sum + (item.price ?? 0) * item.quantity);

  /// 获取已拥有装备数量
  int get ownedItems => equipments.where((item) => item.isOwned).length;

  /// 获取需要购买的装备数量
  int get itemsToBuy => equipments.where((item) => !item.isOwned).length;

  /// 获取需要购买的装备总价值
  double get valueToBuy => equipments
      .where((item) => !item.isOwned)
      .fold(0, (sum, item) => sum + (item.price ?? 0) * item.quantity);

  /// 获取清单类型名称
  String getTypeText() {
    return getListTypeName(type);
  }

  /// 获取清单状态名称
  String getStatusText() {
    return getListStatusName(status);
  }

  /// 创建副本并更新指定字段
  EquipmentListModel copyWith({
    String? id,
    String? name,
    String? description,
    EquipmentListType? type,
    String? routeId,
    String? routeName,
    String? tripId,
    int? tripDays,
    int? personCount,
    List<SeasonSuitability>? seasons,
    List<EquipmentItemModel>? equipments,
    double? totalWeight,
    double? baseWeight,
    double? consumableWeight,
    double? wornWeight,
    String? creatorId,
    String? creatorName,
    List<String>? tags,
    bool? isOfficial,
    bool? isTemplate,
    String? templateId,
    EquipmentListStatus? status,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      tripId: tripId ?? this.tripId,
      tripDays: tripDays ?? this.tripDays,
      personCount: personCount ?? this.personCount,
      seasons: seasons ?? this.seasons,
      equipments: equipments ?? this.equipments,
      totalWeight: totalWeight ?? this.totalWeight,
      baseWeight: baseWeight ?? this.baseWeight,
      consumableWeight: consumableWeight ?? this.consumableWeight,
      wornWeight: wornWeight ?? this.wornWeight,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      tags: tags ?? this.tags,
      isOfficial: isOfficial ?? this.isOfficial,
      isTemplate: isTemplate ?? this.isTemplate,
      templateId: templateId ?? this.templateId,
      status: status ?? this.status,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
