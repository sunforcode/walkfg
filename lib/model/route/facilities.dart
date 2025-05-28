import 'package:json_annotation/json_annotation.dart';

part 'facilities.g.dart';

/// 设施信息值对象
@JsonSerializable()
class FacilitiesVO {
  /// 水源
  final String water;

  /// 食物
  final String food;

  /// 住宿
  final String accommodation;

  /// 厕所
  final String toilets;

  /// 信号覆盖
  @JsonKey(name: 'signal_coverage')
  final String signalCoverage;

  /// 构造函数
  FacilitiesVO({
    required this.water,
    required this.food,
    required this.accommodation,
    required this.toilets,
    required this.signalCoverage,
  });

  /// 从JSON创建
  factory FacilitiesVO.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$FacilitiesVOToJson(this);
}