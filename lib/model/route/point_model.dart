import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import 'coordinates_model.dart';

part 'point_model.g.dart';

/// 设施点模型
@JsonSerializable()
class PointModel extends BaseModel {
  /// 名称
  final String name;

  /// 描述
  final String description;

  /// 坐标
  final CoordinatesVO coordinates;

  /// 设施类型
  final String type;

  /// 构造函数
  PointModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.type,
  });

  /// 从JSON创建
  factory PointModel.fromJson(Map<String, dynamic> json) =>
      _$PointModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$PointModelToJson(this);
}
