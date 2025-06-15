/// API端点配置
///
/// 统一管理所有API路径，便于维护和修改
class ApiEndpoints {
  // 基础配置
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/walkbg/api';

  // ==================== 路线相关 ====================
  /// 路线列表
  static const String routes = '$apiPrefix/routes';

  /// 路线详情
  static String routeDetail(String routeId) => '$apiPrefix/routes/$routeId';

  /// 搜索路线
  static const String searchRoutes = '$apiPrefix/routes/search';

  /// 热门路线
  static const String popularRoutes = '$apiPrefix/routes/popular';

  /// 季节性路线
  static const String seasonalRoutes = '$apiPrefix/routes/seasonal';

  /// 新晋路线
  static const String newRoutes = '$apiPrefix/routes/new';

  /// 周末路线
  static const String weekendRoutes = '$apiPrefix/routes/weekend';

  /// 推荐路线
  static const String recommendedRoutes = '$apiPrefix/routes/recommended';

  /// 按地区获取路线
  static String routesByRegion(String region) =>
      '$apiPrefix/routes/region/$region';

  /// 按难度获取路线
  static String routesByDifficulty(String difficulty) =>
      '$apiPrefix/routes/difficulty/$difficulty';

  /// 按持续时间获取路线
  static const String routesByDuration = '$apiPrefix/routes/duration';

  /// 路线评分
  static String routeRatings(String routeId) =>
      '$apiPrefix/routes/$routeId/ratings';

  /// 路线标签
  static String routeTags(String routeId) => '$apiPrefix/routes/$routeId/tags';

  /// 路线关键点
  static String routeWaypoints(String routeId) =>
      '$apiPrefix/routes/$routeId/waypoints';

  /// 相关路线
  static String relatedRoutes(String routeId) =>
      '$apiPrefix/routes/$routeId/related';

  /// 路线评论
  static String routeComments(String routeId) =>
      '$apiPrefix/routes/$routeId/comments';

  /// 添加路线评论
  static String addRouteComment(String routeId) =>
      '$apiPrefix/routes/$routeId/comments';

  // ==================== 收藏相关 ====================
  /// 收藏路线列表
  static const String favoriteRoutes = '$apiPrefix/favorites/routes';

  /// 收藏/取消收藏路线
  static String favoriteRoute(String routeId) =>
      '$apiPrefix/favorites/routes/$routeId';

  /// 检查路线是否已收藏
  static String checkFavorite(String routeId) =>
      '$apiPrefix/favorites/routes/$routeId/check';

  // ==================== 行程相关 ====================
  /// 行程列表
  static const String trips = '$apiPrefix/trips';

  /// 行程详情
  static String tripDetail(String tripId) => '$apiPrefix/trips/$tripId';

  /// 创建行程
  static const String createTrip = '$apiPrefix/trips';

  /// 更新行程
  static String updateTrip(String tripId) => '$apiPrefix/trips/$tripId';

  /// 删除行程
  static String deleteTrip(String tripId) => '$apiPrefix/trips/$tripId';

  /// 计划行程
  static const String plannedTrips = '$apiPrefix/trips/planned';

  /// 已完成行程
  static const String completedTrips = '$apiPrefix/trips/completed';

  /// 正在进行的行程
  static const String ongoingTrips = '$apiPrefix/trips/ongoing';

  // ==================== 行程计划相关 ====================
  /// 行程计划列表
  static const String tripPlans = '$apiPrefix/trip-plans';

  /// 行程计划详情
  static String tripPlanDetail(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  /// 创建行程计划
  static const String createTripPlan = '$apiPrefix/trip-plans';

  /// 更新行程计划
  static String updateTripPlan(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  /// 删除行程计划
  static String deleteTripPlan(String planId) =>
      '$apiPrefix/trip-plans/$planId';

  // ==================== 用户相关 ====================
  /// 用户信息
  static const String userProfile = '$apiPrefix/user/profile';

  /// 更新用户信息
  static const String updateUserProfile = '$apiPrefix/user/profile';

  /// 用户统计
  static const String userStats = '$apiPrefix/user/stats';

  /// 用户偏好设置
  static const String userPreferences = '$apiPrefix/user/preferences';

  // ==================== 认证相关 ====================
  /// 登录
  static const String login = '$apiPrefix/auth/login';

  /// 注册
  static const String register = '$apiPrefix/auth/register';

  /// 登出
  static const String logout = '$apiPrefix/auth/logout';

  /// 刷新token
  static const String refreshToken = '$apiPrefix/auth/refresh';

  /// 忘记密码
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';

  /// 重置密码
  static const String resetPassword = '$apiPrefix/auth/reset-password';

  // ==================== 天气相关 ====================
  /// 获取天气信息
  static const String weather = '$apiPrefix/weather';

  /// 获取天气预报
  static const String weatherForecast = '$apiPrefix/weather/forecast';

  /// 获取标记点天气
  static String markerPointWeather(String pointId) =>
      '$apiPrefix/weather/marker-point/$pointId';

  // ==================== 装备相关 ====================
  /// 装备列表
  static const String equipment = '$apiPrefix/equipment';

  /// 装备详情
  static String equipmentDetail(String equipmentId) =>
      '$apiPrefix/equipment/$equipmentId';

  /// 装备分类
  static const String equipmentCategories = '$apiPrefix/equipment/categories';

  /// 装备推荐
  static const String recommendedEquipment = '$apiPrefix/equipment/recommended';

  /// 用户装备清单
  static const String userEquipmentList = '$apiPrefix/user/equipment-list';

  // ==================== 攻略相关 ====================
  /// 攻略列表
  static const String guides = '$apiPrefix/guides';

  /// 攻略详情
  static String guideDetail(String guideId) => '$apiPrefix/guides/$guideId';

  /// 攻略分类
  static const String guideCategories = '$apiPrefix/guides/categories';

  /// 热门攻略
  static const String popularGuides = '$apiPrefix/guides/popular';

  // ==================== 推荐相关 ====================
  /// 个性化推荐
  static const String personalizedRecommendations =
      '$apiPrefix/recommendations/personalized';

  /// 基于位置的推荐
  static const String locationBasedRecommendations =
      '$apiPrefix/recommendations/location';

  /// 基于历史的推荐
  static const String historyBasedRecommendations =
      '$apiPrefix/recommendations/history';

  // ==================== 搜索相关 ====================
  /// 全局搜索
  static const String globalSearch = '$apiPrefix/search';

  /// 搜索历史
  static const String searchHistory = '$apiPrefix/search/history';

  /// 热门搜索
  static const String popularSearches = '$apiPrefix/search/popular';

  // ==================== 文件上传相关 ====================
  /// 上传图片
  static const String uploadImage = '$apiPrefix/upload/image';

  /// 上传GPX文件
  static const String uploadGpx = '$apiPrefix/upload/gpx';

  /// 上传头像
  static const String uploadAvatar = '$apiPrefix/upload/avatar';

  // ==================== 系统相关 ====================
  /// 应用版本检查
  static const String versionCheck = '$apiPrefix/system/version';

  /// 系统配置
  static const String systemConfig = '$apiPrefix/system/config';

  /// 反馈
  static const String feedback = '$apiPrefix/system/feedback';

  // ==================== 工具方法 ====================

  /// 构建带查询参数的URL
  static String buildUrl(String endpoint, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return endpoint;
    }

    final uri = Uri.parse(endpoint);
    final newUri = uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...queryParams.map((key, value) => MapEntry(key, value.toString())),
    });

    return newUri.toString();
  }

  /// 构建分页URL
  static String buildPaginatedUrl(
    String endpoint, {
    int page = 1,
    int limit = 20,
    Map<String, dynamic>? additionalParams,
  }) {
    final params = {
      'page': page,
      'limit': limit,
      ...?additionalParams,
    };

    return buildUrl(endpoint, params);
  }
}
