import 'package:json_annotation/json_annotation.dart';

part 'seasonal_closure_model.g.dart';

/// 季节性关闭值对象模型
/// 
/// 表示路径段的季节性关闭信息，不需要独立的ID和时间戳
@JsonSerializable()
class SeasonalClosureVO {
  /// 开始日期
  final DateTime startDate;
  
  /// 结束日期
  final DateTime endDate;
  
  /// 原因
  final String reason;
  
  /// 构造函数
  SeasonalClosureVO({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });
  
  /// 从JSON创建
  factory SeasonalClosureVO.fromJson(Map<String, dynamic> json) =>
      _$SeasonalClosureVOFromJson(json);
      
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SeasonalClosureVOToJson(this);
}
