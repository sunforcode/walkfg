import 'package:json_annotation/json_annotation.dart';

part 'coordinates_model.g.dart';

/// 坐标值对象模型
///
/// 表示地理坐标，不需要独立的ID和时间戳
@JsonSerializable()
class CoordinatesVO {
  /// 纬度
  final double latitude;

  /// 经度
  final double longitude;

  /// 海拔(米)
  final double altitude;

  /// 构造函数
  CoordinatesVO({
    required this.latitude,
    required this.longitude,
    required this.altitude,
  });

  /// 从JSON创建
  factory CoordinatesVO.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesVOFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$CoordinatesVOToJson(this);
}
