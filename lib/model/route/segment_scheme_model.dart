import 'package:json_annotation/json_annotation.dart';
import 'package:walk/model/route/segment_model.dart';

part 'segment_scheme_model.g.dart';

/// 分段方案模型
///
/// 对应后台 SegmentSchemeDto，每条路线可以有多套分段方案，
/// 每套方案代表一种维度的轨迹划分方式。
///
/// scheme_type 枚举值：
/// - slope:     按坡度（爬升/下降/平路），默认方案
/// - day:       按天（时间间隔 >6h 为新天）
/// - terrain:   按地形（垭口/山脊/河谷/平台）
/// - road_type: 按路况（小径/机耕路/公路）
@JsonSerializable()
class SegmentSchemeModel {
  final String id;

  @JsonKey(name: 'route_id')
  final String routeId;

  /// 方案类型：slope | day | terrain | road_type
  @JsonKey(name: 'scheme_type')
  final String schemeType;

  /// 展示用标签（中文），如"按坡度"、"按天"
  final String label;

  /// 是否为默认方案
  @JsonKey(name: 'is_default', defaultValue: false)
  final bool isDefault;

  /// 方案内的分段列表
  final List<SegmentModel> segments;

  SegmentSchemeModel({
    required this.id,
    required this.routeId,
    required this.schemeType,
    required this.label,
    this.isDefault = false,
    this.segments = const [],
  });

  factory SegmentSchemeModel.fromJson(Map<String, dynamic> json) =>
      _$SegmentSchemeModelFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentSchemeModelToJson(this);

  /// 获取方案类型显示文本
  String get schemeTypeText {
    switch (schemeType) {
      case 'slope':
        return '按坡度';
      case 'day':
        return '按天';
      case 'terrain':
        return '按地形';
      case 'road_type':
        return '按路况';
      default:
        return label;
    }
  }

  @override
  String toString() =>
      'SegmentSchemeModel(id: $id, type: $schemeType, label: $label, isDefault: $isDefault, segments: ${segments.length})';
}
