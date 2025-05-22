import 'package:json_annotation/json_annotation.dart';
import '../../base/base_model.dart';

part 'region_model.g.dart';

/// 交通信息值对象
@JsonSerializable()
class TransportationInfoVO {
  /// 公共交通描述
  @JsonKey(name: 'public_transport')
  final String publicTransport;
  
  /// 自驾描述
  @JsonKey(name: 'self_driving')
  final String selfDriving;
  
  /// 最近机场
  @JsonKey(name: 'nearest_airport')
  final String? nearestAirport;
  
  /// 最近火车站
  @JsonKey(name: 'nearest_train_station')
  final String? nearestTrainStation;
  
  /// 本地交通
  @JsonKey(name: 'local_transport')
  final String? localTransport;
  
  /// 构造函数
  TransportationInfoVO({
    required this.publicTransport,
    required this.selfDriving,
    this.nearestAirport,
    this.nearestTrainStation,
    this.localTransport,
  });
  
  /// 从JSON创建
  factory TransportationInfoVO.fromJson(Map<String, dynamic> json) =>
      _$TransportationInfoVOFromJson(json);
      
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$TransportationInfoVOToJson(this);
}

/// 住宿信息值对象
@JsonSerializable()
class AccommodationInfoVO {
  /// 酒店信息
  final String hotels;
  
  /// 旅馆信息
  final String hostels;
  
  /// 露营地信息
  final String? campsites;
  
  /// 山庄/小屋信息
  @JsonKey(name: 'mountain_huts')
  final String? mountainHuts;
  
  /// 构造函数
  AccommodationInfoVO({
    required this.hotels,
    required this.hostels,
    this.campsites,
    this.mountainHuts,
  });
  
  /// 从JSON创建
  factory AccommodationInfoVO.fromJson(Map<String, dynamic> json) =>
      _$AccommodationInfoVOFromJson(json);
      
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AccommodationInfoVOToJson(this);
}

/// 餐饮信息值对象
@JsonSerializable()
class DiningInfoVO {
  /// 餐厅信息
  final String restaurants;
  
  /// 当地特色
  @JsonKey(name: 'local_specialties')
  final String localSpecialties;
  
  /// 自助餐厅
  final String? cafeterias;
  
  /// 构造函数
  DiningInfoVO({
    required this.restaurants,
    required this.localSpecialties,
    this.cafeterias,
  });
  
  /// 从JSON创建
  factory DiningInfoVO.fromJson(Map<String, dynamic> json) =>
      _$DiningInfoVOFromJson(json);
      
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$DiningInfoVOToJson(this);
}

/// 地区模型 - 地理区域的信息聚合
@JsonSerializable()
class RegionModel extends BaseModel {
  /// 名称
  final String name;
  
  /// 描述
  final String description;
  
  /// 国家
  final String country;
  
  /// 省份
  final String province;
  
  /// 城市
  final String? city;
  
  /// 纬度
  final double? latitude;
  
  /// 经度
  final double? longitude;
  
  /// 面积（平方公里）
  final double? area;
  
  /// 海拔范围（最低-最高，米）
  @JsonKey(name: 'elevation_range')
  final String? elevationRange;
  
  /// 子地区列表
  @JsonKey(name: 'sub_regions')
  final List<String>? subRegions;
  
  /// 气候描述
  final String climate;
  
  /// 最佳游览季节
  @JsonKey(name: 'best_seasons')
  final List<String> bestSeasons;
  
  /// 文化背景
  @JsonKey(name: 'cultural_background')
  final String culturalBackground;
  
  /// 主要景点
  @JsonKey(name: 'main_attractions')
  final List<String> mainAttractions;
  
  /// 交通信息
  final TransportationInfoVO transportation;
  
  /// 住宿信息
  final AccommodationInfoVO accommodation;
  
  /// 餐饮信息
  final DiningInfoVO? dining;
  
  /// 图片URL列表
  @JsonKey(name: 'image_urls')
  final List<String> imageUrls;
  
  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;
  
  /// 路线数量
  @JsonKey(name: 'route_count')
  final int routeCount;
  
  /// 人气排名
  @JsonKey(name: 'popularity_rank')
  final int? popularityRank;
  
  /// 官方网站
  @JsonKey(name: 'official_website')
  final String? officialWebsite;
  
  /// 构造函数
  RegionModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.description,
    required this.country,
    required this.province,
    this.city,
    this.latitude,
    this.longitude,
    this.area,
    this.elevationRange,
    this.subRegions,
    required this.climate,
    required this.bestSeasons,
    required this.culturalBackground,
    required this.mainAttractions,
    required this.transportation,
    required this.accommodation,
    this.dining,
    required this.imageUrls,
    this.coverUrl,
    required this.routeCount,
    this.popularityRank,
    this.officialWebsite,
  });
  
  /// 从JSON创建
  factory RegionModel.fromJson(Map<String, dynamic> json) =>
      _$RegionModelFromJson(json);
      
  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$RegionModelToJson(this);
  
  /// 创建副本并更新部分属性
  RegionModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? description,
    String? country,
    String? province,
    String? city,
    double? latitude,
    double? longitude,
    double? area,
    String? elevationRange,
    List<String>? subRegions,
    String? climate,
    List<String>? bestSeasons,
    String? culturalBackground,
    List<String>? mainAttractions,
    TransportationInfoVO? transportation,
    AccommodationInfoVO? accommodation,
    DiningInfoVO? dining,
    List<String>? imageUrls,
    String? coverUrl,
    int? routeCount,
    int? popularityRank,
    String? officialWebsite,
  }) {
    return RegionModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      name: name ?? this.name,
      description: description ?? this.description,
      country: country ?? this.country,
      province: province ?? this.province,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      area: area ?? this.area,
      elevationRange: elevationRange ?? this.elevationRange,
      subRegions: subRegions ?? this.subRegions,
      climate: climate ?? this.climate,
      bestSeasons: bestSeasons ?? this.bestSeasons,
      culturalBackground: culturalBackground ?? this.culturalBackground,
      mainAttractions: mainAttractions ?? this.mainAttractions,
      transportation: transportation ?? this.transportation,
      accommodation: accommodation ?? this.accommodation,
      dining: dining ?? this.dining,
      imageUrls: imageUrls ?? this.imageUrls,
      coverUrl: coverUrl ?? this.coverUrl,
      routeCount: routeCount ?? this.routeCount,
      popularityRank: popularityRank ?? this.popularityRank,
      officialWebsite: officialWebsite ?? this.officialWebsite,
    );
  }
}