import 'package:shared_preferences/shared_preferences.dart';
import '../../model/trip/search_history_model.dart';
import '../search_history_service.dart';

/// 搜索历史服务实现
class MockSearchHistoryService implements SearchHistoryService {
  /// SharedPreferences键
  static const String _prefsKey = 'search_history';

  /// 最大历史记录数
  final int maxHistoryItems;

  /// 构造函数
  MockSearchHistoryService({
    this.maxHistoryItems = 10,
  });

  @override
  Future<SearchHistoryListModel> getSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return SearchHistoryListModel(items: [], maxItems: maxHistoryItems);
      }

      return SearchHistoryListModel.fromJsonString(jsonString);
    } catch (e) {
      // 如果解析失败，返回空列表
      return SearchHistoryListModel(items: [], maxItems: maxHistoryItems);
    }
  }

  @override
  Future<bool> saveSearchHistory(SearchHistoryListModel history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = history.toJsonString();
      return await prefs.setString(_prefsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> addSearch(String keyword) async {
    if (keyword.trim().isEmpty) {
      return false;
    }

    try {
      final history = await getSearchHistory();
      final updatedHistory = history.addSearch(keyword.trim());
      return await saveSearchHistory(updatedHistory);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearSearchHistory() async {
    try {
      final history = await getSearchHistory();
      final clearedHistory = history.clear();
      return await saveSearchHistory(clearedHistory);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> getSearchKeywords() async {
    final history = await getSearchHistory();
    return history.keywords;
  }
}
