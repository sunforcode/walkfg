/// 水容器模型
///
/// 用于表示携带和存储水的容器
/// 
/// WaterContainerModel记录了不同类型的水容器信息，
/// 帮助用户选择和管理携带水的容器。

import '../../base/base_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'water_types.dart';

part 'water_container_model.g.dart';

/// 水容器模型
@JsonSerializable()
class WaterContainerModel extends BaseModel {
  /// 容器名称
  final String name;
  
  /// 容器描述
  final String description;
  
  /// 容器类型
  final WaterContainerType type;
  
  /// 容量(ml)
  final int capacity;
  
  /// 空重(g)
  final double emptyWeight;
  
  /// 材质
  final String material;
  
  /// 是否可折叠
  final bool collapsible;
  
  /// 构造函数
  WaterContainerModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.type,
    required this.capacity,
    required this.emptyWeight,
    required this.material,
    this.collapsible = false,
  });
  
  /// 从JSON创建
  factory WaterContainerModel.fromJson(Map<String, dynamic> json) =>
      _$WaterContainerModelFromJson(json);
  
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$WaterContainerModelToJson(this);
  
  /// 获取满载重量(g)
  double get fullWeight => emptyWeight + capacity;
  
  /// 获取容器类型名称
  String getTypeText() {
    switch (type) {
      case WaterContainerType.bottle: return '水壶';
      case WaterContainerType.bladder: return '水袋';
      case WaterContainerType.softBottle: return '软水瓶';
      case WaterContainerType.thermos: return '保温杯';
    }
  }
  
  /// 获取容量文本
  String getCapacityText() {
    if (capacity >= 1000) {
      return '${(capacity / 1000).toStringAsFixed(1)}L';
    } else {
      return '${capacity}ml';
    }
  }
  
  /// 获取重量文本
  String getWeightText() {
    if (emptyWeight >= 1000) {
      return '${(emptyWeight / 1000).toStringAsFixed(1)}kg';
    } else {
      return '${emptyWeight.toStringAsFixed(0)}g';
    }
  }
  
  /// 创建副本并更新指定字段
  WaterContainerModel copyWith({
    String? id,
    String? name,
    String? description,
    WaterContainerType? type,
    int? capacity,
    double? emptyWeight,
    String? material,
    bool? collapsible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaterContainerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      emptyWeight: emptyWeight ?? this.emptyWeight,
      material: material ?? this.material,
      collapsible: collapsible ?? this.collapsible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}