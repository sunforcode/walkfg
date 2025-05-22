import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'trip_day_plan_model.g.dart';

/// 行程每日计划模型
@JsonSerializable()
class TripDayPlanModel extends BaseModel {
  /// 第几天
  final int day;

  /// 标题
  final String title;

  /// 描述
  final String description;

  /// 起点
  @JsonKey(name: 'start_point')
  final String startPoint;

  /// 终点
  @JsonKey(name: 'end_point')
  final String endPoint;

  /// 距离(km)
  final double distance;

  /// 爬升(m)
  @JsonKey(name: 'elevation_gain')
  final int elevationGain;

  /// 下降(m)
  @JsonKey(name: 'elevation_loss')
  final int elevationLoss;

  /// 预计时间(小时)
  @JsonKey(name: 'estimated_time')
  final double estimatedTime;

  /// 备注
  final String? notes;

  /// 构造函数
  TripDayPlanModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.day,
    required this.title,
    required this.description,
    required this.startPoint,
    required this.endPoint,
    required this.distance,
    required this.elevationGain,
    required this.elevationLoss,
    required this.estimatedTime,
    this.notes,
  });

  /// 从JSON创建
  factory TripDayPlanModel.fromJson(Map<String, dynamic> json) =>
      _$TripDayPlanModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TripDayPlanModelToJson(this);
}
