import 'package:json_annotation/json_annotation.dart';
import 'area_model.dart';
import 'emergency_contact_model.dart';

part 'safety_info_model.g.dart';

/// 安全信息值对象模型
///
/// 作为路径模型的嵌套对象，不需要独立的ID和时间戳
@JsonSerializable()
class SafetyInfoVO {
  /// 紧急联系方式
  final List<EmergencyContactVO> emergencyContacts;

  /// 风险区域
  final List<AreaModel> riskAreas;

  /// 手机信号覆盖
  final List<AreaModel> cellSignal;

  /// 构造函数
  SafetyInfoVO({
    List<EmergencyContactVO>? emergencyContacts,
    List<AreaModel>? riskAreas,
    List<AreaModel>? cellSignal,
  })  : this.emergencyContacts = emergencyContacts ?? const [],
        this.riskAreas = riskAreas ?? const [],
        this.cellSignal = cellSignal ?? const [];

  /// 从JSON创建
  factory SafetyInfoVO.fromJson(Map<String, dynamic> json) =>
      _$SafetyInfoVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SafetyInfoVOToJson(this);
}
