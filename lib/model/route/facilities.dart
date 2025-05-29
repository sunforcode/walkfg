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

  /// 是否需要许可证
  @JsonKey(name: 'requires_permit')
  final bool requiresPermit;

  /// 安全警告列表
  @JsonKey(name: 'safety_warnings')
  final List<String> safetyWarnings;

  /// 构造函数
  FacilitiesVO({
    required this.water,
    required this.food,
    required this.accommodation,
    required this.toilets,
    required this.signalCoverage,
    this.requiresPermit = false,
    this.safetyWarnings = const [],
  });

  /// 从JSON创建
  factory FacilitiesVO.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$FacilitiesVOToJson(this);

  /// 创建副本
  FacilitiesVO copyWith({
    String? water,
    String? food,
    String? accommodation,
    String? toilets,
    String? signalCoverage,
    bool? requiresPermit,
    List<String>? safetyWarnings,
  }) {
    return FacilitiesVO(
      water: water ?? this.water,
      food: food ?? this.food,
      accommodation: accommodation ?? this.accommodation,
      toilets: toilets ?? this.toilets,
      signalCoverage: signalCoverage ?? this.signalCoverage,
      requiresPermit: requiresPermit ?? this.requiresPermit,
      safetyWarnings: safetyWarnings ?? this.safetyWarnings,
    );
  }
}
