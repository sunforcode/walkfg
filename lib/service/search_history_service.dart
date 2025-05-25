import '../model/search/search_history_model.dart';

/// 搜索历史服务抽象类
abstract class SearchHistoryService {
  /// 获取搜索历史
  Future<SearchHistoryListModel> getSearchHistory();

  /// 保存搜索历史
  Future<bool> saveSearchHistory(SearchHistoryListModel history);

  /// 添加搜索记录
  Future<bool> addSearch(String keyword);

  /// 清空搜索历史
  Future<bool> clearSearchHistory();

  /// 获取搜索关键词列表
  Future<List<String>> getSearchKeywords();
  /// get hot search
}
