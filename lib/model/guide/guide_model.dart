import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';
import '../route/route_model.dart';
import '../route/route_enums.dart';
import '../trip/trip_model.dart';
import '../equipment/equipment_list_model.dart';
import '../user/user_model.dart';

part 'guide_model.g.dart';

/// 徒步攻略数据模型
@JsonSerializable()
class GuideModel extends BaseModel {
  /// 攻略标题
  final String title;

  /// 攻略内容
  final String content;

  /// 作者
  final String author;

  /// 作者ID
  @JsonKey(name: 'author_id')
  final String authorId;

  /// 作者头像URL
  @JsonKey(name: 'author_avatar_url')
  final String? authorAvatarUrl;

  /// 点赞数
  final int likes;

  /// 阅读数
  final int views;

  /// 发布时间
  @JsonKey(name: 'publish_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  final DateTime publishDate;

  /// 更新时间
  @JsonKey(name: 'update_date', fromJson: BaseModel.parseTimestamp, toJson: BaseModel.timestampToJson)
  final DateTime updateDate;

  /// 封面图标（图标代码）
  @JsonKey(name: 'icon_code')
  final String iconCode;

  /// 封面图片URL
  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  /// 标签列表
  final List<String> tags;

  /// 是否已点赞
  @JsonKey(name: 'is_liked')
  final bool isLiked;

  // === 新增基础字段 ===

  /// 难度等级（主观感受）
  @JsonKey(fromJson: _parseDifficulty, toJson: _difficultyToJson)
  final RouteDifficulty difficulty;

  /// 阅读时长（分钟）
  @JsonKey(name: 'reading_time')
  final int readingTime;

  /// 收藏状态
  @JsonKey(name: 'is_bookmarked')
  final bool isBookmarked;

  /// 评论数量
  @JsonKey(name: 'comment_count')
  final int commentCount;

  /// 地理位置
  final String location;

  /// 最佳时间建议
  @JsonKey(name: 'best_time')
  final String? bestTime;

  /// 实际花费（元）
  @JsonKey(name: 'actual_cost')
  final double? actualCost;

  /// 实际用时（天数）
  @JsonKey(name: 'actual_days')
  final int? actualDays;

  // === 攻略特有内容字段 ===

  /// 行程亮点
  final List<String> highlights;

  /// 作者个人建议
  @JsonKey(name: 'personal_tips')
  final List<String> personalTips;

  /// 季节建议
  @JsonKey(name: 'seasonal_advice')
  final List<String> seasonalAdvice;

  /// 安全警告
  @JsonKey(name: 'safety_warnings')
  final List<String> safetyWarnings;

  /// 装备调整建议
  @JsonKey(name: 'equipment_adjustments')
  final List<String> equipmentAdjustments;

  /// 路线调整说明
  @JsonKey(name: 'route_modifications')
  final List<String> routeModifications;

  // === 关联模型ID字段 ===

  /// 基础路线ID
  @JsonKey(name: 'base_route_id')
  final String? baseRouteId;

  /// 基础行程ID
  @JsonKey(name: 'base_trip_id')
  final String? baseTripId;

  /// 推荐装备清单ID
  @JsonKey(name: 'equipment_list_id')
  final String? equipmentListId;

  /// 相关攻略ID列表
  @JsonKey(name: 'related_guide_ids')
  final List<String> relatedGuideIds;

  // === 运行时关联数据（不序列化）===

  /// 基础路线数据
  @JsonKey(includeFromJson: false, includeToJson: false)
  final RouteModel? baseRoute;

  /// 基础行程数据
  @JsonKey(includeFromJson: false, includeToJson: false)
  final TripModel? baseTrip;

  /// 推荐装备清单
  @JsonKey(includeFromJson: false, includeToJson: false)
  final EquipmentListModel? equipmentList;

  /// 作者详细信息
  @JsonKey(includeFromJson: false, includeToJson: false)
  final UserModel? authorProfile;

  /// 相关攻略列表
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<GuideModel>? relatedGuides;

  /// 默认作者头像
  static const String defaultAuthorAvatar =
      'assets/images/placeholders/default_avatar.png';

  /// 默认封面图片
  static const String defaultCoverImage =
      'assets/images/placeholders/default_cover.png';

  /// 构造函数
  GuideModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.title,
    required this.content,
    required this.author,
    required this.authorId,
    this.authorAvatarUrl,
    required this.likes,
    required this.views,
    required this.publishDate,
    required this.updateDate,
    required this.iconCode,
    this.coverUrl,
    required this.tags,
    this.isLiked = false,
    // 新增字段
    this.difficulty = RouteDifficulty.medium,
    this.readingTime = 5,
    this.isBookmarked = false,
    this.commentCount = 0,
    required this.location,
    this.bestTime,
    this.actualCost,
    this.actualDays,
    this.highlights = const [],
    this.personalTips = const [],
    this.seasonalAdvice = const [],
    this.safetyWarnings = const [],
    this.equipmentAdjustments = const [],
    this.routeModifications = const [],
    // 关联ID字段
    this.baseRouteId,
    this.baseTripId,
    this.equipmentListId,
    this.relatedGuideIds = const [],
    // 运行时数据
    this.baseRoute,
    this.baseTrip,
    this.equipmentList,
    this.authorProfile,
    this.relatedGuides,
  });

  /// 从JSON创建
  factory GuideModel.fromJson(Map<String, dynamic> json) =>
      _$GuideModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$GuideModelToJson(this);

  // === 便捷方法 ===

  /// 获取格式化的发布日期
  String getFormattedPublishDate() {
    return '${publishDate.year}-${publishDate.month.toString().padLeft(2, '0')}-${publishDate.day.toString().padLeft(2, '0')}';
  }

  /// 获取难度名称
  String getDifficultyName() => difficulty.getName();

  /// 获取阅读时长文本
  String getReadingTimeText() => '阅读时间 ${readingTime}分钟';

  /// 获取距离信息（优先使用客观数据）
  String getDistanceText() {
    final distance = baseRoute?.distance;
    if (distance != null) {
      return '总长约${distance.toStringAsFixed(1)}公里';
    }
    return '距离信息待补充';
  }

  /// 获取天数信息
  String getDaysText() {
    // 优先使用实际天数，其次是计划天数
    final days = actualDays ??
        baseRoute?.dailyPlans?.length ??
        baseTrip?.itinerary.length;
    if (days != null) {
      final planned =
          baseRoute?.dailyPlans?.length ?? baseTrip?.itinerary.length;
      if (actualDays != null && planned != null && actualDays != planned) {
        return '实际${actualDays}天完成（计划${planned}天）';
      }
      return '建议${days}天完成';
    }
    return '行程天数待规划';
  }

  /// 获取完整的行程描述
  String getTripDescription() {
    return '${getDistanceText()}，${getDaysText()}';
  }

  /// 获取难度对比信息
  String getDifficultyComparisonText() {
    final officialDifficulty = baseRoute?.difficulty;
    if (officialDifficulty != null && officialDifficulty != difficulty) {
      return '个人感受：${difficulty.getName()}（官方：${officialDifficulty.getName()}）';
    }
    return '难度：${difficulty.getName()}';
  }

  /// 获取作者经验文本
  String getAuthorExperienceText() {
    if (authorProfile != null) {
      return '资深徒步爱好者 · 已发布${authorProfile!.completedRoutes}篇攻略';
    }
    return '徒步爱好者';
  }

  /// 获取主要路线信息（如果有关联路线）
  RouteModel? get primaryRoute => baseRoute;

  /// 获取主要行程信息（如果有关联行程）
  TripModel? get primaryTrip => baseTrip;

  /// 是否有关联的客观数据
  bool get hasObjectiveData => baseRoute != null || baseTrip != null;

  /// 获取预估费用文本
  String? getCostText() {
    if (actualCost != null) {
      return '实际花费：¥${actualCost!.toStringAsFixed(0)}';
    }
    final tripBudget = baseTrip?.budget;
    if (tripBudget != null) {
      return '预估费用：¥${tripBudget.toStringAsFixed(0)}';
    }
    return null;
  }

  // === JSON转换辅助方法 ===

  /// 解析难度
  static RouteDifficulty _parseDifficulty(dynamic difficulty) {
    if (difficulty is int &&
        difficulty >= 0 &&
        difficulty < RouteDifficulty.values.length) {
      return RouteDifficulty.values[difficulty];
    } else if (difficulty is String) {
      switch (difficulty.toLowerCase()) {
        case 'easy':
        case '简单':
        case '初级':
          return RouteDifficulty.easy;
        case 'medium':
        case '中等':
        case '中级':
          return RouteDifficulty.medium;
        case 'hard':
        case '困难':
        case '高级':
          return RouteDifficulty.hard;
        case 'extreme':
        case '极限':
        case '专业级':
          return RouteDifficulty.extreme;
        default:
          return RouteDifficulty.medium;
      }
    }
    return RouteDifficulty.medium;
  }

  /// 难度转JSON
  static int _difficultyToJson(RouteDifficulty difficulty) {
    return difficulty.index;
  }

  /// 创建带有点赞状态的副本
  GuideModel copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? title,
    String? content,
    String? author,
    String? authorId,
    String? authorAvatarUrl,
    int? likes,
    int? views,
    DateTime? publishDate,
    DateTime? updateDate,
    String? iconCode,
    String? coverUrl,
    List<String>? tags,
    bool? isLiked,
    // 新增字段
    RouteDifficulty? difficulty,
    int? readingTime,
    bool? isBookmarked,
    int? commentCount,
    String? location,
    String? bestTime,
    double? actualCost,
    int? actualDays,
    List<String>? highlights,
    List<String>? personalTips,
    List<String>? seasonalAdvice,
    List<String>? safetyWarnings,
    List<String>? equipmentAdjustments,
    List<String>? routeModifications,
    // 关联ID字段
    String? baseRouteId,
    String? baseTripId,
    String? equipmentListId,
    List<String>? relatedGuideIds,
    // 运行时数据
    RouteModel? baseRoute,
    TripModel? baseTrip,
    EquipmentListModel? equipmentList,
    UserModel? authorProfile,
    List<GuideModel>? relatedGuides,
  }) {
    return GuideModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      likes: isLiked == null
          ? (likes ?? this.likes)
          : (isLiked
              ? (likes ?? this.likes) + (this.isLiked ? 0 : 1)
              : (likes ?? this.likes) - (this.isLiked ? 1 : 0)),
      views: views ?? this.views,
      publishDate: publishDate ?? this.publishDate,
      updateDate: updateDate ?? this.updateDate,
      iconCode: iconCode ?? this.iconCode,
      coverUrl: coverUrl ?? this.coverUrl,
      tags: tags ?? this.tags,
      isLiked: isLiked ?? this.isLiked,
      // 新增字段
      difficulty: difficulty ?? this.difficulty,
      readingTime: readingTime ?? this.readingTime,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      commentCount: commentCount ?? this.commentCount,
      location: location ?? this.location,
      bestTime: bestTime ?? this.bestTime,
      actualCost: actualCost ?? this.actualCost,
      actualDays: actualDays ?? this.actualDays,
      highlights: highlights ?? this.highlights,
      personalTips: personalTips ?? this.personalTips,
      seasonalAdvice: seasonalAdvice ?? this.seasonalAdvice,
      safetyWarnings: safetyWarnings ?? this.safetyWarnings,
      equipmentAdjustments: equipmentAdjustments ?? this.equipmentAdjustments,
      routeModifications: routeModifications ?? this.routeModifications,
      // 关联ID字段
      baseRouteId: baseRouteId ?? this.baseRouteId,
      baseTripId: baseTripId ?? this.baseTripId,
      equipmentListId: equipmentListId ?? this.equipmentListId,
      relatedGuideIds: relatedGuideIds ?? this.relatedGuideIds,
      // 运行时数据
      baseRoute: baseRoute ?? this.baseRoute,
      baseTrip: baseTrip ?? this.baseTrip,
      equipmentList: equipmentList ?? this.equipmentList,
      authorProfile: authorProfile ?? this.authorProfile,
      relatedGuides: relatedGuides ?? this.relatedGuides,
    );
  }
}
