import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import '../equipment/gear_recommendation_model.dart';

part 'user_gear_model.g.dart';

/// 用户装备库模型
@JsonSerializable()
class UserGearModel extends BaseModel {
  /// 用户ID
  final String userId;
  
  /// 装备列表
  final List<UserGearItemModel> gears;
  
  /// 构造函数
  UserGearModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.userId,
    List<UserGearItemModel>? gears,
  }) : this.gears = gears ?? const [];
  
  /// 从JSON创建
  factory UserGearModel.fromJson(Map<String, dynamic> json) => _$UserGearModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UserGearModelToJson(this);
  
  /// 获取总重量
  double get totalWeight => gears.fold(0, (sum, gear) => sum + gear.weight);
  
  /// 获取总价值
  double get totalValue => gears.fold(0, (sum, gear) => sum + (gear.price ?? 0));
  
  /// 按类别分组
  Map<String, List<UserGearItemModel>> getGearsByCategory() {
    final result = <String, List<UserGearItemModel>>{};
    
    for (final gear in gears) {
      if (!result.containsKey(gear.category)) {
        result[gear.category] = [];
      }
      result[gear.category]!.add(gear);
    }
    
    return result;
  }
}

/// 用户装备项目模型
@JsonSerializable()
class UserGearItemModel extends BaseModel {
  /// 类别
  final String category;
  
  /// 名称
  final String name;
  
  /// 品牌
  final String? brand;
  
  /// 型号
  final String? model;
  
  /// 重量(g)
  final double weight;
  
  /// 规格参数
  final Map<String, dynamic>? specifications;
  
  /// 状态
  final String condition;
  
  /// 购买日期
  final DateTime? purchaseDate;
  
  /// 价格
  final double? price;
  
  /// 备注
  final String? notes;
  
  /// 构造函数
  UserGearItemModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.category,
    required this.name,
    this.brand,
    this.model,
    required this.weight,
    this.specifications,
    required this.condition,
    this.purchaseDate,
    this.price,
    this.notes,
  });
  
  /// 从JSON创建
  factory UserGearItemModel.fromJson(Map<String, dynamic> json) => _$UserGearItemModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$UserGearItemModelToJson(this);
  
  /// 获取重量文本
  String getWeightText() {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)}kg';
    } else {
      return '${weight.toStringAsFixed(0)}g';
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
  
  /// 获取购买日期文本
  String? getPurchaseDateText() {
    if (purchaseDate == null) return null;
    return '${purchaseDate!.year}-${purchaseDate!.month.toString().padLeft(2, '0')}-${purchaseDate!.day.toString().padLeft(2, '0')}';
  }
  
  /// 从GearItemModel创建
  factory UserGearItemModel.fromGearItem(GearItemModel gearItem, {
    String? brand,
    String? model,
    double? weight,
    String condition = '良好',
    DateTime? purchaseDate,
    double? price,
    String? notes,
  }) {
    return UserGearItemModel(
      id: gearItem.id,
      category: gearItem.category,
      name: gearItem.name,
      brand: brand ?? gearItem.brand,
      model: model ?? gearItem.model,
      weight: weight ?? gearItem.weight.average.toDouble(),
      condition: condition,
      purchaseDate: purchaseDate,
      price: price ?? gearItem.estimatedCost.average.toDouble(),
      notes: notes ?? gearItem.notes,
    );
  }
}
