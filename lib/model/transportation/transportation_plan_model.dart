import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'transportation_plan_model.g.dart';

/// 交通方案模型
@JsonSerializable()
class TransportationPlanModel extends BaseModel {
  /// 出发城市
  final String departureCity;
  
  /// 目的地城市
  final String destinationCity;
  
  /// 交通方式
  final TransportationType type;
  
  /// 出发时间
  final DateTime departureTime;
  
  /// 到达时间
  final DateTime arrivalTime;
  
  /// 价格
  final double price;
  
  /// 耗时(分钟)
  final int duration;
  
  /// 供应商
  final String provider;
  
  /// 备注
  final String? notes;
  
  /// 构造函数
  TransportationPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.departureCity,
    required this.destinationCity,
    required this.type,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.duration,
    required this.provider,
    this.notes,
  });
  
  /// 从JSON创建
  factory TransportationPlanModel.fromJson(Map<String, dynamic> json) => _$TransportationPlanModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TransportationPlanModelToJson(this);
  
  /// 获取交通方式名称
  String getTypeName() {
    switch (type) {
      case TransportationType.flight:
        return '飞机';
      case TransportationType.train:
        return '火车';
      case TransportationType.bus:
        return '汽车';
      case TransportationType.ferry:
        return '轮渡';
      case TransportationType.taxi:
        return '出租车';
      case TransportationType.subway:
        return '地铁';
      case TransportationType.other:
        return '其他';
    }
  }
  
  /// 获取格式化出发时间
  String getFormattedDepartureTime() {
    return '${departureTime.month}月${departureTime.day}日 ${departureTime.hour}:${departureTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取格式化到达时间
  String getFormattedArrivalTime() {
    return '${arrivalTime.month}月${arrivalTime.day}日 ${arrivalTime.hour}:${arrivalTime.minute.toString().padLeft(2, '0')}';
  }
  
  /// 获取格式化耗时
  String getFormattedDuration() {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0) {
      return '$hours小时${minutes > 0 ? '$minutes分钟' : ''}';
    } else {
      return '$minutes分钟';
    }
  }
}

/// 交通方式枚举
enum TransportationType {
  /// 飞机
  flight,
  
  /// 火车
  train,
  
  /// 汽车
  bus,
  
  /// 轮渡
  ferry,
  
  /// 出租车
  taxi,
  
  /// 地铁
  subway,
  
  /// 其他
  other,
}
