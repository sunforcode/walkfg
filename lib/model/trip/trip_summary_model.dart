import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'trip_summary_model.g.dart';

/// 行程摘要模型 - 用于路线详情页的"相关行程"展示
@JsonSerializable()
class TripSummaryModel extends BaseModel {
  /// 组织者名称
  @JsonKey(name: 'organizer')
  final String organizer;
  
  /// 出发日期
  @JsonKey(name: 'start_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  final DateTime startDate;
  
  /// 返回日期
  @JsonKey(name: 'end_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  final DateTime endDate;
  
  /// 参与人数
  @JsonKey(name: 'participant_count', defaultValue: 0)
  final int participantCount;
  
  /// 费用（元）
  @JsonKey(defaultValue: 0)
  final double cost;
  
  /// 简短描述
  @JsonKey(defaultValue: '')
  final String description;
  
  TripSummaryModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.organizer,
    required this.startDate,
    required this.endDate,
    this.participantCount = 0,
    this.cost = 0,
    this.description = '',
  });
  
  factory TripSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$TripSummaryModelFromJson(json);
  
  @override
  Map<String, dynamic> toJson() => _$TripSummaryModelToJson(this);
}
