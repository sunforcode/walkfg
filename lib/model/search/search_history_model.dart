import 'package:json_annotation/json_annotation.dart';

part 'search_history_model.g.dart';

/// 搜索历史类型
enum SearchHistoryType {
  /// 路线
  route,

  /// 攻略
  guide,

  /// 装备
  equipment,

  /// 其他
  other,
}

/// 搜索历史模型
@JsonSerializable()
class SearchHistoryModel {
  /// ID
  final String id;

  /// 关键词
  final String keyword;

  /// 搜索时间
  final DateTime timestamp;

  /// 搜索类型
  final SearchHistoryType type;

  /// 构造函数
  SearchHistoryModel({
    required this.id,
    required this.keyword,
    required this.timestamp,
    this.type = SearchHistoryType.route,
  });

  /// 从JSON创建
  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SearchHistoryModelToJson(this);

  /// 创建副本并更新部分属性
  SearchHistoryModel copyWith({
    String? id,
    String? keyword,
    DateTime? timestamp,
    SearchHistoryType? type,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      keyword: keyword ?? this.keyword,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
    );
  }
}

/// 搜索历史列表模型
@JsonSerializable()
class SearchHistoryListModel {
  /// 搜索历史列表
  final List<SearchHistoryModel> items;

  /// 构造函数
  SearchHistoryListModel({
    required this.items,
  });

  /// 从JSON创建
  factory SearchHistoryListModel.fromJson(Map<String, dynamic> json) =>
      _$SearchHistoryListModelFromJson(json);

  /// 转换为JSON
  Map<String, dynamic> toJson() => _$SearchHistoryListModelToJson(this);

  /// 获取关键词列表
  List<String> get keywords => items.map((item) => item.keyword).toList();
}
