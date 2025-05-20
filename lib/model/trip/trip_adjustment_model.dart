/// 行程调整模型类
///
/// 用于存储行程调整的信息

import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'trip_adjustment_model.g.dart';

/// 行程调整模型
@JsonSerializable()
class TripAdjustmentModel extends BaseModel {
  /// 行程调整名称
  final String name;

  /// 行程调整描述
  final String description;

  /// 原始行程天数
  final int originalDays;

  /// 调整后行程天数
  final int adjustedDays;

  /// 原始行程日期
  final DateTime originalStartDate;

  /// 调整后行程日期
  final DateTime adjustedStartDate;

  /// 调整原因
  final String reason;

  /// 构造函数
  TripAdjustmentModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.originalDays,
    required this.adjustedDays,
    required this.originalStartDate,
    required this.adjustedStartDate,
    required this.reason,
  });

  /// 从JSON创建行程调整模型
  factory TripAdjustmentModel.fromJson(Map<String, dynamic> json) =>
      _$TripAdjustmentModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$TripAdjustmentModelToJson(this);

  /// 创建副本并更新指定字段
  TripAdjustmentModel copyWith({
    String? id,
    String? name,
    String? description,
    int? originalDays,
    int? adjustedDays,
    DateTime? originalStartDate,
    DateTime? adjustedStartDate,
    String? reason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TripAdjustmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      originalDays: originalDays ?? this.originalDays,
      adjustedDays: adjustedDays ?? this.adjustedDays,
      originalStartDate: originalStartDate ?? this.originalStartDate,
      adjustedStartDate: adjustedStartDate ?? this.adjustedStartDate,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
