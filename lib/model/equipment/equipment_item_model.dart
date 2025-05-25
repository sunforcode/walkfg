import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'equipment_necessity.dart';

part 'equipment_item_model.g.dart';

/// 装备项目模型 - 统一的装备项目表示
@JsonSerializable(fieldRename: FieldRename.snake)
class EquipmentItemModel extends BaseModel {
  /// 名称
  final String name;

  /// 类别
  final String category;

  /// 描述
  final String? description;

  /// 重量(g)
  final double weight;

  /// 数量
  final int quantity;

  /// 必要性
  @JsonKey(
      name: 'is_essential',
      fromJson: _necessityFromJson,
      toJson: _necessityToJson)
  final EquipmentNecessity necessity;

  /// 是否已准备
  final bool prepared;

  /// 品牌
  final String? brand;

  /// 型号
  final String? model;

  /// 价格
  final double? price;

  /// 备注
  final String? notes;

  bool isOwned = true;

  /// 构造函数
  EquipmentItemModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.category,
    this.description,
    this.weight = 0,
    this.quantity = 1,
    this.necessity = EquipmentNecessity.recommended,
    this.prepared = false,
    this.brand,
    this.model,
    this.price,
    this.notes,
  });

  /// 从JSON创建
  factory EquipmentItemModel.fromJson(Map<String, dynamic> json) =>
      _$EquipmentItemModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$EquipmentItemModelToJson(this);

  /// 解析必要性
  static EquipmentNecessity _necessityFromJson(dynamic necessity) {
    if (necessity is int &&
        necessity >= 0 &&
        necessity < EquipmentNecessity.values.length) {
      return EquipmentNecessity.values[necessity];
    } else if (necessity is bool) {
      // 兼容旧版本的isEssential字段
      return necessity
          ? EquipmentNecessity.essential
          : EquipmentNecessity.recommended;
    }
    return EquipmentNecessity.recommended;
  }

  /// 必要性转JSON
  static int _necessityToJson(EquipmentNecessity necessity) {
    return necessity.index;
  }

  /// 获取总重量
  double get totalWeight => weight * quantity;

  /// 获取重量文本
  String getWeightText() {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
    }
  }

  /// 获取总重量文本
  String getTotalWeightText() {
    final total = totalWeight;
    if (total >= 1000) {
      return '${(total / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${total.toStringAsFixed(0)}g';
    }
  }

  /// 获取价格文本
  String? getPriceText() {
    if (price == null) return null;
    return '¥${price!.toStringAsFixed(2)}';
  }

  /// 获取品牌型号文本
  String? getBrandModelText() {
    if (brand != null && model != null) {
      return '$brand $model';
    } else if (brand != null) {
      return brand;
    } else if (model != null) {
      return model;
    } else {
      return null;
    }
  }

  /// 获取必要性名称
  String getNecessityText() {
    return getNecessityName(necessity);
  }

  /// 创建副本并更新部分属性
  EquipmentItemModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? category,
    String? description,
    double? weight,
    int? quantity,
    EquipmentNecessity? necessity,
    bool? prepared,
    String? brand,
    String? model,
    double? price,
    String? notes,
  }) {
    return EquipmentItemModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      quantity: quantity ?? this.quantity,
      necessity: necessity ?? this.necessity,
      prepared: prepared ?? this.prepared,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      price: price ?? this.price,
      notes: notes ?? this.notes,
    );
  }

  /// 从TripGearItemModel创建（用于兼容旧代码）
  factory EquipmentItemModel.fromTripGearItem(Map<String, dynamic> json) {
    return EquipmentItemModel(
      id: json['id'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int? ?? 1,
      weight: (json['weight'] as int? ?? 0).toDouble(),
      prepared: json['prepared'] as bool? ?? false,
      notes: json['notes'] as String?,
      necessity: EquipmentNecessity.recommended,
    );
  }

  /// 从EquipmentItem创建（用于兼容旧代码）
  factory EquipmentItemModel.fromEquipmentItem(
      Map<String, dynamic> json, String id) {
    return EquipmentItemModel(
      id: id,
      name: json['name'] as String,
      category: 'Unknown', // 需要从外部传入
      description: json['description'] as String?,
      weight: (json['weight']).toDouble(),
      quantity: json['quantity'] as int,
      necessity: EquipmentNecessity.values[json['necessity'] as int],
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      price: json['price'] != null ? (json['price']).toDouble() : null,
      notes: json['notes'] as String?,
      prepared: false,
    );
  }
}
