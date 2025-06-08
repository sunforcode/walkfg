import 'package:json_annotation/json_annotation.dart';

part 'accommodation_tip.g.dart';

/// 住宿建议模型
@JsonSerializable()
class AccommodationTip {
  /// 住宿类型
  final AccommodationType type;
  
  /// 标题
  final String title;
  
  /// 描述
  final String description;
  
  /// 建议提示
  final String tips;
  
  /// 相关平台
  final List<AccommodationPlatform> platforms;
  
  /// 价格区间
  final String priceRange;
  
  /// 优势
  final List<String> advantages;
  
  /// 注意事项
  final List<String> considerations;
  
  /// 适合人群
  final List<String> suitableFor;
  
  /// 安全提示（可选）
  final List<String>? safetyTips;
  
  /// 构造函数
  AccommodationTip({
    required this.type,
    required this.title,
    required this.description,
    required this.tips,
    required this.platforms,
    required this.priceRange,
    required this.advantages,
    required this.considerations,
    required this.suitableFor,
    this.safetyTips,
  });
  
  /// 从JSON创建
  factory AccommodationTip.fromJson(Map<String, dynamic> json) =>
      _$AccommodationTipFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AccommodationTipToJson(this);
  
  /// 获取类型的中文名称
  String get typeDisplayName {
    switch (type) {
      case AccommodationType.hotel:
        return '酒店民宿';
      case AccommodationType.camping:
        return '露营地';
      case AccommodationType.mountainHut:
        return '山屋客栈';
      case AccommodationType.guesthouse:
        return '青年旅社';
      case AccommodationType.tent:
        return '自搭帐篷';
      case AccommodationType.dayHike:
        return '一日徒步';
      case AccommodationType.resupply:
        return '补给点住宿';
    }
  }
  
  /// 获取类型图标
  String get typeIcon {
    switch (type) {
      case AccommodationType.hotel:
        return '🏨';
      case AccommodationType.camping:
        return '🏕️';
      case AccommodationType.mountainHut:
        return '🏠';
      case AccommodationType.guesthouse:
        return '🏠';
      case AccommodationType.tent:
        return '⛺';
      case AccommodationType.dayHike:
        return '🥾';
      case AccommodationType.resupply:
        return '🏪';
    }
  }
  
  /// 是否有安全提示
  bool get hasSafetyTips => safetyTips != null && safetyTips!.isNotEmpty;
}

/// 住宿平台模型
@JsonSerializable()
class AccommodationPlatform {
  /// 平台名称
  final String name;
  
  /// 平台描述
  final String description;
  
  /// 深链接（可选）
  final String? deepLink;
  
  /// 网页链接（可选）
  final String? webUrl;
  
  /// 构造函数
  AccommodationPlatform({
    required this.name,
    required this.description,
    this.deepLink,
    this.webUrl,
  });
  
  /// 从JSON创建
  factory AccommodationPlatform.fromJson(Map<String, dynamic> json) =>
      _$AccommodationPlatformFromJson(json);
  
  /// 转换为JSON
  Map<String, dynamic> toJson() => _$AccommodationPlatformToJson(this);
  
  /// 是否有可用链接
  bool get hasLink => deepLink != null || webUrl != null;
}

/// 住宿类型枚举
enum AccommodationType {
  hotel,        // 酒店民宿
  camping,      // 露营地
  mountainHut,  // 山屋客栈
  guesthouse,   // 青年旅社
  tent,         // 自搭帐篷
  dayHike,      // 一日徒步（无需住宿）
  resupply,     // 补给点住宿
}