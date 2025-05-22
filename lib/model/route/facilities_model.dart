import 'package:json_annotation/json_annotation.dart';
import 'point_model.dart';

part 'facilities_model.g.dart';

/// 设施信息值对象模型
///
/// 作为路径模型的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class FacilitiesVO {
  /// 水源点
  final List<PointModel> waterSources;

  /// 厕所
  final List<PointModel> restrooms;

  /// 庇护所
  final List<PointModel> shelters;

  /// 商店
  final List<PointModel> shops;

  /// 构造函数
  FacilitiesVO({
    List<PointModel>? waterSources,
    List<PointModel>? restrooms,
    List<PointModel>? shelters,
    List<PointModel>? shops,
  })  : this.waterSources = waterSources ?? const [],
        this.restrooms = restrooms ?? const [],
        this.shelters = shelters ?? const [],
        this.shops = shops ?? const [];

  /// 从JSON创建
  factory FacilitiesVO.fromJson(Map<String, dynamic> json) =>
      _$FacilitiesVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$FacilitiesVOToJson(this);
}
