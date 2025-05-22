import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'campsite_model.g.dart';

/// 营地模型
@JsonSerializable()
class CampsiteModel extends BaseModel {
  /// 名称
  final String name;
  
  /// 设施
  final List<String> facilities;
  
  /// 容量
  final int capacity;
  
  /// 是否需要预订
  final bool reservationRequired;
  
  /// 构造函数
  CampsiteModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    List<String>? facilities,
    this.capacity = 0,
    this.reservationRequired = false,
  }) : this.facilities = facilities ?? const [];
  
  /// 从JSON创建
  factory CampsiteModel.fromJson(Map<String, dynamic> json) =>
      _$CampsiteModelFromJson(json);
      
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$CampsiteModelToJson(this);
}