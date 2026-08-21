import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../model/route/route_model.dart';
import '../model/search/hot_search_model.dart';

/// 推荐服务（本地数据，后端暂未实现）
///
/// 使用静态方法，无需实例化
/// 当前使用本地 JSON 数据，后续可改为 API 请求
class RecommendationService {
  // 禁止实例化
  RecommendationService._();

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

  /// 获取热门搜索
  ///
  /// [limit] 限制返回的结果数量
  static Future<HotSearchListModel> getHotSearches({int limit = 10}) async {
    final hotSearchesJson =
        await _loadJsonData('assets/mock_data/hot_searches.json');
    if (hotSearchesJson == null) {
      return HotSearchListModel(items: []);
    }

    final List<dynamic> itemsJson = hotSearchesJson['items'] as List<dynamic>;
    List<HotSearchModel> items = itemsJson
        .map<HotSearchModel>((json) => HotSearchModel.fromJson(json))
        .toList();

    // 限制数量
    if (items.length > limit) {
      items = items.sublist(0, limit);
    }

    return HotSearchListModel(items: items);
  }

  /// 获取季节性推荐路线
  ///
  /// [season] 季节，如"春"、"夏"、"秋"、"冬"
  /// [limit] 限制返回的结果数量
  static Future<List<RouteModel>> getSeasonalRecommendations(
      {String? season, int limit = 10}) async {
    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    return routes;
  }

  /// 获取个性化推荐路线
  ///
  /// 基于用户历史行为和偏好推荐路线
  /// [limit] 限制返回的结果数量
  static Future<List<RouteModel>> getPersonalizedRecommendations(
      {int limit = 10}) async {
    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();

    return routes;
  }

  /// 获取相似路线推荐
  ///
  /// [routeId] 参考路线ID
  /// [limit] 限制返回的结果数量
  static Future<List<RouteModel>> getSimilarRoutes(String routeId,
      {int limit = 5}) async {
    final routesJson = await _loadJsonData('assets/mock_data/routes.json');
    if (routesJson == null || !(routesJson is List)) {
      return [];
    }

    List<RouteModel> routes = routesJson
        .where((json) => json['id'] != routeId) // 排除参考路线自身
        .map<RouteModel>((json) => RouteModel.fromJson(json))
        .toList();
    return routes;
  }
}
