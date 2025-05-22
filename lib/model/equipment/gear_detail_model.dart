import 'package:json_annotation/json_annotation.dart';
import '../base/base_model.dart';

part 'gear_detail_model.g.dart';

/// 装备详情模型
@JsonSerializable()
class GearDetailModel extends BaseModel {
  /// 名称
  final String name;
  
  /// 类别
  final String category;
  
  /// 描述
  final String description;
  
  /// 特性
  final List<String> features;
  
  /// 重量(g)
  final int weight;
  
  /// 推荐品牌
  final List<String> recommendedBrands;
  
  /// 价格范围
  final PriceRangeModel priceRange;
  
  /// 维护提示
  final List<String> maintenanceTips;
  
  /// 用户评价
  final List<UserReviewModel> userReviews;

  /// 构造函数
  GearDetailModel({
    required super.id,
    super.createdAt,
    super.updatedAt,
    required this.name,
    required this.category,
    required this.description,
    required this.features,
    required this.weight,
    required this.recommendedBrands,
    required this.priceRange,
    required this.maintenanceTips,
    required this.userReviews,
  });

  /// 从JSON创建
  factory GearDetailModel.fromJson(Map<String, dynamic> json) => _$GearDetailModelFromJson(json);

  /// 转换为JSON
  @override
  Map<String, dynamic> toJson() => _$GearDetailModelToJson(this);
  
  /// 获取平均评分
  double get averageRating {
    if (userReviews.isEmpty) return 0.0;
    final total = userReviews.fold(0.0, (sum, review) => sum + review.rating);
    return total / userReviews.length;
  }
  
  /// 获取重量文本
  String getWeightText() {
    if (weight >= 1000) {
      return '${(weight / 1000).toStringAsFixed(2)}kg';
    } else {
      return '${weight}g';
    }
  }
}

/// 价格范围模型
@JsonSerializable()
class PriceRangeModel {
  /// 最低价格(元)
  final int min;
  
  /// 最高价格(元)
  final int max;

  /// 构造函数
  PriceRangeModel({
    required this.min,
    required this.max,
  });

  /// 从JSON创建
  factory PriceRangeModel.fromJson(Map<String, dynamic> json) => _$PriceRangeModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$PriceRangeModelToJson(this);
  
  /// 获取价格范围文本
  String getPriceRangeText() {
    return '¥$min-¥$max';
  }
}

/// 用户评价模型
@JsonSerializable()
class UserReviewModel {
  /// 用户名
  final String user;
  
  /// 评分
  final double rating;
  
  /// 评论
  final String comment;

  /// 构造函数
  UserReviewModel({
    required this.user,
    required this.rating,
    required this.comment,
  });

  /// 从JSON创建
  factory UserReviewModel.fromJson(Map<String, dynamic> json) => _$UserReviewModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$UserReviewModelToJson(this);
}