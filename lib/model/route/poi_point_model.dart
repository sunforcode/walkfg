import 'package:json_annotation/json_annotation.dart';

part 'poi_point_model.g.dart';

/// 统一附属信息点模型
///
/// 对应后台 PoiPointDto，将路线上所有类型的附属位置信息统一存储。
/// 通过 category 字段区分类型，通过 cardData JSON 存储各类型的扩展属性。
///
/// category 枚举值：
/// - water:    水源（泉水/河流/自来水等）
/// - camp:     营地
/// - supply:   补给点（村庄/商店/餐饮）
/// - photo:    拍照/打卡点
/// - pass:     垭口（高程局部最高点）
/// - valley:   河谷（高程局部最低点）
/// - weather:  气象信息点
/// - danger:   危险点
/// - start:    起点
/// - end:      终点
@JsonSerializable()
class PoiPointModel {
  final String id;

  @JsonKey(name: 'route_id')
  final String routeId;

  final String name;

  final double latitude;

  final double longitude;

  final double? elevation;

  /// POI 类型：water | camp | supply | photo | pass | valley | weather | danger | start | end
  final String category;

  /// 细分类型，如 water 的 spring/river/tap
  @JsonKey(name: 'sub_category')
  final String? subCategory;

  /// 数据来源：kml_marker | algorithm | osm | weather_api | experience
  final String source;

  final String? description;

  /// 数据置信度 0.0-1.0
  final double? confidence;

  /// 各 category 的扩展属性，JSON 对象
  @JsonKey(name: 'card_data')
  final dynamic cardData;

  PoiPointModel({
    required this.id,
    required this.routeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.elevation,
    required this.category,
    this.subCategory,
    required this.source,
    this.description,
    this.confidence,
    this.cardData,
  });

  factory PoiPointModel.fromJson(Map<String, dynamic> json) =>
      _$PoiPointModelFromJson(json);

  Map<String, dynamic> toJson() => _$PoiPointModelToJson(this);

  /// 获取 POI 类型显示文本
  String get categoryText {
    switch (category) {
      case 'water':
        return '水源';
      case 'camp':
        return '营地';
      case 'supply':
        return '补给点';
      case 'photo':
        return '拍照点';
      case 'pass':
        return '垭口';
      case 'valley':
        return '河谷';
      case 'weather':
        return '气象点';
      case 'danger':
        return '危险点';
      case 'start':
        return '起点';
      case 'end':
        return '终点';
      default:
        return '其他';
    }
  }

  /// 获取 POI 类型图标
  String get categoryIcon {
    switch (category) {
      case 'water':
        return '💧';
      case 'camp':
        return '⛺';
      case 'supply':
        return '🏪';
      case 'photo':
        return '📸';
      case 'pass':
        return '🏔️';
      case 'valley':
        return '🏞️';
      case 'weather':
        return '🌤️';
      case 'danger':
        return '⚠️';
      case 'start':
        return '🚩';
      case 'end':
        return '🏁';
      default:
        return '📍';
    }
  }

  @override
  String toString() =>
      'PoiPointModel(id: $id, name: $name, category: $category, lat: $latitude, lng: $longitude)';
}
