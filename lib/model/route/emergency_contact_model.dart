import 'package:json_annotation/json_annotation.dart';

part 'emergency_contact_model.g.dart';

/// 紧急联系方式值对象模型
///
/// 作为安全信息的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class EmergencyContactVO {
  /// 名称
  final String name;

  /// 电话
  final String phone;

  /// 描述
  final String description;

  /// 构造函数
  EmergencyContactVO({
    required this.name,
    required this.phone,
    required this.description,
  });

  /// 从JSON创建
  factory EmergencyContactVO.fromJson(Map<String, dynamic> json) =>
      _$EmergencyContactVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$EmergencyContactVOToJson(this);
}
