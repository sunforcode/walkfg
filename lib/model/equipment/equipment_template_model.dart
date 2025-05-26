import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/equipment/equipment_category.dart';
import '../base/base_model.dart';
import 'equipment_item_model.dart';
import 'equipment_list_model.dart';
import 'equipment_list_type.dart';
import 'equipment_list_status.dart';

part 'equipment_template_model.g.dart';

/// 装备模板模型
@JsonSerializable()
class EquipmentTemplateModel extends BaseModel {
  /// 模板名称
  final String name;

  /// 模板描述
  final String description;

  /// 模板类型
  @JsonKey(fromJson: _listTypeFromJson, toJson: _listTypeToJson)
  final EquipmentListType type;

  /// 适用季节
  @JsonKey(fromJson: _seasonsFromJson, toJson: _seasonsToJson)
  final List<SeasonSuitability> seasons;

  /// 装备项目列表
  @JsonKey(fromJson: _equipmentsFromJson, toJson: _equipmentsToJson)
  final List<EquipmentItemModel> equipments;

  /// 标签列表
  final List<String> tags;

  /// 是否官方模板
  final bool isOfficial;

  /// 创建者ID
  final String creatorId;

  /// 创建者名称
  final String creatorName;

  /// 使用次数
  final int usageCount;

  /// 评分 (1-5)
  final double rating;

  /// 构造函数
  EquipmentTemplateModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.type,
    required this.seasons,
    required this.equipments,
    required this.tags,
    this.isOfficial = false,
    required this.creatorId,
    required this.creatorName,
    this.usageCount = 0,
    this.rating = 0,
  });

  /// 从JSON创建
  factory EquipmentTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentTemplateModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentTemplateModelToJson(this);

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

  /// 获取总装备数
  int get totalItems => equipments.length;

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

  /// 获取清单类型名称
  String getTypeText() {
    return getListTypeName(type);
  }

  /// 从模板创建装备清单
  EquipmentListModel createEquipmentList({
    required String id,
    required String creatorId,
    required String creatorName,
    String? routeId,
    String? routeName,
    String? tripId,
    required int tripDays,
    int personCount = 1,
  }) {
    // 计算重量
    double totalWeight = 0;
    double baseWeight = 0;
    double consumableWeight = 0;
    double wornWeight = 0;

    // 复制装备项目并计算重量
    final equipmentsCopy = equipments.map((item) {
      final itemCopy = item.copyWith(
        id: '${id}_${item.id}',
        prepared: false,
      );

      // 计算重量
      totalWeight += itemCopy.totalWeight;

      // 根据分类计算不同类型的重量
      if (itemCopy.category == EquipmentCategory.food) {
        consumableWeight += itemCopy.totalWeight;
      } else if (itemCopy.category == EquipmentCategory.clothing) {
        wornWeight += itemCopy.totalWeight;
      } else {
        baseWeight += itemCopy.totalWeight;
      }

      return itemCopy;
    }).toList();

    // 创建装备清单
    return EquipmentListModel(
      id: id,
      name: name,
      description: description,
      type: type,
      routeId: routeId,
      routeName: routeName,
      tripId: tripId,
      tripDays: tripDays,
      personCount: personCount,
      seasons: List.from(seasons),
      equipments: equipmentsCopy,
      totalWeight: totalWeight,
      baseWeight: baseWeight,
      consumableWeight: consumableWeight,
      wornWeight: wornWeight,
      creatorId: creatorId,
      creatorName: creatorName,
      tags: List.from(tags),
      isOfficial: false,
      isTemplate: false,
      templateId: this.id,
      status: EquipmentListStatus.planning,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 创建副本并更新指定字段
  EquipmentTemplateModel copyWith({
    String? id,
    String? name,
    String? description,
    EquipmentListType? type,
    List<SeasonSuitability>? seasons,
    List<EquipmentItemModel>? equipments,
    List<String>? tags,
    bool? isOfficial,
    String? creatorId,
    String? creatorName,
    int? usageCount,
    double? rating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EquipmentTemplateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      seasons: seasons ?? this.seasons,
      equipments: equipments ?? this.equipments,
      tags: tags ?? this.tags,
      isOfficial: isOfficial ?? this.isOfficial,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      usageCount: usageCount ?? this.usageCount,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
