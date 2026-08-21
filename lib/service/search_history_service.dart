import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/search/search_history_model.dart';

/// 搜索历史服务
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class SearchHistoryService {
  // 禁止实例化
  SearchHistoryService._();

  /// 搜索历史缓存
  static SearchHistoryListModel? _searchHistoryCache;

  /// 从JSON文件加载数据
  static Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      debugPrint('加载JSON文件失败: $e');
      return null;
    }
  }

  /// 获取搜索历史
  static Future<SearchHistoryListModel> getSearchHistory() async {
    // 如果有缓存，直接返回
    if (_searchHistoryCache != null) {
      return _searchHistoryCache!;
    }

    final historyJson =
        await _loadJsonData('assets/mock_data/search_history.json');
    if (historyJson == null || !(historyJson is List)) {
      _searchHistoryCache = SearchHistoryListModel(items: []);
      return _searchHistoryCache!;
    }

    final items = historyJson
        .map<SearchHistoryModel>((json) => SearchHistoryModel.fromJson(json))
        .toList();
    _searchHistoryCache = SearchHistoryListModel(items: items);

    return _searchHistoryCache!;
  }

  /// 保存搜索历史
  static Future<bool> saveSearchHistory(SearchHistoryListModel history) async {
    // 更新缓存
    _searchHistoryCache = history;

    return true;
  }

  /// 添加搜索记录
  static Future<bool> addSearch(String keyword) async {
    // 确保缓存已初始化
    if (_searchHistoryCache == null) {
      await getSearchHistory();
    }

    // 检查是否已存在相同关键词
    final existingIndex = _searchHistoryCache!.items
        .indexWhere((item) => item.keyword == keyword);
    if (existingIndex >= 0) {
      // 更新时间戳
      final updatedItem = _searchHistoryCache!.items[existingIndex].copyWith(
        timestamp: DateTime.now(),
      );

      // 创建新的列表，替换旧项
      final newItems =
          List<SearchHistoryModel>.from(_searchHistoryCache!.items);
      newItems[existingIndex] = updatedItem;

      // 按时间排序
      newItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 更新缓存
      _searchHistoryCache = SearchHistoryListModel(items: newItems);
    } else {
      // 添加新记录
      final newItem = SearchHistoryModel(
        id: 'history_${DateTime.now().millisecondsSinceEpoch}',
        keyword: keyword,
        timestamp: DateTime.now(),
        type: SearchHistoryType.route, // 默认为路线类型
      );

      // 创建新的列表，添加新项
      final newItems =
          List<SearchHistoryModel>.from(_searchHistoryCache!.items);
      newItems.add(newItem);

      // 按时间排序
      newItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // 限制数量
      if (newItems.length > 20) {
        newItems.removeRange(20, newItems.length);
      }

      // 更新缓存
      _searchHistoryCache = SearchHistoryListModel(items: newItems);
    }

    return true;
  }

  /// 清空搜索历史
  static Future<bool> clearSearchHistory() async {
    // 清空缓存
    _searchHistoryCache = SearchHistoryListModel(items: []);

    return true;
  }

  /// 获取搜索关键词列表
  static Future<List<String>> getSearchKeywords() async {
    // 获取搜索历史
    final history = await getSearchHistory();

    // 提取关键词
    return history.keywords;
  }
}
