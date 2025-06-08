import 'package:json_annotation/json_annotation.dart';

part 'facilities_model.g.dart';

/// 设施信息模型
@JsonSerializable()
class FacilitiesModel {
  /// 饮用水信息
  final String? water;

  /// 食物信息
  final String? food;

  /// 住宿信息
  final String? accommodation;

  /// 厕所信息
  final String? toilets;

  /// 信号覆盖情况
  @JsonKey(name: 'signal_coverage')
  final String? signalCoverage;

  /// 是否需要许可证
  @JsonKey(name: 'requires_permit')
  final bool requiresPermit;

  /// 安全警告列表
  @JsonKey(name: 'safety_warnings')
  final List<String> safetyWarnings;

  /// 构造函数
  FacilitiesModel({
    this.water,
    this.food,
    this.accommodation,
    this.toilets,
    this.signalCoverage,
    this.requiresPermit = false,
    this.safetyWarnings = const [],
  });

  /// 从JSON创建
  factory FacilitiesModel.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$FacilitiesModelToJson(this);

  /// 获取设施完备程度评分（1-5）
  int get facilitiesScore {
    int score = 0;
    if (water != null && water!.isNotEmpty) score++;
    if (food != null && food!.isNotEmpty) score++;
    if (accommodation != null && accommodation!.isNotEmpty) score++;
    if (toilets != null && toilets!.isNotEmpty) score++;
    if (signalCoverage != null && signalCoverage!.contains('有')) score++;
    return score;
  }

  /// 获取设施完备程度描述
  String get facilitiesDescription {
    switch (facilitiesScore) {
      case 5:
        return '设施完备';
      case 4:
        return '设施良好';
      case 3:
        return '设施一般';
      case 2:
        return '设施较少';
      case 1:
        return '设施简陋';
      default:
        return '无设施信息';
    }
  }

  /// 是否有基础设施
  bool get hasBasicFacilities {
    return facilitiesScore >= 2;
  }

  /// 是否适合过夜
  bool get suitableForOvernight {
    return accommodation != null && accommodation!.isNotEmpty;
  }

  /// 获取安全等级（1-5，5最安全）
  int get safetyLevel {
    if (safetyWarnings.isEmpty) return 5;
    if (safetyWarnings.length <= 2) return 4;
    if (safetyWarnings.length <= 4) return 3;
    if (safetyWarnings.length <= 6) return 2;
    return 1;
  }

  /// 获取安全等级描述
  String get safetyDescription {
    switch (safetyLevel) {
      case 5:
        return '非常安全';
      case 4:
        return '比较安全';
      case 3:
        return '一般安全';
      case 2:
        return '需要注意';
      case 1:
        return '高风险';
      default:
        return '未知';
    }
  }

  /// 创建副本
  FacilitiesModel copyWith({
    String? water,
    String? food,
    String? accommodation,
    String? toilets,
    String? signalCoverage,
    bool? requiresPermit,
    List<String>? safetyWarnings,
  }) {
    return FacilitiesModel(
      water: water ?? this.water,
      food: food ?? this.food,
      accommodation: accommodation ?? this.accommodation,
      toilets: toilets ?? this.toilets,
      signalCoverage: signalCoverage ?? this.signalCoverage,
      requiresPermit: requiresPermit ?? this.requiresPermit,
      safetyWarnings: safetyWarnings ?? this.safetyWarnings,
    );
  }

  @override
  String toString() {
    return 'FacilitiesModel(score: $facilitiesScore, safety: $safetyLevel, permit: $requiresPermit)';
  }
}