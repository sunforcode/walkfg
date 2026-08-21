import 'package:json_annotation/json_annotation.dart';

part 'gear_item_model.g.dart';

/// 装备优先级枚举
enum GearPriority {
  /// 必备
  required,
  /// 推荐
  recommended,
}

/// 季节性装备建议模型 - 路线详情页的"季节装备"卡片展示
@JsonSerializable()
class GearItemModel {
  /// 装备名称
  final String name;
  
  /// 优先级：必备/推荐
  @JsonKey(fromJson: _parsePriority, toJson: _priorityToJson)
  final GearPriority priority;
  
  /// 适用季节
  @JsonKey(defaultValue: '')
  final String season;
  
  GearItemModel({
    required this.name,
    this.priority = GearPriority.recommended,
    this.season = '',
  });
  
  factory GearItemModel.fromJson(Map<String, dynamic> json) =>
      _$GearItemModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$GearItemModelToJson(this);
  
  /// 优先级显示文本
  String get priorityText {
    switch (priority) {
      case GearPriority.required: return '必备';
      case GearPriority.recommended: return '推荐';
    }
  }
}

GearPriority _parsePriority(dynamic value) {
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'required':
      case '必备':
        return GearPriority.required;
      case 'recommended':
      case '推荐':
        return GearPriority.recommended;
    }
  }
  return GearPriority.recommended;
}

String _priorityToJson(GearPriority priority) {
  return priority.name;
}
