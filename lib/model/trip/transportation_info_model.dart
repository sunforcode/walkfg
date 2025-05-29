import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'transportation_info_model.g.dart';

/// 交通信息模型
@JsonSerializable()
class TransportationInfoModel extends BaseModel {
  /// 类型（去程/返程/中转）
  final String type;
  
  /// 出发地
  final String from;
  
  /// 目的地
  final String to;
  
  /// 交通方式
  final String method;
  
  /// 时间
  final String time;
  
  /// 状态（已预订/未预订）
  @JsonKey(name: 'is_booked')
  final bool isBooked;

  /// 价格（可选）
  final double? price;

  /// 备注
  final String? notes;
  
  /// 构造函数
  TransportationInfoModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.type,
    required this.from,
    required this.to,
    required this.method,
    required this.time,
    this.isBooked = false,
    this.price,
    this.notes,
  });

  /// 从JSON创建
  factory TransportationInfoModel.fromJson(Map<String, dynamic> json) =>
      _$TransportationInfoModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TransportationInfoModelToJson(this);

  /// 简单构造函数（兼容原有的TransportationInfo）
  factory TransportationInfoModel.simple({
    required String type,
    required String from,
    required String to,
    required String method,
    required String time,
    bool isBooked = false,
    double? price,
    String? notes,
  }) {
    return TransportationInfoModel(
      id: 'transport_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      from: from,
      to: to,
      method: method,
      time: time,
      isBooked: isBooked,
      price: price,
      notes: notes,
    );
  }

  /// 获取状态文本
  String get statusText => isBooked ? '已预订' : '未预订';

  /// 获取格式化的价格
  String get formattedPrice {
    if (price != null) {
      return '¥${price!.toStringAsFixed(0)}';
    }
    return '价格待定';
  }
}