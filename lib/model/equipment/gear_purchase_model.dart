import 'package:json_annotation/json_annotation.dart';

part 'gear_purchase_model.g.dart';

/// 装备购买选项模型
@JsonSerializable()
class GearPurchaseOptionsModel {
  /// 装备ID
  final String gearId;
  
  /// 购买选项列表
  final List<PurchaseOptionModel> options;

  /// 构造函数
  GearPurchaseOptionsModel({
    required this.gearId,
    required this.options,
  });

  /// 从JSON创建
  factory GearPurchaseOptionsModel.fromJson(Map<String, dynamic> json) => _$GearPurchaseOptionsModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$GearPurchaseOptionsModelToJson(this);
  
  /// 获取最低价格选项
  PurchaseOptionModel? getLowestPriceOption() {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.price < b.price ? a : b);
  }
  
  /// 获取最快送达选项
  PurchaseOptionModel? getFastestDeliveryOption() {
    if (options.isEmpty) return null;
    return options.reduce((a, b) => a.deliveryDays < b.deliveryDays ? a : b);
  }
  
  /// 获取有库存的选项
  List<PurchaseOptionModel> getInStockOptions() {
    return options.where((option) => option.inStock).toList();
  }
}

/// 购买选项模型
@JsonSerializable()
class PurchaseOptionModel {
  /// 商店名称
  final String store;
  
  /// 价格(元)
  final int price;
  
  /// 链接
  final String url;
  
  /// 是否有库存
  final bool inStock;
  
  /// 送货天数
  final int deliveryDays;

  /// 构造函数
  PurchaseOptionModel({
    required this.store,
    required this.price,
    required this.url,
    required this.inStock,
    required this.deliveryDays,
  });

  /// 从JSON创建
  factory PurchaseOptionModel.fromJson(Map<String, dynamic> json) => _$PurchaseOptionModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PurchaseOptionModelToJson(this);
  
  /// 获取价格文本
  String getPriceText() {
    return '¥$price';
  }
  
  /// 获取送货时间文本
  String getDeliveryText() {
    return '$deliveryDays天';
  }
  
  /// 获取库存状态文本
  String getStockStatusText() {
    return inStock ? '有货' : '缺货';
  }
}