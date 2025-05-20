/// 热门搜索模型
class HotSearchModel {
  /// 搜索关键词
  final String keyword;

  /// 搜索次数
  final int count;

  /// 是否热门
  final bool isHot;

  /// 标签颜色（可选）
  final String? tagColor;

  /// 构造函数
  const HotSearchModel({
    required this.keyword,
    required this.count,
    this.isHot = false,
    this.tagColor,
  });

  /// 从JSON创建
  factory HotSearchModel.fromJson(Map<String, dynamic> json) {
    return HotSearchModel(
      keyword: json['keyword'] as String,
      count: json['count'] as int,
      isHot: json['is_hot'] as bool? ?? false,
      tagColor: json['tag_color'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'count': count,
      'is_hot': isHot,
      'tag_color': tagColor,
    };
  }
}

/// 热门搜索列表模型
class HotSearchListModel {
  /// 热门搜索列表
  final List<HotSearchModel> items;

  /// 更新时间
  final DateTime updatedAt;

  /// 构造函数
  const HotSearchListModel({
    required this.items,
    required this.updatedAt,
  });

  /// 从JSON创建
  factory HotSearchListModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((item) => HotSearchModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return HotSearchListModel(
      items: items,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 获取关键词列表
  List<String> get keywords => items.map((item) => item.keyword).toList();
}