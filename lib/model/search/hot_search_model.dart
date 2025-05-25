import 'package:json_annotation/json_annotation.dart';

part 'hot_search_model.g.dart';

/// 热门搜索模型
@JsonSerializable()
class HotSearchModel {
  /// 搜索关键词
  final String keyword;

  /// 搜索次数
  final int count;

  /// 构造函数
  HotSearchModel({
    required this.keyword,
    required this.count,
  });

  /// 从JSON创建
  factory HotSearchModel.fromJson(Map<String, dynamic> json) =>
      _$HotSearchModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$HotSearchModelToJson(this);
}

/// 热门搜索列表模型
@JsonSerializable()
class HotSearchListModel {
  /// 热门搜索列表
  final List<HotSearchModel> items;

  /// 更新时间
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  /// 构造函数
  HotSearchListModel({
    required this.items,
    this.updatedAt,
  });

  /// 从JSON创建
  factory HotSearchListModel.fromJson(Map<String, dynamic> json) =>
      _$HotSearchListModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$HotSearchListModelToJson(this);

  /// 获取关键词列表
  List<String> get keywords => items.map((item) => item.keyword).toList();
}
