import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'coordinates_model.dart';

part 'area_model.g.dart';

/// 区域模型
@JsonSerializable()
class AreaModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 边界点
  final List<CoordinatesVO> boundary;

  /// 级别(1-5)
  final int level;

  /// 构造函数
  AreaModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.boundary,
    required this.level,
  });

  /// 从JSON创建
  factory AreaModel.fromJson(Map<String, dynamic> json) =>
      _$AreaModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$AreaModelToJson(this);
}
