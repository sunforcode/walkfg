import 'dart:convert';

/// 搜索历史模型
class SearchHistoryModel {
  /// 搜索关键词
  final String keyword;

  /// 搜索时间
  final DateTime timestamp;

  /// 构造函数
  const SearchHistoryModel({
    required this.keyword,
    required this.timestamp,
  });

  /// 从JSON创建
  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryModel(
      keyword: json['keyword'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchHistoryModel && other.keyword == keyword;
  }

  @override
  int get hashCode => keyword.hashCode;
}

/// 搜索历史列表模型
class SearchHistoryListModel {
  /// 搜索历史列表
  final List<SearchHistoryModel> items;

  /// 最大历史记录数
  final int maxItems;

  /// 构造函数
  const SearchHistoryListModel({
    required this.items,
    this.maxItems = 10,
  });

  /// 从JSON创建
  factory SearchHistoryListModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryListModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => SearchHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      maxItems: json['maxItems'] as int? ?? 10,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((e) => e.toJson()).toList(),
      'maxItems': maxItems,
    };
  }

  /// 从JSON字符串创建
  factory SearchHistoryListModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return SearchHistoryListModel.fromJson(jsonMap);
  }

  /// 转换为JSON字符串
  String toJsonString() {
    return json.encode(toJson());
  }

  /// 添加搜索历史
  SearchHistoryListModel addSearch(String keyword) {
    // 创建新的搜索历史项
    final newItem = SearchHistoryModel(
      keyword: keyword,
      timestamp: DateTime.now(),
    );

    // 创建新的列表，移除已存在的相同关键词
    final newItems = items.where((item) => item.keyword != keyword).toList();

    // 添加到列表开头
    newItems.insert(0, newItem);

    // 如果超过最大数量，移除最旧的
    if (newItems.length > maxItems) {
      newItems.removeLast();
    }

    return SearchHistoryListModel(
      items: newItems,
      maxItems: maxItems,
    );
  }

  /// 清空搜索历史
  SearchHistoryListModel clear() {
    return SearchHistoryListModel(
      items: [],
      maxItems: maxItems,
    );
  }

  /// 获取关键词列表
  List<String> get keywords => items.map((item) => item.keyword).toList();
}
