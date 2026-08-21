import 'package:json_annotation/json_annotation.dart';
import 'package:walk/utils/json_utils.dart';

part 'hitchhike_contact_model.g.dart';

/// 搭车联系方式模型
@JsonSerializable()
class HitchhikeContactModel {
  /// ID
  final String id;

  /// 姓名
  final String name;

  /// 电话号码
  final String phone;

  /// 描述
  final String? description;

  /// 位置
  final String? location;

  /// 价格
  final double? price;

  /// 创建时间
  @JsonKey(
      name: 'created_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? createdAt;

  /// 更新时间
  @JsonKey(
      name: 'updated_at',
      fromJson: JsonUtils.parseTimestamp,
      toJson: JsonUtils.timestampToJson)
  final DateTime? updatedAt;

  /// 是否已认证（后端字段名为 last_verified，类型为 Boolean）
  @JsonKey(name: 'last_verified')
  final bool isVerified;

  /// 构造函数
  const HitchhikeContactModel({
    required this.id,
    required this.name,
    required this.phone,
    this.description,
    this.location,
    this.price,
    this.createdAt,
    this.updatedAt,
    this.isVerified = false,
  });

  /// 从JSON创建
  factory HitchhikeContactModel.fromJson(Map<String, dynamic> json) =>
      _$HitchhikeContactModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$HitchhikeContactModelToJson(this);
}
