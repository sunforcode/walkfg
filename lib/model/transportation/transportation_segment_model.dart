import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/transportation/transportation_plan_model.dart';
import '../base/base_model.dart';

part 'transportation_segment_model.g.dart';

/// 交通段模型
@JsonSerializable(fieldRename: FieldRename.snake)
class TransportationSegment extends BaseModel {
  /// 名称
  final String name;

  /// 交通类型
  final TransportationType type;

  /// 出发地点
  final String departureLocation;

  /// 到达地点
  final String arrivalLocation;

  /// 出发时间
  final DateTime departureTime;

  /// 到达时间
  final DateTime arrivalTime;

  /// 价格
  final double price;

  /// 供应商
  final String provider;

  /// 预订参考号
  final String bookingReference;

  /// 备注
  final String notes;

  /// 是否已预订
  final bool isBooked;

  /// 驾驶距离(公里)
  final double drivingDistance;

  /// 驾驶时间(分钟)
  final int drivingDuration;

  /// 途经点
  final List<String> viaPoints;

  /// 换乘次数
  final int transfers;

  /// 换乘详情
  final List<String> transferDetails;

  /// 构造函数
  TransportationSegment({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.type,
    required this.departureLocation,
    required this.arrivalLocation,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.provider,
    required this.bookingReference,
    required this.notes,
    required this.isBooked,
    required this.drivingDistance,
    required this.drivingDuration,
    required this.viaPoints,
    required this.transfers,
    required this.transferDetails,
  });

  /// 从JSON创建
  factory TransportationSegment.fromJson(Map<String, dynamic> json) =>
      _$TransportationSegmentFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TransportationSegmentToJson(this);
}
