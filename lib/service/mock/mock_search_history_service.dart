import 'dart:convert';
import 'package:flutter/services.dart';
import '../search_history_service.dart';
import '../../model/search/search_history_model.dart';

/// Mock搜索历史服务实现
class MockSearchHistoryService implements SearchHistoryService {
  /// 单例实例
  static final MockSearchHistoryService _instance =
      MockSearchHistoryService._internal();

  /// 工厂构造函数
  factory MockSearchHistoryService() {
    return _instance;
  }

  /// 私有构造函数
  MockSearchHistoryService._internal();

  /// 搜索历史缓存
  SearchHistoryListModel? _searchHistoryCache;

  /// 从JSON文件加载数据
  Future<dynamic> _loadJsonData(String path) async {
    try {
      final String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } catch (e) {
      print('加载JSON文件失败: $e');
      return null;
    }
  }

  @override
  Future<SearchHistoryListModel> getSearchHistory() async {
    // 如果有缓存，直接返回
    if (_searchHistoryCache != null) {
      return _searchHistoryCache!;
    }

    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

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

  @override
  Future<bool> saveSearchHistory(SearchHistoryListModel history) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 更新缓存
    _searchHistoryCache = history;

    return true;
  }

  @override
  Future<bool> addSearch(String keyword) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

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

  @override
  Future<bool> clearSearchHistory() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 400));

    // 清空缓存
    _searchHistoryCache = SearchHistoryListModel(items: []);

    return true;
  }

  @override
  Future<List<String>> getSearchKeywords() async {
    // 获取搜索历史
    final history = await getSearchHistory();

    // 提取关键词
    return history.keywords;
  }
}
