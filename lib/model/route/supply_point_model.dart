import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'supply_point_model.g.dart';

/// 补给点模型
@JsonSerializable()
class SupplyPointModel extends BaseModel {
  /// 补给点名称
  final String name;

  /// 距离起点的距离(km)
  final double distance;

  /// 位置描述
  final String location;

  /// 补给点类型（综合商店/小卖部/餐厅/住宿）
  final String type;

  /// 营业状态（营业/停业/季节性营业）
  final String status;

  /// 营业时间
  final String hours;

  /// 可购买物品列表
  final List<String> items;

  /// 备注信息
  final String notes;

  /// 价格水平（便宜/适中/较高/昂贵）
  final String? priceLevel;

  /// 支付方式（现金/刷卡/移动支付）
  final List<String>? paymentMethods;

  /// 联系电话
  final String? phone;

  /// 海拔高度
  final int? elevation;

  /// 经纬度
  final double? latitude;
  final double? longitude;

  /// 是否提供住宿
  final bool? hasAccommodation;

  /// 是否提供热食
  final bool? hasHotFood;

  /// 构造函数
  SupplyPointModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.distance,
    required this.location,
    required this.type,
    required this.status,
    required this.hours,
    required this.items,
    required this.notes,
    this.priceLevel,
    this.paymentMethods,
    this.phone,
    this.elevation,
    this.latitude,
    this.longitude,
    this.hasAccommodation,
    this.hasHotFood,
  });

  /// 从JSON创建
  factory SupplyPointModel.fromJson(Map<String, dynamic> json) =>
      _$SupplyPointModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$SupplyPointModelToJson(this);

  /// 简单构造函数（兼容原有的Map数据）
  factory SupplyPointModel.fromMap(Map<String, dynamic> map) {
    return SupplyPointModel(
      id: 'supply_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name'] ?? '',
      distance: (map['distance'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? '',
      hours: map['hours'] ?? '',
      items: List<String>.from(map['items'] ?? []),
      notes: map['notes'] ?? '',
      priceLevel: map['priceLevel'],
      paymentMethods: map['paymentMethods'] != null 
          ? List<String>.from(map['paymentMethods'])
          : null,
      phone: map['phone'],
      elevation: map['elevation'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      hasAccommodation: map['hasAccommodation'],
      hasHotFood: map['hasHotFood'],
    );
  }

  /// 获取状态颜色
  String get statusColor {
    switch (status) {
      case '营业':
        return '#4CAF50'; // 绿色
      case '季节性营业':
        return '#FF9800'; // 橙色
      case '停业':
        return '#F44336'; // 红色
      default:
        return '#9E9E9E'; // 灰色
    }
  }

  /// 获取类型图标
  String get typeIcon {
    switch (type) {
      case '综合商店':
        return '🏪';
      case '小卖部':
        return '🏬';
      case '餐厅':
        return '🍽️';
      case '住宿':
        return '🏨';
      default:
        return '🏪';
    }
  }

  /// 是否正在营业
  bool get isOpen => status == '营业';

  /// 获取距离显示文本
  String get distanceText {
    if (distance == 0) {
      return '起点';
    } else if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  /// 获取物品显示文本
  String get itemsText {
    if (items.isEmpty) return '暂无商品信息';
    if (items.length <= 3) {
      return items.join('、');
    } else {
      return '${items.take(3).join('、')}等${items.length}种商品';
    }
  }

  /// 获取价格水平显示
  String get priceLevelText {
    switch (priceLevel) {
      case '便宜':
        return '💰';
      case '适中':
        return '💰💰';
      case '较高':
        return '💰💰💰';
      case '昂贵':
        return '💰💰💰💰';
      default:
        return '价格未知';
    }
  }
}