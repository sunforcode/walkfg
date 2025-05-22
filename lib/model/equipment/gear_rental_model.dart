import 'package:json_annotation/json_annotation.dart';

part 'gear_rental_model.g.dart';

/// 装备租赁选项模型
@JsonSerializable()
class GearRentalOptionModel {
  /// 商店名称
  final String store;
  
  /// 位置
  final String location;
  
  /// 价格
  final RentalPriceModel price;
  
  /// 押金(元)
  final int deposit;
  
  /// 是否可用
  final bool available;
  
  /// 联系电话
  final String contactPhone;
  
  /// 链接
  final String url;

  /// 构造函数
  GearRentalOptionModel({
    required this.store,
    required this.location,
    required this.price,
    required this.deposit,
    required this.available,
    required this.contactPhone,
    required this.url,
  });

  /// 从JSON创建
  factory GearRentalOptionModel.fromJson(Map<String, dynamic> json) => _$GearRentalOptionModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$GearRentalOptionModelToJson(this);
  
  /// 获取押金文本
  String getDepositText() {
    return '¥$deposit';
  }
  
  /// 获取可用状态文本
  String getAvailabilityText() {
    return available ? '可租赁' : '暂不可租';
  }
}

/// 租赁价格模型
@JsonSerializable()
class RentalPriceModel {
  /// 日租价格(元)
  final int daily;
  
  /// 周租价格(元)
  final int weekly;

  /// 构造函数
  RentalPriceModel({
    required this.daily,
    required this.weekly,
  });

  /// 从JSON创建
  factory RentalPriceModel.fromJson(Map<String, dynamic> json) => _$RentalPriceModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$RentalPriceModelToJson(this);
  
  /// 获取日租价格文本
  String getDailyPriceText() {
    return '¥$daily/天';
  }
  
  /// 获取周租价格文本
  String getWeeklyPriceText() {
    return '¥$weekly/周';
  }
  
  /// 计算指定天数的租赁价格
  int calculatePrice(int days) {
    if (days <= 0) return 0;
    
    // 计算周数和剩余天数
    final weeks = days ~/ 7;
    final remainingDays = days % 7;
    
    // 计算总价
    return weeks * weekly + remainingDays * daily;
  }
  
  /// 获取指定天数的租赁价格文本
  String getPriceText(int days) {
    return '¥${calculatePrice(days)}';
  }
}