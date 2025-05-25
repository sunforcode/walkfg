import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'transportation_segment_model.dart';

part 'transportation_plan_model.g.dart';

/// 交通方向枚举
enum TransportationDirection {
  /// 去程
  outbound,

  /// 返程
  inbound,
}

/// 交通方案模型
@JsonSerializable(fieldRename: FieldRename.snake)
class TransportationPlanModel extends BaseModel {
  /// 名称
  final String name;

  /// 交通方向
  final TransportationDirection direction;

  /// 交通段列表
  final List<TransportationSegment> segments;

  /// 出发日期
  final DateTime departureDate;

  /// 到达日期
  final DateTime arrivalDate;

  /// 总价格
  final double totalPrice;

  /// 备注
  final String notes;

  /// 构造函数
  TransportationPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.direction,
    required this.segments,
    required this.departureDate,
    required this.arrivalDate,
    required this.totalPrice,
    required this.notes,
  });

  /// 从JSON创建
  factory TransportationPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TransportationPlanModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TransportationPlanModelToJson(this);

  /// 获取出发城市
  String get departureCity =>
      segments.isNotEmpty ? segments.first.departureLocation : '';

  /// 获取目的地城市
  String get destinationCity =>
      segments.isNotEmpty ? segments.last.arrivalLocation : '';

  /// 获取交通方式名称
  String getTypeName() {
    if (segments.isEmpty) return '未知';

    final types = segments.map((s) => s.type).toSet();
    if (types.length == 1) {
      return _getTransportationTypeName(types.first);
    } else {
      return segments.map((s) => _getTransportationTypeName(s.type)).join('+');
    }
  }

  /// 获取交通类型名称
  String _getTransportationTypeName(TransportationType type) {
    switch (type) {
      case TransportationType.flight:
        return '飞机';
      case TransportationType.train:
        return '火车';
      case TransportationType.highSpeedRail:
        return '高铁';
      case TransportationType.bus:
        return '大巴';
      case TransportationType.ferry:
        return '轮渡';
      case TransportationType.car:
        return '私家车';
      case TransportationType.taxi:
        return '出租车';
      case TransportationType.rideshare:
        return '拼车';
      case TransportationType.shuttle:
        return '班车';
      case TransportationType.publicTransport:
        return '公共交通';
      case TransportationType.subway:
        return '地铁';
      case TransportationType.other:
        return '其他';
    }
  }

  /// 获取格式化出发时间
  String getFormattedDepartureTime() {
    return '${departureDate.month}月${departureDate.day}日 ${departureDate.hour}:${departureDate.minute.toString().padLeft(2, '0')}';
  }

  /// 获取格式化到达时间
  String getFormattedArrivalTime() {
    return '${arrivalDate.month}月${arrivalDate.day}日 ${arrivalDate.hour}:${arrivalDate.minute.toString().padLeft(2, '0')}';
  }

  /// 获取格式化耗时
  String getFormattedDuration() {
    final duration = arrivalDate.difference(departureDate).inMinutes;
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

  /// 高铁
  @JsonValue('high_speed_rail')
  highSpeedRail,

  /// 私家车
  car,

  /// 拼车
  rideshare,

  /// 班车
  shuttle,

  /// 公共交通
  @JsonValue('public_transport')
  publicTransport,
}
