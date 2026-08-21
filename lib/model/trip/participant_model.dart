import 'package:json_annotation/json_annotation.dart';

part 'participant_model.g.dart';

/// 参与确认状态枚举
enum ConfirmationStatus {
  /// 待确认
  pending,
  /// 已确认
  confirmed,
  /// 已拒绝
  declined,
}

/// 行程参与者模型 - 包含参与状态*和经验信息
@JsonSerializable()
class ParticipantModel {
  /// 用户ID
  final String userId;
  
  /// 昵称
  final String name;
  
  /// 头像URL
  final String? avatar;
  
  /// 是否为组织者
  @JsonKey(defaultValue: false)
  final bool isOrganizer;
  
  /// 徒步经验描述
  @JsonKey(defaultValue: '')
  final String experience;
  
  /// 确认状态
  @JsonKey(name: 'confirmation_status', fromJson: _parseConfirmationStatus, toJson: _confirmationStatusToJson)
  final ConfirmationStatus confirmationStatus;
  
  ParticipantModel({
    required this.userId,
    required this.name,
    this.avatar,
    this.isOrganizer = false,
    this.experience = '',
    this.confirmationStatus = ConfirmationStatus.pending,
  });
  
  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$ParticipantModelToJson(this);
  
  /// 确认状态显示文本
  String get confirmationText {
    switch (confirmationStatus) {
      case ConfirmationStatus.pending: return '待确认';
      case ConfirmationStatus.confirmed: return '已确认';
      case ConfirmationStatus.declined: return '已拒绝';
    }
  }
}

ConfirmationStatus _parseConfirmationStatus(dynamic value) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'pending': return ConfirmationStatus.pending;
      case 'confirmed': return ConfirmationStatus.confirmed;
      case 'declined': return ConfirmationStatus.declined;
    }
  }
  return ConfirmationStatus.pending;
}

String _confirmationStatusToJson(ConfirmationStatus status) {
  return status.name;
}
